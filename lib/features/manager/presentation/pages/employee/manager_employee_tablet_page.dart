import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/position_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/left_panel_position_widget.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/right_employee_panel_widget.dart';

class ManagerEmployeeTabletPage extends StatefulWidget {
  const ManagerEmployeeTabletPage({super.key});

  @override
  State<ManagerEmployeeTabletPage> createState() =>
      _ManagerEmployeeTabletPageState();
}

class _ManagerEmployeeTabletPageState extends State<ManagerEmployeeTabletPage> {
  String? _selectedPositionId;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<EmployeeController>();
    final posCtrl = Get.find<PositionController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ColoredBox(
      color: isDark ? kBgDark : kBgLight,
      child: Row(
        children: [
          // ── Left Panel: Positions ─────────────────────────
          SizedBox(
            width: 260,
            child: LeftPanelPositionWidget(
              isDark: isDark,
              ctrl: ctrl,
              posCtrl: posCtrl,
              selectedId: _selectedPositionId,
              onSelect: (id) => setState(() => _selectedPositionId = id),
            ),
          ),

          VerticalDivider(
            width: 1,
            thickness: 1,
            color: isDark
                ? Colors.white.withAlpha(15)
                : Colors.black.withAlpha(10),
          ),

          // ── Right Panel: Employees ────────────────────────
          Expanded(
            child: RightEmployeePanelWidget(
              isDark: isDark,
              ctrl: ctrl,
              selectedPositionId: _selectedPositionId,
            ),
          ),
        ],
      ),
    );
  }
}
