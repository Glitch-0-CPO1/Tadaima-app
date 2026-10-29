import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/contacts_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/rides_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../widgets/icon_tile.dart';
import '../widgets/section_header.dart';
import '../widgets/sos_button.dart';
import 'safe_places_screen.dart';
import 'safety_tips_screen.dart';
import 'sos_confirm_screen.dart';
import 'tadaima_screen.dart';

/// Home tab: redesigned home screen.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onOpenContacts,
    this.onOpenRides,
  });

  /// Switches the app to the Contacts tab.
  final VoidCallback onOpenContacts;
  /// Switches the app to the Rides tab.
  final VoidCallback? onOpenRides;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  _LocationStatus _locationStatus = _LocationStatus.checking;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshLocationStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshLocationStatus();
    }
  }

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
    if (!mounted) return;
    setState(() => _locationStatus = status);
  }

  Future<void> _handleLocationTap() async {
    // Never request permission automatically when Home loads, only after a tap.
    if (_locationStatus == _LocationStatus.on) {
      return;
    }
    if (_locationStatus == _LocationStatus.blocked) {
      try {
        await Geolocator.openAppSettings();
      } catch (_) {}
      await _refreshLocationStatus();
      return;
    }
    // off - request permission
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        try {
          await Geolocator.openAppSettings();
        } catch (_) {}
        await _refreshLocationStatus();
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        try {
          await Geolocator.openAppSettings();
        } catch (_) {}
      }
    } catch (_) {}
    await _refreshLocationStatus();
  }

  String _greeting(ProfileProvider profile) {
    final name = profile.name.trim();
    final firstName = name.isEmpty ? '' : name.split(RegExp(r'\s+')).first;
    final hour = DateTime.now().hour;
    if (name.isEmpty) {
      return 'Hello there';
    }
    if (hour < 12) {
      return 'Good morning, $firstName';
    } else if (hour < 18) {
      return 'Good afternoon, $firstName';
    } else {
      return 'Good evening, $firstName';
    }
  }

  void _openNameEditSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _NameEditSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final contacts = context.watch<ContactsProvider>();
    final rides = context.watch<RidesProvider>();
    final contactCount = contacts.contacts.length;

    final hasName = profile.hasName;
    final greeting = _greeting(profile);

    String contactsText;
    if (contacts.isLoaded && contactCount == 0) {
      contactsText = 'No trusted contacts';
    } else if (contactCount == 1) {
      contactsText = '1 trusted contact';
    } else {
      contactsText = '$contactCount trusted contacts';
    }

    String locationText;
    switch (_locationStatus) {
      case _LocationStatus.on:
        locationText = 'Location on';
        break;
      case _LocationStatus.blocked:
      case _LocationStatus.off:
      case _LocationStatus.checking:
        locationText = 'Location off';
        break;
    }

    final hasContacts = contactCount >= 1;
    final locationDone = _locationStatus == _LocationStatus.on;
    final latestRide = rides.latestRecentRide;
    final rideDone = latestRide != null;

    int readyCount = 0;
    if (hasContacts) readyCount++;
    if (locationDone) readyCount++;
    if (rideDone) readyCount++;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.screenPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppTheme.spaceLg),
                      Text(
                        greeting,
                        style: AppTextStyles.title.copyWith(
                          color: AppColors.onPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!hasName) ...[
                        const SizedBox(height: AppTheme.spaceXs),
                        Semantics(
                          button: true,
                          label: 'Add your name',
                          child: InkWell(
                            onTap: _openNameEditSheet,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                'Add your name',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.onPrimary.withValues(alpha: 0.9),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppTheme.spaceXs),
                      Text(
                        "Let's get you home safe.",
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.onPrimary.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceMd),
                      Wrap(
                        spacing: AppTheme.spaceSm,
                        runSpacing: AppTheme.spaceSm,
                        children: [
                          Semantics(
                            label: contactsText,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.onPrimary.withValues(alpha: 0.15),
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusChip),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.people_outline,
                                    size: 18,
                                    color: AppColors.onPrimary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    contactsText,
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.onPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Semantics(
                            label: locationText,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.onPrimary.withValues(alpha: 0.15),
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusChip),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _locationStatus == _LocationStatus.on
                                        ? Icons.location_on
                                        : (_locationStatus == _LocationStatus.blocked
                                            ? Icons.block
                                            : Icons.location_off),
                                    size: 18,
                                    color: AppColors.onPrimary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    locationText,
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.onPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
              child: Transform.translate(
                offset: const Offset(0, -24),
                child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Emergency', style: AppTextStyles.heading),
                        const SizedBox(height: AppTheme.spaceXs),
                        Text(
                          'Hold the button for 3 seconds. We prepare a text with your location for your trusted contacts.',
                          style: AppTextStyles.caption,
                        ),
                        const SizedBox(height: AppTheme.spaceLg),
                        Center(
                          child: SosButton(
                            onCompleted: () => _openSosConfirm(context),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spaceMd),
                        Text(
                          'Needs cellular signal and load to send SMS.',
                          style: AppTextStyles.caption,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
              child: FilledButton.icon(
                onPressed: () => _openTadaima(context),
                icon: const Icon(Icons.home),
                label: const Text("Tadaima - I'm home safe"),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, AppTheme.buttonHeight),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spaceLg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader('Ready to ride?'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spaceMd),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (readyCount < 3) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: readyCount / 3.0,
                                minHeight: 8,
                                backgroundColor: AppColors.divider,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppColors.primary),
                              ),
                            ),
                            const SizedBox(height: AppTheme.spaceSm),
                            Text(
                              '$readyCount of 3 ready',
                              style: AppTextStyles.caption,
                            ),
                            const SizedBox(height: AppTheme.spaceMd),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.all(AppTheme.spaceMd),
                              decoration: BoxDecoration(
                                color: AppColors.successBg,
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusCard),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle,
                                      color: AppColors.success),
                                  const SizedBox(width: AppTheme.spaceSm),
                                  Expanded(
                                    child: Text(
                                      "You're ready to ride.",
                                      style: AppTextStyles.bodyStrong.copyWith(
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppTheme.spaceMd),
                          ],
                          _ChecklistRow(
                            icon: Icons.people,
                            title: hasContacts
                                ? (contactCount == 1
                                    ? '1 contact saved'
                                    : '$contactCount contacts saved')
                                : 'Add a trusted contact',
                            subtitle: hasContacts
                                ? 'Trusted contacts ready'
                                : 'You need at least one contact',
                            done: hasContacts,
                            onTap: hasContacts ? null : () => widget.onOpenContacts(),
                            semanticsLabel: hasContacts
                                ? 'Trusted contacts done'
                                : 'Add a trusted contact',
                          ),
                          const SizedBox(height: AppTheme.spaceSm),
                          _ChecklistRow(
                            icon: _locationStatus == _LocationStatus.on
                                ? Icons.location_on
                                : Icons.location_off,
                            title: locationDone
                                ? 'Location allowed'
                                : (_locationStatus == _LocationStatus.blocked
                                    ? 'Location blocked'
                                    : 'Location off'),
                            subtitle: locationDone
                                ? 'Location services ready'
                                : 'Tap to enable or open settings',
                            done: locationDone,
                            onTap: _handleLocationTap,
                            semanticsLabel: locationDone
                                ? 'Location done'
                                : 'Location not ready, tap to fix',
                          ),
                          const SizedBox(height: AppTheme.spaceSm),
                          _ChecklistRow(
                            icon: Icons.directions_car,
                            title: rideDone
                                ? 'Ride logged: ${latestRide.vehicleType} ${latestRide.plate}'
                                : "Log your ride's plate number",
                            subtitle: rideDone
                                ? 'Recent ride available'
                                : 'Add your current ride details',
                            done: rideDone,
                            onTap: rideDone
                                ? null
                                : () {
                                    if (widget.onOpenRides != null) {
                                      widget.onOpenRides!();
                                    } else {
                                      widget.onOpenContacts();
                                    }
                                  },
                            semanticsLabel: rideDone
                                ? 'Ride logged'
                                : 'Log your ride',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spaceLg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader('Quick actions'),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final textScale = MediaQuery.textScalerOf(context).scale(1.0);
                      if (textScale > 1.3 || constraints.maxWidth < 300) {
                        return Column(
                          children: [
                            _QuickActionTile(
                              icon: Icons.place,
                              label: 'Safe places',
                              onTap: () => _openSafePlaces(context),
                            ),
                            const SizedBox(height: AppTheme.spaceSm),
                            _QuickActionTile(
                              icon: Icons.lightbulb,
                              label: 'Safety tips',
                              onTap: () => _openSafetyTips(context),
                            ),
                            const SizedBox(height: AppTheme.spaceSm),
                            _QuickActionTile(
                              icon: Icons.phone,
                              label: 'Call 911',
                              onTap: () => _call911(context),
                              isDanger: true,
                            ),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(
                            child: _QuickActionTile(
                              icon: Icons.place,
                              label: 'Safe places',
                              onTap: () => _openSafePlaces(context),
                            ),
                          ),
                          const SizedBox(width: AppTheme.spaceSm),
                          Expanded(
                            child: _QuickActionTile(
                              icon: Icons.lightbulb,
                              label: 'Safety tips',
                              onTap: () => _openSafetyTips(context),
                            ),
                          ),
                          const SizedBox(width: AppTheme.spaceSm),
                          Expanded(
                            child: _QuickActionTile(
                              icon: Icons.phone,
                              label: 'Call 911',
                              onTap: () => _call911(context),
                              isDanger: true,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spaceXxl),
          ],
        ),
      ),
    );
  }

  void _openSosConfirm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SosConfirmScreen(onOpenContacts: widget.onOpenContacts),
      ),
    );
  }

  void _openTadaima(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TadaimaScreen(onOpenContacts: widget.onOpenContacts),
      ),
    );
  }

  void _openSafePlaces(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SafePlacesScreen()),
    );
  }

  void _openSafetyTips(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SafetyTipsScreen()),
    );
  }

  Future<void> _call911(BuildContext context) async {
    final uri = Uri.parse('tel:911');
    try {
      await launchUrl(uri);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the dialer.')),
        );
      }
    }
  }
}

