import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

Widget buildBadge(IconData icon, String label, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w500)),
      ],
    ),
  );
}

/// Datum + čas: "dd.MM.yyyy HH:mm"
String formatDateTimeCz(dynamic timestamp, {String fallback = '-'}) {
  if (timestamp == null) return fallback;
  return DateFormat('dd.MM.yyyy HH:mm')
      .format((timestamp as Timestamp).toDate());
}

Widget buildZamcenyModul(BuildContext context, {required String nazevModulu}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Modul $nazevModulu není součástí vašeho předplatného.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
          ),
        ],
      ),
    ),
  );
}

/// Jen datum: "dd.MM.yyyy"
String formatDateCz(dynamic timestamp, {String fallback = '-'}) {
  if (timestamp == null) return fallback;
  return DateFormat('dd.MM.yyyy')
      .format((timestamp as Timestamp).toDate());
}
