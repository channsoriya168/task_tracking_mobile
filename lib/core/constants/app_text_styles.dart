import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppTextStyles {
  // AppTextStyles._();
  // static String get _fontFamily =>
  //     Get.locale?.languageCode == 'km' ? 'Siemreap' : 'Kantumruy Pro';
  static double? _ls(double? spacing) =>
      (spacing == null || Get.locale?.languageCode == 'km') ? 0.0 : spacing;

  // Scales base size proportionally to screen width (clamped so text stays legible).
  static double _sp(double base) {
    final ctx = Get.context;
    if (ctx == null) return base;
    final w = MediaQuery.of(ctx).size.width;
    return (base * (w / 1024)).clamp(base * 0.80, base * 1.25);
  }

  // ── Base builder ────────────────────────────────────────────────────────
  static TextStyle _font({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) => GoogleFonts.getFont(
    "Battambang",
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: _ls(letterSpacing),
    height: height,
  );

  // ── TextTheme for ThemeData ─────────────────────────────────────────────
  static TextTheme textTheme([TextTheme? base]) =>
      GoogleFonts.getTextTheme("Battambang", base);

  // ── Shared styles ───────────────────────────────────────────────────────
  static TextStyle chipLabel({required bool selected, Color? color}) => _font(
    fontSize: _sp(19),
    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
    color: color,
  );

  static TextStyle appBarTitle({Color? color}) =>
      _font(fontSize: _sp(25), fontWeight: FontWeight.bold, color: color);

  static TextStyle title({Color? color}) =>
      _font(fontSize: _sp(22), letterSpacing: -0.5, color: color);

  static TextStyle subTitle({Color? color}) => _font(
    fontSize: _sp(19),
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    color: color,
  );

  static TextStyle buttonLabel({Color? color}) => _font(
    fontSize: _sp(19),
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    color: color,
  );
  // ── Login styles ────────────────────────────────────────────────────────
  static TextStyle loginTitle({Color? color}) => _font(
    fontSize: _sp(30),
    fontWeight: FontWeight.w800,
    color: color,
    height: 1.2,
  );
  static TextStyle loginSubtitle({Color? color}) =>
      _font(fontSize: _sp(22), color: color);
  static TextStyle formLabel({Color? color}) =>
      _font(fontSize: _sp(18), fontWeight: FontWeight.w600, color: color);
  static TextStyle inputText({Color? color}) =>
      _font(fontSize: _sp(18), color: color);
  static TextStyle errorText({Color? color}) =>
      _font(fontSize: _sp(18), fontWeight: FontWeight.w500, color: color);
}