enum _LocationStatus { checking, on, off, blocked }

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.done,
    required this.onTap,
    required this.semanticsLabel,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool done;
  final VoidCallback? onTap;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spaceMd,
              vertical: AppTheme.spaceSm,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Row(
                children: [
                  IconTile(
                    icon: icon,
                    color: done ? AppColors.success : AppColors.primary,
                    background: done ? AppColors.successBg : AppColors.primaryTint,
                  ),
                  const SizedBox(width: AppTheme.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.bodyStrong,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: AppTextStyles.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppTheme.spaceSm),
                  Icon(
                    done ? Icons.check_circle : Icons.chevron_right,
                    color: done ? AppColors.success : AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDanger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final tileColor = isDanger ? AppColors.dangerBg : AppColors.primaryTint;
    final iconColor = isDanger ? AppColors.danger : AppColors.primary;
    final textColor = isDanger ? AppColors.danger : AppColors.textPrimary;
    return Semantics(
      label: label,
      button: true,
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 96),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconTile(icon: icon, color: iconColor, background: tileColor),
                  const SizedBox(height: AppTheme.spaceSm),
                  Text(
                    label,
                    style: AppTextStyles.bodyStrong.copyWith(color: textColor),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NameEditSheet extends StatefulWidget {
  const _NameEditSheet();

  @override
  State<_NameEditSheet> createState() => _NameEditSheetState();
}

class _NameEditSheetState extends State<_NameEditSheet> {
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
