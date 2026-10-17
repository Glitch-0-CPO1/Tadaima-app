import 'package:flutter/material.dart';

import '../data/safety_tips_data.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// Safety tips screen: a short, offline list of general guidance.
///
/// The tips are placeholder content (see [kSafetyTips]) and the footer reminds
/// the student to call 911 when in danger.
class SafetyTipsScreen extends StatelessWidget {
  const SafetyTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Safety tips')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.screenPadding),
          children: [
            Text('For your commute', style: AppTextStyles.title),
            const SizedBox(height: AppTheme.spaceMd),
            for (final tip in kSafetyTips) ...[
              _TipCard(tip: tip),
              const SizedBox(height: AppTheme.spaceSm),
            ],
            const SizedBox(height: AppTheme.spaceMd),
            Text(
              'Tips are general guidance. In danger, call 911.',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// One tip shown as a card: a strong title and a body paragraph.
class _TipCard extends StatelessWidget {
  const _TipCard({required this.tip});

  final SafetyTip tip;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tip.title, style: AppTextStyles.bodyStrong),
            const SizedBox(height: AppTheme.spaceXs),
            Text(tip.body, style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }
}
