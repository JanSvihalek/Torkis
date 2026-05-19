import 'package:flutter/material.dart';

import 'design_tokens.dart';

/// TORKIS sdílené UI komponenty. Brand-konzistentní stavební bloky.

// ─── LOGO MARK ──────────────────────────────────────────────
/// Vykresluje TORKIS "Circle T s torque arc" logo pomocí CustomPaint.
/// Bez závislosti na asset PNG — tím funguje na všech velikostech ostře.
class TorkisMark extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? accent;
  final Color? inner;

  const TorkisMark({
    super.key,
    this.size = 32,
    this.color,
    this.accent,
    this.inner,
  });

  @override
  Widget build(BuildContext context) {
    final tok = context.tok;
    final c = color ?? tok.ink;
    final a = accent ?? TokColors.accent;
    final i = inner ?? (c == TokColors.paper ? TokColors.ink : TokColors.paper);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TorkisMarkPainter(circle: c, accent: a, inner: i),
      ),
    );
  }
}

class _TorkisMarkPainter extends CustomPainter {
  final Color circle;
  final Color accent;
  final Color inner;

  _TorkisMarkPainter({
    required this.circle,
    required this.accent,
    required this.inner,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final unit = size.width / 64.0;
    final radius = 26 * unit;

    // Main circle
    canvas.drawCircle(center, radius, Paint()..color = circle);

    // Torque arc (top-right ~90°)
    final arcRect = Rect.fromCircle(center: center, radius: radius);
    final arcPaint = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5 * unit
      ..strokeCap = StrokeCap.round;
    // From -90° (top) sweep +60° to right
    canvas.drawArc(arcRect, -1.5708, 1.0472, false, arcPaint);

    // Inner "T"
    final tPaint = Paint()
      ..color = inner
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6 * unit
      ..strokeCap = StrokeCap.round;
    // Horizontal bar
    canvas.drawLine(
      Offset(center.dx - 12 * unit, center.dy - 6 * unit),
      Offset(center.dx + 12 * unit, center.dy - 6 * unit),
      tPaint,
    );
    // Vertical stem
    canvas.drawLine(
      Offset(center.dx, center.dy - 6 * unit),
      Offset(center.dx, center.dy + 14 * unit),
      tPaint,
    );
  }

  @override
  bool shouldRepaint(_TorkisMarkPainter old) =>
      old.circle != circle || old.accent != accent || old.inner != inner;
}

// ─── BRAND HEADER ───────────────────────────────────────────
/// Hlavička aplikace s logem a textem TORKIS + volitelnou akcí vpravo.
class TorkisBrandHeader extends StatelessWidget {
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final double markSize;
  final double titleSize;
  final bool dark;

  const TorkisBrandHeader({
    super.key,
    this.trailing,
    this.padding =
        const EdgeInsets.symmetric(horizontal: TokSpace.xl, vertical: 6),
    this.markSize = 26,
    this.titleSize = 18,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    final tok = context.tok;
    final brandColor = dark ? TokColors.paper : tok.textPrimary;
    return Padding(
      padding: padding,
      child: Row(
        children: [
          TorkisMark(
            size: markSize,
            color: brandColor,
            inner: dark ? TokColors.ink : tok.surface,
          ),
          const SizedBox(width: 9),
          Text(
            'TORKIS',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: brandColor,
            ),
          ),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ─── PRIMARY BUTTON ─────────────────────────────────────────
class TorkisPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? trailingIcon;
  final IconData? leadingIcon;
  final bool loading;
  final bool dark; // true = use accent on dark surface; false = use ink
  final double height;

  const TorkisPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.trailingIcon = Icons.arrow_forward_rounded,
    this.leadingIcon,
    this.loading = false,
    this.dark = false,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final bg = dark ? TokColors.accent : context.tok.inkSurface;
    const fg = Colors.white;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          disabledBackgroundColor: bg.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TokRadius.lg),
          ),
          shadowColor: dark
              ? TokColors.accent.withValues(alpha: 0.4)
              : Colors.black.withValues(alpha: 0.2),
          elevation: 0,
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leadingIcon != null) ...[
                    Icon(leadingIcon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      )),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 8),
                    Icon(trailingIcon, size: 16),
                  ],
                ],
              ),
      ),
    );
  }
}

