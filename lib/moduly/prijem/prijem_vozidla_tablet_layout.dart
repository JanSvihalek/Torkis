import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/design_tokens.dart';

const double kTabletBreakpoint = 800.0;
const double kSidebarWidth = 210.0;
const double kPreviewPanelWidth = 240.0;

// ── Sidebar ───────────────────────────────────────────────────────────────────

class PrijemTabletSidebar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepLabels;
  final ValueChanged<int> onStepTap;

  const PrijemTabletSidebar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepLabels,
    required this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: kSidebarWidth,
      color: TokColors.ink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  TokSpace.lg, TokSpace.lg, TokSpace.lg, TokSpace.md),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: TokColors.accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('T',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text('Torkis',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                ],
              ),
            ),
          ),
          Divider(
              color: TokColors.darkLine, height: 1, indent: 0, endIndent: 0),
          const SizedBox(height: TokSpace.md),
          Expanded(
            child: ListView.builder(
              padding:
                  const EdgeInsets.symmetric(horizontal: TokSpace.md),
              itemCount: totalSteps,
              itemBuilder: (ctx, i) => _SidebarStepTile(
                index: i,
                label: stepLabels[i],
                isActive: i == currentStep,
                isCompleted: i < currentStep,
                onTap: i <= currentStep ? () => onStepTap(i) : null,
              ),
            ),
          ),
          Divider(
              color: TokColors.darkLine, height: 1, indent: 0, endIndent: 0),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(TokSpace.lg),
              child: _UserInitialsChip(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarStepTile extends StatelessWidget {
  final int index;
  final String label;
  final bool isActive;
  final bool isCompleted;
  final VoidCallback? onTap;

  const _SidebarStepTile({
    required this.index,
    required this.label,
    required this.isActive,
    required this.isCompleted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: isActive
            ? TokColors.accent.withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(TokRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(TokRadius.md),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: TokSpace.md, vertical: 10),
            child: Row(
              children: [
                _StepBadge(
                    index: index,
                    isActive: isActive,
                    isCompleted: isCompleted),
                const SizedBox(width: TokSpace.sm),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isActive
                          ? Colors.white
                          : TokColors.steelSoft,
                      fontSize: 13,
                      fontWeight: isActive
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
                if (isActive)
                  const Icon(Icons.chevron_right_rounded,
                      size: 16, color: TokColors.steelSoft),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepBadge extends StatelessWidget {
  final int index;
  final bool isActive;
  final bool isCompleted;

  const _StepBadge(
      {required this.index,
      required this.isActive,
      required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    Color bg;
    if (isActive) {
      bg = TokColors.accent;
    } else if (isCompleted) {
      bg = TokColors.success;
    } else {
      bg = TokColors.darkSurface2;
    }
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check_rounded,
                size: 12, color: Colors.white)
            : Text(
                '${index + 1}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}

class _UserInitialsChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final initials = _initials(user);
    return CircleAvatar(
      radius: 14,
      backgroundColor: TokColors.accent.withValues(alpha: 0.2),
      child: Text(
        initials,
        style: const TextStyle(
            color: TokColors.accent,
            fontSize: 11,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  String _initials(User? user) {
    if (user == null) return '?';
    final name = user.displayName;
    if (name != null && name.isNotEmpty) {
      final parts = name.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      }
      return name[0].toUpperCase();
    }
    final email = user.email;
    if (email != null && email.isNotEmpty) return email[0].toUpperCase();
    return '?';
  }
}

// ── Vehicle Preview Panel ─────────────────────────────────────────────────────

class PrijemVehiclePreviewPanel extends StatelessWidget {
  final String spz;
  final String vin;
  final String cisloZakazky;
  final String znacka;
  final String model;
  final String rokVyroby;
  final bool isDark;

  const PrijemVehiclePreviewPanel({
    super.key,
    required this.spz,
    required this.vin,
    required this.cisloZakazky,
    required this.znacka,
    required this.model,
    required this.rokVyroby,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final tok = TorkisTokens(isDark ? Brightness.dark : Brightness.light);
    final vehicleTitle = [znacka, model]
        .where((s) => s.isNotEmpty)
        .join(' ');
    final hasData = spz.isNotEmpty ||
        vin.isNotEmpty ||
        cisloZakazky.isNotEmpty ||
        vehicleTitle.isNotEmpty;

    return Container(
      width: kPreviewPanelWidth,
      decoration: BoxDecoration(
        color: isDark ? TokColors.darkSurface : TokColors.bg,
        border: Border(left: BorderSide(color: tok.line)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(TokSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: TokSpace.sm),
            Text(
              'NÁHLED VOZIDLA',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: tok.textSecondary,
              ),
            ),
            const SizedBox(height: TokSpace.md),
            // Car card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(TokSpace.md),
              decoration: BoxDecoration(
                color: tok.surface,
                borderRadius: BorderRadius.circular(TokRadius.lg),
                border: Border.all(color: tok.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: TokColors.accentSoft,
                          borderRadius:
                              BorderRadius.circular(TokRadius.sm),
                        ),
                        child: const Icon(Icons.directions_car_rounded,
                            color: TokColors.accent, size: 16),
                      ),
                      const SizedBox(width: TokSpace.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vehicleTitle.isEmpty
                                  ? 'Vozidlo'
                                  : vehicleTitle,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: tok.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (rokVyroby.isNotEmpty)
                              Text(
                                rokVyroby,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: tok.textSecondary),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (hasData) ...[
                    const SizedBox(height: TokSpace.md),
                    Divider(color: tok.line, height: 1),
                    const SizedBox(height: TokSpace.md),
                    if (spz.isNotEmpty)
                      _PreviewRow(label: 'SPZ', value: spz, tok: tok),
                    if (vin.isNotEmpty)
                      _PreviewRow(label: 'VIN', value: vin, tok: tok),
                    if (cisloZakazky.isNotEmpty)
                      _PreviewRow(
                          label: 'Zakázka',
                          value: cisloZakazky,
                          tok: tok),
                  ],
                ],
              ),
            ),
            const SizedBox(height: TokSpace.md),
            // Info note
            Container(
              padding: const EdgeInsets.all(TokSpace.md),
              decoration: BoxDecoration(
                color: TokColors.accentSoft,
                borderRadius: BorderRadius.circular(TokRadius.md),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 13, color: TokColors.accent),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Údaje se plní průběžně při vyplňování formuláře.',
                      style: const TextStyle(
                          fontSize: 11, color: TokColors.accent),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final String label;
  final String value;
  final TorkisTokens tok;

  const _PreviewRow(
      {required this.label, required this.value, required this.tok});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TokSpace.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  TextStyle(fontSize: 11, color: tok.textSecondary)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: tok.textPrimary),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
