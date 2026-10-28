import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// A card row with leading widget, title/subtitle, and a round 48x48 action button.
class ActionListTile extends StatelessWidget {
  const ActionListTile({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.onAction,
    required this.actionIcon,
    required this.actionLabel,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final VoidCallback onAction;
  final IconData actionIcon;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        child: Row(
          children: [
            leading,
            const SizedBox(width: AppTheme.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyStrong,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppTheme.spaceXs),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppTheme.spaceSm),
            Semantics(
              label: actionLabel,
              button: true,
              child: IconButton(
                onPressed: onAction,
                icon: Icon(actionIcon),
                iconSize: 24,
                constraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 48,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
