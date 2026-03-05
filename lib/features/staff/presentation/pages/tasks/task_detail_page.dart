import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/staff/data/models/task_model.dart';
import 'package:task_tracking_mobile/features/staff/presentation/controllers/task_controller.dart';

part 'task_detail_header.dart';
part 'task_detail_sections.dart';
part 'task_detail_components.dart';

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

  String _itemText(String item) =>
      item.startsWith('[x]') ? item.substring(3).trim() : item.trim();

  void _showNoteSheet({
    required String title,
    required String hint,
    required String initial,
    required String buttonLabel,
    required void Function(String) onSubmit,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputCtrl = TextEditingController(text: initial);
    Get.bottomSheet(
      _NoteSheet(
        isDark: isDark,
        title: title,
        hint: hint,
        buttonLabel: buttonLabel,
        controller: inputCtrl,
        onSubmit: (text) {
          onSubmit(text);
          Get.back();
        },
      ),
      isScrollControlled: true,
    );
  }

  void _addProgress() => _showNoteSheet(
        title: 'Add progress note',
        hint: 'What did you accomplish?',
        initial: '',
        buttonLabel: 'Add note',
        onSubmit: (text) => setState(() => _progressItems.add(text)),
      );

  void _editProgress(int index) => _showNoteSheet(
        title: 'Edit progress note',
        hint: 'Edit your note...',
        initial: _itemText(_progressItems[index]),
        buttonLabel: 'Save',
        onSubmit: (text) => setState(() => _progressItems[index] = text),
      );

  void _addMember() {
    final name = _memberCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _members.add(name);
      _memberCtrl.clear();
    });
  }

  void _save() {
    widget.ctrl.updateTask(widget.task.copyWith(
      description: _descCtrl.text.trim(),
      members: _members,
      progressItems: _progressItems,
    ));
    Get.back();
  }

  void _submit() {
    widget.ctrl.updateTask(widget.task.copyWith(
      description: _descCtrl.text.trim(),
      status: TaskStatus.done,
      members: _members,
      progressItems: _progressItems,
    ));
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFFE5E7EB);
    final cardBg = isDark ? kCardDark : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? kBgDark : const Color(0xFFF9FAFB),
      appBar: _buildAppBar(isDark, borderColor, cardBg),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TaskHeaderCard(
                task: widget.task, isDark: isDark,
                borderColor: borderColor, cardBg: cardBg),
            const SizedBox(height: 16),
            _DescriptionCard(
                controller: _descCtrl, isDark: isDark,
                borderColor: borderColor, cardBg: cardBg),
            const SizedBox(height: 12),
            _MembersCard(
                members: _members,
                controller: _memberCtrl,
                isDark: isDark,
                borderColor: borderColor,
                cardBg: cardBg,
                onAdd: _addMember,
                onRemove: (i) => setState(() => _members.removeAt(i))),
            const SizedBox(height: 12),
            _ProgressCard(
                items: _progressItems,
                isDark: isDark,
                borderColor: borderColor,
                cardBg: cardBg,
                onAdd: _addProgress,
                onEdit: _editProgress,
                onDelete: (i) => setState(() => _progressItems.removeAt(i)),
                itemText: _itemText),
          ],
        ),
      ),
      bottomNavigationBar: _BottomBar(
        isDark: isDark,
        borderColor: borderColor,
        onSave: _save,
        onComplete: _submit,
      ),
    );
  }

  AppBar _buildAppBar(bool isDark, Color borderColor, Color cardBg) {
    return AppBar(
      backgroundColor: isDark ? kBgDark : const Color(0xFFF9FAFB),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: GestureDetector(
        onTap: Get.back,
        child: Container(
          margin: const EdgeInsets.only(left: 16),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          child: Icon(Icons.arrow_back_ios_new_rounded,
              size: 16, color: isDark ? Colors.white : kTextDark),
        ),
      ),
      leadingWidth: 60,
      title: Text(
        'Task Detail',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white70 : kTextMuted,
        ),
      ),
    );
  }
}
