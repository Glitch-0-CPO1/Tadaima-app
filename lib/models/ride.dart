/// One logged ride: the vehicle the student took home.
///
/// Stored only on the phone. The [plate] is the most important field because
/// the newest ride's plate is included in the SOS message.
class Ride {
  const Ride({
    required this.id,
    required this.vehicleType,
    required this.plate,
    required this.driverName,
    required this.createdAt,
  });

  /// Unique id for this ride. Used to delete the right card later.
  final String id;

  /// One of: Tricycle, Jeepney, Bus, Other.
  final String vehicleType;

  /// Plate or body number, already trimmed and upper-cased by the caller.
  final String plate;

  /// Driver name, or an empty string when the student skipped it.
  final String driverName;

  final DateTime createdAt;

  /// Converts the ride to a plain map so it can be saved as JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'vehicleType': vehicleType,
        'plate': plate,
        'driverName': driverName,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  /// Rebuilds a [Ride] from stored JSON.
  ///
  /// Missing or wrongly typed values fall back to safe defaults so a single
  /// bad record can never crash the app.
  factory Ride.fromJson(Map<String, dynamic> json) {
    final rawCreatedAt = json['createdAt'];
    final createdAt = rawCreatedAt is int
        ? DateTime.fromMillisecondsSinceEpoch(rawCreatedAt)
        : DateTime.tryParse(rawCreatedAt?.toString() ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);

    return Ride(
      id: json['id']?.toString() ?? '',
      vehicleType: json['vehicleType']?.toString() ?? '',
      plate: json['plate']?.toString() ?? '',
      driverName: json['driverName']?.toString() ?? '',
      createdAt: createdAt,
    );
  }
}
