import 'package:flutter/material.dart';

// ── Colors ──────────────────────────────────────────────
const Color kPrimary = Color(0xFF6C63FF);
const Color kHighPriority = Color(0xFFFF4757);
const Color kMediumPriority = Color(0xFFFFA502);
const Color kLowPriority = Color(0xFF2ED573);

const Color kBgLight = Color(0xFFF5F6FA);
const Color kBgDark = Color(0xFF0F0E17);
const Color kCardDark = Color(0xFF1A1A2E);
const Color kSurfaceDark = Color(0xFF16213E);
const Color kTextDark = Color(0xFF1A1A2E);
const Color kTextMuted = Color(0xFF8E8EA0);

// ── Padding ────────────────────────────────────────────

// Page level padding
const EdgeInsets kPagePadding = EdgeInsets.fromLTRB(20, 20, 20, 0);
const EdgeInsets kPagePaddingHorizontal = EdgeInsets.symmetric(horizontal: 20);
const EdgeInsets kPagePaddingWithBottom = EdgeInsets.all(20);
const EdgeInsets kPageSectionPadding = EdgeInsets.fromLTRB(20, 16, 20, 0);
const EdgeInsets kPageSectionLargePadding = EdgeInsets.fromLTRB(20, 24, 20, 0);
const EdgeInsets kPageBottomPadding = EdgeInsets.fromLTRB(20, 16, 20, 32);

// Content padding
const EdgeInsets kContentPadding = EdgeInsets.all(16);
const EdgeInsets kContentPaddingLarge = EdgeInsets.all(24);
const EdgeInsets kContentPaddingHorizontal = EdgeInsets.symmetric(
  horizontal: 16,
);
const EdgeInsets kContentPaddingSmall = EdgeInsets.symmetric(
  horizontal: 14,
  vertical: 12,
);
const EdgeInsets kContentPaddingTiny = EdgeInsets.symmetric(
  horizontal: 10,
  vertical: 4,
);

// Input & Button padding
const EdgeInsets kInputPadding = EdgeInsets.symmetric(
  horizontal: 16,
  vertical: 14,
);
const EdgeInsets kButtonPadding = EdgeInsets.symmetric(
  horizontal: 24,
  vertical: 14,
);
const EdgeInsets kButtonPaddingSmall = EdgeInsets.symmetric(
  horizontal: 14,
  vertical: 8,
);

// Navigation padding
const EdgeInsets kNavPadding = EdgeInsets.symmetric(
  horizontal: 20,
  vertical: 12,
);
const EdgeInsets kNavContainer = EdgeInsets.symmetric(
  horizontal: 16,
  vertical: 6,
);
const EdgeInsets kNavMargin = EdgeInsets.symmetric(horizontal: 12, vertical: 8);

// Item spacing
const EdgeInsets kItemSpacing = EdgeInsets.only(bottom: 12);
const EdgeInsets kItemSpacingVertical = EdgeInsets.symmetric(vertical: 16);
const EdgeInsets kItemSpacingSmall = EdgeInsets.symmetric(
  horizontal: 7,
  vertical: 2,
);
const EdgeInsets kItemSpacingRight = EdgeInsets.only(right: 8);
const EdgeInsets kItemSpacingRightLarge = EdgeInsets.only(right: 20);

// Chip & Tag padding
const EdgeInsets kChipPadding = EdgeInsets.symmetric(
  horizontal: 14,
  vertical: 7,
);
const EdgeInsets kTagPaddingSmall = EdgeInsets.symmetric(
  horizontal: 16,
  vertical: 4,
);

// ── Categories ──────────────────────────────────────────
const List<String> kCategories = [
  'General',
  'Engineering',
  'Design',
  'Documentation',
  'Research',
  'Meeting',
  'Marketing',
  'Maintenance',
];
