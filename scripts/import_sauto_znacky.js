/**
 * import_sauto_znacky.js
 *
 * Stáhne číselník značek a modelů ze Sauto.cz a naplní/doplní
 * Firestore kolekci 'znacka'. Existující dokumenty (s logy apod.)
 * se NEPŘEPISUJÍ — modely se jen doplní.
 *
 * Spuštění:
 *   cd scripts
 *   npm install
 *   node import_sauto_znacky.js ../serviceAccountKey.json
 */

import { XMLParser } from 'fast-xml-parser';
import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { readFileSync } from 'fs';
import { resolve } from 'path';

// ── Povolené značky ──────────────────────────────────────────────────────────
// Upravte dle potřeby. Porovnává se case-insensitive.

const POVOLENE_ZNACKY = new Set([
  // Masové
  'Škoda', 'Volkswagen', 'Ford', 'Renault', 'Opel',
  'Peugeot', 'Citroën', 'Dacia', 'Fiat', 'Seat','Chevrolet',
  // Prémiové
  'BMW', 'Mercedes-Benz', 'Audi', 'Volvo', 'Land Rover',
  'Mini', 'Alfa Romeo', 'Jaguar',
  // Asijské
  'Toyota', 'Hyundai', 'Kia', 'Nissan', 'Mazda', 'Isuzu',
  'Honda', 'Mitsubishi', 'Suzuki', 'Subaru', 'Lexus','Jaecoo', 'MG', 'Leapmotor',
  // Ostatní časté
  'Jeep', 'Porsche', 'Cupra', 'Tesla',
].map(s => s.toLowerCase()));

// ── Argumenty ────────────────────────────────────────────────────────────────

const keyPath = process.argv[2];
if (!keyPath) {
  console.error('Použití: node import_sauto_znacky.js <cesta/k/serviceAccountKey.json>');
  process.exit(1);
}

// ── Firebase init ─────────────────────────────────────────────────────────────

const serviceAccount = JSON.parse(readFileSync(resolve(keyPath), 'utf8'));
initializeApp({ credential: cert(serviceAccount) });
const db = getFirestore();

// ── Stažení XML ───────────────────────────────────────────────────────────────

console.log('Stahuji číselník ze Sauto.cz...');
const res = await fetch('https://www.sauto.cz/import/carList?2');
if (!res.ok) throw new Error(`HTTP ${res.status}`);
const xml = await res.text();
console.log(`Staženo ${Math.round(xml.length / 1024)} kB.`);

// ── Parsování XML ─────────────────────────────────────────────────────────────

const parser = new XMLParser({ ignoreAttributes: false, isArray: (name) => name === 'model' || name === 'manufacturer' || name === 'kind' });
const parsed = parser.parse(xml);

// Chceme jen osobní auta (kind_name === 'Osobní')
const kinds = parsed?.car_list?.kind ?? [];
const osobni = kinds.find(k => k.kind_name === 'Osobní');
if (!osobni) throw new Error('Sekce "Osobní" nebyla v XML nalezena.');

const manufacturers = osobni.manufacturer ?? [];
console.log(`Nalezeno ${manufacturers.length} značek.`);

// ── Načtení existujících dokumentů z Firestore ────────────────────────────────

console.log('Načítám existující kolekci znacka z Firestore...');
const snapshot = await db.collection('znacka').get();

// Mapa: nazev_lowercase → { docId, existingModels: Set<string> }
const existing = new Map();
for (const doc of snapshot.docs) {
  const data = doc.data();
  const nazev = (data.nazev ?? doc.id).trim().toLowerCase();
  const modelyRaw = Array.isArray(data.model) ? data.model : [];
  const existingModels = new Set(
    modelyRaw.map(m => (typeof m === 'string' ? m : m?.model ?? '').toLowerCase()).filter(Boolean)
  );
  existing.set(nazev, { docId: doc.id, existingModels, data });
}

// ── Zápis do Firestore ────────────────────────────────────────────────────────

let created = 0;
let updated = 0;
let skipped = 0;

const batch = db.batch();
let batchCount = 0;

const flush = async () => {
  if (batchCount > 0) {
    await batch.commit();
    batchCount = 0;
  }
};

for (const mfr of manufacturers) {
  const nazev = mfr.manufacturer_name?.trim();
  if (!nazev) continue;
  if (!POVOLENE_ZNACKY.has(nazev.toLowerCase())) continue;

  const modelsFromXml = (Array.isArray(mfr.model) ? mfr.model : mfr.model ? [mfr.model] : [])
    .map(m => m.model_name?.toString().trim())
    .filter(Boolean);

  if (modelsFromXml.length === 0) {
    skipped++;
    continue;
  }

  const key = nazev.toLowerCase();
  const found = existing.get(key);

  if (found) {
    // Dokument existuje — přidáme jen chybějící modely
    const novaModely = modelsFromXml.filter(m => !found.existingModels.has(m.toLowerCase()));
    if (novaModely.length === 0) {
      skipped++;
      continue;
    }
    const stareModely = found.data.model ?? [];
    const doplnene = [...stareModely, ...novaModely.map(m => ({ model: m }))];
    batch.update(db.collection('znacka').doc(found.docId), { model: doplnene });
    console.log(`  [UPDATE] ${nazev} — přidáno ${novaModely.length} modelů`);
    updated++;
  } else {
    // Nový dokument
    const ref = db.collection('znacka').doc();
    batch.set(ref, {
      nazev,
      logo: '',
      model: modelsFromXml.map(m => ({ model: m })),
    });
    console.log(`  [CREATE] ${nazev} — ${modelsFromXml.length} modelů`);
    created++;
  }

  batchCount++;
  // Firestore batch limit je 500 operací
  if (batchCount >= 400) await flush();
}

await flush();

console.log('\n── Hotovo ─────────────────────────────────────────────────');
console.log(`  Vytvořeno:  ${created} nových značek`);
console.log(`  Doplněno:   ${updated} existujících značek`);
console.log(`  Přeskočeno: ${skipped} (žádné změny nebo bez modelů)`);
