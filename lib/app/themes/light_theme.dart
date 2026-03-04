import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: kPrimary,
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: kBgLight,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    iconTheme: IconThemeData(color: kTextDark),
    titleTextStyle: TextStyle(
      color: kTextDark,
      fontSize: 26,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
    ),
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
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
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    hintStyle: const TextStyle(color: kTextMuted),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
    backgroundColor: Colors.white,
    selectedItemColor: kPrimary,
    unselectedItemColor: kTextMuted,
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
  ),
);