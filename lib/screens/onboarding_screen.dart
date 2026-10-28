import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import 'setup_screen.dart';

/// Three-slide onboarding shown on first launch.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  static const _slides = [
    _OnboardingSlideData(
      icon: Icons.route,
      headline: 'Prepare before you ride',
      subtitle: "Save trusted contacts and log your ride's plate number.",
    ),
    _OnboardingSlideData(
      icon: Icons.sos,
      headline: 'Ask for help fast',
      subtitle:
          'Hold the SOS button for 3 seconds. We prepare a text with your location for your contacts.',
    ),
    _OnboardingSlideData(
      icon: Icons.signal_cellular_alt,
      headline: 'Works without mobile data',
      subtitle:
          'We use GPS and SMS, so you need cellular signal and load, not internet. Tadaima does not replace calling 911.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToNext() {
    if (_currentPage < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    } else {
      _goToSetup();
    }
  }

  void _goToSetup() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const SetupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.screenPadding,
                  vertical: AppTheme.spaceSm,
                ),
                child: TextButton(
                  onPressed: _goToSetup,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(48, 48),
                  ),
                  child: const Text('Skip'),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return _OnboardingSlide(slide: slide);
                },
              ),
            ),
            // Bottom area: dots + button
            Padding(
              padding: const EdgeInsets.all(AppTheme.screenPadding),
              child: Row(
                children: [
                  // Page dots
                  Expanded(
                    child: Row(
                      children: List.generate(_slides.length, (index) {
                        final active = index == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: AppTheme.spaceSm),
                          height: 8,
                          width: active ? 24 : 8,
                          decoration: BoxDecoration(
                            color: active ? AppColors.primary : AppColors.divider,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spaceMd),
                  if (isLast)
                    FilledButton(
                      onPressed: _goToSetup,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(120, AppTheme.buttonHeight),
                      ),
                      child: const Text('Continue'),
                    )
                  else
                    Semantics(
                      label: 'Next',
                      button: true,
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: FilledButton(
                          onPressed: _goToNext,
                          style: FilledButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(48, 48),
                          ),
                          child: const Icon(Icons.arrow_forward),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlideData {
  const _OnboardingSlideData({
    required this.icon,
    required this.headline,
    required this.subtitle,
  });

  final IconData icon;
  final String headline;
  final String subtitle;
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({required this.slide});

  final _OnboardingSlideData slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.primaryTint,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                slide.icon,
                size: 96,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spaceXl),
          Text(
            slide.headline,
            style: AppTextStyles.title,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spaceMd),
          Text(
            slide.subtitle,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
