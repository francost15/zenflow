import 'package:app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// Shimmer loading effect widget.
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? AppColors.darkSurfaceElevated
        : AppColors.lightSurfaceElevated;
    final highlightColor = isDark
        ? AppColors.darkBorder
        : AppColors.lightBorder;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [0.0, _controller.value, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Task tile skeleton with shimmer effect.
class TaskTileSkeleton extends StatelessWidget {
  const TaskTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.obsidian : Colors.white,
        border: Border.all(
          color: isDark ? AppColors.monolithBorder : Colors.black12,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          ShimmerLoading(
            width: 28,
            height: 28,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoading(
                  width: 150,
                  height: 14,
                  borderRadius: BorderRadius.circular(2),
                ),
                const SizedBox(height: 8),
                ShimmerLoading(
                  width: 80,
                  height: 10,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Task list skeleton with multiple task tiles.
class TaskListSkeleton extends StatelessWidget {
  final int itemCount;

  const TaskListSkeleton({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount, (_) => const TaskTileSkeleton()),
    );
  }
}

/// Calendar skeleton shimmer.
class CalendarSkeleton extends StatelessWidget {
  const CalendarSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Week strip skeleton
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.obsidian
                : Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: List.generate(
              7,
              (_) => Expanded(
                child: ShimmerLoading(
                  width: double.infinity,
                  height: 60,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Event placeholders
        ...List.generate(
          3,
          (_) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.obsidian
                  : Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ShimmerLoading(
              width: double.infinity,
              height: 20,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }
}
