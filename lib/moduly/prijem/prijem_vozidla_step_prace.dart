import 'package:flutter/material.dart';
import 'prijem_vozidla_helpers.dart';

/// Krok 5 – Požadované práce.
/// Rychlé čipy z katalogu úkonů + dynamický seznam textových polí.
class StepPrace extends StatelessWidget {
  final bool isDark;

  final bool isLoadingUkony;
  final List<String> rychleUkony;
  final List<TextEditingController> pozadavkyControllers;

  final VoidCallback onPridatUkon;
  final void Function(int index) onOdebratUkon;
  final void Function(String ukon) onRychlyUkonTap;

  const StepPrace({
    super.key,
    required this.isDark,
    required this.isLoadingUkony,
    required this.rychleUkony,
    required this.pozadavkyControllers,
    required this.onPridatUkon,
    required this.onOdebratUkon,
    required this.onRychlyUkonTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Požadované práce',
              style:
                  TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const Text('Na čem jsme se se zákazníkem domluvili?',
              style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 30),
          if (!isLoadingUkony && rychleUkony.isNotEmpty) ...[
            const Text('Rychlý výběr nejčastějších úkonů:',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: rychleUkony
                  .map((ukon) => ActionChip(
                      label: Text(ukon,
                          style: const TextStyle(fontSize: 13)),
                      backgroundColor: isDark
                          ? const Color(0xFF1E3A5F)
                          : Colors.blue.withValues(alpha: 0.05),
                      side: BorderSide(
                          color:
                              Colors.blue.withValues(alpha: 0.3)),
                      onPressed: () => onRychlyUkonTap(ukon)))
                  .toList(),
            ),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),
          ],
          const Text('Seznam požadavků k zakázce:',
              style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 20),
          ...List.generate(pozadavkyControllers.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                      child: buildInput(
                          'Úkon ${index + 1}',
                          Icons.build_circle_outlined,
                          pozadavkyControllers[index],
                          isDark)),
                  if (pozadavkyControllers.length > 1)
                    Padding(
                        padding: const EdgeInsets.only(
                            left: 10, bottom: 5),
                        child: IconButton(
                            icon: const Icon(
                                Icons.remove_circle_outline,
                                color: Colors.red,
                                size: 30),
                            onPressed: () => onOdebratUkon(index))),
                ],
              ),
            );
          }),
          const SizedBox(height: 10),
          TextButton.icon(
              onPressed: onPridatUkon,
              icon: const Icon(Icons.add),
              label: const Text('Přidat jiný úkon',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16))),
        ],
      ),
    );
  }
}
