import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/contact.dart';
import '../providers/contacts_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// Contacts tab: the list of trusted contacts that receive SOS texts.
///
/// The screen only reads from and writes to [ContactsProvider]; it never
/// touches storage itself. Adding happens in a bottom sheet, deleting asks
/// for confirmation first.
class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ContactsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppTheme.screenPadding),
            children: [
              Text('Trusted contacts', style: AppTextStyles.title),
              const SizedBox(height: AppTheme.spaceSm),
              Text(
                'Your SOS and safe-arrival texts go to these contacts.',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: AppTheme.spaceMd),
              const _WarningBanner(),
              const SizedBox(height: AppTheme.spaceLg),
              if (provider.isEmpty)
                _EmptyState(
                  onAdd: () => _showAddContactSheet(context),
                )
              else
                ...provider.contacts.map(
                  (contact) => Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.spaceSm),
                    child: _ContactCard(
                      contact: contact,
                      onDelete: () => _confirmDelete(context, contact),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppTheme.screenPadding),
          child: FilledButton(
            onPressed: () => _showAddContactSheet(context),
            child: const Text('Add contact'),
          ),
        ),
      ],
    );
  }

  /// Opens the bottom sheet with the "add contact" form.
  Future<void> _showAddContactSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _AddContactSheet(),
    );
  }

  /// Asks the user to confirm before removing [contact].
  Future<void> _confirmDelete(BuildContext context, Contact contact) async {
    final provider = context.read<ContactsProvider>();

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete contact?'),
        content: Text(
          'Remove ${contact.name} from your trusted contacts? '
          'They will no longer receive your SOS texts.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await provider.delete(contact.id);
    }
  }
}

/// A single trusted contact, shown as a card with a delete button.
class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.contact, required this.onDelete});

  final Contact contact;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final hasRelationship = contact.relationship.isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primaryTint,
              child: Icon(Icons.person, color: AppColors.primaryDark),
            ),
            const SizedBox(width: AppTheme.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: AppTextStyles.bodyStrong,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (hasRelationship) ...[
                    const SizedBox(height: AppTheme.spaceXs),
                    Text(contact.relationship, style: AppTextStyles.caption),
                  ],
                  const SizedBox(height: AppTheme.spaceXs),
                  Text(contact.phone, style: AppTextStyles.caption),
                ],
              ),
            ),
            // IconButton already gives a 48x48 tap target.
            IconButton(
              onPressed: onDelete,
              tooltip: 'Delete ${contact.name}',
              icon: const Icon(Icons.delete_outline),
              color: AppColors.danger,
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when there are no contacts saved yet.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceXl),
      child: Column(
        children: [
          const Icon(
            Icons.people_outline,
            size: 64,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppTheme.spaceMd),
          Text(
            'No trusted contacts yet. Add a family member or friend who can '
            'respond when you need help.',
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spaceLg),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Add contact'),
          ),
        ],
      ),
    );
  }
}

/// The amber reminder that SMS delivery cannot be guaranteed.
class _WarningBanner extends StatelessWidget {
  const _WarningBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.warning),
          const SizedBox(width: AppTheme.spaceSm),
          Expanded(
            child: Text(
              'SMS delivery is not guaranteed. Tell your contacts what to do '
              'if they get an SOS.',
              style: AppTextStyles.caption.copyWith(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }
}

/// The "add contact" form shown inside a bottom sheet.
///
/// Validates the name and the Philippine mobile number before saving via the
/// [ContactsProvider].
class _AddContactSheet extends StatefulWidget {
  const _AddContactSheet();

  @override
  State<_AddContactSheet> createState() => _AddContactSheetState();
}

class _AddContactSheetState extends State<_AddContactSheet> {
  // Accepts 09XXXXXXXXX (11 digits) or +639XXXXXXXXX (12 chars).
  static final RegExp _phMobile = RegExp(r'^(09\d{9}|\+639\d{9})$');

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _relationshipController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _relationshipController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a name';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) {
      return 'Please enter a phone number';
    }
    if (!_phMobile.hasMatch(phone)) {
      return 'Use 09XXXXXXXXX or +639XXXXXXXXX';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _saving = true);

    final provider = context.read<ContactsProvider>();
    await provider.add(
      name: _nameController.text,
      relationship: _relationshipController.text,
      phone: _phoneController.text,
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: AppTheme.screenPadding,
        right: AppTheme.screenPadding,
        top: AppTheme.spaceMd,
        bottom: AppTheme.screenPadding + bottomInset,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Add contact', style: AppTextStyles.heading),
              const SizedBox(height: AppTheme.spaceLg),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: _validateName,
              ),
              const SizedBox(height: AppTheme.spaceMd),
              TextFormField(
                controller: _relationshipController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Relationship',
                  hintText: 'e.g. Mother',
                ),
              ),
              const SizedBox(height: AppTheme.spaceMd),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  hintText: '09XXXXXXXXX',
                ),
                validator: _validatePhone,
                onFieldSubmitted: (_) => _save(),
              ),
              const SizedBox(height: AppTheme.spaceLg),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: const Text('Save contact'),
              ),
              const SizedBox(height: AppTheme.spaceSm),
              OutlinedButton(
                onPressed: _saving
                    ? null
                    : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
