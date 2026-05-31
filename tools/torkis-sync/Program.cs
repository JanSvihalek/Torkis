using System.Text.Json;
using Google.Cloud.Firestore;
using Microsoft.Data.SqlClient;

// ───────────────────────────────────────────────────────────────────────────
// TORKIS ERP sync
//
// Malý ETL nástroj, který běží na straně dealera (Windows Task Scheduler,
// typicky 2× denně). Přečte vozidla a zákazníky ze stávajícího ERP na MS SQL
// a nasype je (upsert) do Firestore projektu Torkis pod daný servis_id.
//
// Appka Torkis pak čte data z Firestore jako dnes — nesahá se jí.
//
// Spuštění:
//   torkis-sync.exe [cesta-k-appsettings.json]
// Bez argumentu se hledá appsettings.json vedle .exe.
// ───────────────────────────────────────────────────────────────────────────

int exitCode = 0;
var runId = Guid.NewGuid().ToString("N");

try
{
    var configPath = args.Length > 0
        ? args[0]
        : Path.Combine(AppContext.BaseDirectory, "appsettings.json");

    Log.Info($"=== TORKIS sync start (run {runId}) ===");
    Log.Info($"Konfigurace: {configPath}");

    var config = AppConfig.Load(configPath);
    config.Validate();

    var db = new FirestoreDbBuilder
    {
        ProjectId = config.Firebase!.ProjectId,
        CredentialsPath = config.ResolveServiceAccountPath(configPath),
    }.Build();

    Log.Info($"Firestore projekt: {config.Firebase.ProjectId}, servis_id: {config.ServisId}");

    // ── Vozidla ──────────────────────────────────────────────────────────
    var pocetVozidel = await Syncer.SyncCollectionAsync(
        db, config.Sql!.ConnectionString!, config.Sql.VozidlaQuery!,
        collection: "vozidla", servisId: config.ServisId!, runId: runId);
    Log.Info($"Vozidla: nasypáno/aktualizováno {pocetVozidel} záznamů.");

    // ── Zákazníci ────────────────────────────────────────────────────────
    var pocetZakazniku = await Syncer.SyncCollectionAsync(
        db, config.Sql.ConnectionString!, config.Sql.ZakazniciQuery!,
        collection: "zakaznici", servisId: config.ServisId!, runId: runId);
    Log.Info($"Zákazníci: nasypáno/aktualizováno {pocetZakazniku} záznamů.");

    // ── Úklid záznamů smazaných v ERP ──────────────────────────────────────
    if (config.DeleteStale)
    {
        var smazanaVozidla = await Syncer.CleanupStaleAsync(
            db, "vozidla", config.ServisId!, runId);
        var smazaniZakaznici = await Syncer.CleanupStaleAsync(
            db, "zakaznici", config.ServisId!, runId);
        Log.Info($"Úklid: smazáno {smazanaVozidla} vozidel a {smazaniZakaznici} zákazníků (odebráno z ERP).");
    }
    else
    {
        Log.Info("Úklid přeskočen (DeleteStale = false).");
    }

    Log.Info($"=== TORKIS sync hotovo OK (run {runId}) ===");
}
catch (Exception ex)
{
    Log.Error($"CHYBA: {ex.Message}");
    Log.Error(ex.ToString());
    Log.Error($"=== TORKIS sync SELHAL (run {runId}) ===");
    exitCode = 1; // ať Task Scheduler vidí neúspěch
}

return exitCode;


// ═══════════════════════════════════════════════════════════════════════════
//  Synchronizace
// ═══════════════════════════════════════════════════════════════════════════
static class Syncer
{
    // Firestore dovolí max 500 operací v jednom batchi.
    private const int BatchLimit = 450;

