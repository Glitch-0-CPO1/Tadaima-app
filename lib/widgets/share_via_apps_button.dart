import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// A reusable button that opens the system share sheet with a message.
///
/// The button takes either a [message] string or a [messageBuilder] that
/// produces it. This lets callers wait for location data (like the SMS flow)
/// before sharing, matching the existing behaviour.
class ShareViaAppsButton extends StatelessWidget {
  const ShareViaAppsButton({
    super.key,
    this.message,
    this.messageBuilder,
    this.caption =
        'Opens your share menu. Pick Messenger, Viber or another app, choose a contact, then tap Send. Needs internet or Wi-Fi.',
  }) : assert(
          message != null || messageBuilder != null,
          'Either message or messageBuilder must be provided',
        );

  /// The message to share, if it is already known.
  final String? message;

  /// Builds the message to share. Useful when the message depends on location
  /// that may still be loading.
  final Future<String> Function()? messageBuilder;

  /// Caption shown below the button.
  final String caption;

  Future<void> _share(BuildContext context) async {
    String textToShare;
    if (message != null) {
      textToShare = message!;
    } else if (messageBuilder != null) {
      try {
        textToShare = await messageBuilder!();
      } catch (_) {
        if (!context.mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not prepare the message.')),
        );
        return;
      }
    } else {
      return;
    }

    try {
      await SharePlus.instance.share(
        ShareParams(text: textToShare),
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the share menu.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: 'Share via apps',
          button: true,
          child: OutlinedButton.icon(
            onPressed: () => _share(context),
            icon: const Icon(Icons.share_outlined),
            label: const Text('Share via apps'),
          ),
        ),
        const SizedBox(height: AppTheme.spaceXs),
        Text(
          caption,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
