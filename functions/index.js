/**
 * TORKIS Cloud Functions
 * ----------------------------------------------------------------------------
 * Serverové volání Vincario API (VIN decode + tržní hodnota) s tvrdým
 * vynucením měsíčních limitů dle plánu. Tajný sdílený klíč žije POUZE zde
 * (Functions secrets), nikdy ne v klientské aplikaci.
 *
 * Tok každého volání:
 *   1. Ověření přihlášeného uživatele → servis_id (z kolekce 'uzivatele').
 *   2. Zjištění plánu (predplatne/{servis_id}.plan_typ) → limit.
 *   3. Cache (vin_cache / value_cache) — zásah se nepočítá a nevolá API.
 *   4. Při cache-miss: atomická REZERVACE slotu v počítadle 'pouziti'.
 *      Pokud je limit vyčerpán → resource-exhausted.
 *   5. Volání Vincaria sdíleným klíčem; výsledek se uloží do cache.
 *      Při chybě API se rezervovaný slot vrátí zpět.
 */

const crypto = require("crypto");
const {onCall, onRequest, HttpsError} = require("firebase-functions/v2/https");
const {defineSecret} = require("firebase-functions/params");
const {initializeApp} = require("firebase-admin/app");
const {getAuth} = require("firebase-admin/auth");
const {getFirestore, FieldValue, Timestamp} =
    require("firebase-admin/firestore");

initializeApp();
const db = getFirestore();

// Tajný sdílený Vincario klíč — nastav přes:
//   firebase functions:secrets:set VINCARIO_API_KEY
//   firebase functions:secrets:set VINCARIO_SECRET
const VINCARIO_API_KEY = defineSecret("VINCARIO_API_KEY");
const VINCARIO_SECRET = defineSecret("VINCARIO_SECRET");

// Sdílený token pro ověření RevenueCat webhooku (hodnota hlavičky Authorization
// nastavená v RevenueCat → Integrations → Webhooks). Nastav přes:
//   firebase functions:secrets:set REVENUECAT_WEBHOOK_AUTH
const REVENUECAT_WEBHOOK_AUTH = defineSecret("REVENUECAT_WEBHOOK_AUTH");

// API klíč pro dataovozidlech.cz (STK / technická data vozidel). Nastav přes:
//   firebase functions:secrets:set DATAOVOZIDLECH_API_KEY
const DATAOVOZIDLECH_API_KEY = defineSecret("DATAOVOZIDLECH_API_KEY");

// Priorita plánů (nejvyšší vyhrává, když má zákazník víc entitlementů).
const PLAN_PRIORITY = ["pro", "standard", "basic"];

const REGION = "europe-west3";

// Měsíční limity dle plánu (null = neomezeno).
// MUSÍ zůstat v souladu s lib/core/constants.dart (kPlanVinLimit / kPlanValueLimit).
const VIN_LIMITS = {basic: 30, standard: 60, pro: 120, trial: 10, custom: null};
const VALUE_LIMITS = {basic: 0, standard: 0, pro: 5, trial: 0, custom: null};

/** Kontrolní součet Vincaria: prvních 10 znaků SHA1 z "{VIN}|{id}|{KEY}|{SECRET}". */
function controlSum(vin, id, apiKey, secret) {
  const input = `${vin}|${id}|${apiKey}|${secret}`;
  return crypto.createHash("sha1").update(input).digest("hex").substring(0, 10);
}

/** Klíč měsíce ve tvaru YYYY_MM (např. 2026_06) — pole v dokumentu 'pouziti'. */
function monthKey(prefix) {
  const now = new Date();
  const m = String(now.getUTCMonth() + 1).padStart(2, "0");
  return `${prefix}_${now.getUTCFullYear()}_${m}`;
}

/** Ověří uživatele a vrátí jeho servis_id. */
async function resolveServisId(auth) {
  if (!auth) {
    throw new HttpsError("unauthenticated", "Vyžadováno přihlášení.");
  }
  const userDoc = await db.collection("uzivatele").doc(auth.uid).get();
  if (!userDoc.exists) {
    throw new HttpsError("failed-precondition", "Profil uživatele nenalezen.");
  }
  const servisId = userDoc.get("servis_id");
  if (!servisId) {
    throw new HttpsError("failed-precondition", "Účet nemá přiřazený servis.");
  }
  return servisId;
}

/**
 * Zjistí typ plánu servisu z důvěryhodného zdroje (predplatne zapisuje pouze
 * server přes webhook / Admin SDK). Expirované předplatné = trial floor.
 * Výchozí (chybějící doklad/plán) = trial — nejpřísnější, chrání náklady.
 */
