# TORKIS ERP sync

Malý ETL nástroj, který běží **na straně dealera** a 2× denně (Windows Task
Scheduler) nasype vozidla a zákazníky z jeho **ERP na MS SQL Serveru** do
**Firestore** projektu Torkis. Aplikace Torkis pak data čte jako dnes — nesahá se jí.

```
[ERP / MS SQL]  ──SELECT──►  [torkis-sync.exe]  ──upsert──►  [Firestore]  ──►  [Torkis app]
                              (Task Scheduler)               (tvůj projekt)
```

Synchronizace je **jednosměrná a read-only z pohledu appky**: importovaná data
mají `zdroj: "erp"` a appka je nesmí editovat (viz security rules níže), jinak
by je příští běh přepsal.

---

## 1. Příprava (jednorázově, u tebe)

### Build samostatného .exe
Potřebuješ .NET SDK 8+ na **svém** stroji (ne u dealera).

```powershell
cd tools/torkis-sync
dotnet publish -c Release -r win-x64 --self-contained true `
  -p:PublishSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true
```

Výstup: `bin/Release/net8.0/win-x64/publish/torkis-sync.exe` — jeden soubor,
dealer nepotřebuje instalovat žádný runtime.

### Service account klíč (Firebase)
1. Firebase konzole → ⚙️ Project settings → **Service accounts** → *Generate new private key*.
2. Doporučení: vytvoř **dedikovaný** service account jen pro sync (a ideálně
   jeden **per dealer**, aby šel kdykoliv zneplatnit samostatně).
3. Stažený JSON = `service-account.json`.

---

## 2. Nasazení u dealera

Do jedné složky (např. `C:\TorkisSync\`) dej:

| Soubor | Popis |
|---|---|
| `torkis-sync.exe` | binárka (stejná pro všechny dealery) |
| `appsettings.json` | konfigurace dealera — vyrob z `appsettings.example.json` |
| `service-account.json` | Firebase klíč (tajný) |

V `appsettings.json` vyplň:
- **`ServisId`** — servis_id dealera v Torkisu (u každého jiné),
- **`Sql.ConnectionString`** — připojení k jejich ERP,
- **`Sql.VozidlaQuery` / `ZakazniciQuery`** — SELECT s aliasy sloupců na pole,
  která čte appka (viz komentáře v example). Dotaz **musí** vracet sloupec `erp_id`.
- **`Firebase.ProjectId`** — ID Torkis projektu.

### Test ručního spuštění
```powershell
C:\TorkisSync\torkis-sync.exe
```
Průběh se vypisuje do konzole i do `torkis-sync.log`. Exit kód 0 = OK, 1 = chyba.

---

## 3. Naplánování (Task Scheduler)

```powershell
# Spouští 2× denně (07:00 a 18:00). Uprav cesty/časy dle potřeby.
schtasks /Create /TN "Torkis ERP sync" /TR "C:\TorkisSync\torkis-sync.exe" ^
  /SC DAILY /ST 07:00 /RU SYSTEM /RL HIGHEST /F
schtasks /Create /TN "Torkis ERP sync (odpoledne)" /TR "C:\TorkisSync\torkis-sync.exe" ^
  /SC DAILY /ST 18:00 /RU SYSTEM /RL HIGHEST /F
```

> Pozn.: účet, pod kterým úloha běží (`/RU`), musí mít přístup k MS SQL. Pokud
> používáš Windows autentizaci v connection stringu, zvol účet s právy do ERP DB
> místo `SYSTEM`.

---

## 4. Firestore security rules (důležité)

Aby appka nemohla editovat ERP záznamy (a sync je nepřepisoval):

```
match /vozidla/{id} {
  allow read: if request.auth != null;
  // ERP záznamy jsou read-only z klienta; zapisuje jen Admin SDK (sync), který rules obchází.
  allow write: if request.auth != null
               && !(resource.data.zdroj == 'erp');
}
match /zakaznici/{id} {
  allow read: if request.auth != null;
  allow write: if request.auth != null
               && !(resource.data.zdroj == 'erp');
}
```

---

## Jak to funguje uvnitř

- **ID dokumentu** = `erp_<servisId>_<erp_id>` → opakovaný běh aktualizuje
  stejné dokumenty (upsert), nevznikají duplicity.
- **Metadata** u každého záznamu: `servis_id`, `zdroj: "erp"`, `synced_run`, `synced_at`.
- **Mazání odebraných** (`DeleteStale: true`): co se v aktuálním běhu neobjevilo
  (jiný `synced_run`), se z Firestore smaže — ale jen záznamy se `zdroj == "erp"`,
  ručně přidaná data v appce zůstávají.
- Zápisy jdou v dávkách (batch po 450) kvůli limitu Firestore.