// ─── SECONDARY BUTTON ───────────────────────────────────────
class TorkisSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool dark;
  final double height;

  const TorkisSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.dark = false,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    final tok = context.tok;
    final fg = dark ? Colors.white : tok.textPrimary;
    final border = dark
        ? Colors.white.withValues(alpha: 0.14)
        : tok.lineStrong;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: fg,
          side: BorderSide(color: border),
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TokRadius.lg),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, size: 18),
              const SizedBox(width: 8),
            ],
            Text(label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                )),
            if (trailingIcon != null) ...[
              const SizedBox(width: 8),
              Icon(trailingIcon, size: 16),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── FIELD (label nad inputem) ──────────────────────────────
class TorkisField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool required;
  final bool mono;
  final bool obscure;
  final bool readOnly;
  final TextInputType keyboardType;
  final int? maxLines;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final bool dark;

  const TorkisField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.prefixIcon,
    this.suffix,
    this.required = false,
    this.mono = false,
    this.obscure = false,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.onChanged,
    this.onTap,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    final tok = context.tok;
    final isDark = dark || tok.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 2),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? TokColors.steelSoft : tok.textSecondary,
                  letterSpacing: 0.2,
                ),
              ),
              if (required)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: TokColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
        TextField(
          controller: controller,
          obscureText: obscure,
          readOnly: readOnly,
          onChanged: onChanged,
          onTap: onTap,
          keyboardType: keyboardType,
          maxLines: obscure ? 1 : maxLines,
          style: TextStyle(
            fontFamily: mono ? 'IBMPlexMono' : null,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : tok.textPrimary,
            letterSpacing: mono ? 0.5 : 0,
          ),
          cursorColor: TokColors.accent,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon,
                    color: TokColors.accent, size: 18)
                : null,
            suffixIcon: suffix == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: suffix,
                  ),
            suffixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : TokColors.paper,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(TokRadius.md),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : tok.line,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── STEP PROGRESS ──────────────────────────────────────────
class TorkisStepProgress extends StatelessWidget {
  final int currentStep; // 1-based
  final int totalSteps;
  final String? stepLabel;

  const TorkisStepProgress({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.stepLabel,
  });

