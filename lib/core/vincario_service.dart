import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

/// Výsledek dekódování VINu přes Vincario API 3.2.
/// Zvládá tři formáty odpovědi: decode jako Map, decode jako List
/// objektů {label, value}, nebo hodnoty na root úrovni JSONu.
class VincarioResult {
  final Map<String, dynamic> raw;
  const VincarioResult(this.raw);

  /// Hodnota pole podle labelu (např. 'Make', 'Engine Power (kW)').
  String field(String key) {
    final decode = raw['decode'];
    if (decode is Map) {
      final v = decode[key]?.toString() ?? '';
      if (v.isNotEmpty) return v;
    } else if (decode is List) {
      for (final item in decode) {
        if (item is Map && item['label']?.toString() == key) {
          return item['value']?.toString() ?? '';
        }
      }
    }
    return raw[key]?.toString() ?? '';
  }

  /// Všechny vrácené dvojice label/hodnota — pro náhledový výpis v modulu.
  List<({String label, String value})> get vsechnyUdaje {
    final out = <({String label, String value})>[];
    final decode = raw['decode'];
    if (decode is List) {
      for (final item in decode) {
        if (item is Map) {
          final label = item['label']?.toString() ?? '';
          final value = item['value']?.toString() ?? '';
          if (label.isNotEmpty && value.isNotEmpty) {
            out.add((label: label, value: value));
          }
        }
      }
    } else if (decode is Map) {
      decode.forEach((k, v) {
        final value = v?.toString() ?? '';
        if (value.isNotEmpty) out.add((label: k.toString(), value: value));
      });
    }
    return out;
  }
}

class VincarioException implements Exception {
  final String message;
  const VincarioException(this.message);
  @override
  String toString() => message;
}

/// Volání Vincario API 3.2 /decode. Sdílí příjem vozidla i modul VIN dekodér.
class VincarioService {
  /// Kontrolní součet: prvních 10 znaků SHA1 z "{VIN}|{id}|{API_KEY}|{SECRET}".
  static String _controlSum(
      String vin, String id, String apiKey, String secret) {
    final input = '$vin|$id|$apiKey|$secret';
    return sha1.convert(utf8.encode(input)).toString().substring(0, 10);
  }

  static Future<VincarioResult> decode({
    required String vin,
    required String apiKey,
    required String secretKey,
  }) async {
    final cs = _controlSum(vin, 'decode', apiKey, secretKey);
    final uri = Uri.parse(
        'https://api.vincario.com/3.2/$apiKey/$cs/decode/$vin.json');
    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw VincarioException('Vincario API chyba ${resp.statusCode}.');
    }
    final data = json.decode(resp.body) as Map<String, dynamic>;
    return VincarioResult(data);
  }
}