async function resolvePlan(servisId) {
  const pred = await db.collection("predplatne").doc(servisId).get();
  if (!pred.exists) return "trial";
  const platnostDo = pred.get("platnost_do");
  if (platnostDo && typeof platnostDo.toMillis === "function" &&
      platnostDo.toMillis() < Date.now()) {
    return "trial";
  }
  return pred.get("plan_typ") || "trial";
}

/**
 * Atomicky rezervuje jeden slot v měsíčním počítadle. Vyhodí resource-exhausted,
 * pokud je limit vyčerpán. Vrací funkci pro vrácení slotu (při chybě API).
 */
async function reserveSlot(servisId, prefix, limit) {
  if (limit === null || limit === undefined) {
    return async () => {}; // neomezený plán — nic nerezervujeme
  }
  const ref = db.collection("pouziti").doc(servisId);
  const field = monthKey(prefix);

  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const used = (snap.exists && snap.get(field)) || 0;
    if (used >= limit) {
      throw new HttpsError(
          "resource-exhausted",
          `Dosáhli jste měsíčního limitu ${used} / ${limit}. ` +
          "Upgradujte plán pro pokračování.",
      );
    }
    tx.set(ref, {servis_id: servisId, [field]: used + 1}, {merge: true});
  });

  // Vrácení slotu (best-effort) při selhání API.
  return async () => {
    try {
      await ref.set({[field]: FieldValue.increment(-1)}, {merge: true});
    } catch (_) {
      // počítadlo se srovná příští měsíc; nekritické
    }
  };
}

/** Aktuální stav počítadla pro daný měsíc (pro zobrazení v klientovi). */
async function currentUsage(servisId, prefix) {
  const snap = await db.collection("pouziti").doc(servisId).get();
  return (snap.exists && snap.get(monthKey(prefix))) || 0;
}

function sanitizeVin(input) {
  const vin = String(input || "").trim().toUpperCase().replace(/\s+/g, "");
  if (vin.length < 11 || vin.length > 17) {
    throw new HttpsError("invalid-argument", "Neplatný VIN kód.");
  }
  return vin;
}

/**
 * Sdílená logika pro decode i vehicle-market-value.
 * @param {string} kind 'decode' | 'vehicle-market-value'
 * @param {string} cacheCol název cache kolekce
 * @param {string} usagePrefix prefix pole v počítadle ('vin' | 'value')
 * @param {object} limits mapa plán→limit
 */
async function handleVincario(request, kind, cacheCol, usagePrefix, limits) {
  const vin = sanitizeVin(request.data && request.data.vin);
  const servisId = await resolveServisId(request.auth);

  // 1. Cache — zásah se nepočítá ani nevolá API.
  const cacheRef = db.collection(cacheCol).doc(vin);
  const cached = await cacheRef.get();
  if (cached.exists) {
    return {
      raw: cached.get("raw"),
      fromCache: true,
      used: await currentUsage(servisId, usagePrefix),
      limit: limits[(await resolvePlan(servisId))] ?? null,
    };
  }

  // 2. Limit + rezervace slotu.
  const plan = await resolvePlan(servisId);
  const limit = limits[plan] ?? null;
  const release = await reserveSlot(servisId, usagePrefix, limit);

  // 3. Volání Vincaria sdíleným klíčem.
  let raw;
  try {
    const apiKey = VINCARIO_API_KEY.value();
    const secret = VINCARIO_SECRET.value();
    const cs = controlSum(vin, kind, apiKey, secret);
    const url =
        `https://api.vincario.com/3.2/${apiKey}/${cs}/${kind}/${vin}.json`;
    const resp = await fetch(url);
    if (!resp.ok) {
      throw new HttpsError("unavailable", `Vincario API chyba ${resp.status}.`);
    }
    raw = await resp.json();
    if (kind === "vehicle-market-value" && raw.market_price == null) {
      throw new HttpsError(
          "not-found",
          "Pro toto vozidlo nejsou dostupná tržní data (min. 10 vzorků).",
      );
    }
  } catch (err) {
    await release(); // vrátíme rezervovaný slot
    if (err instanceof HttpsError) throw err;
    throw new HttpsError("internal", "Chyba při volání Vincario API.");
  }

  // 4. Uložení do cache (další dotazy na stejný VIN se nepočítají).
  await cacheRef.set({
    vin,
    raw,
    dekodovano: FieldValue.serverTimestamp(),
  });

  return {
    raw,
    fromCache: false,
    used: await currentUsage(servisId, usagePrefix),
    limit,
  };
}

