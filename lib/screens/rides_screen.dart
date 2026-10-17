import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ride.dart';
import '../providers/rides_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// Rides tab: log a ride and see the recent ones.
///
/// Business logic (saving, loading, keeping the newest 30) lives in
/// [RidesProvider]; this screen only collects input and shows the list.
class RidesScreen extends StatefulWidget {
  const RidesScreen({super.key});

  @override
  State<RidesScreen> createState() => _RidesScreenState();
}

class _RidesScreenState extends State<RidesScreen> {
  /// The fixed set of vehicle choices shown in the dropdown.
  static const List<String> _vehicleTypes = <String>[
    'Tricycle',
    'Jeepney',
    'Bus',
    'Other',
  ];

  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _driverController = TextEditingController();

  String _vehicleType = _vehicleTypes.first;
  String? _plateError;
  bool _saved = false;

  @override
  void dispose() {
    _plateController.dispose();
    _driverController.dispose();
    super.dispose();
  }

  /// Validates and saves the ride, then clears the form.
  Future<void> _save() async {
    // Trim and upper-case the plate so "abc 123 " and "ABC 123" are the same.
    final plate = _plateController.text.trim().toUpperCase();
    if (plate.isEmpty) {
      setState(() => _plateError = 'Please enter a plate or body number');
      return;
    }

    await context.read<RidesProvider>().add(
          vehicleType: _vehicleType,
          plate: plate,
          driverName: _driverController.text.trim(),
        );

    if (!mounted) {
      return;
    }
    _plateController.clear();
    _driverController.clear();
    setState(() {
      _plateError = null;
      _saved = true;
      _vehicleType = _vehicleTypes.first;
    });
  }

  /// Asks for confirmation before deleting a ride.
  Future<void> _confirmDelete(Ride ride) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this ride?'),
        content: Text(
          '${ride.vehicleType} · ${ride.plate} will be removed from your '
          'recent rides.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            style: TextButton.styleFrom(
              minimumSize: const Size(64, AppTheme.buttonHeight),
            ),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.danger,
              minimumSize: const Size(64, AppTheme.buttonHeight),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }
    await context.read<RidesProvider>().delete(ride.id);
  }

  @override
  Widget build(BuildContext context) {
    final rides = context.watch<RidesProvider>().rides;

    return ListView(
      padding: const EdgeInsets.all(AppTheme.screenPadding),
      children: [
        Text('Log a ride', style: AppTextStyles.title),
        const SizedBox(height: AppTheme.spaceMd),
        _buildForm(),
        if (_saved) ...[
          const SizedBox(height: AppTheme.spaceMd),
          _SavedBanner(onDismiss: () => setState(() => _saved = false)),
        ],
        const SizedBox(height: AppTheme.spaceXl),
        Text('Recent rides', style: AppTextStyles.heading),
        const SizedBox(height: AppTheme.spaceMd),
        if (rides.isEmpty)
          const _EmptyState()
        else
          for (final ride in rides) ...[
            _RideCard(
              ride: ride,
              onDelete: () => _confirmDelete(ride),
            ),
            const SizedBox(height: AppTheme.spaceSm),
          ],
      ],
    );
  }

  /// The vehicle dropdown, the two text fields and the Save button.
  Widget _buildForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _vehicleType,
              decoration: const InputDecoration(labelText: 'Vehicle type'),
              items: [
                for (final type in _vehicleTypes)
                  DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _vehicleType = value);
                }
              },
            ),
            const SizedBox(height: AppTheme.spaceMd),
            TextField(
              controller: _plateController,
              textCapitalization: TextCapitalization.characters,
              maxLength: 12,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Plate or body number',
                counterText: '',
                errorText: _plateError,
              ),
              // Clear the error as soon as the student starts typing again.
              onChanged: (_) {
                if (_plateError != null) {
                  setState(() => _plateError = null);
                }
              },
            ),
            const SizedBox(height: AppTheme.spaceMd),
            TextField(
              controller: _driverController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Driver name (optional)',
              ),
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            Text(
              'Saved only on this phone. The latest plate is included in '
              'your SOS.',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: AppTheme.spaceMd),
            FilledButton(
              onPressed: _save,
              child: const Text('Save ride'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Green banner shown after a successful save. Icon + text, never colour-only.
class _SavedBanner extends StatelessWidget {
  const _SavedBanner({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spaceMd,
        AppTheme.spaceSm,
        AppTheme.spaceSm,
        AppTheme.spaceSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.successBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success),
          const SizedBox(width: AppTheme.spaceSm),
          Expanded(
            child: Text(
              'Ride saved',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            tooltip: 'Dismiss',
            icon: const Icon(Icons.close),
            color: AppColors.success,
          ),
        ],
      ),
    );
  }
}

/// One saved ride shown as a card with a delete button.
class _RideCard extends StatelessWidget {
  const _RideCard({required this.ride, required this.onDelete});

  final Ride ride;
  final VoidCallback onDelete;

  /// Picks an icon for the vehicle type so the list is easy to scan.
  IconData get _icon {
    switch (ride.vehicleType) {
      case 'Tricycle':
        return Icons.two_wheeler;
      case 'Jeepney':
        return Icons.airport_shuttle;
      case 'Bus':
        return Icons.directions_bus;
      default:
        return Icons.directions_car;
    }
  }

  /// Builds the small line under the title: time, then driver if present.
  String _subtitle(BuildContext context) {
    final parts = <String>[_formatRideTime(context, ride.createdAt)];
    final driver = ride.driverName.trim();
    if (driver.isNotEmpty) {
      parts.add('Driver: $driver');
    }
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(_icon, color: AppColors.primaryDark),
        title: Text(
          '${ride.vehicleType} · ${ride.plate}',
          style: AppTextStyles.bodyStrong,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(_subtitle(context), style: AppTextStyles.caption),
        trailing: IconButton(
          onPressed: onDelete,
          tooltip: 'Delete ride',
          icon: const Icon(Icons.delete_outline),
          color: AppColors.danger,
        ),
      ),
    );
  }
}

/// Shown when there is nothing logged yet.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Column(
          children: [
            const Icon(
              Icons.directions_car_outlined,
              size: 32,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              'No rides logged yet.',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Formats a ride time as "Today 8:45 PM", "Yesterday 8:45 PM" or
/// "Wed, Oct 15, 8:45 PM" using the phone's own date/time formatting.
String _formatRideTime(BuildContext context, DateTime time) {
  final local = time.toLocal();
  final l10n = MaterialLocalizations.of(context);
  final clock = l10n.formatTimeOfDay(TimeOfDay.fromDateTime(local));

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final thatDay = DateTime(local.year, local.month, local.day);
  final daysAgo = today.difference(thatDay).inDays;

  if (daysAgo == 0) {
    return 'Today $clock';
  }
  if (daysAgo == 1) {
    return 'Yesterday $clock';
  }
  return '${l10n.formatMediumDate(local)}, $clock';
}
