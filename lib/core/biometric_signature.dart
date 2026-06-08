import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Datový model pro dynamický biometrický podpis (AES-ekvivalent).
///
/// Zaznamenává nejen výsledný obrázek podpisu, ale i **dynamiku tahu** —
/// každý bod má časové razítko a (pokud to zařízení/stylus umí) tlak a
/// poloměr dotyku. Spolu s [SignatureSeal] vytváří podpis, který je
/// jednoznačně vázaný na podepisujícího (biometrie) a na přesný obsah
/// dokumentu (hash), takže jakákoli pozdější změna je detekovatelná.

/// Jeden zaznamenaný bod tahu.
class SignaturePoint {
  final double x;
  final double y;

  /// Čas v milisekundách od začátku prvního tahu.
  final int t;

  /// Tlak 0..1, pokud ho zařízení hlásí (stylus). U prstu bývá null/konstanta.
  final double? pressure;

  /// Poloměr dotykové plochy, pokud je k dispozici (proxy „tlaku" u prstu).
  final double? radius;

  const SignaturePoint({
    required this.x,
    required this.y,
    required this.t,
    this.pressure,
    this.radius,
  });

  Map<String, dynamic> toJson() => {
        'x': double.parse(x.toStringAsFixed(2)),
        'y': double.parse(y.toStringAsFixed(2)),
        't': t,
        if (pressure != null)
          'p': double.parse(pressure!.toStringAsFixed(3)),
        if (radius != null) 'r': double.parse(radius!.toStringAsFixed(2)),
      };

  factory SignaturePoint.fromJson(Map<String, dynamic> j) => SignaturePoint(
        x: (j['x'] as num).toDouble(),
        y: (j['y'] as num).toDouble(),
        t: (j['t'] as num).toInt(),
        pressure: (j['p'] as num?)?.toDouble(),
        radius: (j['r'] as num?)?.toDouble(),
      );
}

/// Jeden souvislý tah (od přiložení po zvednutí prstu/pera).
class SignatureStroke {
  final List<SignaturePoint> points;
  SignatureStroke({List<SignaturePoint>? points}) : points = points ?? [];

  Map<String, dynamic> toJson() =>
      {'body': points.map((p) => p.toJson()).toList()};

