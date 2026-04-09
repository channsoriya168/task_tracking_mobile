import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized typography for the app.
abstract class AppTextStyles {
  AppTextStyles._();

  // Returns 'Siemreap' for Khmer, 'Inter' for all other locales.
  static String get _fontFamily =>
      Get.locale?.languageCode == 'km' ? 'Siemreap' : 'Kantumruy Pro';
  // ── Single source of truth — change THIS line to switch font app-wide ───

  // Returns 0 letter-spacing for Khmer — Khmer script breaks visually with
  // any explicit spacing between characters.
  static double? _ls(double? spacing) =>
      (spacing == null || Get.locale?.languageCode == 'km') ? 0.0 : spacing;

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
    letterSpacing: _ls(letterSpacing),
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
    fontSize: 22,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    color: color,
  );
  static TextStyle sectionHeader({Color? color}) =>
      _font(fontSize: 16, fontWeight: FontWeight.w600, color: color);

  static TextStyle buttonLabel() =>
      _font(fontSize: 15, fontWeight: FontWeight.w600);
}
