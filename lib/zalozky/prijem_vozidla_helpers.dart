// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';

/// Sdílené pomocné widgety pro wizard příjmu vozidla.
/// Používají se ve všech krocích (StepVozidlo, StepZakaznik, StepCheck, StepPrace).

Widget buildInput(
  String label,
  IconData icon,
  TextEditingController controller,
  bool isDark, {
  bool caps = false,
  bool numbersOnly = false,
  Widget? customSuffix,
  void Function(TextEditingController, bool)? onScan,
}) =>
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
              ],
              borderRadius: BorderRadius.circular(15)),
          child: TextField(
            controller: controller,
            textCapitalization:
                caps ? TextCapitalization.characters : TextCapitalization.none,
            keyboardType:
                numbersOnly ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
                prefixIcon: Icon(icon, color: Colors.blue),
                suffixIcon: customSuffix ??
                    (onScan != null
                        ? IconButton(
                            icon: const Icon(Icons.document_scanner),
                            onPressed: () => onScan(controller, numbersOnly))
                        : null),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                        color:
                            isDark ? Colors.grey[800]! : Colors.grey[300]!,
                        width: 1)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                        const BorderSide(color: Colors.blue, width: 2)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                        color:
                            isDark ? Colors.grey[800]! : Colors.grey[300]!,
                        width: 1))),
          ),
        ),
      ],
    );

Widget buildDropdown(
  String label,
  IconData icon,
  String value,
  List<String> items,
  ValueChanged<String?> onChanged,
  bool isDark,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.grey)),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
            boxShadow: [
              if (!isDark)
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
            ],
            borderRadius: BorderRadius.circular(15)),
        child: DropdownButtonFormField<String>(
          initialValue: value,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.blue),
              filled: true,
              fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                      color:
                          isDark ? Colors.grey[800]! : Colors.grey[300]!,
                      width: 1)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide:
                      const BorderSide(color: Colors.blue, width: 2)),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                      color:
                          isDark ? Colors.grey[800]! : Colors.grey[300]!,
                      width: 1))),
        ),
      ),
    ],
  );
}

Widget buildHalfInput(
  String hint,
  IconData icon,
  TextEditingController controller,
  bool isDark,
  TextInputType type,
) {
  return Container(
    decoration: BoxDecoration(
        boxShadow: [
          if (!isDark)
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
        ],
        borderRadius: BorderRadius.circular(15)),
    child: TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.blue, size: 20),
          filled: true,
          fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                  color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                  width: 1)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide:
                  const BorderSide(color: Colors.blue, width: 2)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                  color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                  width: 1)),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15)),
    ),
  );
}

/// Widget pro pole telefonního čísla s výběrem předvolby.
class PhoneFieldWidget extends StatelessWidget {
  final bool isDark;
  final String telPredvolba;
  final TextEditingController telefonController;
  final List<Map<String, String>> predvolby;
  final ValueChanged<String> onPredvolbaChanged;

  const PhoneFieldWidget({
    super.key,
    required this.isDark,
    required this.telPredvolba,
    required this.telefonController,
    required this.predvolby,
    required this.onPredvolbaChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selectedEntry = predvolby.firstWhere(
      (p) => p['kod'] == telPredvolba,
      orElse: () => predvolby.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Telefonní číslo',
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                  ],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () => showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (_) => Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1A1A1A)
                            : Colors.white,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(25)),
                      ),
                      padding:
                          const EdgeInsets.fromLTRB(20, 16, 20, 30),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius:
                                    BorderRadius.circular(10)),
                          ),
                          const Text('Vyberte předvolbu',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          ...predvolby.map((p) => ListTile(
                                leading: Text(p['vlajka']!,
                                    style:
                                        const TextStyle(fontSize: 24)),
                                title: Text(p['nazev']!),
                                trailing: Text(p['kod']!,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue)),
                                selected: p['kod'] == telPredvolba,
                                selectedColor: Colors.blue,
                                onTap: () {
                                  onPredvolbaChanged(p['kod']!);
                                  Navigator.pop(context);
                                },
                              )),
                        ],
                      ),
                    ),
                  ),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E1E1E)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                          color: isDark
                              ? Colors.grey[800]!
                              : Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(selectedEntry['vlajka']!,
                            style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 6),
                        Text(selectedEntry['kod']!,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_drop_down, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                    ],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextField(
                    controller: telefonController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Telefonní číslo',
                      prefixIcon:
                          const Icon(Icons.phone, color: Colors.blue),
                      filled: true,
                      fillColor:
                          isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                              color: isDark
                                  ? Colors.grey[800]!
                                  : Colors.grey[300]!,
                              width: 1)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                              color: Colors.blue, width: 2)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                              color: isDark
                                  ? Colors.grey[800]!
                                  : Colors.grey[300]!,
                              width: 1)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
