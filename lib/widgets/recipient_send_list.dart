import 'package:flutter/material.dart';

import '../models/contact.dart';
import '../services/sms_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// Shows one row per trusted [contacts], each with a `Send to <name>` button.
///
/// Tapping a button asks [buildMessage] for the finished SOS text (which may
/// wait a moment for the location), then opens the SMS app with
/// [SmsService.openSms]. After that the row shows "Opened in SMS app" with a
/// check icon and text, so the result is never shown by colour alone.
///
/// This widget is reused by the SOS flow and can be reused by the "Tadaima"
/// safe-arrival flow later.
class RecipientSendList extends StatelessWidget {
  const RecipientSendList({
    super.key,
    required this.contacts,
    required this.buildMessage,
  });

  /// The people who should receive the message.
  final List<Contact> contacts;

  /// Returns the message to send. Called when a "Send" button is tapped, so it
  /// can wait for the best location data before building the text.
  final Future<String> Function() buildMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < contacts.length; i++) ...[
          if (i > 0) const SizedBox(height: AppTheme.spaceSm),
          _RecipientRow(contact: contacts[i], buildMessage: buildMessage),
        ],
      ],
    );
  }
}

/// What a single row is currently doing.
enum _SendStatus { idle, sending, opened, failed }

/// A single contact with its own send button and result state.
class _RecipientRow extends StatefulWidget {
  const _RecipientRow({required this.contact, required this.buildMessage});

  final Contact contact;
  final Future<String> Function() buildMessage;

  @override
  State<_RecipientRow> createState() => _RecipientRowState();
}

class _RecipientRowState extends State<_RecipientRow> {
  _SendStatus _status = _SendStatus.idle;

  Future<void> _send() async {
    // Guard against double taps while the message is being prepared.
    if (_status == _SendStatus.sending) {
      return;
    }

    setState(() => _status = _SendStatus.sending);

    final body = await widget.buildMessage();
    final opened = await SmsService.openSms(widget.contact.phone, body);

    if (!mounted) {
      return;
    }
    setState(
      () => _status = opened ? _SendStatus.opened : _SendStatus.failed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasRelationship = widget.contact.relationship.trim().isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.contact.name,
              style: AppTextStyles.bodyStrong,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (hasRelationship) ...[
              const SizedBox(height: AppTheme.spaceXs),
              Text(widget.contact.relationship, style: AppTextStyles.caption),
            ],
            const SizedBox(height: AppTheme.spaceXs),
            Text(widget.contact.phone, style: AppTextStyles.caption),
            const SizedBox(height: AppTheme.spaceMd),
            _buildAction(),
          ],
        ),
      ),
    );
  }

  /// The button or status shown under the contact details.
  Widget _buildAction() {
    switch (_status) {
      case _SendStatus.idle:
        return FilledButton.icon(
          onPressed: _send,
          icon: const Icon(Icons.send),
          label: Text('Send to ${widget.contact.name}'),
        );

      case _SendStatus.sending:
        // Kept at the button height so the row does not jump.
        return SizedBox(
          height: AppTheme.buttonHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: AppTheme.spaceSm),
              Text('Opening...'),
            ],
          ),
        );

      case _SendStatus.opened:
        // Icon + text together: the success state is not colour-only.
        return SizedBox(
          height: AppTheme.buttonHeight,
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.success),
              const SizedBox(width: AppTheme.spaceSm),
              Expanded(
                child: Text(
                  'Opened in SMS app',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );

      case _SendStatus.failed:
        // Friendly failure: explain and let the user try again.
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.danger),
                const SizedBox(width: AppTheme.spaceSm),
                Expanded(
                  child: Text(
                    'Could not open the SMS app.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceSm),
            OutlinedButton.icon(
              onPressed: _send,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        );
    }
  }
}
