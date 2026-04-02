import 'package:flutter/material.dart';

/// FAB with scale animation on tap for satisfying micro-interaction.
class AnimatedFAB extends StatefulWidget {
  final VoidCallback onPressed;
  final String heroTag;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Widget icon;
  final Widget label;

  const AnimatedFAB({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.heroTag = 'fab',
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<AnimatedFAB> createState() => _AnimatedFABState();
}

class _AnimatedFABState extends State<AnimatedFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    Widget fab = GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FloatingActionButton.extended(
          heroTag: widget.heroTag,
          onPressed: null,
          backgroundColor: widget.backgroundColor,
          foregroundColor: widget.foregroundColor,
          icon: widget.icon,
          label: widget.label,
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: fab);
    }

    return fab;
  }
}
