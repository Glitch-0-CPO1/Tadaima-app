/// One safety tip shown as a card on the Safety tips screen.
class SafetyTip {
  const SafetyTip({required this.title, required this.body});

  final String title;
  final String body;
}

/// TODO: verify these tips against official sources (for example PNP, DSWD, or
/// our school guidance office) and add a sources line.
const List<SafetyTip> kSafetyTips = <SafetyTip>[
  SafetyTip(
    title: "If you're harassed",
    body: 'It is not your fault. If it is safe, move toward people or a lit, '
        'staffed place. Contact someone you trust.',
  ),
  SafetyTip(
    title: 'How to log a ride',
    body: 'Before boarding, save the plate or body number in Rides. Add a '
        'driver name only if it is safe to do so.',
  ),
  SafetyTip(
    title: 'Emergency numbers',
    body: 'Philippines: call 911 for emergencies. Save your local barangay and '
        'campus security numbers in Contacts.',
  ),
];
