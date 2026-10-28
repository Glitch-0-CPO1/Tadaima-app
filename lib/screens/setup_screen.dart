import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../providers/profile_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../widgets/icon_tile.dart';

/// Final setup step after onboarding slides.
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _locationStatusText;
  IconData? _locationStatusIcon;
  Color? _locationStatusColor;
  bool _locationChecked = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _allowLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (!mounted) {
        return;
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        setState(() {
          _locationStatusText = 'Location allowed';
          _locationStatusIcon = Icons.check_circle;
          _locationStatusColor = AppColors.success;
          _locationChecked = true;
        });
      } else {
        setState(() {
          _locationStatusText =
              'Location not allowed. You can change this in More.';
          _locationStatusIcon = Icons.info_outline;
          _locationStatusColor = AppColors.warning;
          _locationChecked = true;
        });
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _locationStatusText =
            'Location not allowed. You can change this in More.';
        _locationStatusIcon = Icons.info_outline;
        _locationStatusColor = AppColors.warning;
        _locationChecked = true;
      });
    }
  }

  Future<void> _startUsingApp() async {
    final profileProvider = context.read<ProfileProvider>();
    final name = _nameController.text;
    if (name.trim().isNotEmpty) {
      await profileProvider.saveName(name);
    }
    await profileProvider.markOnboardingDone();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const AppShell()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Almost ready'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.screenPadding),
          children: [
            Text(
              'Your name (optional)',
              style: AppTextStyles.bodyStrong,
            ),
            const SizedBox(height: AppTheme.spaceSm),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'Enter your name',
                helperText: 'Used in your SOS texts. Stays on this phone.',
              ),
            ),
            const SizedBox(height: AppTheme.spaceLg),
            // Location explanation card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spaceMd),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const IconTile(icon: Icons.location_on),
                    const SizedBox(width: AppTheme.spaceMd),
                    Expanded(
                      child: Text(
                        'Why location? We add your position to your SOS text so your contacts can find you. We only ask when you press SOS, and the SOS still works without it.',
                        style: AppTextStyles.body,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            OutlinedButton(
              onPressed: _allowLocation,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, AppTheme.buttonHeight),
              ),
              child: const Text('Allow location now'),
            ),
            if (_locationChecked && _locationStatusText != null)
              Padding(
                padding: const EdgeInsets.only(top: AppTheme.spaceSm),
                child: Row(
                  children: [
                    Icon(
                      _locationStatusIcon,
                      color: _locationStatusColor,
                      size: 20,
                    ),
                    const SizedBox(width: AppTheme.spaceSm),
                    Expanded(
                      child: Text(
                        _locationStatusText!,
                        style: AppTextStyles.caption.copyWith(
                          color: _locationStatusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const Spacer(),
            const SizedBox(height: AppTheme.spaceLg),
            FilledButton(
              onPressed: _startUsingApp,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, AppTheme.buttonHeight),
              ),
              child: const Text('Start using Tadaima'),
            ),
          ],
        ),
      ),
    );
  }
}
