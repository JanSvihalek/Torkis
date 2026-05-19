import 'package:flutter/material.dart';

import '../../core/design_tokens.dart';

/// Sdílené pomocné widgety pro wizard příjmu vozidla.
/// Používají TORKIS design tokens — sjednocený vizuál se zbytkem aplikace.

const _radius = TokRadius.md;

InputDecoration _buildDecoration({
  required IconData icon,
  required bool isDark,
  Widget? suffix,
  String? hint,
}) {
  final tok = TorkisTokens(isDark ? Brightness.dark : Brightness.light);
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      color: tok.textMuted,
      fontSize: 14,
    ),
    prefixIcon: Icon(icon, color: TokColors.accent, size: 18),
    suffixIcon: suffix,
    filled: true,
    fillColor: isDark
        ? Colors.white.withValues(alpha: 0.06)
        : TokColors.paper,
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(_radius),
      borderSide: BorderSide(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : tok.line),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(_radius),
      borderSide: const BorderSide(color: TokColors.accent, width: 1.5),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(_radius),
      borderSide: BorderSide(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : tok.line),
    ),
  );
}

Widget _labelText(String label, bool isDark) {
  final tok = TorkisTokens(isDark ? Brightness.dark : Brightness.light);
  return Padding(
    padding: const EdgeInsets.only(bottom: 6, left: 2),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: tok.textSecondary,
        letterSpacing: 0.2,
      ),
    ),
  );
}

Widget buildInput(
  String label,
  IconData icon,
  TextEditingController controller,
  bool isDark, {
  bool caps = false,
  bool numbersOnly = false,
  Widget? customSuffix,
  void Function(TextEditingController, bool)? onScan,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _labelText(label, isDark),
      TextField(
        controller: controller,
        textCapitalization:
            caps ? TextCapitalization.characters : TextCapitalization.none,
        keyboardType:
            numbersOnly ? TextInputType.number : TextInputType.text,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : TokColors.ink,
        ),
        cursorColor: TokColors.accent,
        decoration: _buildDecoration(
          icon: icon,
          isDark: isDark,
          suffix: customSuffix ??
              (onScan != null
                  ? IconButton(
                      icon: const Icon(Icons.qr_code_scanner_rounded,
                          color: TokColors.steel, size: 18),
                      onPressed: () => onScan(controller, numbersOnly),
                    )
                  : null),
        ),
      ),
    ],
  );
}

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
      _labelText(label, isDark),
      DropdownButtonFormField<String>(
        initialValue: value,
        items: items
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.white : TokColors.ink,
                      )),
                ))
            .toList(),
        onChanged: onChanged,
        style: TextStyle(
          fontSize: 15,
          color: isDark ? Colors.white : TokColors.ink,
        ),
        icon: const Icon(Icons.keyboard_arrow_down_rounded,
            color: TokColors.steel, size: 20),
        dropdownColor: isDark ? TokColors.darkSurface2 : TokColors.paper,
        decoration: _buildDecoration(icon: icon, isDark: isDark),
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
  return TextField(
    controller: controller,
    keyboardType: type,
    style: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: isDark ? Colors.white : TokColors.ink,
    ),
    cursorColor: TokColors.accent,
    decoration: _buildDecoration(
      icon: icon,
      isDark: isDark,
      hint: hint,
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
    final tok = context.tok;
    final selectedEntry = predvolby.firstWhere(
      (p) => p['kod'] == telPredvolba,
      orElse: () => predvolby.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelText('Telefonní číslo', isDark),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(_radius),
                onTap: () => showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (_) => Container(
                    decoration: BoxDecoration(
                      color: tok.surface,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20)),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: tok.line,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        Text(
                          'Vyberte předvolbu',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: tok.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...predvolby.map((p) => ListTile(
                              leading: Text(p['vlajka']!,
                                  style: const TextStyle(fontSize: 24)),
                              title: Text(p['nazev']!,
                                  style: TextStyle(
                                    color: tok.textPrimary,
                                    fontSize: 14,
                                  )),
                              trailing: Text(p['kod']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: TokColors.accent,
                                    fontSize: 13,
                                  )),
                              selected: p['kod'] == telPredvolba,
                              selectedColor: TokColors.accent,
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
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : TokColors.paper,
                    borderRadius: BorderRadius.circular(_radius),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : tok.line,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(selectedEntry['vlajka']!,
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 6),
                      Text(
                        selectedEntry['kod']!,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: isDark ? Colors.white : TokColors.ink,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.arrow_drop_down,
                          size: 18, color: tok.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: telefonController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : TokColors.ink,
                  ),
                  cursorColor: TokColors.accent,
                  decoration: _buildDecoration(
                    icon: Icons.phone_outlined,
                    isDark: isDark,
                    hint: 'Telefonní číslo',
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
