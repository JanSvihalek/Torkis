import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
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

/// Výsledek Vehicle Market Value API.
class VincarioMarketValue {
  final Map<String, dynamic> raw;
  const VincarioMarketValue(this.raw);

  String get make => raw['vehicle']?['make']?.toString() ?? '';
  String get model => raw['vehicle']?['model']?.toString() ?? '';
  int? get modelYear => raw['vehicle']?['model_year'] as int?;
  String get logoUrl => raw['vehicle']?['make_logo']?.toString() ?? '';

  String get periodFrom => (raw['period'] as Map?)?['from']?.toString() ?? '';
  String get periodTo => (raw['period'] as Map?)?['to']?.toString() ?? '';

  Map<String, dynamic>? get europePrice =>
      ((raw['market_price'] as Map?)?['europe']) as Map<String, dynamic>?;
  Map<String, dynamic>? get europeOdometer =>
      ((raw['market_odometer'] as Map?)?['europe']) as Map<String, dynamic>?;

  List<Map<String, dynamic>> get records {
    final list = raw['records'] as List?;
    if (list == null) return [];
    return list.whereType<Map<String, dynamic>>().toList();
  }
}

class VincarioException implements Exception {
  final String message;
  const VincarioException(this.message);
  @override
  String toString() => message;
}

/// Volání Vincario API přes Cloud Functions. Tajný sdílený klíč je pouze na
/// serveru; klient jen volá callable funkce, které vynucují měsíční limity.
/// Sdílí příjem vozidla i modul VIN dekodér.
class VincarioService {
  // Region musí odpovídat nasazení funkcí (functions/index.js → REGION).
  static final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'europe-west3');

  /// Rekurzivně převede odpověď callable funkce (Map<Object?,Object?>) na
  /// správně typované Map<String,dynamic> / List — jinak by selhaly přetypování
  /// jako `whereType<Map<String, dynamic>>()` u tržních dat.
  static dynamic _deepConvert(dynamic value) {
    if (value is Map) {
      return value.map(
          (k, v) => MapEntry(k.toString(), _deepConvert(v)));
    }
    if (value is List) {
      return value.map(_deepConvert).toList();
    }
    return value;
  }

  /// Přemapuje výjimky z Cloud Functions na čitelnou hlášku (vč. vyčerpaného
  /// limitu — kód 'resource-exhausted').
  static VincarioException _mapError(Object e) {
    if (e is FirebaseFunctionsException) {
      return VincarioException(e.message ?? 'Chyba serveru (${e.code}).');
    }
    return VincarioException(e.toString());
  }

  /// Načte aktuální kurz EUR → CZK z ČNB API (veřejné, bez klíče).
  static Future<double> kurzEurCzk() async {
    final resp = await http.get(
        Uri.parse('https://api.cnb.cz/cnbapi/exrates/daily?lang=EN'));
    if (resp.statusCode != 200) {
      throw VincarioException('ČNB API chyba ${resp.statusCode}.');
    }
    final data = json.decode(resp.body) as Map<String, dynamic>;
    final rates = (data['rates'] as List?)?.whereType<Map>() ?? [];
    for (final r in rates) {
      if (r['currencyCode'] == 'EUR') {
        final amount = (r['amount'] as num?)?.toDouble() ?? 1.0;
        final rate = (r['rate'] as num?)?.toDouble();
        if (rate != null) return rate / amount;
      }
    }
    throw const VincarioException('Kurz EUR/CZK nebyl nalezen.');
  }

  /// Tržní hodnota vozidla. `fromCache` = true → nepočítalo se do limitu.
  static Future<({VincarioMarketValue result, bool fromCache})> marketValue({
    required String vin,
  }) async {
    try {
      final resp =
          await _functions.httpsCallable('marketValueVin').call({'vin': vin});
      final data = Map<String, dynamic>.from(resp.data as Map);
      final raw = _deepConvert(data['raw']) as Map<String, dynamic>;
      return (
        result: VincarioMarketValue(raw),
        fromCache: data['fromCache'] == true,
      );
    } catch (e) {
      throw _mapError(e);
    }
  }

  /// Dekódování VINu. `fromCache` = true → nepočítalo se do limitu.
  static Future<({VincarioResult result, bool fromCache})> decode({
    required String vin,
  }) async {
    try {
      final resp =
          await _functions.httpsCallable('decodeVin').call({'vin': vin});
      final data = Map<String, dynamic>.from(resp.data as Map);
      final raw = _deepConvert(data['raw']) as Map<String, dynamic>;
      return (
        result: VincarioResult(raw),
        fromCache: data['fromCache'] == true,
      );
    } catch (e) {
      throw _mapError(e);
    }
  }
}