    /// Načte řádky z SQL dotazu a upsertne je do dané Firestore kolekce.
    /// Dotaz MUSÍ vracet sloupec "erp_id" (primární klíč z ERP) — z něj se
    /// odvozuje stabilní ID dokumentu, aby se záznamy aktualizovaly a nevznikaly
    /// duplicity. Ostatní sloupce se uloží 1:1 jako pole dokumentu.
    public static async Task<int> SyncCollectionAsync(
        FirestoreDb db, string connectionString, string query,
        string collection, string servisId, string runId)
    {
        var col = db.Collection(collection);
        var count = 0;
        var batch = db.StartBatch();
        var batchOps = 0;

        await using var conn = new SqlConnection(connectionString);
        await conn.OpenAsync();
        await using var cmd = new SqlCommand(query, conn) { CommandTimeout = 180 };
        await using var reader = await cmd.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            var data = new Dictionary<string, object?>(StringComparer.Ordinal);
            string? erpId = null;

            for (var i = 0; i < reader.FieldCount; i++)
            {
                var name = reader.GetName(i);
                var value = reader.IsDBNull(i) ? null : reader.GetValue(i);

                if (name.Equals("erp_id", StringComparison.OrdinalIgnoreCase))
                {
                    erpId = value?.ToString();
                    continue;
                }
                data[name] = Normalize(value);
            }

            if (string.IsNullOrWhiteSpace(erpId))
                throw new InvalidOperationException(
                    $"Řádek v kolekci '{collection}' nemá hodnotu ve sloupci 'erp_id'. " +
                    "Zkontroluj, že SQL dotaz vrací sloupec erp_id (primární klíč z ERP).");

            // Metadata pro multi-tenant, read-only ochranu a úklid.
            data["servis_id"] = servisId;
            data["zdroj"] = "erp";
            data["synced_run"] = runId;
            data["synced_at"] = Timestamp.FromDateTime(DateTime.UtcNow);

            var docId = $"erp_{servisId}_{erpId}".Replace('/', '_');
            batch.Set(col.Document(docId), data, SetOptions.MergeAll);
            batchOps++;
            count++;

            if (batchOps >= BatchLimit)
            {
                await batch.CommitAsync();
                batch = db.StartBatch();
                batchOps = 0;
            }
        }

        if (batchOps > 0)
            await batch.CommitAsync();

        return count;
    }

    /// Smaže z Firestore ERP záznamy daného servisu, které se v tomto běhu
    /// neobjevily (tj. byly v ERP odstraněny). Pozná je podle jiného synced_run.
    /// Filtruje jen na servis_id (jedno pole = bez nutnosti composite indexu),
    /// zbytek řeší na klientu.
    public static async Task<int> CleanupStaleAsync(
        FirestoreDb db, string collection, string servisId, string runId)
    {
        var snapshot = await db.Collection(collection)
            .WhereEqualTo("servis_id", servisId)
            .GetSnapshotAsync();

        var deleted = 0;
        var batch = db.StartBatch();
        var batchOps = 0;

        foreach (var doc in snapshot.Documents)
        {
            // Mazat smí jen ERP záznamy — ručně přidaná data v appce neřešíme.
            var zdroj = doc.ContainsField("zdroj") ? doc.GetValue<string>("zdroj") : null;
            if (zdroj != "erp") continue;

            var docRun = doc.ContainsField("synced_run") ? doc.GetValue<string>("synced_run") : null;
            if (docRun == runId) continue; // čerstvý záznam z tohoto běhu — ponechat

            batch.Delete(doc.Reference);
            batchOps++;
            deleted++;

            if (batchOps >= BatchLimit)
            {
                await batch.CommitAsync();
                batch = db.StartBatch();
                batchOps = 0;
            }
        }

        if (batchOps > 0)
            await batch.CommitAsync();

        return deleted;
    }

    /// Převede hodnotu z SQL na typ, kterému rozumí Firestore .NET klient.
    private static object? Normalize(object? value) => value switch
    {
        null => null,
        bool or string or long or double => value,
        byte or sbyte or short or ushort or int or uint => Convert.ToInt64(value),
        decimal d => (double)d,
        float f => (double)f,
        DateTime dt => Timestamp.FromDateTime(DateTime.SpecifyKind(dt, DateTimeKind.Utc)),
        DateTimeOffset dto => Timestamp.FromDateTimeOffset(dto),
        Guid g => g.ToString(),
        byte[] => null, // binární data (foto apod.) do číselníku nepatří
        _ => value.ToString(),
    };
}


