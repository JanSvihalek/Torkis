import 'package:flutter/material.dart';
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
      color: context.tok.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Padding(
            padding: const EdgeInsets.fromLTRB(
                TokSpace.lg, TokSpace.md, TokSpace.lg, TokSpace.sm),
            child: _SidebarProgress(
              currentStep: currentStep,
              totalSteps: totalSteps,
            ),
          ),
          const SizedBox(height: TokSpace.md),
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
                          ? TokColors.accent
                          : context.tok.textSecondary,
                      fontSize: 13,
                      fontWeight: isActive
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
                if (isActive)
                  const Icon(Icons.chevron_right_rounded,
                      size: 16, color: TokColors.accent),
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
      bg = context.tok.line;
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
                style: TextStyle(
                    color: isActive ? Colors.white : context.tok.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}

class _SidebarProgress extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _SidebarProgress({
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              'POSTUP',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: context.tok.textSecondary,
              ),
            ),
            const Spacer(),
            Text(
              '${currentStep + 1} / $totalSteps',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: context.tok.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: List.generate(totalSteps, (i) {
            final done = i <= currentStep;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < totalSteps - 1 ? 3 : 0),
                height: 3,
                decoration: BoxDecoration(
                  color: done ? TokColors.accent : context.tok.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
      ],
    );
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
  final Map<String, dynamic>? vehicleInfo;

  const PrijemVehiclePreviewPanel({
    super.key,
    required this.spz,
    required this.vin,
    required this.cisloZakazky,
    required this.znacka,
    required this.model,
    required this.rokVyroby,
    required this.isDark,
    this.vehicleInfo,
  });

  @override
  Widget build(BuildContext context) {
    final tok = TorkisTokens(isDark ? Brightness.dark : Brightness.light);
    return Container(
      width: kPreviewPanelWidth,
      decoration: BoxDecoration(
        color: isDark ? TokColors.darkSurface : TokColors.bg,
        border: Border(left: BorderSide(color: tok.line)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(TokSpace.lg),
        child: vehicleInfo != null
            ? _buildHistoryView(tok)
            : _buildLiveView(tok),
      ),
    );
  }

  // Zobrazí historická data načteného vozidla
  Widget _buildHistoryView(TorkisTokens tok) {
    final info = vehicleInfo!;
    final title = [info['znacka'] ?? '', info['model'] ?? '']
        .where((s) => (s as String).isNotEmpty)
        .join(' ');
    final rok = info['rok_vyroby'] as String? ?? '';
    final spzVal = info['spz'] as String? ?? '';
    final tach = info['tachometr'] as String? ?? '';
    final stk = info['stk'] as String? ?? '';
    final navsteva = info['posledni_navsteva'] as String? ?? '';
    final zakaznik = info['zakaznik_jmeno'] as String? ?? '';
    final zakazkaCislo = info['posledni_zakazka'] as String? ?? '';
    final zakazkaDatum = info['posledni_zakazka_datum'] as String? ?? '';
    final zakazkaStav = info['posledni_zakazka_stav'] as String? ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: TokSpace.sm),
        Text(
          'POSLEDNÍ NÁVŠTĚVA',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: tok.textSecondary,
          ),
        ),
        const SizedBox(height: TokSpace.md),

        // Karta vozidla
        _InfoCard(tok: tok, children: [
          _CardHeader(
            icon: Icons.directions_car_rounded,
            title: title.isEmpty ? 'Vozidlo' : title,
            subtitle: rok,
            tok: tok,
          ),
          if (spzVal.isNotEmpty || tach.isNotEmpty || stk.isNotEmpty) ...[
            const SizedBox(height: TokSpace.md),
            Divider(color: tok.line, height: 1),
            const SizedBox(height: TokSpace.md),
            if (spzVal.isNotEmpty)
              _PreviewRow(label: 'SPZ', value: spzVal, tok: tok),
            if (tach.isNotEmpty)
              _PreviewRow(label: 'Tachometr', value: '$tach km', tok: tok),
            if (stk.isNotEmpty)
              _PreviewRow(label: 'STK', value: stk, tok: tok),
            if (navsteva.isNotEmpty)
              _PreviewRow(label: 'Naposledy', value: navsteva, tok: tok),
          ],
        ]),

        // Karta zákazníka
        if (zakaznik.isNotEmpty) ...[
          const SizedBox(height: TokSpace.sm),
          _InfoCard(tok: tok, children: [
            _CardHeader(
              icon: Icons.person_outline_rounded,
              title: zakaznik,
              tok: tok,
            ),
          ]),
        ],

        // Karta poslední zakázky
        if (zakazkaCislo.isNotEmpty) ...[
          const SizedBox(height: TokSpace.sm),
          _InfoCard(tok: tok, children: [
            _CardHeader(
              icon: Icons.assignment_outlined,
              title: zakazkaCislo,
              subtitle: zakazkaDatum,
              tok: tok,
            ),
            if (zakazkaStav.isNotEmpty) ...[
              const SizedBox(height: TokSpace.md),
              Divider(color: tok.line, height: 1),
              const SizedBox(height: TokSpace.md),
              _PreviewRow(label: 'Stav', value: zakazkaStav, tok: tok),
            ],
          ]),
        ],
      ],
    );
  }

  // Původní live náhled při zadávání nového vozidla
  Widget _buildLiveView(TorkisTokens tok) {
    final vehicleTitle = [znacka, model].where((s) => s.isNotEmpty).join(' ');
    final hasData = spz.isNotEmpty ||
        vin.isNotEmpty ||
        cisloZakazky.isNotEmpty ||
        vehicleTitle.isNotEmpty;

    return Column(
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
        _InfoCard(tok: tok, children: [
          _CardHeader(
            icon: Icons.directions_car_rounded,
            title: vehicleTitle.isEmpty ? 'Vozidlo' : vehicleTitle,
            subtitle: rokVyroby,
            tok: tok,
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
              _PreviewRow(label: 'Zakázka', value: cisloZakazky, tok: tok),
          ],
        ]),
        const SizedBox(height: TokSpace.md),
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
              const Expanded(
                child: Text(
                  'Údaje se plní průběžně při vyplňování formuláře.',
                  style: TextStyle(fontSize: 11, color: TokColors.accent),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final TorkisTokens tok;
  final List<Widget> children;

  const _InfoCard({required this.tok, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TokSpace.md),
      decoration: BoxDecoration(
        color: tok.surface,
        borderRadius: BorderRadius.circular(TokRadius.lg),
        border: Border.all(color: tok.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final TorkisTokens tok;

  const _CardHeader({
    required this.icon,
    required this.title,
    required this.tok,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: TokColors.accentSoft,
            borderRadius: BorderRadius.circular(TokRadius.sm),
          ),
          child: Icon(icon, color: TokColors.accent, size: 16),
        ),
        const SizedBox(width: TokSpace.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: tok.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null && subtitle!.isNotEmpty)
                Text(
                  subtitle!,
                  style: TextStyle(fontSize: 11, color: tok.textSecondary),
                ),
            ],
          ),
        ),
      ],
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
