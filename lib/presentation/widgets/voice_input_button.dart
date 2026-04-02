import 'package:app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Voice input button with listening animation.
class VoiceInputButton extends StatefulWidget {
  const VoiceInputButton({
    super.key,
    required this.onResult,
    this.isListening = false,
  });

  final ValueChanged<String> onResult;
  final bool isListening;

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with SingleTickerProviderStateMixin {
  final SpeechToText _speechToText = SpeechToText();
  bool _isAvailable = false;
  bool _isListening = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _speechToText.stop();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    _isAvailable = await _speechToText.initialize(
      onError: (error) => _handleError(error.errorMsg),
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          _stopListening();
        }
      },
    );
    if (mounted) {
      setState(() {});
    }
  }

  void _handleError(String error) {
    _stopListening();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de voz: $error'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _toggleListening() async {
    if (!_isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voice input no está disponible'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  Future<void> _startListening() async {
    setState(() => _isListening = true);
    _pulseController.repeat(reverse: true);

    await _speechToText.listen(
      onResult: (result) {
        if (result.finalResult) {
          widget.onResult(result.recognizedWords);
          _stopListening();
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
    );
  }

  void _stopListening() {
    _speechToText.stop();
    _pulseController.stop();
    _pulseController.reset();
    if (mounted) {
      setState(() => _isListening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: _toggleListening,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isListening ? _pulseAnimation.value : 1.0,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _isListening
                    ? AppColors.accent
                    : (isDark
                          ? AppColors.darkSurfaceElevated
                          : AppColors.lightSurfaceElevated),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _isListening
                      ? AppColors.accent
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
              ),
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                size: 20,
                color: _isListening
                    ? Colors.white
                    : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary),
              ),
            ),
          );
        },
      ),
    );
  }
}
