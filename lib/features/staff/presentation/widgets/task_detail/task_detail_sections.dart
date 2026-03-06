part of '../../pages/tasks/task_detail_page.dart';

// ── Description card ────────────────────────────────────────────

class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({
    required this.controller,
    required this.isDark,
    required this.borderColor,
    required this.cardBg,
  });
  final TextEditingController controller;
  final bool isDark;
  final Color borderColor;
  final Color cardBg;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      isDark: isDark, borderColor: borderColor, cardBg: cardBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(label: 'Description', isDark: isDark),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            maxLines: 4,
            style: TextStyle(
              fontSize: 14, height: 1.5,
              color: isDark ? Colors.white : const Color(0xFF374151),
            ),
            decoration: _inputDeco(
              isDark: isDark,
              borderColor: borderColor,
              hint: 'Add a description...',
            ),
          ),
        ],
      ),
    );
  }
}

// ── Members card ────────────────────────────────────────────────

class _MembersCard extends StatelessWidget {
  const _MembersCard({
    required this.members,
    required this.controller,
    required this.isDark,
    required this.borderColor,
    required this.cardBg,
    required this.onAdd,
    required this.onRemove,
  });
  final List<String> members;
  final TextEditingController controller;
  final bool isDark;
  final Color borderColor;
  final Color cardBg;
  final VoidCallback onAdd;
  final void Function(int) onRemove;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      isDark: isDark, borderColor: borderColor, cardBg: cardBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(label: 'Team Members', isDark: isDark),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            onSubmitted: (_) => onAdd(),
            style: TextStyle(
                fontSize: 14, color: isDark ? Colors.white : kTextDark),
            decoration: _inputDeco(
              isDark: isDark,
              borderColor: borderColor,
              hint: 'Add member name...',
              suffix: GestureDetector(
                onTap: onAdd,
                child: const Icon(Icons.person_add_rounded,
                    color: kPrimary, size: 20),
              ),
            ),
          ),
          if (members.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: members.asMap().entries.map((e) => _MemberAvatar(
                index: e.key,
                name: e.value,
                isDark: isDark,
                onRemove: () => onRemove(e.key),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Progress card ───────────────────────────────────────────────

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.items,
    required this.isDark,
    required this.borderColor,
    required this.cardBg,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.itemText,
  });
  final List<String> items;
  final bool isDark;
  final Color borderColor;
  final Color cardBg;
  final VoidCallback onAdd;
  final void Function(int) onEdit;
  final void Function(int) onDelete;
  final String Function(String) itemText;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      isDark: isDark, borderColor: borderColor, cardBg: cardBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _SectionHeader(label: 'Progress', isDark: isDark),
              const Spacer(),
              if (items.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: kPrimary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${items.length} notes',
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700, color: kPrimary),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                      color: kPrimary, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.add_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          if (items.isEmpty) ...[
            const SizedBox(height: 16),
            Center(
              child: Text(
                'No progress notes yet.\nTap + to add your first one.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13, height: 1.6,
                  color: isDark ? Colors.white30 : kTextMuted,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ] else ...[
            const SizedBox(height: 12),
            ...items.asMap().entries.map((e) => _ProgressItem(
              text: itemText(e.value),
              isDark: isDark,
              borderColor: borderColor,
              onEdit: () => onEdit(e.key),
              onDelete: () => onDelete(e.key),
            )),
          ],
        ],
      ),
    );
  }
}

// ── Bottom bar ──────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.isDark,
    required this.borderColor,
    required this.onSave,
    required this.onComplete,
  });
  final bool isDark;
  final Color borderColor;
  final VoidCallback onSave;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: isDark ? kSurfaceDark : Colors.white,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onSave,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.20)
                        : const Color(0xFFD1D5DB)),
                foregroundColor: isDark ? Colors.white70 : kTextDark,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Save',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: onComplete,
              style: ElevatedButton.styleFrom(
                backgroundColor: kLowPriority,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_rounded, size: 18),
                  SizedBox(width: 6),
                  Text('Mark Complete',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Note bottom sheet ───────────────────────────────────────────

class _NoteSheet extends StatelessWidget {
  const _NoteSheet({
    required this.isDark,
    required this.title,
    required this.hint,
    required this.buttonLabel,
    required this.controller,
    required this.onSubmit,
  });
  final bool isDark;
  final String title;
  final String hint;
  final String buttonLabel;
  final TextEditingController controller;
  final void Function(String) onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? kSurfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : kTextDark,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            autofocus: true,
            maxLines: 3,
            style: TextStyle(
                fontSize: 14, color: isDark ? Colors.white : kTextDark),
            decoration: _inputDeco(
              isDark: isDark,
              borderColor: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : const Color(0xFFE5E7EB),
              hint: hint,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) onSubmit(text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(buttonLabel,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
