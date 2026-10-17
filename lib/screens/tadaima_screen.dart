import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/contacts_provider.dart';
import '../providers/profile_provider.dart';
import '../services/sms_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../widgets/recipient_send_list.dart';

/// The "I'm home safe" screen opened from the Home tab.
///
/// It shows the exact message that will be sent and one `Send to <name>`
/// button per trusted contact. There is no GPS here: safe arrival does not
/// need a location. The actual message text lives in [SmsService] so it can be
/// checked in one place.
///
/// [onOpenContacts] is used by the "no contacts" warning to jump to the
/// Contacts tab after this screen closes.
class TadaimaScreen extends StatelessWidget {
  const TadaimaScreen({super.key, this.onOpenContacts});

  /// Switches the app to the Contacts tab once this screen is popped.
  final VoidCallback? onOpenContacts;

  /// Closes this screen and switches to the Contacts tab.
  void _openContacts(BuildContext context) {
    Navigator.of(context).pop();
    onOpenContacts?.call();
  }

  /// Opens the SMS app with the message but no fixed recipient.
  Future<void> _chooseRecipientInSms(BuildContext context, String message) async {
    final opened = await SmsService.openSms('', message);
    if (!context.mounted || opened) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open the SMS app.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch the profile so the preview updates if the name changes.
    final name = context.watch<ProfileProvider>().name;
    final contacts = context.watch<ContactsProvider>().contacts;
    final message = SmsService.buildHomeSafeMessage(name);

    return Scaffold(
      appBar: AppBar(title: const Text('Tadaima')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.screenPadding),
          children: [
            Text('Welcome home!', style: AppTextStyles.title),
            const SizedBox(height: AppTheme.spaceMd),
            _PreviewCard(message: message),
            const SizedBox(height: AppTheme.spaceLg),
            if (contacts.isEmpty)
              _NoContactsBlock(
                onOpenContacts: () => _openContacts(context),
                onChooseInSms: () => _chooseRecipientInSms(context, message),
              )
            else
              RecipientSendList(
                contacts: contacts,
                // The message is fixed and needs no GPS, but the widget asks
                // for a Future, so we wrap it in an async function.
                buildMessage: () async => message,
              ),
            const SizedBox(height: AppTheme.spaceXl),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

/// A card that shows the exact SMS text that will be sent.
class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Message preview', style: AppTextStyles.heading),
            const SizedBox(height: AppTheme.spaceSm),
            Text(message, style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }
}

/// Warning shown when there is nobody to text.
///
/// The same block is used on the SOS screen, including the "Choose recipient
/// in SMS app" fallback so the student is never stuck.
class _NoContactsBlock extends StatelessWidget {
  const _NoContactsBlock({
    required this.onOpenContacts,
    required this.onChooseInSms,
  });

  final VoidCallback onOpenContacts;
  final VoidCallback onChooseInSms;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Banner(
          icon: Icons.warning_amber_rounded,
          background: AppColors.warningBg,
          foreground: AppColors.warning,
          text: 'No trusted contacts saved.',
        ),
        const SizedBox(height: AppTheme.spaceMd),
        OutlinedButton.icon(
          onPressed: onOpenContacts,
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text('Add a contact'),
        ),
        const SizedBox(height: AppTheme.spaceSm),
        FilledButton.icon(
          onPressed: onChooseInSms,
          icon: const Icon(Icons.sms_outlined),
          label: const Text('Choose recipient in SMS app'),
        ),
      ],
    );
  }
}

/// A small coloured message box that always pairs an icon with text, so the
/// meaning never depends on colour alone.
class _Banner extends StatelessWidget {
  const _Banner({
    required this.icon,
    required this.background,
    required this.foreground,
    required this.text,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: foreground),
          const SizedBox(width: AppTheme.spaceSm),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.caption.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
