import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';
import '../services/location_service.dart';
import '../services/sms_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import 'safe_places_screen.dart';
import 'safety_tips_screen.dart';

/// The GPS permission state we show in the Permissions section.
enum _LocationStatus { checking, on, off, blocked }

/// More tab: name, permissions, emergency numbers, extra links and about.
///
/// Read-only status (like the GPS permission) is fetched with the platform
/// plugins; all state that must be saved lives in [ProfileProvider].
class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  _LocationStatus _locationStatus = _LocationStatus.checking;

  @override
  void initState() {
    super.initState();
    _refreshLocationStatus();
  }

  /// Reads the current location permission and service state.
  ///
  /// Never throws: any error is treated as "off".
  Future<void> _refreshLocationStatus() async {
    var status = _LocationStatus.off;
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        status = _LocationStatus.off;
      } else {
        final permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.deniedForever) {
          status = _LocationStatus.blocked;
        } else if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          status = _LocationStatus.on;
        } else {
          status = _LocationStatus.off;
        }
      }
    } catch (_) {
      status = _LocationStatus.off;
    }

    if (!mounted) {
      return;
    }
    setState(() => _locationStatus = status);
  }

  /// Opens the app's system settings, then re-checks the permission.
  Future<void> _openSettings() async {
    final opened = await LocationService().openAppSettings();
    if (!mounted) {
      return;
    }
    if (!opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open settings.')),
      );
    }
    // The student may have changed the permission while away.
    await _refreshLocationStatus();
  }

  /// Opens the phone dialer with 911 typed in. Never dials by itself.
  Future<void> _call911() async {
    final opened = await SmsService.openDialer911();
    if (!mounted || opened) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open the dialer.')),
    );
  }

  /// Opens the bottom sheet used to edit the saved name.
  Future<void> _editName() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _EditNameSheet(),
    );
  }

  void _openSafePlaces() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SafePlacesScreen()),
    );
  }

  void _openSafetyTips() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SafetyTipsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();

    return ListView(
      padding: const EdgeInsets.all(AppTheme.screenPadding),
      children: [
        // --- Your name ---
        const _SectionHeader('Your name'),
        Card(
          child: ListTile(
            leading: const Icon(
              Icons.person_outline,
              color: AppColors.primaryDark,
            ),
            title: Text(
              profile.hasName ? profile.name : 'Not set',
              style: AppTextStyles.bodyStrong,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              'Used in your SOS and Tadaima texts',
              style: AppTextStyles.caption,
            ),
            trailing: TextButton.icon(
              onPressed: _editName,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit'),
              style: TextButton.styleFrom(
                minimumSize: const Size(64, AppTheme.buttonHeight),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spaceLg),

        // --- Permissions ---
        const _SectionHeader('Permissions'),
        _buildPermissionsCard(),
        const SizedBox(height: AppTheme.spaceLg),

        // --- Emergency ---
        const _SectionHeader('Emergency'),
        _buildEmergencyCard(),
        const SizedBox(height: AppTheme.spaceLg),

        // --- Learn more ---
        const _SectionHeader('Learn more'),
        Card(
          child: Column(
            children: [
              _LinkTile(
                icon: Icons.place_outlined,
                title: 'Safe places',
                onTap: _openSafePlaces,
              ),
              const Divider(height: 1),
              _LinkTile(
                icon: Icons.tips_and_updates_outlined,
                title: 'Safety tips',
                onTap: _openSafetyTips,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spaceLg),

        // --- About ---
        const _SectionHeader('About Tadaima'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spaceMd),
            child: Text(
              'Tadaima · ITMSD1 Hackathon · Team F-7 · SDG 5',
              style: AppTextStyles.body,
            ),
          ),
        ),
      ],
    );
  }

  /// The location status row plus the SMS explanation.
  Widget _buildPermissionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon + text together, so the status is not colour-only.
                Icon(_statusIcon, color: _statusColor),
                const SizedBox(width: AppTheme.spaceSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Location', style: AppTextStyles.bodyStrong),
                      const SizedBox(height: AppTheme.spaceXs),
                      Text(
                        _statusLabel,
                        style: AppTextStyles.caption.copyWith(
                          color: _statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceXs),
                      Text(_statusExplanation, style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceMd),
            OutlinedButton.icon(
              onPressed: _openSettings,
              icon: const Icon(Icons.settings),
              label: const Text('Open settings'),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            const Divider(height: 1),
            const SizedBox(height: AppTheme.spaceMd),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.sms_outlined,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppTheme.spaceSm),
                Expanded(
                  child: Text(
                    'SMS: we open your SMS app, so no SMS permission is '
                    'needed.',
                    style: AppTextStyles.caption,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// The Call 911 button and the numbers placeholder line.
  Widget _buildEmergencyCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.icon(
              onPressed: _call911,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: AppColors.onPrimary,
              ),
              icon: const Icon(Icons.phone),
              label: const Text('Call 911 (opens dialer)'),
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              'This only opens the dialer. The app never calls by itself.',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: AppTheme.spaceMd),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.contacts_outlined,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppTheme.spaceSm),
                Expanded(
                  child: Text(
                    'Add your barangay and school numbers in Contacts',
                    style: AppTextStyles.caption,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData get _statusIcon {
    switch (_locationStatus) {
      case _LocationStatus.on:
        return Icons.location_on;
      case _LocationStatus.off:
      case _LocationStatus.checking:
        return Icons.location_off;
      case _LocationStatus.blocked:
        return Icons.block;
    }
  }

  Color get _statusColor {
    switch (_locationStatus) {
      case _LocationStatus.on:
        return AppColors.success;
      case _LocationStatus.off:
      case _LocationStatus.checking:
        return AppColors.warning;
      case _LocationStatus.blocked:
        return AppColors.danger;
    }
  }

  String get _statusLabel {
    switch (_locationStatus) {
      case _LocationStatus.checking:
        return 'Checking...';
      case _LocationStatus.on:
        return 'On';
      case _LocationStatus.off:
        return 'Off';
      case _LocationStatus.blocked:
        return 'Blocked';
    }
  }

  String get _statusExplanation {
    switch (_locationStatus) {
      case _LocationStatus.checking:
        return 'Checking your location permission.';
      case _LocationStatus.on:
        return 'Location is allowed and services are on.';
      case _LocationStatus.off:
        return 'Location is not allowed yet. Your SOS still works without it.';
      case _LocationStatus.blocked:
        return 'Permission is blocked. Change it in settings to share your '
            'location.';
    }
  }
}

/// A section label above a group of cards.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceSm),
      child: Text(title, style: AppTextStyles.heading),
    );
  }
}

/// A tappable row used for the "Learn more" links.
class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.primaryDark),
      title: Text(title, style: AppTextStyles.body),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

/// Bottom sheet for editing the saved name.
class _EditNameSheet extends StatefulWidget {
  const _EditNameSheet();

  @override
  State<_EditNameSheet> createState() => _EditNameSheetState();
}

class _EditNameSheetState extends State<_EditNameSheet> {
  late final TextEditingController _controller;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: context.read<ProfileProvider>().name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final value = _controller.text.trim();
    if (value.isEmpty) {
      setState(() => _error = 'Please enter your name');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    await context.read<ProfileProvider>().saveName(value);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Lift the sheet above the keyboard when it is open.
      padding: EdgeInsets.only(
        left: AppTheme.spaceMd,
        right: AppTheme.spaceMd,
        top: AppTheme.spaceMd,
        bottom: AppTheme.spaceMd + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Your name', style: AppTextStyles.heading),
          const SizedBox(height: AppTheme.spaceMd),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Your name',
              errorText: _error,
            ),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: AppTheme.spaceMd),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