  factory SignatureStroke.fromJson(Map<String, dynamic> j) => SignatureStroke(
        points: (j['body'] as List)
            .map((e) => SignaturePoint.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// Kompletní biometrická data podpisu + prostředí, ve kterém vznikl.
class BiometricSignature {
  static const int schemaVersion = 1;

  final List<SignatureStroke> strokes;

  /// Rozměr plátna v logických pixelech (pro reprodukovatelnost souřadnic).
  final double canvasWidth;
  final double canvasHeight;

  /// Kdy byl podpis dokončen (epoch ms, UTC).
  final int capturedAtMs;

  // Prostředí podpisu
  final String deviceModel;
  final String platform;
  final String appVersion;
  final String locale;

  BiometricSignature({
    required this.strokes,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.capturedAtMs,
    required this.deviceModel,
    required this.platform,
    required this.appVersion,
    required this.locale,
  });

  // ── Odvozené metriky ──────────────────────────────────────────────────

  int get pointCount =>
      strokes.fold(0, (sum, s) => sum + s.points.length);

  int get strokeCount => strokes.length;

  /// Celková doba podpisu v ms (od prvního po poslední bod).
  int get durationMs {
    int maxT = 0;
    for (final s in strokes) {
      for (final p in s.points) {
        if (p.t > maxT) maxT = p.t;
      }
    }
    return maxT;
  }

  /// True, pokud aspoň jeden bod nese reálný (nekonstantní) tlak.
  bool get hasPressure {
    final vals = <double>[];
    for (final s in strokes) {
      for (final p in s.points) {
        if (p.pressure != null) vals.add(p.pressure!);
      }
    }
    if (vals.length < 2) return false;
    final first = vals.first;
    return vals.any((v) => (v - first).abs() > 0.01);
  }

  /// Plná biometrická data — ukládají se jako blob do Storage.
  Map<String, dynamic> toJson() => {
        'verze': schemaVersion,
        'zachyceno_at': capturedAtMs,
        'canvas': {'w': canvasWidth, 'h': canvasHeight},
        'zarizeni': deviceModel,
        'platforma': platform,
        'app_verze': appVersion,
        'jazyk': locale,
        'metriky': {
          'pocet_tahu': strokeCount,
          'pocet_bodu': pointCount,
          'trvani_ms': durationMs,
          'ma_tlak': hasPressure,
        },
        'tahy': strokes.map((s) => s.toJson()).toList(),
      };

  factory BiometricSignature.fromJson(Map<String, dynamic> j) =>
      BiometricSignature(
        strokes: (j['tahy'] as List)
            .map((e) => SignatureStroke.fromJson(e as Map<String, dynamic>))
            .toList(),
        canvasWidth: (j['canvas']?['w'] as num?)?.toDouble() ?? 0,
        canvasHeight: (j['canvas']?['h'] as num?)?.toDouble() ?? 0,
        capturedAtMs: (j['zachyceno_at'] as num?)?.toInt() ?? 0,
        deviceModel: j['zarizeni'] as String? ?? '',
        platform: j['platforma'] as String? ?? '',
        appVersion: j['app_verze'] as String? ?? '',
        locale: j['jazyk'] as String? ?? '',
      );

  String encode() => jsonEncode(toJson());
}

/// Tamper-evident pečeť: SHA-256 hash, který váže podpis na přesný obsah
/// dokumentu i na biometrická data. Uloží se do Firestore vedle zakázky.
///
/// Při sporu se znovu sestaví kanonický obsah dokumentu, spočítá hash a
/// porovná s [documentHash]. Pokud se cokoli v dokumentu změnilo, hashe
/// nebudou sedět → změna je prokazatelná.
class SignatureSeal {
  static const int version = 1;
  static const String algorithm = 'SHA-256';

  final String documentHash;
  final String biometricHash;
  final int signedAtMs;
  final String consentText;

  // Kopie klíčových metadat (pro rychlý audit bez stahování blobu)
  final String deviceModel;
  final String platform;
  final String appVersion;
  final int strokeCount;
  final int pointCount;
  final int durationMs;
  final bool hasPressure;

  SignatureSeal({
    required this.documentHash,
    required this.biometricHash,
    required this.signedAtMs,
    required this.consentText,
    required this.deviceModel,
    required this.platform,
    required this.appVersion,
    required this.strokeCount,
    required this.pointCount,
    required this.durationMs,
    required this.hasPressure,
  });

  /// Sestaví pečeť z biometrie + obsahu dokumentu, který zákazník stvrdil.
  ///
  /// [documentContent] musí být deterministicky serializovatelná mapa
  /// odrážející přesně to, co zákazník na shrnutí viděl.
  factory SignatureSeal.create({
    required BiometricSignature biometrics,
    required Map<String, dynamic> documentContent,
    required String consentText,
  }) {
    final biometricJson = biometrics.encode();
    final biometricHash = _sha256Hex(biometricJson);

    // Kanonický payload, nad kterým se počítá hash dokumentu.
    final payload = <String, dynamic>{
      'verze': version,
      'dokument': documentContent,
      'souhlas': consentText,
      'biometrie_hash': biometricHash,
      'podepsano_at': biometrics.capturedAtMs,
    };
    final documentHash = _sha256Hex(_canonicalJson(payload));

    return SignatureSeal(
      documentHash: documentHash,
      biometricHash: biometricHash,
      signedAtMs: biometrics.capturedAtMs,
      consentText: consentText,
      deviceModel: biometrics.deviceModel,
      platform: biometrics.platform,
      appVersion: biometrics.appVersion,
      strokeCount: biometrics.strokeCount,
      pointCount: biometrics.pointCount,
      durationMs: biometrics.durationMs,
      hasPressure: biometrics.hasPressure,
    );
  }

  Map<String, dynamic> toJson() => {
        'verze': version,
        'algo': algorithm,
        'dokument_hash': documentHash,
        'biometrie_hash': biometricHash,
        'podepsano_at': signedAtMs,
        'souhlas_text': consentText,
        'zarizeni': deviceModel,
        'platforma': platform,
        'app_verze': appVersion,
        'pocet_tahu': strokeCount,
        'pocet_bodu': pointCount,
        'trvani_ms': durationMs,
        'ma_tlak': hasPressure,
      };

  static String _sha256Hex(String input) =>
      sha256.convert(utf8.encode(input)).toString();

  /// Deterministická JSON serializace s rekurzivně seřazenými klíči — aby
  /// stejný obsah dal vždy stejný hash bez ohledu na pořadí vložení.
  static String _canonicalJson(dynamic value) {
    final buffer = StringBuffer();
    _writeCanonical(value, buffer);
    return buffer.toString();
  }

  static void _writeCanonical(dynamic value, StringBuffer out) {
    if (value is Map) {
      final keys = value.keys.map((k) => k.toString()).toList()..sort();
      out.write('{');
      for (var i = 0; i < keys.length; i++) {
        if (i > 0) out.write(',');
        out.write(jsonEncode(keys[i]));
        out.write(':');
        _writeCanonical(value[keys[i]], out);
      }
      out.write('}');
    } else if (value is List) {
      out.write('[');
      for (var i = 0; i < value.length; i++) {
        if (i > 0) out.write(',');
        _writeCanonical(value[i], out);
      }
      out.write(']');
    } else {
      out.write(jsonEncode(value));
    }
  }
}
