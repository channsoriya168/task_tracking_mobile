import 'package:flutter/material.dart';

class ProfileShimmerWidget extends StatefulWidget {
  const ProfileShimmerWidget({required this.isDark});
  final bool isDark;

  @override
  State<ProfileShimmerWidget> createState() => _ProfileShimmerState();
}

class _ProfileShimmerState extends State<ProfileShimmerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.05);
    final highlight = widget.isDark
        ? Colors.white.withValues(alpha: 0.13)
        : Colors.black.withValues(alpha: 0.10);

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final c = Color.lerp(base, highlight, _anim.value)!;
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // title placeholder
              _Box(c: c, width: 100, height: 22),
              const SizedBox(height: 28),

              // ── Header: avatar + name/role/email ──────────────
              Row(
                children: [
                  _Box(c: c, width: 72, height: 72, radius: 36),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Box(c: c, width: double.infinity, height: 16),
                        const SizedBox(height: 8),
                        _Box(c: c, width: 120, height: 12),
                        const SizedBox(height: 6),
                        _Box(c: c, width: 160, height: 12),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),
              Divider(height: 1, color: c),
              const SizedBox(height: 24),

              // ── Section label ─────────────────────────────────
              _Box(c: c, width: 90, height: 13),
              const SizedBox(height: 14),

              // ── Groups placeholder rows ───────────────────────
              _InfoRow(c: c),
              const SizedBox(height: 10),
              _InfoRow(c: c),
              const SizedBox(height: 28),

              // ── Personal info label ───────────────────────────
              _Box(c: c, width: 110, height: 13),
              const SizedBox(height: 14),
              _InfoRow(c: c),
              const SizedBox(height: 10),
              _InfoRow(c: c),
              const SizedBox(height: 10),
              _InfoRow(c: c),
              const SizedBox(height: 28),

              // ── Settings label ────────────────────────────────
              _Box(c: c, width: 80, height: 13),
              const SizedBox(height: 14),
              _InfoRow(c: c),
              const SizedBox(height: 10),
              _InfoRow(c: c),
            ],
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.c});
  final Color c;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      _Box(c: c, width: 20, height: 20, radius: 4),
      const SizedBox(width: 12),
      Expanded(
        child: _Box(c: c, width: double.infinity, height: 14),
      ),
    ],
  );
}

class _Box extends StatelessWidget {
  const _Box({
    required this.c,
    required this.width,
    required this.height,
    this.radius = 6,
  });
  final Color c;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: c,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}
