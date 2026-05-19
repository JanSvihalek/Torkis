import 'package:flutter/material.dart';

/// TORKIS design tokens — sjednocený brand jazyk pro celou aplikaci.
/// Inspirováno mockupem "TORKIS App Redesign".
///
/// Použití:
///   color: TokColors.accent
///   padding: EdgeInsets.all(TokSpace.md)
///   final tok = context.tok; // brightness-aware
class TokColors {
  // Brand
  static const ink = Color(0xFF0B1A2E);
  static const inkSoft = Color(0xFF14253D);
  static const accent = Color(0xFF3B82F6);
  static const accent2 = Color(0xFF2563EB);
  static const accentSoft = Color(0x1A3B82F6); // 10% accent

  // Neutral (light)
  static const paper = Color(0xFFFFFFFF);
  static const bg = Color(0xFFF8FAFC);
  static const line = Color(0xFFE2E8F0);
  static const steel = Color(0xFF64748B);
  static const steelSoft = Color(0xFF94A3B8);

  // Neutral (dark) — světlejší ladění (bg = původní scan tile)
  static const darkBg = Color(0xFF1B2E4D);
  static const darkSurface = Color(0xFF22365A);
  static const darkSurface2 = Color(0xFF2A3F6B);
  static const darkLine = Color(0x1AFFFFFF); // ~10% white
  static const darkLineStrong = Color(0x26FFFFFF); // ~15% white

  // Semantic
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFDC2626);
}

/// Brightness-aware token bundle. Use `context.tok` for adaptive colors.
class TorkisTokens {
  final Brightness brightness;
  const TorkisTokens(this.brightness);

  bool get isDark => brightness == Brightness.dark;

  // Surfaces
  Color get bg => isDark ? TokColors.darkBg : TokColors.bg;
  Color get surface => isDark ? TokColors.darkSurface : TokColors.paper;
  Color get surfaceElevated =>
      isDark ? TokColors.darkSurface2 : TokColors.paper;

  // Text
  Color get textPrimary => isDark ? TokColors.paper : TokColors.ink;
  Color get textSecondary => isDark ? TokColors.steelSoft : TokColors.steel;
  Color get textMuted =>
      isDark ? TokColors.steelSoft.withValues(alpha: 0.7) : TokColors.steelSoft;

  // Lines / dividers
  Color get line => isDark ? TokColors.darkLine : TokColors.line;
  Color get lineStrong => isDark ? TokColors.darkLineStrong : TokColors.line;

  // Brand stays constant
  Color get accent => TokColors.accent;
  Color get accentSoft =>
      isDark ? const Color(0x333B82F6) : TokColors.accentSoft;

  // Ink — inverted for cards/buttons
  Color get ink => isDark ? TokColors.paper : TokColors.ink;
  Color get inkSurface => isDark ? TokColors.darkSurface2 : TokColors.ink;
  Color get onInk => isDark ? TokColors.ink : TokColors.paper;
}

extension TorkisContext on BuildContext {
  TorkisTokens get tok => TorkisTokens(Theme.of(this).brightness);
}

class TokSpace {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 28.0;
  static const xxxl = 40.0;
}

class TokRadius {
  static const sm = 8.0;
  static const md = 10.0;
  static const lg = 12.0;
  static const xl = 14.0;
  static const xxl = 20.0;
  static const round = 100.0;
}

class TokDuration {
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 400);
}
