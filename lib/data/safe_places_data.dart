import '../models/safe_place.dart';

/// Placeholder safe places for the prototype.
///
/// TODO: replace these placeholders with real, verified places near our school
/// and routes.
const List<SafePlace> kSafePlaces = <SafePlace>[
  SafePlace(
    name: 'Corner Store A',
    type: 'store',
    typeLabel: '24-hour store',
    hours: 'Open 24 hours',
    landmark: 'Beside the pedestrian crossing',
  ),
  SafePlace(
    name: 'Barangay Outpost B',
    type: 'help_post',
    typeLabel: 'Barangay outpost',
    hours: 'Open 24 hours',
    landmark: 'Across from the covered court',
  ),
  SafePlace(
    name: 'Police Station C',
    type: 'help_post',
    typeLabel: 'Police station',
    hours: 'Open 24 hours',
    landmark: 'Main road next to the plaza',
  ),
  SafePlace(
    name: 'School Gate D',
    type: 'help_post',
    typeLabel: 'School guard post',
    hours: '6 AM-10 PM',
    landmark: 'At the main campus entrance',
  ),
  SafePlace(
    name: 'Corner Store E',
    type: 'store',
    typeLabel: '24-hour store',
    hours: 'Open 24 hours',
    landmark: 'Near the public market entrance',
  ),
];
