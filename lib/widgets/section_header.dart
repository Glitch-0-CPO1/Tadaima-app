import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// Section header with Heading text style, 24 top spacing and 8 bottom spacing.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppTheme.spaceLg,
        bottom: AppTheme.spaceSm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: AppTextStyles.heading),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
