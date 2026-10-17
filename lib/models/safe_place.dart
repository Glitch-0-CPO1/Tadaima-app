/// A safe place the student can head to when they feel unsafe.
///
/// [type] is a stable code ("store" or "help_post") used for filtering, while
/// [typeLabel] is the friendly name shown on the card (e.g. "Police station").
class SafePlace {
  const SafePlace({
    required this.name,
    required this.type,
    required this.typeLabel,
    required this.hours,
    required this.landmark,
  });

  final String name;

  /// One of: "store" or "help_post". Kept as a code so filters stay stable
  /// even if the displayed label changes.
  final String type;

  /// Human-readable type shown in the card's chip (e.g. "24-hour store").
  final String typeLabel;

  /// When the place is open, written for a person (e.g. "Open 24 hours").
  final String hours;

  /// How to find it (e.g. "Beside the pedestrian crossing").
  final String landmark;

  /// True for shops and stores (the "Stores" filter).
  bool get isStore => type == 'store';

  /// True for outposts and stations (the "Help posts" filter).
  bool get isHelpPost => type == 'help_post';
}
