import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/categories.dart';
import '../core/formatters.dart';
import '../l10n/l10n.dart';

class DonutChart extends StatefulWidget {
  const DonutChart({super.key, required this.values});
  final Map<String, int> values;

  @override
  State<DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<DonutChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 550),
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
  void didUpdateWidget(covariant DonutChart oldWidget) {
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
    final total = widget.values.values.fold<int>(0, (a, b) => a + b);
    return Semantics(
      label: context.l10n.categoryChartSemantics(formatVnd(total)),
      child: SizedBox(
        height: 230,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (_, _) => CustomPaint(
                size: const Size(220, 220),
                painter: _DonutPainter(
                  values: widget.values,
                  progress: _animation.value,
                  track: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.allSpending,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  formatVnd(total),
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({
    required this.values,
    required this.progress,
    required this.track,
  });
  final Map<String, int> values;
  final double progress;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final rect = Rect.fromCircle(
      center: center,
      radius: size.shortestSide / 2 - 16,
    );
    final base = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24;
    canvas.drawArc(rect, 0, math.pi * 2, false, base);
    final total = values.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) return;
    var start = -math.pi / 2;
    for (final entry in values.entries) {
      final sweep = (entry.value / total) * math.pi * 2 * progress;
      final paint = Paint()
        ..color = categoryColor(entry.key)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 24;
      canvas.drawArc(rect, start, math.max(0, sweep - .025), false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.values != values ||
      oldDelegate.track != track;
}
