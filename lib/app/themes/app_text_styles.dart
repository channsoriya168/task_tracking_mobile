import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized typography for the app.
///
/// To switch the entire app font, change [_fontFamily] only — one line.
abstract class AppTextStyles {
  AppTextStyles._();

  // ── Single source of truth — change THIS line to switch font app-wide ───
  static const String _fontFamily = 'Kantumruy Pro';

  // ── Base builder ────────────────────────────────────────────────────────
  static TextStyle _font({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) => GoogleFonts.getFont(
    _fontFamily,
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );

  // ── TextTheme for ThemeData ─────────────────────────────────────────────
  static TextTheme textTheme([TextTheme? base]) =>
      GoogleFonts.getTextTheme(_fontFamily, base);

  // ── Shared styles ───────────────────────────────────────────────────────
  static TextStyle chipLabel({required bool selected, Color? color}) => _font(
    fontSize: 12,
    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
    color: color,
  );

  static TextStyle appBarTitle({Color? color}) => _font(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    color: color,
  );

  static TextStyle buttonLabel() =>
      _font(fontSize: 15, fontWeight: FontWeight.w600);
}
