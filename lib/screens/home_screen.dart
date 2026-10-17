import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/contacts_provider.dart';
import '../providers/profile_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../widgets/sos_button.dart';
import 'safe_places_screen.dart';
import 'safety_tips_screen.dart';
import 'sos_confirm_screen.dart';
import 'tadaima_screen.dart';

/// Home tab: greeting, the big SOS button, the "Tadaima" button and quick
/// links to Safe places and Safety tips.
///
/// This screen only reads from [ProfileProvider] and [ContactsProvider]; all
/// saving and SMS/GPS logic lives in providers and services, not here.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onOpenContacts});

  /// Switches the app to the Contacts tab. Passed in by [AppShell] because the
  /// bottom navigation index lives there.
  final VoidCallback onOpenContacts;

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final contacts = context.watch<ContactsProvider>();
    final contactCount = contacts.contacts.length;

    return ListView(
      padding: const EdgeInsets.all(AppTheme.screenPadding),
      children: [
        // Greeting, or the "what's your name?" card on first run.
        if (profile.hasName)
          Text(
            'Hi, ${profile.name}! Ready for your ride?',
            style: AppTextStyles.title,
          )
        else
          const _NameCard(),

        const SizedBox(height: AppTheme.spaceSm),
        Text(
          'SMS + GPS · $contactCount trusted contacts',
          style: AppTextStyles.caption,
        ),

        // Reminder banner when there is nobody to text.
        if (contacts.isLoaded && contacts.isEmpty) ...[
          const SizedBox(height: AppTheme.spaceMd),
          _AddContactsBanner(onAddContacts: onOpenContacts),
        ],

        const SizedBox(height: AppTheme.spaceXl),

        // The big hold-to-send SOS button.
        Center(
          child: SosButton(
            onCompleted: () => _openSosConfirm(context),
          ),
        ),

        const SizedBox(height: AppTheme.spaceXl),

        FilledButton(
          onPressed: () => _openTadaima(context),
          child: const Text("Tadaima - I'm home safe"),
        ),

        const SizedBox(height: AppTheme.spaceLg),

        Row(
          children: [
            Expanded(
              child: _QuickLinkCard(
                title: 'Safe places',
                icon: Icons.place_outlined,
                onTap: () => _openSafePlaces(context),
              ),
            ),
            const SizedBox(width: AppTheme.spaceMd),
            Expanded(
              child: _QuickLinkCard(
                title: 'Safety tips',
                icon: Icons.tips_and_updates_outlined,
                onTap: () => _openSafetyTips(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _openSosConfirm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        // Pass the "open Contacts" callback so the SOS screen can offer it in
        // its "no trusted contacts" warning.
        builder: (_) => SosConfirmScreen(onOpenContacts: onOpenContacts),
      ),
    );
  }

  /// Opens the "I'm home safe" flow. No GPS is needed there.
  void _openTadaima(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TadaimaScreen(onOpenContacts: onOpenContacts),
      ),
    );
  }

  /// Opens the Safe places list.
  void _openSafePlaces(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SafePlacesScreen()),
    );
  }

  /// Opens the Safety tips list.
  void _openSafetyTips(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SafetyTipsScreen()),
    );
  }
}

/// First-run card that asks the student for their name.
///
/// The name is used in the SOS text, so we ask for it before relying on SOS.
class _NameCard extends StatefulWidget {
  const _NameCard();

  @override
  State<_NameCard> createState() => _NameCardState();
}

class _NameCardState extends State<_NameCard> {
  final _controller = TextEditingController();
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final value = _controller.text.trim();
    if (value.isEmpty) {
      // Friendly validation instead of saving a blank name.
      setState(() => _error = 'Please enter your name');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    await context.read<ProfileProvider>().saveName(value);

    if (mounted) {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("What's your name?", style: AppTextStyles.heading),
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              'We use it in your SOS texts.',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: AppTheme.spaceMd),
            TextField(
              controller: _controller,
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
      ),
    );
  }
}

/// Amber banner shown when there are no trusted contacts saved yet.
class _AddContactsBanner extends StatelessWidget {
  const _AddContactsBanner({required this.onAddContacts});

  final VoidCallback onAddContacts;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon + text together, so the warning is not colour-only.
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.warning,
              ),
              const SizedBox(width: AppTheme.spaceSm),
              Expanded(
                child: Text(
                  'Add at least one trusted contact before relying on SOS.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: onAddContacts,
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Add contact'),
            ),
          ),
        ],
      ),
    );
  }
}

/// One of the two quick-link tiles on the Home screen.
class _QuickLinkCard extends StatelessWidget {
  const _QuickLinkCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceMd),
          child: Column(
            children: [
              Icon(icon, size: 32, color: AppColors.primary),
              const SizedBox(height: AppTheme.spaceSm),
              Text(
                title,
                style: AppTextStyles.bodyStrong,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
