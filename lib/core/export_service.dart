import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

enum ExportEntity { zakaznici, vozidla, zakazky }

enum ExportFormat { csv, json }

/// Stažení a export dat ze Firestore do CSV nebo JSON, sdílení přes share sheet.
class ExportService {
  // Formát data v exportu
  static final _datumFmt = DateFormat('dd.MM.yyyy HH:mm');

  // ── Hlavní vstupní bod ────────────────────────────────────────────────────

  static Future<void> export({
    required BuildContext context,
    required String servisId,
    required ExportEntity entity,
    required ExportFormat format,
  }) async {
    // Zobraz progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _ExportProgressDialog(),
    );

    try {
      final List<Map<String, dynamic>> rows;
      final String nazev;
      final List<String> csvHlavicka;

      switch (entity) {
        case ExportEntity.zakaznici:
          rows = await _nactiZakazniky(servisId);
          nazev = 'zakaznici';
          csvHlavicka = _zakazniciHlavicka;
        case ExportEntity.vozidla:
          rows = await _nactiVozidla(servisId);
          nazev = 'vozidla';
          csvHlavicka = _vozidlaHlavicka;
        case ExportEntity.zakazky:
          rows = await _nactiZakazky(servisId);
          nazev = 'zakazky';
          csvHlavicka = _zakazkyHlavicka;
      }

      final datum = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final pripona = format == ExportFormat.csv ? 'csv' : 'json';
      final soubor = '${nazev}_$datum.$pripona';

      final String obsah;
      if (format == ExportFormat.csv) {
        obsah = _buildCsv(csvHlavicka, rows);
      } else {
        obsah = const JsonEncoder.withIndent('  ').convert(rows);
      }

      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/$soubor';
      await File(path).writeAsString(obsah, encoding: utf8);

      if (context.mounted) Navigator.of(context).pop(); // zavři progress

      await Share.shareXFiles(
        [XFile(path)],
        subject: 'Export TORKIS — $soubor',
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Export selhal: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  // ── Načtení dat ──────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> _nactiZakazniky(
      String servisId) async {
    final snap = await FirebaseFirestore.instance
        .collection('zakaznici')
        .where('servis_id', isEqualTo: servisId)
        .get();
    return snap.docs.map((d) {
      final data = d.data();
      return {
        'id_zakaznika': _s(data['id_zakaznika']),
        'jmeno': _s(data['jmeno']),
        'ico': _s(data['ico']),
        'pravni_forma': _s(data['pravni_forma']),
        'ulice': _s(data['ulice']),
        'mesto': _s(data['mesto']),
        'psc': _s(data['psc']),
        'telefon': _s(data['telefon']),
        'email': _s(data['email']),
      };
    }).toList();
  }

  static Future<List<Map<String, dynamic>>> _nactiVozidla(
      String servisId) async {
    final snap = await FirebaseFirestore.instance
        .collection('vozidla')
        .where('servis_id', isEqualTo: servisId)
        .get();
    return snap.docs.map((d) {
      final data = d.data();
      return {
        'spz': _s(data['spz']),
        'zeme_registrace': _s(data['zeme_registrace']),
        'vin': _s(data['vin']),
        'znacka': _s(data['znacka']),
        'model': _s(data['model']),
        'rok_vyroby': _s(data['rok_vyroby']),
        'motorizace': _s(data['motorizace']),
        'palivo': _s(data['palivo']),
        'prevodovka': _s(data['prevodovka']),
        'typ_karoserie': _s(data['typ_karoserie']),
        'barva': _s(data['barva']),
        'vykon_kw': _s(data['vykon_kw']),
        'pocet_mist': _s(data['pocet_mist']),
        'stk_mesic': _s(data['stk_mesic']),
        'stk_rok': _s(data['stk_rok']),
        'tachometr': _s(data['tachometr']),
        'zakaznik_id': _s(data['zakaznik_id']),
      };
    }).toList();
  }

  static Future<List<Map<String, dynamic>>> _nactiZakazky(
      String servisId) async {
    final snap = await FirebaseFirestore.instance
        .collection('zakazky')
        .where('servis_id', isEqualTo: servisId)
        .get();
    return snap.docs.map((d) {
      final data = d.data();
      final zakaznik =
          data['zakaznik'] as Map<String, dynamic>? ?? {};
      final stavV =
          data['stav_vozidla'] as Map<String, dynamic>? ?? {};
      final pozadavky =
          (data['pozadavky_zakaznika'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .join('; ');
      final poskozeni =
          (stavV['poskozeni'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .join('; ');
      return {
        'cislo_zakazky': _s(data['cislo_zakazky']),
        'datum_prijeti': _ts(data['cas_prijeti']),
        'typ_zaznamu': _s(data['typ_zaznamu']),
        'stav_zakazky': _s(data['stav_zakazky']),
        'spz': _s(data['spz']),
        'vin': _s(data['vin']),
        'znacka': _s(data['znacka']),
        'model': _s(data['model']),
        'rok_vyroby': _s(data['rok_vyroby']),
        'zakaznik_jmeno': _s(zakaznik['jmeno']),
        'zakaznik_telefon': _s(zakaznik['telefon']),
        'zakaznik_email': _s(zakaznik['email']),
        'tachometr': _s(stavV['tachometr']),
        'stav_nadrze_pct': _s(stavV['nadrz']),
        'poskozeni': poskozeni,
        'pozadavky': pozadavky,
        'poznamky': _s(data['poznamky']),
      };
    }).toList();
  }

  // ── CSV builder ──────────────────────────────────────────────────────────

  // UTF-8 BOM zajišťuje správné otevření v Excelu
  static String _buildCsv(
      List<String> hlavicka, List<Map<String, dynamic>> rows) {
    final buf = StringBuffer('﻿'); // BOM
    buf.writeln(hlavicka.map(_csvEsc).join(','));
    for (final row in rows) {
      buf.writeln(hlavicka
          .map((k) => _csvEsc(row[k]?.toString() ?? ''))
          .join(','));
    }
    return buf.toString();
  }

  // Escapuje hodnotu pro CSV: obalí uvozovkami pokud obsahuje čárku, newline nebo uvozovku
  static String _csvEsc(String v) {
    if (v.contains(',') || v.contains('"') || v.contains('\n')) {
      return '"${v.replaceAll('"', '""')}"';
    }
    return v;
  }

  // ── Pomocné konverze ─────────────────────────────────────────────────────

  static String _s(dynamic v) => v?.toString() ?? '';

  static String _ts(dynamic v) {
    if (v == null) return '';
    try {
      return _datumFmt.format((v as Timestamp).toDate());
    } catch (_) {
      return '';
    }
  }

  // ── CSV hlavičky (klíče = pole v mapě + popisné labely) ─────────────────

  static const List<String> _zakazniciHlavicka = [
    'id_zakaznika',
    'jmeno',
    'ico',
    'pravni_forma',
    'ulice',
    'mesto',
    'psc',
    'telefon',
    'email',
  ];

  static const List<String> _vozidlaHlavicka = [
    'spz',
    'zeme_registrace',
    'vin',
    'znacka',
    'model',
    'rok_vyroby',
    'motorizace',
    'palivo',
    'prevodovka',
    'typ_karoserie',
    'barva',
    'vykon_kw',
    'pocet_mist',
    'stk_mesic',
    'stk_rok',
    'tachometr',
    'zakaznik_id',
  ];

  static const List<String> _zakazkyHlavicka = [
    'cislo_zakazky',
    'datum_prijeti',
    'typ_zaznamu',
    'stav_zakazky',
    'spz',
    'vin',
    'znacka',
    'model',
    'rok_vyroby',
    'zakaznik_jmeno',
    'zakaznik_telefon',
    'zakaznik_email',
    'tachometr',
    'stav_nadrze_pct',
    'poskozeni',
    'pozadavky',
    'poznamky',
  ];
}

// ── Progress dialog ───────────────────────────────────────────────────────

class _ExportProgressDialog extends StatelessWidget {
  const _ExportProgressDialog();

  @override
  Widget build(BuildContext context) {
    return const AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 20),
          Text('Exportuji data…'),
        ],
      ),
    );
  }
}
