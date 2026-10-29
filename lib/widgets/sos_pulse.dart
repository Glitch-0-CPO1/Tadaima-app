import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Decorative pulse ring behind the SOS button.
/// Must not intercept touches, be excluded from Semantics, respect disableAnimations,
/// and dispose its controller properly.
class SosPulse extends StatefulWidget {
  const SosPulse({super.key, required this.child});

  final Widget child;

  @override
  State<SosPulse> createState() => _SosPulseState();
}

class _SosPulseState extends State<SosPulse> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.2, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
        _controller.forward();
      }
    });

    // Start animation if not disabled
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disableAnimations =
        MediaQuery.of(context).disableAnimations;
    if (disableAnimations) {
      if (_controller.isAnimating) {
        _controller.stop();
      }
    } else {
      if (!_controller.isAnimating && _controller.status != AnimationStatus.forward) {
        _controller.reset();
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    if (disableAnimations) {
      return IgnorePointer(
        ignoring: true,
        child: ExcludeSemantics(
          child: widget.child,
        ),
      );
    }

    return IgnorePointer(
      ignoring: true,
      child: ExcludeSemantics(
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.sosRed.withValues(alpha: _opacityAnimation.value),
                    ),
                  ),
                );
              },
            ),
            IgnorePointer(
              ignoring: true,
              child: widget.child,
            ),
          ],
        ),
      ),
    );
  }
}
