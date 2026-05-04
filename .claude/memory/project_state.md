---
name: Stav projektu TORKIS
description: Přehled architektury, hotových funkcí a klíčových souborů — aktualizováno 2026-05-04
type: project
originSessionId: 5d411500-fae5-45ee-abb4-fd9e8aca059d
---
Firebase projekt: visto-51cb7. Flutter/Firebase aplikace pro správu autoservisu.
Web portál pro zákazníky: https://app.torkis.cz/zakazka/{token}

**Why:** Projekt běží na dvou počítačích, sumář slouží jako synchronizační bod.
**How to apply:** Při práci s portálem, komunikací nebo Firebase Hosting vycházet z tohoto stavu.

## Architektura souborů (po refaktoringu)

Původní monolitické soubory rozděleny do podsložek:

```
lib/moduly/
├── nastaveni.dart                          ← Šablony zpráv, auto číslo zakázky
├── zakazka_komunikace.dart                 ← Obousměrný chat + badge nepřečtených
├── fakturace/
│   ├── faktura_detail.dart                 ← syncAndRegenerateFaktura()
│   ├── faktura_edit_polozky.dart           ← PolozkaInput, EditFakturaWorkScreen
│   ├── faktura_manual.dart                 ← ManualInvoiceScreen (pultový prodej)
│   └── fakturace_page.dart                 ← FakturacePage (seznam faktur)
├── prijem/
│   ├── prijem_vozidla.dart                 ← _nactiNastaveni() + podmíněné generování č. zakázky
│   └── prijem_vozidla_step_vozidlo.dart    ← autoGenerateCislo param, LayoutBuilder (breakpoint 400px)
└── zakazka/
    └── prubeh_detail_akce.dart             ← Badge StreamBuilder (nepřečtené zprávy)

web/zakazka.html                            ← Zákaznický portál s chatem (Firebase JS SDK)
firestore.rules                             ← allow create pro anonymní zápis zpráv zákazníka
```

## Firestore struktura — komunikace

```
zakazky/{docId}/zakaznik_zpravy/{msgId}
  text: String
  cas: Timestamp
  autor: String          ← jméno uživatele nebo zákazníka
  from_zakaznik: bool    ← true = zákazník z portálu
  odeslan_email: bool
  precteno: bool         ← true = servis zprávu viděl (nastavuje Flutter app)
  foto_urls: List<String>
```

Emaily: kolekce `maily` (Firebase Trigger Email extension)

## Hotové funkce

### Zákaznický portál
- `build/web/zakazka.html` — standalone HTML, Firebase JS SDK, bez Flutteru
- Doména `app.torkis.cz` připojena k Firebase Hosting, SSL funguje
- `firebase.json` — rewrite `/zakazka/**` → `zakazka.html`
- `torkis.cz` odpojena od Firebase, volná pro webovou prezentaci

### Obousměrná komunikace se zákazníkem
- Flutter (`zakazka_komunikace.dart`): chat bubliny — servis vlevo (světlá), zákazník vpravo (modrá)
- Zákazníkova zpráva identifikována: `from_zakaznik == true` nebo `autor == 'Zákazník'`
- Při otevření stránky batch update — všechny zákazníkovy zprávy `precteno: true`
- Web portál (`web/zakazka.html`): textarea + tlačítko „Odeslat zprávu", Enter odešle, Shift+Enter = nový řádek
- Firestore pravidla: `allow create` pro anonymní uživatele na `zakaznik_zpravy` (pouze `from_zakaznik == true`)

### Badge s nepřečtenými zprávami (prubeh_detail_akce.dart)
- StreamBuilder na `zakaznik_zpravy` kde `from_zakaznik == true` a `precteno != true`
- Červený badge s počtem (> 9 zobrazí jako „9+")
- Ikona komunikace se zbarví oranžově při nepřečtených (jinak teal)

### Šablony zpráv
- Nastavení (`nastaveni.dart`): karta „Šablony zpráv" (pouze admin), `nastaveni_servisu/{id}.sablony_zprav` — pole stringů
- Přidat / upravit (dialog) / smazat — okamžité uložení do Firestore
- Komunikace (`zakazka_komunikace.dart`): `_PridatZpravuSheet` načítá šablony v `initState`, horizontálně scrollovatelné ActionChip chipy nad polem

### Volitelné vypnutí auto-generování čísla zakázky
- Nastavení: `nastaveni_servisu/{id}.auto_cislo_zakazky` (bool, default true)
- UI toggle v `nastaveni.dart` (sekce Provozní nastavení)
- `prijem_vozidla.dart`: `_nactiNastaveni()` načte setting, podmíněně spustí `_generujCisloZakazky()`
- `prijem_vozidla_step_vozidlo.dart`: param `autoGenerateCislo` — skryje refresh button

### Nacenění v komunikaci
- `PridatZpravuSheet`: přepínač „Přiložit nacenění" + pole pro cenu → zpráva uložena s `typ: 'naceneni'`, `castka`, `stav_schvaleni: 'cekajici'`
- `ZpravaKarta` (`zprava_karta.dart`): detekuje `typ == 'naceneni'` → zelená karta s cenou + stavový odznak (⏳ / ✓ / ✗)
- Web portál (`zakazka.html`): nacenění karta s tlačítky Schválit/Zamítnout → `updateDoc` na `stav_schvaleni` + nová zpráva od zákazníka (aktivuje badge)
- Firestore rules: `allow update` pro anonymní uživatele pouze na poli `stav_schvaleni` u `typ == 'naceneni'`
- Po změnách: `cp web/zakazka.html build/web/zakazka.html` + `firebase deploy --only hosting,firestore:rules`

### Refaktoring zakazka_komunikace.dart → složka
- `zakazka_komunikace/zakazka_komunikace_page.dart` — hlavní stránka
- `zakazka_komunikace/zprava_karta.dart` — chat bublina
- `zakazka_komunikace/foto_nahled.dart` — fullscreen foto
- `zakazka_komunikace/pridat_zpravu_sheet.dart` — bottom sheet pro novou zprávu

## Branding / loga (přidáno 2026-05-04)

`assets/images/` obsahuje nová loga: `torkis-app-icon-32/180/192/256/512/1024.png`
`auth_screen.dart` používá nové logo (`torkis-app-icon-192.png`) + novou barevnou paletu:
- Pozadí: `#0B1A2E` (tmavě modrá)
- Akcenty: `Colors.blueAccent`
- Styl polí: Glassmorphism (průhledné pozadí, žádný border, fokus s modrým outline)

## Závislosti (pubspec)
Žádné nové závislosti — vše využívá: `cloud_firestore`, `firebase_auth`, `firebase_storage`, `image_picker`, `printing`, `intl`, `http`.
