import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ride.dart';
import '../providers/contacts_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/rides_provider.dart';
import '../services/location_service.dart';
import '../services/sms_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../widgets/recipient_send_list.dart';

/// The "Send SOS" screen.
///
/// As soon as it opens it starts looking for the best location, but it never
/// blocks the user: they can tap Send immediately and we will wait for the
/// location before building the text. The screen always shows a preview of
/// exactly what will be sent, plus quick access to Calling 911.
///
/// [onOpenContacts] is used by the "no contacts" warning to jump to the
/// Contacts tab after this screen closes.
class SosConfirmScreen extends StatefulWidget {
  const SosConfirmScreen({super.key, this.onOpenContacts});

  /// Switches the app to the Contacts tab once this screen is popped.
  final VoidCallback? onOpenContacts;

  @override
  State<SosConfirmScreen> createState() => _SosConfirmScreenState();
}

class _SosConfirmScreenState extends State<SosConfirmScreen> {
  final LocationService _locationService = LocationService();

  /// The in-flight location lookup. Kept so a Send tap can await the same
  /// result instead of starting a second lookup.
  late final Future<LocationFix?> _fixFuture;

  LocationFix? _fix;
  bool _locating = true;
  bool _permissionDeniedForever = false;

  @override
  void initState() {
    super.initState();
    _fixFuture = _locationService.getBestFix();
    _loadLocation();
  }

  /// Waits for the location lookup and updates the screen when it finishes.
  Future<void> _loadLocation() async {
    final fix = await _fixFuture;
    if (!mounted) {
      return;
    }
    setState(() {
      _fix = fix;
      _locating = false;
      _permissionDeniedForever = _locationService.permissionDeniedForever;
    });
  }

  /// The text shown in the preview card.
  ///
  /// While we are still locating, the location line reads "getting it now..."
  /// instead of the final "unavailable" line.
  String _previewMessage(String name, Ride? recentRide) {
    final full = SmsService.buildSosMessage(
      name: name,
      fix: _fix,
      plate: recentRide?.plate,
      plateLoggedAt: recentRide?.createdAt,
    );
    if (_locating && _fix == null) {
      return full.replaceFirst(
        SmsService.noLocationLine,
        'Location: getting it now...',
      );
    }
    return full;
  }

  /// Builds the message for sending, waiting for the location if it is still
  /// on its way. GPS failure still sends with "Location: unavailable".
  Future<String> _messageForSend(String name, Ride? recentRide) async {
    var fix = _fix;
    if (fix == null && _locating) {
      try {
        // The service already caps a fresh fix at 30 seconds; this outer
        // timeout covers the last-known fallback too.
        fix = await _fixFuture.timeout(const Duration(seconds: 35));
      } catch (_) {
        // Ignore: we send with whatever we have.
      }
    }
    return SmsService.buildSosMessage(
      name: name,
      fix: fix,
      plate: recentRide?.plate,
      plateLoggedAt: recentRide?.createdAt,
    );
  }

  /// Closes this screen and switches to the Contacts tab.
  void _openContacts() {
    Navigator.of(context).pop();
    widget.onOpenContacts?.call();
  }

  /// Opens the SMS app with the message but no fixed recipient.
  Future<void> _chooseRecipientInSms(String name, Ride? recentRide) async {
    final opened =
        await SmsService.openSms('', await _messageForSend(name, recentRide));
    if (!mounted || opened) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open the SMS app.')),
    );
  }

  Future<void> _call911() async {
    final opened = await SmsService.openDialer911();
    if (!mounted || opened) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open the dialer.')),
    );
  }

  Future<void> _openSettings() async {
    final opened = await _locationService.openAppSettings();
    if (!mounted || opened) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open settings.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch the profile so the preview updates if the name changes.
    final name = context.watch<ProfileProvider>().name;
    final contacts = context.watch<ContactsProvider>().contacts;
    // The newest ride logged in the last 12 hours, if any, supplies the plate.
    final recentRide = context.watch<RidesProvider>().latestRecentRide;

    return Scaffold(
      appBar: AppBar(title: const Text('Send SOS')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppTheme.screenPadding),
                children: [
                  _buildLocationSection(),
                  const SizedBox(height: AppTheme.spaceLg),
                  _PreviewCard(message: _previewMessage(name, recentRide)),
                  const SizedBox(height: AppTheme.spaceLg),
                  if (contacts.isEmpty)
                    _NoContactsBlock(
                      onOpenContacts: _openContacts,
                      onChooseInSms: () =>
                          _chooseRecipientInSms(name, recentRide),
                    )
                  else
                    RecipientSendList(
                      contacts: contacts,
                      buildMessage: () => _messageForSend(name, recentRide),
                    ),
                  const SizedBox(height: AppTheme.spaceXl),
                  FilledButton.icon(
                    onPressed: _call911,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      foregroundColor: AppColors.onPrimary,
                    ),
                    icon: const Icon(Icons.phone),
                    label: const Text('Call 911'),
                  ),
                  const SizedBox(height: AppTheme.spaceSm),
                  Text(
                    'If you are in danger, call 911 too.',
                    style: AppTextStyles.caption,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spaceXl),
                  Text(
                    'Needs cellular signal and load to send SMS. '
                    'This app does not replace emergency services.',
                    style: AppTextStyles.caption,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // Cancel stays visible no matter how long the content is.
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.screenPadding,
                AppTheme.spaceSm,
                AppTheme.screenPadding,
                AppTheme.screenPadding,
              ),
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The location status area: progress, warning or ready.
  Widget _buildLocationSection() {
    final children = <Widget>[];

    if (_locating) {
      children.add(
        const _Banner(
          icon: Icons.location_searching,
          background: AppColors.primaryTint,
          foreground: AppColors.primaryDark,
          text: 'Getting your location...',
          child: Padding(
            padding: EdgeInsets.only(top: AppTheme.spaceSm),
            child: LinearProgressIndicator(),
          ),
        ),
      );
      children.add(const SizedBox(height: AppTheme.spaceSm));
      children.add(
        Text(
          'This can take up to 30 seconds. You can still send now.',
          style: AppTextStyles.caption,
        ),
      );
    } else if (_fix == null) {
      children.add(
        _Banner(
          icon: Icons.location_off,
          background: AppColors.dangerBg,
          foreground: AppColors.danger,
          text: _permissionDeniedForever
              ? 'Location permission is off. Enable it in settings to share '
                  'your location. Your SOS will still be sent without it.'
              : 'Location unavailable. Your SOS will be sent without it.',
        ),
      );
      if (_permissionDeniedForever) {
        children.add(const SizedBox(height: AppTheme.spaceSm));
        children.add(
          OutlinedButton.icon(
            onPressed: _openSettings,
            icon: const Icon(Icons.settings),
            label: const Text('Open settings'),
          ),
        );
      }
    } else if (!_fix!.fresh) {
      children.add(
        const _Banner(
          icon: Icons.history,
          background: AppColors.warningBg,
          foreground: AppColors.warning,
          text: 'Using your last known location. It may be old.',
        ),
      );
    } else {
      children.add(
        const _Banner(
          icon: Icons.check_circle,
          background: AppColors.successBg,
          foreground: AppColors.success,
          text: 'Location ready.',
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
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
    this.child,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final String text;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          ?child,
        ],
      ),
    );
  }
}
