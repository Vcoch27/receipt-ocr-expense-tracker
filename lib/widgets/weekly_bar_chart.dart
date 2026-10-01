import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../l10n/l10n.dart';

class WeeklyBarChart extends StatefulWidget {
  const WeeklyBarChart({super.key, required this.values});
  final List<int> values;

  @override
  State<WeeklyBarChart> createState() => _WeeklyBarChartState();
}

class _WeeklyBarChartState extends State<WeeklyBarChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _animation.value = 1;
    } else if (_animation.status == AnimationStatus.dismissed) {
      _animation.forward();
    }
  }

  @override
  void didUpdateWidget(covariant WeeklyBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.values != widget.values) {
      if (MediaQuery.disableAnimationsOf(context)) {
        _animation.value = 1;
      } else {
        _animation.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = [
      context.l10n.mon,
      context.l10n.tue,
      context.l10n.wed,
      context.l10n.thu,
      context.l10n.fri,
      context.l10n.sat,
      context.l10n.sun,
    ];
    final total = widget.values.fold<int>(0, (a, b) => a + b);
    return Semantics(
      label: context.l10n.weekChartSemantics(formatVnd(total)),
      child: Column(
        children: [
          SizedBox(
            height: 170,
            width: double.infinity,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (_, _) => CustomPaint(
                painter: _BarPainter(
                  values: widget.values,
                  progress: _animation.value,
                  color: Theme.of(context).colorScheme.primary,
                  grid: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: labels
                .map(
                  (label) => Expanded(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  const _BarPainter({
    required this.values,
    required this.progress,
    required this.color,
    required this.grid,
  });
  final List<int> values;
  final double progress;
  final Color color;
  final Color grid;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
    final maxValue = values.fold<int>(0, math.max);
    if (maxValue == 0) return;
    final slot = size.width / 7;
    final width = math.min(26.0, slot * .55);
    final barPaint = Paint()..color = color;
    for (var i = 0; i < 7; i++) {
      final height = (values[i] / maxValue) * (size.height - 8) * progress;
      final left = slot * i + (slot - width) / 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, size.height - height, width, height),
          const Radius.circular(6),
        ),
        barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.values != values ||
      oldDelegate.color != color ||
      oldDelegate.grid != grid;
}
