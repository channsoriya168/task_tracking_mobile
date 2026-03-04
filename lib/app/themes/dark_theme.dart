import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: kPrimary,
    brightness: Brightness.dark,
  ).copyWith(surface: kBgDark, surfaceContainerHighest: kCardDark),
  scaffoldBackgroundColor: kBgDark,
  textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    iconTheme: const IconThemeData(color: Colors.white),
    titleTextStyle: GoogleFonts.inter(
      color: Colors.white,
      fontSize: 26,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
    ),
  ),
  cardTheme: CardThemeData(
    color: kCardDark,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: kCardDark,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kPrimary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kHighPriority, width: 1),
    ),
    contentPadding: kInputPadding,
    hintStyle: const TextStyle(color: Color(0xFF4A4A6A)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: kButtonPadding,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
    ),
  ),
  chipTheme: ChipThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: kPrimary,
    foregroundColor: Colors.white,
    elevation: 4,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: kCardDark,
    selectedItemColor: kPrimary,
    unselectedItemColor: Color(0xFF4A4A6A),
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
  ),
);