exports.decodeVin = onCall(
    {region: REGION, secrets: [VINCARIO_API_KEY, VINCARIO_SECRET]},
    (request) =>
      handleVincario(request, "decode", "vin_cache", "vin", VIN_LIMITS),
);

exports.marketValueVin = onCall(
    {region: REGION, secrets: [VINCARIO_API_KEY, VINCARIO_SECRET]},
    (request) =>
      handleVincario(
          request, "vehicle-market-value", "value_cache", "value", VALUE_LIMITS),
);

/**
 * Zjištění STK a technických dat vozidla z api.dataovozidlech.cz.
 * Výsledky se cachují na 24 hodin (STK data se mění jen při nové prohlídce).
 * Bez uživatelských limitů — jen ověření přihlášení.
 */
exports.stkVin = onCall(
    {region: REGION, secrets: [DATAOVOZIDLECH_API_KEY]},
    async (request) => {
      const vin = sanitizeVin(request.data && request.data.vin);
      await resolveServisId(request.auth);

      // Cache na 24 hodin
      const cacheRef = db.collection("stk_cache").doc(vin);
      const cached = await cacheRef.get();
      if (cached.exists) {
        const cachedMs = cached.get("cachedAt")?.toMillis() ?? 0;
        if (Date.now() - cachedMs < 24 * 60 * 60 * 1000) {
          return {raw: cached.get("raw"), fromCache: true};
        }
      }

      const apiKey = DATAOVOZIDLECH_API_KEY.value();
      const url =
          `https://api.dataovozidlech.cz/api/vehicletechnicaldata/v2?vin=${vin}`;
      let raw;
      try {
        const resp = await fetch(url, {
          headers: {
            "api_key": apiKey,
            "Accept": "application/json",
          },
        });
        if (!resp.ok) {
          if (resp.status === 404) {
            throw new HttpsError(
                "not-found",
                "Pro toto VIN nebyla nalezena data STK.",
            );
          }
          throw new HttpsError(
              "unavailable",
              `Chyba API dataovozidlech.cz: ${resp.status}.`,
          );
        }
        raw = await resp.json();
        // Odpověď je obalená: { Status: 1, Data: { ... } }
        if (raw && typeof raw === "object" && "Data" in raw) {
          if (raw.Status !== 1 || !raw.Data) {
            throw new HttpsError("not-found",
                "Pro toto VIN nebyla nalezena data STK.");
          }
          raw = raw.Data;
        }
        // Záloha pro případ pole
        if (Array.isArray(raw)) {
          if (raw.length === 0) {
            throw new HttpsError("not-found",
                "Pro toto VIN nebyla nalezena data STK.");
          }
          raw = raw[0];
        }
      } catch (err) {
        if (err instanceof HttpsError) throw err;
        throw new HttpsError("internal", "Nepodařilo se kontaktovat databázi STK.");
      }

      await cacheRef.set({vin, raw, cachedAt: FieldValue.serverTimestamp()});
      return {raw, fromCache: false};
    },
);

// ─────────────────────────────────────────────────────────────────────────
// SPRÁVA TÝMU — úplné odstranění člena (Auth účet + Firestore profil)
// ─────────────────────────────────────────────────────────────────────────

/**
 * Úplné odstranění člena týmu: smaže jeho Firebase Auth účet i Firestore profil.
 * Na rozdíl od klientského smazání (jen Firestore dokument) uvolní i e-mail,
 * takže stejnou adresu lze později znovu přidat a uživatel po přihlášení
 * neskončí omylem v onboardingu.
 *
 * Oprávnění (zrcadlí firestore.rules → canManageStaff + allow delete):
 *   - volající je přihlášený člen servisu s právem 'zamestnanci',
 *   - mazaný uživatel patří do STEJNÉHO servisu,
 *   - nelze smazat sám sebe.
 */
