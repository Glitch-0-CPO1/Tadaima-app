import 'package:flutter/material.dart';

import '../data/safe_places_data.dart';
import '../models/safe_place.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// Which places the list is showing.
enum _PlaceFilter { all, stores, helpPosts }

/// Safe places screen: a filterable, offline list of places to head to.
///
/// The data is placeholder only (see [kSafePlaces]); the banner tells the
/// student to verify places before trusting them.
class SafePlacesScreen extends StatefulWidget {
  const SafePlacesScreen({super.key});

  @override
  State<SafePlacesScreen> createState() => _SafePlacesScreenState();
}

class _SafePlacesScreenState extends State<SafePlacesScreen> {
  _PlaceFilter _filter = _PlaceFilter.all;

  /// The places matching the current filter.
  List<SafePlace> get _visiblePlaces {
    switch (_filter) {
      case _PlaceFilter.all:
        return kSafePlaces;
      case _PlaceFilter.stores:
        return kSafePlaces.where((p) => p.isStore).toList();
      case _PlaceFilter.helpPosts:
        return kSafePlaces.where((p) => p.isHelpPost).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final places = _visiblePlaces;

    return Scaffold(
      appBar: AppBar(title: const Text('Safe places')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.screenPadding),
          children: [
            Wrap(
              spacing: AppTheme.spaceSm,
              runSpacing: AppTheme.spaceSm,
              children: [
                _buildFilterChip('All', _PlaceFilter.all),
                _buildFilterChip('Stores', _PlaceFilter.stores),
                _buildFilterChip('Help posts', _PlaceFilter.helpPosts),
              ],
            ),
            const SizedBox(height: AppTheme.spaceMd),
            const _InfoBanner(
              text: 'Illustrative places, not vetted. Verify the hours and '
                  'staff on arrival.',
            ),
            const SizedBox(height: AppTheme.spaceLg),
            if (places.isEmpty)
              const _EmptyState()
            else
              for (final place in places) ...[
                _PlaceCard(place: place),
                const SizedBox(height: AppTheme.spaceSm),
              ],
          ],
        ),
      ),
    );
  }

  /// Builds one filter chip. The selected chip uses the primary colour, white
  /// text and a check mark so the choice is clear without relying on colour.
  Widget _buildFilterChip(String label, _PlaceFilter value) {
    final selected = _filter == value;
    return FilterChip(
      label: Text(label),
      selected: selected,
      showCheckmark: true,
      onSelected: (_) => setState(() => _filter = value),
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary,
      checkmarkColor: AppColors.onPrimary,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      side: BorderSide(
        color: selected ? AppColors.primary : AppColors.borderInput,
      ),
      labelStyle: AppTextStyles.caption.copyWith(
        color: selected ? AppColors.onPrimary : AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// A single place with its name, type chip, hours and landmark.
class _PlaceCard extends StatelessWidget {
  const _PlaceCard({required this.place});

  final SafePlace place;

  IconData get _icon =>
      place.isStore ? Icons.storefront : Icons.local_police_outlined;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_icon, color: AppColors.primaryDark),
                const SizedBox(width: AppTheme.spaceSm),
                Expanded(
                  child: Text(place.name, style: AppTextStyles.bodyStrong),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceSm),
            _TypeChip(label: place.typeLabel),
            const SizedBox(height: AppTheme.spaceSm),
            _DetailRow(icon: Icons.schedule, text: place.hours),
            const SizedBox(height: AppTheme.spaceXs),
            _DetailRow(icon: Icons.place_outlined, text: place.landmark),
          ],
        ),
      ),
    );
  }
}

/// A small pill showing the place type ("24-hour store", "Police station", ...).
class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceMd,
        vertical: AppTheme.spaceXs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryTint,
        borderRadius: BorderRadius.circular(AppTheme.radiusChip),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// A small icon + text line used for hours and landmark.
class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: AppTheme.spaceSm),
        Expanded(child: Text(text, style: AppTextStyles.caption)),
      ],
    );
  }
}

/// Informational banner (icon + text, never colour-only).
class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.primaryTint,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.primaryDark),
          const SizedBox(width: AppTheme.spaceSm),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown when the current filter has no matching places.
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
              Icons.search_off,
              size: 32,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              'No places match this filter.',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
