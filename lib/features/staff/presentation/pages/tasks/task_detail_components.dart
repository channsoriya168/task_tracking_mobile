part of 'task_detail_page.dart';

// ── Shared input decoration ─────────────────────────────────────

InputDecoration _inputDeco({
  required bool isDark,
  required Color borderColor,
  required String hint,
  Widget? suffix,
}) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: borderColor),
  );
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
        color: isDark ? Colors.white30 : kTextMuted, fontSize: 14),
    filled: true,
    fillColor: isDark
        ? Colors.white.withValues(alpha: 0.04)
        : const Color(0xFFF9FAFB),
    border: border,
    enabledBorder: border,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: kPrimary, width: 1.5),
    ),
    contentPadding: kContentPaddingSmall,
    suffixIcon: suffix,
  );
}

// ── Section card & header ───────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.child,
    required this.isDark,
    required this.borderColor,
    required this.cardBg,
  });
  final Widget child;
  final bool isDark;
  final Color borderColor;
  final Color cardBg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.isDark});
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        color: isDark ? Colors.white70 : const Color(0xFF374151),
      ),
    );
  }
}

// ── Progress item ───────────────────────────────────────────────

class _ProgressItem extends StatelessWidget {
  const _ProgressItem({
    required this.text,
    required this.isDark,
    required this.borderColor,
    required this.onEdit,
    required this.onDelete,
  });
  final String text;
  final bool isDark;
  final Color borderColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEdit,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 6, height: 6,
              margin: const EdgeInsets.only(top: 5),
              decoration: BoxDecoration(
                color: kPrimary.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13, height: 1.4,
                  color: isDark ? Colors.white : const Color(0xFF374151),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDelete,
              child: Icon(Icons.close_rounded, size: 15,
                  color: isDark ? Colors.white24 : const Color(0xFFD1D5DB)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Member avatar ───────────────────────────────────────────────

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({
    required this.index,
    required this.name,
    required this.isDark,
    required this.onRemove,
  });
  final int index;
  final String name;
  final bool isDark;
  final VoidCallback onRemove;

  static const _colors = [
    Color(0xFF6C63FF), Color(0xFF1976D2), Color(0xFF00838F),
    Color(0xFF6B3FA0), Color(0xFFD81B60), Color(0xFFF57C00),
  ];

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => e[0].toUpperCase())
        .take(2).join();
    final color = _colors[index % _colors.length];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.20 : 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(initials,
                style: const TextStyle(
                    fontSize: 9, fontWeight: FontWeight.w800,
                    color: Colors.white)),
          ),
          const SizedBox(width: 7),
          Text(name,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : const Color(0xFF374151))),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded, size: 14,
                color: isDark ? Colors.white38 : kTextMuted),
          ),
        ],
      ),
    );
  }
}