exports.deleteZamestnanec = onCall(
    {region: REGION},
    async (request) => {
      const auth = request.auth;
      if (!auth) {
        throw new HttpsError("unauthenticated", "Vyžadováno přihlášení.");
      }
      const targetUid =
          request.data && typeof request.data.uid === "string" ?
              request.data.uid.trim() : "";
      if (!targetUid) {
        throw new HttpsError("invalid-argument", "Chybí uid člena ke smazání.");
      }
      if (targetUid === auth.uid) {
        throw new HttpsError(
            "failed-precondition", "Nelze odstranit vlastní účet.");
      }

      // Volající: ověř, že smí spravovat zaměstnance (právo 'zamestnanci').
      const callerDoc = await db.collection("uzivatele").doc(auth.uid).get();
      if (!callerDoc.exists) {
        throw new HttpsError(
            "failed-precondition", "Profil uživatele nenalezen.");
      }
      const callerServisId = callerDoc.get("servis_id");
      const callerPrava = callerDoc.get("prava") || {};
      if (!callerServisId || callerPrava.zamestnanci !== true) {
        throw new HttpsError(
            "permission-denied", "Nemáte oprávnění spravovat tým.");
      }

      // Cíl: musí existovat a patřit do stejného servisu.
      const targetDoc = await db.collection("uzivatele").doc(targetUid).get();
      if (!targetDoc.exists) {
        throw new HttpsError("not-found", "Člen týmu nenalezen.");
      }
      if (targetDoc.get("servis_id") !== callerServisId) {
        throw new HttpsError(
            "permission-denied", "Člen nepatří do vašeho servisu.");
      }

      // 1) Smazání Auth účtu (uvolní e-mail). Pokud už neexistuje, pokračujeme.
      try {
        await getAuth().deleteUser(targetUid);
      } catch (e) {
        if (e.code !== "auth/user-not-found") {
          throw new HttpsError(
              "internal", "Nepodařilo se smazat přihlašovací účet.", e.message);
        }
      }

      // 2) Smazání Firestore profilu (tím zaniká členství i přístup k datům).
      await db.collection("uzivatele").doc(targetUid).delete();

      return {success: true};
    },
);

// ─────────────────────────────────────────────────────────────────────────
// REVENUECAT WEBHOOK — synchronizace plánu do Firestore (zdroj pravdy pro limity)
// ─────────────────────────────────────────────────────────────────────────

/**
 * Z entitlement_ids vybere nejvyšší plán dle priority (nebo null).
 * Porovnává malými písmeny — RevenueCat může mít 'Basic' apod.
 */
function planFromEntitlements(ids) {
  if (!Array.isArray(ids)) return null;
  const lower = ids.map((s) => String(s).toLowerCase());
  for (const p of PLAN_PRIORITY) {
    if (lower.includes(p)) return p;
  }
  return null;
}

/**
 * RevenueCat posílá události o nákupu/obnově/expiraci. Endpoint zapíše
 * důvěryhodný plán do predplatne/{servis_id} přes Admin SDK (obchází rules).
 * Zabezpečení: hlavička Authorization musí odpovídat tajnému tokenu.
 */
exports.revenuecatWebhook = onRequest(
    {region: REGION, secrets: [REVENUECAT_WEBHOOK_AUTH]},
    async (req, res) => {
      if (req.method !== "POST") {
        res.status(405).send("Method Not Allowed");
        return;
      }
      if (req.get("Authorization") !== REVENUECAT_WEBHOOK_AUTH.value()) {
        res.status(401).send("Unauthorized");
        return;
      }

      const event = (req.body && req.body.event) || {};
      const type = event.type;
      const appUserId = event.app_user_id;
      if (!appUserId) {
        res.status(200).send("ignored: no app_user_id");
        return;
      }

      // app_user_id = Firebase uid → najdeme servis_id (na který je vázáno predplatne).
      let servisId = appUserId;
      try {
        const userDoc = await db.collection("uzivatele").doc(appUserId).get();
        if (userDoc.exists && userDoc.get("servis_id")) {
          servisId = userDoc.get("servis_id");
        }
      } catch (_) {
        // fallback: appUserId
      }

      const predRef = db.collection("predplatne").doc(servisId);

      // Expirace / ukončení přístupu → posuneme platnost do minulosti
      // (resolvePlan pak spadne na trial floor; klient jde na paywall).
      if (type === "EXPIRATION") {
        await predRef.set({
          platnost_do: Timestamp.fromMillis(
              event.expiration_at_ms || Date.now()),
          plan_zdroj: "revenuecat",
          aktualizovano: FieldValue.serverTimestamp(),
        }, {merge: true});
        res.status(200).send("ok: expiration");
        return;
      }

      // Aktivní událost (nákup, obnova, změna plánu, zrušení auto-obnovy…)
      const plan = planFromEntitlements(event.entitlement_ids) ||
          planFromEntitlements(
              event.entitlement_id ? [event.entitlement_id] : []);
      if (!plan) {
        res.status(200).send("ignored: no known entitlement");
        return;
      }

      await predRef.set({
        servis_id: servisId,
        plan_typ: plan,
        platnost_do: event.expiration_at_ms ?
            Timestamp.fromMillis(event.expiration_at_ms) : null,
        plan_zdroj: "revenuecat",
        aktualizovano: FieldValue.serverTimestamp(),
      }, {merge: true});

      res.status(200).send(`ok: ${plan}`);
    },
);
