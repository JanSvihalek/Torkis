import {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} from '@firebase/rules-unit-testing';
import {
  doc, setDoc, getDoc, getDocs, collection, query, where,
  addDoc, updateDoc, deleteDoc,
} from 'firebase/firestore';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const __dirname = dirname(fileURLToPath(import.meta.url));
const rules = readFileSync(join(__dirname, '..', '..', 'firestore.rules'), 'utf8');

const OWNER_EMAIL = 'jan.svihalek00@gmail.com';

let pass = 0, fail = 0;
async function check(name, p) {
  try { await p; console.log('  ✓', name); pass++; }
  catch (e) { console.log('  ✗', name, '—', e.message); fail++; }
}

const testEnv = await initializeTestEnvironment({
  projectId: 'visto-rules-test',
  firestore: { rules },
});

// ── Seed dat (bez pravidel) ──────────────────────────────────────────────
// A = majitel servisu A (uid == servis_id), E = zaměstnanec servisu A,
// X = majitel cizího servisu X.
await testEnv.withSecurityRulesDisabled(async (ctx) => {
  const db = ctx.firestore();
  await setDoc(doc(db, 'uzivatele/A'), { servis_id: 'A', role: 'admin', prava: { zamestnanci: true } });
  await setDoc(doc(db, 'uzivatele/E'), { servis_id: 'A', role: 'zamestnanec', prava: { zamestnanci: false } });
  await setDoc(doc(db, 'uzivatele/X'), { servis_id: 'X', role: 'admin', prava: { zamestnanci: true } });
  await setDoc(doc(db, 'vozidla/vA'), { servis_id: 'A', spz: '1A' });
  await setDoc(doc(db, 'vozidla/vB'), { servis_id: 'B', spz: '1B' });
  await setDoc(doc(db, 'zakaznici/zA'), { servis_id: 'A', jmeno: 'Klient A' });
  await setDoc(doc(db, 'nastaveni_servisu/A'), { nazev: 'Servis A' });
  await setDoc(doc(db, 'predplatne/A'), { servis_id: 'A', plan_typ: 'trial' });
});

const A = testEnv.authenticatedContext('A').firestore();
const E = testEnv.authenticatedContext('E').firestore();
const X = testEnv.authenticatedContext('X').firestore();
const N = testEnv.authenticatedContext('N').firestore(); // nový uživatel bez profilu
const owner = testEnv.authenticatedContext('OWN', { email: OWNER_EMAIL }).firestore();

console.log('\n— Izolace tenantů (čtení/zápis) —');
await check('admin čte své vozidlo', assertSucceeds(getDoc(doc(A, 'vozidla/vA'))));
await check('zaměstnanec čte vozidlo svého servisu', assertSucceeds(getDoc(doc(E, 'vozidla/vA'))));
await check('zaměstnanec NEčte cizí vozidlo (servis B)', assertFails(getDoc(doc(E, 'vozidla/vB'))));
await check('cizí majitel NEčte vozidlo servisu A', assertFails(getDoc(doc(X, 'vozidla/vA'))));
await check('cizí majitel NEčte zákazníka servisu A', assertFails(getDoc(doc(X, 'zakaznici/zA'))));
await check('zaměstnanec vytvoří vozidlo pro servis A', assertSucceeds(setDoc(doc(E, 'vozidla/vNew'), { servis_id: 'A', spz: 'NEW' })));
await check('cizí NEvytvoří vozidlo pro servis A', assertFails(setDoc(doc(X, 'vozidla/vEvil'), { servis_id: 'A' })));
await check('cizí NEsmaže vozidlo servisu A', assertFails(deleteDoc(doc(X, 'vozidla/vA'))));

console.log('\n— Dotazy (list) —');
await check('list vozidel filtrovaný servisem A projde', assertSucceeds(getDocs(query(collection(E, 'vozidla'), where('servis_id', '==', 'A')))));
await check('list vozidel cizího servisu B odmítnut', assertFails(getDocs(query(collection(E, 'vozidla'), where('servis_id', '==', 'B')))));
await check('list vozidel bez filtru odmítnut', assertFails(getDocs(collection(E, 'vozidla'))));

console.log('\n— Nastavení / předplatné —');
await check('zaměstnanec čte nastavení servisu A', assertSucceeds(getDoc(doc(E, 'nastaveni_servisu/A'))));
await check('cizí NEčte nastavení servisu A', assertFails(getDoc(doc(X, 'nastaveni_servisu/A'))));
await check('admin čte své předplatné', assertSucceeds(getDoc(doc(A, 'predplatne/A'))));
await check('cizí NEčte předplatné servisu A', assertFails(getDoc(doc(X, 'predplatne/A'))));
await check('owner aplikace čte cizí předplatné', assertSucceeds(getDoc(doc(owner, 'predplatne/A'))));

console.log('\n— Onboarding (bootstrap nového majitele N) —');
await check('N založí vlastní profil (servis_id == uid)', assertSucceeds(setDoc(doc(N, 'uzivatele/N'), { servis_id: 'N', role: 'admin', prava: { zamestnanci: true } })));
await check('N NEzaloží profil do cizího servisu A', assertFails(setDoc(doc(N, 'uzivatele/N2'), { servis_id: 'A' })));
await check('N založí nastavení vlastního servisu', assertSucceeds(setDoc(doc(N, 'nastaveni_servisu/N'), { nazev: 'N' })));
await check('N založí vlastní úkon', assertSucceeds(addDoc(collection(N, 'ukony'), { servis_id: 'N', nazev: 'olej' })));
await check('N založí vlastní trial', assertSucceeds(setDoc(doc(N, 'predplatne/N'), { servis_id: 'N', plan_typ: 'trial' })));
await check('NElze založit placený plán (jen trial)', assertFails(setDoc(doc(N, 'predplatne/N'), { servis_id: 'N', plan_typ: 'premium' })));

console.log('\n— Eskalace oprávnění —');
await check('zaměstnanec si NEpovýší roli (self-update)', assertFails(updateDoc(doc(E, 'uzivatele/E'), { role: 'admin' })));
await check('zaměstnanec smí změnit svůj tmavý režim', assertSucceeds(setDoc(doc(E, 'uzivatele/E'), { tmavy_rezim: true }, { merge: true })));
await check('zaměstnanec NEmění profil kolegy (nemá právo)', assertFails(updateDoc(doc(E, 'uzivatele/A'), { role: 'zamestnanec' })));
await check('admin přidá zaměstnance do svého servisu', assertSucceeds(setDoc(doc(A, 'uzivatele/E2'), { servis_id: 'A', role: 'zamestnanec', prava: { zamestnanci: false } })));
await check('cizí NEpřidá uživatele do servisu A', assertFails(setDoc(doc(X, 'uzivatele/EVIL'), { servis_id: 'A' })));
await check('cizí NEupraví profil admina A', assertFails(updateDoc(doc(X, 'uzivatele/A'), { role: 'hacker' })));

console.log('\n— Server-only / ostatní —');
await check('klient NEpíše do pouziti', assertFails(setDoc(doc(A, 'pouziti/A'), { x: 1 })));
await check('klient NEčte pouziti', assertFails(getDoc(doc(A, 'pouziti/A'))));
await check('signedIn smí založit mail', assertSucceeds(addDoc(collection(A, 'maily'), { to: 'x@y.cz', message: {} })));
await check('signedIn NEčte frontu mailů', assertFails(getDoc(doc(A, 'maily/m1'))));

await testEnv.cleanup();
console.log(`\nVÝSLEDEK: ${pass} prošlo, ${fail} selhalo`);
process.exit(fail === 0 ? 0 : 1);
