import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart' show XFile;
import 'package:path_provider/path_provider.dart';

/// Trvalá záloha rozdělané zakázky příjmu (koncept), aby uživatel nepřišel
/// o data při pádu spojení nebo aplikace během odesílání. Drží snapshot
/// formuláře + trvalé kopie fotek (mimo dočasný adresář, který OS čistí).
class KonceptZakazky {
  /// Snapshot formuláře (texty kontrolérů + výběry). Viz prijem_vozidla.dart.
  final Map<String, dynamic> formular;

  /// Trvalé cesty k fotkám podle kategorie.
  final Map<String, List<String>> fotkyDleKategorie;

  /// Cesta k uloženému schématu poškození (PNG), pokud bylo nakresleno.
  final String? schemaPath;

  KonceptZakazky({
    required this.formular,
    required this.fotkyDleKategorie,
    this.schemaPath,
  });

  Map<String, dynamic> toJson() => {
        'formular': formular,
        'fotky': fotkyDleKategorie,
        'schema': schemaPath,
      };

  factory KonceptZakazky.fromJson(Map<String, dynamic> j) => KonceptZakazky(
        formular: Map<String, dynamic>.from(j['formular'] ?? {}),
        fotkyDleKategorie:
            (j['fotky'] as Map<String, dynamic>? ?? {}).map(
          (k, v) => MapEntry(k, List<String>.from(v ?? const [])),
        ),
        schemaPath: j['schema'] as String?,
      );

  /// Koncept je prázdný, když nemá vyplněné nic podstatného ani žádnou fotku.
  bool get jePrazdny {
    final maFotky =
        fotkyDleKategorie.values.any((l) => l.isNotEmpty);
    final maObsah = formular.values.any((v) {
      if (v is String) return v.trim().isNotEmpty;
      if (v is List) return v.isNotEmpty;
      return false;
    });
    return !maFotky && !maObsah;
  }
}

/// Práce s jediným rozpracovaným konceptem v trvalém úložišti aplikace.
class KonceptService {
  static const _slozka = 'koncept_prijem';
  static const _jsonNazev = 'koncept.json';
  static int _citac = 0;

  static Future<Directory> _adresar() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/$_slozka');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static Future<Directory> _adresarFotek() async {
    final base = await _adresar();
    final dir = Directory('${base.path}/fotky');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Zkopíruje pořízenou fotku z dočasného umístění do trvalého adresáře
  /// konceptu a vrátí trvalou cestu.
  static Future<String> ulozFotku(XFile zdroj, String kategorie) async {
    final dir = await _adresarFotek();
    final nazev =
        '${kategorie}_${DateTime.now().microsecondsSinceEpoch}_${_citac++}.jpg';
    final cil = '${dir.path}/$nazev';
    await zdroj.saveTo(cil);
    return cil;
  }

  /// Uloží schéma poškození (PNG) do konceptu a vrátí cestu.
  static Future<String> ulozSchema(Uint8List bajty) async {
    final dir = await _adresar();
    final cesta = '${dir.path}/schema_poskozeni.png';
    await File(cesta).writeAsBytes(bajty);
    return cesta;
  }

  static Future<void> ulozKoncept(KonceptZakazky k) async {
    final dir = await _adresar();
    final f = File('${dir.path}/$_jsonNazev');
    await f.writeAsString(jsonEncode(k.toJson()));
  }

  /// Vrátí uložený koncept, pokud existuje a není prázdný; jinak null.
  static Future<KonceptZakazky?> nactiKoncept() async {
    try {
      final dir = await _adresar();
      final f = File('${dir.path}/$_jsonNazev');
      if (!await f.exists()) return null;
      final k = KonceptZakazky.fromJson(
          jsonDecode(await f.readAsString()) as Map<String, dynamic>);
      return k.jePrazdny ? null : k;
    } catch (_) {
      return null;
    }
  }

  /// Smaže celý koncept (JSON i fotky) — volá se po úspěšném odeslání nebo
  /// při zahození.
  static Future<void> smazKoncept() async {
    try {
      final dir = await _adresar();
      if (await dir.exists()) await dir.delete(recursive: true);
    } catch (_) {}
  }
}