// ═══════════════════════════════════════════════════════════════════════════
//  Konfigurace (appsettings.json)
// ═══════════════════════════════════════════════════════════════════════════
sealed class AppConfig
{
    public string? ServisId { get; set; }
    public SqlConfig? Sql { get; set; }
    public FirebaseConfig? Firebase { get; set; }
    public bool DeleteStale { get; set; } = true;

    public static AppConfig Load(string path)
    {
        if (!File.Exists(path))
            throw new FileNotFoundException(
                $"Konfigurační soubor nenalezen: {path}. " +
                "Zkopíruj appsettings.example.json na appsettings.json a vyplň údaje.");

        var json = File.ReadAllText(path);
        var cfg = JsonSerializer.Deserialize<AppConfig>(json, new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true,
            ReadCommentHandling = JsonCommentHandling.Skip,
            AllowTrailingCommas = true,
        });
        return cfg ?? throw new InvalidOperationException("Konfiguraci se nepodařilo načíst.");
    }

    public void Validate()
    {
        if (string.IsNullOrWhiteSpace(ServisId))
            throw new InvalidOperationException("Chybí 'ServisId' v konfiguraci.");
        if (Sql is null || string.IsNullOrWhiteSpace(Sql.ConnectionString))
            throw new InvalidOperationException("Chybí 'Sql.ConnectionString'.");
        if (string.IsNullOrWhiteSpace(Sql.VozidlaQuery))
            throw new InvalidOperationException("Chybí 'Sql.VozidlaQuery'.");
        if (string.IsNullOrWhiteSpace(Sql.ZakazniciQuery))
            throw new InvalidOperationException("Chybí 'Sql.ZakazniciQuery'.");
        if (Firebase is null || string.IsNullOrWhiteSpace(Firebase.ProjectId))
            throw new InvalidOperationException("Chybí 'Firebase.ProjectId'.");
        if (string.IsNullOrWhiteSpace(Firebase.ServiceAccountPath))
            throw new InvalidOperationException("Chybí 'Firebase.ServiceAccountPath'.");
    }

    /// Cestu k service-account.json bere relativně k umístění appsettings.json.
    public string ResolveServiceAccountPath(string configPath)
    {
        var saPath = Firebase!.ServiceAccountPath!;
        if (!Path.IsPathRooted(saPath))
        {
            var baseDir = Path.GetDirectoryName(Path.GetFullPath(configPath))
                          ?? AppContext.BaseDirectory;
            saPath = Path.Combine(baseDir, saPath);
        }
        if (!File.Exists(saPath))
            throw new FileNotFoundException($"Service account klíč nenalezen: {saPath}");
        return saPath;
    }
}

sealed class SqlConfig
{
    public string? ConnectionString { get; set; }
    public string? VozidlaQuery { get; set; }
    public string? ZakazniciQuery { get; set; }
}

sealed class FirebaseConfig
{
    public string? ProjectId { get; set; }
    public string? ServiceAccountPath { get; set; }
}


// ═══════════════════════════════════════════════════════════════════════════
//  Logování (konzole + soubor torkis-sync.log vedle .exe)
// ═══════════════════════════════════════════════════════════════════════════
static class Log
{
    private static readonly string LogPath =
        Path.Combine(AppContext.BaseDirectory, "torkis-sync.log");
    private static readonly object Gate = new();

    public static void Info(string msg) => Write("INFO", msg);
    public static void Error(string msg) => Write("ERR ", msg);

    private static void Write(string level, string msg)
    {
        var line = $"{DateTime.Now:yyyy-MM-dd HH:mm:ss} [{level}] {msg}";
        Console.WriteLine(line);
        try
        {
            lock (Gate)
                File.AppendAllText(LogPath, line + Environment.NewLine);
        }
        catch { /* logování do souboru je best-effort */ }
    }
}
