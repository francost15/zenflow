import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ZenModeScreen extends StatefulWidget {
  final VoidCallback onExit;
  final String? taskName;

  const ZenModeScreen({super.key, required this.onExit, this.taskName});

  @override
  State<ZenModeScreen> createState() => _ZenModeScreenState();
}

class _ZenModeScreenState extends State<ZenModeScreen>
    with SingleTickerProviderStateMixin {
  static const int _totalSeconds = 25 * 60; // 25 minutes
  int _remainingSeconds = _totalSeconds;
  Timer? _timer;
  bool _isRunning = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
        setState(() => _isRunning = false);
      }
    });
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      _startTimer();
    }
  }

  double get _progress => 1.0 - (_remainingSeconds / _totalSeconds);

  String get _timeString {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // Zen mode always uses light background
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // ─── Task Name Badge ───
            if (widget.taskName != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.lightBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.menu_book,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        widget.taskName!.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          letterSpacing: 0.5,
                          color: AppColors.lightTextPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

            // ─── Timer Ring ───
            Expanded(
              child: GestureDetector(
                onTap: _toggleTimer,
                child: Center(
                  child: SizedBox(
                    width: 260,
                    height: 260,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background ring
                        SizedBox(
                          width: 260,
                          height: 260,
                          child: CircularProgressIndicator(
                            value: 1.0,
                            strokeWidth: 8,
                            color: AppColors.lightBorder,
                          ),
                        ),
                        // Progress ring
                        SizedBox(
                          width: 260,
                          height: 260,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: _progress),
                            duration: const Duration(milliseconds: 500),
                            builder: (context, value, child) {
                              return CustomPaint(
                                painter: _ProgressRingPainter(
                                  progress: value,
                                  color: AppColors.accent,
                                  strokeWidth: 10,
                                ),
                              );
                            },
                          ),
                        ),
                        // Timer text
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _timeString,
                              style: const TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -2,
                                color: AppColors.lightTextPrimary,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isRunning ? 'ENFOQUE' : 'PAUSADO',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 3,
                                color: _isRunning
                                    ? AppColors.lightTextTertiary
                                    : AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ─── Exit Button ───
            Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: GestureDetector(
                onTap: widget.onExit,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.lightTextTertiary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'RENDIRSE',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                        color: AppColors.lightTextTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw arc from top (270°) clockwise
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      2 * math.pi * progress, // Sweep angle
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