  @override
  Widget build(BuildContext context) {
    final tok = context.tok;
    final progress = currentStep / totalSteps;
    return Row(
      children: [
        Text(
          stepLabel != null
              ? 'KROK $currentStep Z $totalSteps · ${stepLabel!.toUpperCase()}'
              : 'KROK $currentStep Z $totalSteps',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: TokColors.accent,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(TokRadius.round),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: tok.line,
              valueColor: const AlwaysStoppedAnimation(TokColors.accent),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── INFO BANNER ────────────────────────────────────────────
class TorkisInfoBanner extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const TorkisInfoBanner({
    super.key,
    required this.icon,
    required this.accentColor,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final tok = context.tok;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: tok.surface,
        border: Border(
          left: BorderSide(color: accentColor, width: 3),
          top: BorderSide(color: tok.line),
          right: BorderSide(color: tok.line),
          bottom: BorderSide(color: tok.line),
        ),
        borderRadius: BorderRadius.circular(TokRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: accentColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: tok.textPrimary,
                    )),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!,
                      style: TextStyle(
                        fontSize: 11,
                        color: tok.textSecondary,
                      )),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ─── ROLE PILL ──────────────────────────────────────────────
class TorkisRolePill extends StatelessWidget {
  final String role;

  const TorkisRolePill({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: TokColors.accentSoft,
        borderRadius: BorderRadius.circular(TokRadius.round),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: TokColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            role.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: TokColors.accent,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── MODULE CARD ────────────────────────────────────────────
class TorkisModuleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? meta;
  final bool accent;
  final bool locked;
  final VoidCallback? onTap;

  const TorkisModuleCard({
    super.key,
    required this.icon,
    required this.label,
    this.meta,
    this.accent = false,
    this.locked = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tok = context.tok;
    final bg = accent ? tok.inkSurface : tok.surface;
    final fg = accent ? Colors.white : tok.textPrimary;
    final iconBg = accent
        ? TokColors.accent.withValues(alpha: 0.18)
        : tok.bg;
    final iconColor = accent ? TokColors.accent : tok.textPrimary;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(TokRadius.xl),
      child: InkWell(
        onTap: locked ? null : onTap,
        borderRadius: BorderRadius.circular(TokRadius.xl),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TokRadius.xl),
            border: accent ? null : Border.all(color: tok.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(TokRadius.md),
                ),
                child: Icon(icon,
                    size: 22,
                    color: locked
                        ? tok.textMuted
                        : iconColor),
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: locked ? tok.textMuted : fg,
                      letterSpacing: -0.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (meta != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      meta!,
                      style: TextStyle(
                        fontFamily: 'IBMPlexMono',
                        fontSize: 11,
                        color: accent
                            ? TokColors.steelSoft
                            : tok.textSecondary,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── CTA TILE (action banner like "Scan VIN") ───────────────
class TorkisActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool dark;

  const TorkisActionTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.dark = true,
  });

  @override
  Widget build(BuildContext context) {
    final tok = context.tok;
    final bg = dark ? tok.inkSurface : tok.surface;
    final fg = dark ? Colors.white : tok.textPrimary;
    final subFg = dark
        ? Colors.white.withValues(alpha: 0.7)
        : tok.textSecondary;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(TokRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TokRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: TokColors.accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(TokRadius.sm),
                ),
                child: const Icon(Icons.qr_code_scanner_rounded,
                    color: TokColors.accent, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: fg,
                        )),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!,
                          style: TextStyle(
                            fontSize: 11,
                            color: subFg,
                          )),
                    ],
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: fg),
            ],
          ),
        ),
      ),
    );
  }
  // ignore: unused_element
  // (icon param kept for future variation)
}

// ─── PERIOD TOGGLE ──────────────────────────────────────────
class TorkisSegmented<T> extends StatelessWidget {
  final List<({T value, String label, String? badge})> options;
  final T selected;
  final ValueChanged<T> onChanged;

  const TorkisSegmented({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tok = context.tok;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: tok.line,
        borderRadius: BorderRadius.circular(TokRadius.round),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((opt) {
          final isSel = opt.value == selected;
          return GestureDetector(
            onTap: () => onChanged(opt.value),
            child: AnimatedContainer(
              duration: TokDuration.fast,
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
              decoration: BoxDecoration(
                color: isSel ? tok.surface : Colors.transparent,
                borderRadius: BorderRadius.circular(TokRadius.round),
                boxShadow: isSel
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    opt.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSel ? FontWeight.w600 : FontWeight.w500,
                      color: isSel ? tok.textPrimary : tok.textSecondary,
                    ),
                  ),
                  if (opt.badge != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: TokColors.success,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        opt.badge!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── FEATURE CHECK ROW (pricing card) ───────────────────────
class TorkisFeatureCheck extends StatelessWidget {
  final String text;
  final bool dark;

  const TorkisFeatureCheck({super.key, required this.text, this.dark = false});

  @override
  Widget build(BuildContext context) {
    final tok = context.tok;
    final color = dark ? Colors.white : tok.textPrimary;
    final ringBg = dark
        ? TokColors.accent.withValues(alpha: 0.2)
        : TokColors.accentSoft;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: ringBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check,
                size: 10, color: TokColors.accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: TextStyle(fontSize: 13, color: color, height: 1.4)),
          ),
        ],
      ),
    );
  }
}

// ─── PAGE TITLE ─────────────────────────────────────────────
/// Velký nadpis + volitelný podtitulek (sjednocený typografický blok).
class TorkisPageTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final EdgeInsetsGeometry padding;

  const TorkisPageTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.padding = const EdgeInsets.fromLTRB(
        TokSpace.xl, TokSpace.md, TokSpace.xl, TokSpace.sm),
  });

  @override
  Widget build(BuildContext context) {
    final tok = context.tok;
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: tok.textPrimary,
              letterSpacing: -0.4,
              height: 1.1,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 13,
                color: tok.textSecondary,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
