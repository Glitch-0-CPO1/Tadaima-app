import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// The big red SOS button.
///
/// The user must press and hold for [holdDuration] (3 seconds by default) to
/// avoid sending an SOS by accident. While holding, a white progress ring
/// fills around the circle. Releasing early cancels and resets the ring.
/// When the hold completes we vibrate the phone and call [onCompleted].
class SosButton extends StatefulWidget {
  const SosButton({
    super.key,
    required this.onCompleted,
    this.holdDuration = const Duration(seconds: 3),
  });

  /// Called once the button has been held for the full [holdDuration].
  final VoidCallback onCompleted;

  /// How long the user must hold the button.
  final Duration holdDuration;

  /// Fixed diameter of the button. 200 is well above the 48dp tap-target
  /// minimum, which is important for a button used in a hurry.
  static const double size = 200;

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.holdDuration,
    )..addStatusListener(_onStatusChanged);
  }

  void _onStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      // A short, strong buzz tells the user (who may not be looking at the
      // screen) that the SOS action is going ahead.
      HapticFeedback.vibrate();
      widget.onCompleted();
    }
  }

  /// Called the moment a finger touches down: start filling the ring.
  void _startHold() {
    _controller.forward(from: 0);
  }

  /// Called when the finger lifts or leaves the button before the hold
  /// finished. Cancels and resets the ring. Does nothing if already completed
  /// (so the completion is not undone on release).
  void _cancelHold() {
    if (_controller.status != AnimationStatus.completed) {
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'SOS button. Press and hold for three seconds to send an SOS.',
      child: GestureDetector(
        onTapDown: (_) => _startHold(),
        onTapUp: (_) => _cancelHold(),
        onTapCancel: _cancelHold,
        child: SizedBox(
          width: SosButton.size,
          height: SosButton.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // The solid red circle.
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.sosRed,
                ),
              ),
              // The white progress ring drawn on top of the circle.
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return CustomPaint(
                    size: const Size.square(SosButton.size),
                    painter: _ProgressRingPainter(progress: _controller.value),
                  );
                },
              ),
              // The SOS label and the hold hint.
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'SOS',
                    style: AppTextStyles.display.copyWith(
                      color: AppColors.onSos,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hold 3 seconds',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.onSos,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Paints the white progress ring around the SOS circle.
///
/// [progress] runs from 0.0 (not held) to 1.0 (fully held). We always draw a
/// faint full-circle track so the user can see what will fill up, then the
/// bright filled arc on top.
class _ProgressRingPainter extends CustomPainter {
  const _ProgressRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const double stroke = 8;
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - stroke) / 2;

    // Faint track: white at 30% opacity.
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = AppColors.onSos.withValues(alpha: 0.30);
    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      // Filled arc: starts at the top (12 o'clock) and sweeps clockwise.
      final progressPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = AppColors.onSos;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
