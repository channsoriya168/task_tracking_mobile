import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/staff/data/models/task_model.dart';
import 'package:task_tracking_mobile/features/staff/presentation/controllers/task_controller.dart';

class TaskDetailPage extends StatefulWidget {
  final TaskModel task;
  final TaskController ctrl;

  const TaskDetailPage({super.key, required this.task, required this.ctrl});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late final TextEditingController _descCtrl;
  late final TextEditingController _memberCtrl;
  late List<String> _members;
  late List<String> _progressItems;

  @override
  void initState() {
    super.initState();
    _descCtrl = TextEditingController(text: widget.task.description);
    _memberCtrl = TextEditingController();
    _members = List.from(widget.task.members);
    _progressItems = List.from(widget.task.progressItems);
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _memberCtrl.dispose();
    super.dispose();
  }

  void _addMember() {
    final name = _memberCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _members.add(name);
      _memberCtrl.clear();
    });
  }

  void _addProgress() {
    final inputCtrl = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: isDark ? kSurfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Add Progress',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : kTextDark,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: inputCtrl,
              autofocus: true,
              maxLines: 3,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : kTextDark,
              ),
              decoration: InputDecoration(
                hintText: 'Describe your progress...',
                hintStyle: const TextStyle(color: kTextMuted, fontSize: 14),
                filled: true,
                fillColor: isDark ? kCardDark : kBgLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: kContentPaddingSmall,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final text = inputCtrl.text.trim();
                  if (text.isNotEmpty) {
                    setState(() => _progressItems.add(text));
                  }
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _save() {
    widget.ctrl.updateTask(
      widget.task.copyWith(
        description: _descCtrl.text.trim(),
        members: _members,
        progressItems: _progressItems,
      ),
    );
    Get.back();
  }

  void _submit() {
    widget.ctrl.updateTask(
      widget.task.copyWith(
        description: _descCtrl.text.trim(),
        status: TaskStatus.done,
        members: _members,
        progressItems: _progressItems,
      ),
    );
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final task = widget.task;

    return Scaffold(
      backgroundColor: isDark ? kBgDark : kBgLight,
      appBar: AppBar(
        backgroundColor: isDark ? kSurfaceDark : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : kTextDark,
            size: 18,
          ),
          onPressed: Get.back,
        ),
        title: Text(
          'Task Detail',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : kTextDark,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: kPageBottomPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            // ── Title ─────────────────────────────────────────
            Text(
              task.title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : kTextDark,
              ),
            ),
            const SizedBox(height: 12),
            // ── Category + Priority ───────────────────────────
            Row(
              children: [
                _infoChip(
                  task.category,
                  kPrimary.withValues(alpha: 0.1),
                  kPrimary,
                ),
                const SizedBox(width: 8),
                _infoChip(
                  task.priorityLabel,
                  task.priorityColor.withValues(alpha: 0.12),
                  task.priorityColor,
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── Description ───────────────────────────────────
            _sectionLabel('Description', isDark),
            const SizedBox(height: 8),
            TextField(
              controller: _descCtrl,
              maxLines: 4,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : kTextDark,
              ),
              decoration: InputDecoration(
                hintText: 'Add a description...',
                hintStyle: const TextStyle(color: kTextMuted, fontSize: 14),
                filled: true,
                fillColor: isDark ? kCardDark : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: kContentPaddingSmall,
              ),
            ),
            const SizedBox(height: 28),

            // ── Members ───────────────────────────────────────
            _sectionLabel('Members', isDark),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _memberCtrl,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : kTextDark,
                    ),
                    onSubmitted: (_) => _addMember(),
                    decoration: InputDecoration(
                      hintText: 'Add member name...',
                      hintStyle: const TextStyle(
                        color: kTextMuted,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: isDark ? kCardDark : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: kContentPaddingSmall,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _addMember,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: kPrimary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person_add_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            if (_members.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _members.asMap().entries.map((e) {
                  return _memberChip(e.key, e.value);
                }).toList(),
              ),
            ],
            const SizedBox(height: 28),

            // ── Progress ──────────────────────────────────────
            Row(
              children: [
                _sectionLabel('Progress', isDark),
                const Spacer(),
                GestureDetector(
                  onTap: _addProgress,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: kPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: kPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_progressItems.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No progress yet. Tap + to add.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white38 : kTextMuted,
                  ),
                ),
              )
            else
              ..._progressItems.asMap().entries.map(
                (e) => _progressTile(e.key, e.value, isDark),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: isDark ? kSurfaceDark : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _save,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: kPrimary.withValues(alpha: 0.4)),
                  foregroundColor: kPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────

  Widget _sectionLabel(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white70 : kTextMuted,
      ),
    );
  }

  Widget _infoChip(String label, Color bg, Color fg) {
    return Container(
      padding: kContentPaddingTiny,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  Widget _memberChip(int index, String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: kPrimary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: kPrimary,
            child: Text(
              name[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            name,
            style: const TextStyle(
              fontSize: 13,
              color: kPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => setState(() => _members.removeAt(index)),
            child: const Icon(Icons.close_rounded, size: 14, color: kPrimary),
          ),
        ],
      ),
    );
  }

  Widget _progressTile(int index, String text, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: kContentPaddingSmall,
      decoration: BoxDecoration(
        color: isDark ? kCardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: kPrimary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : kTextDark,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => setState(() => _progressItems.removeAt(index)),
            child: Icon(
              Icons.close_rounded,
              size: 16,
              color: isDark ? Colors.white38 : kTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}
