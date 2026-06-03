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
const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {defineSecret} = require("firebase-functions/params");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore, FieldValue} = require("firebase-admin/firestore");

initializeApp();
const db = getFirestore();

// Tajný sdílený Vincario klíč — nastav přes:
//   firebase functions:secrets:set VINCARIO_API_KEY
//   firebase functions:secrets:set VINCARIO_SECRET
const VINCARIO_API_KEY = defineSecret("VINCARIO_API_KEY");
const VINCARIO_SECRET = defineSecret("VINCARIO_SECRET");

const REGION = "europe-west3";

// Měsíční limity dle plánu (null = neomezeno).
// MUSÍ zůstat v souladu s lib/core/constants.dart (kPlanVinLimit / kPlanValueLimit).
const VIN_LIMITS = {basic: 50, standard: 150, pro: 500, trial: 10, custom: null};
const VALUE_LIMITS = {basic: 10, standard: 30, pro: 100, trial: 5, custom: null};

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

/** Zjistí typ plánu servisu (výchozí 'basic'). */
async function resolvePlan(servisId) {
  const pred = await db.collection("predplatne").doc(servisId).get();
  return (pred.exists && pred.get("plan_typ")) || "basic";
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
