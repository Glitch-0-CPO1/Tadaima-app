/// A trusted contact that receives SOS and safe-arrival texts.
///
/// Kept deliberately simple: an [id], a [name], a [relationship] label
/// (e.g. "Mother") and a [phone] number. Everything is stored on the phone
/// only, so the model also knows how to turn itself into JSON and back.
class Contact {
  const Contact({
    required this.id,
    required this.name,
    required this.relationship,
    required this.phone,
    this.isPrimary = false,
  });

  /// Unique id for this contact. Used to delete the right card later.
  final String id;

  final String name;
  final String relationship;
  final String phone;
  final bool isPrimary;

  /// Converts the contact to a plain map so it can be saved as JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'relationship': relationship,
        'phone': phone,
        'isPrimary': isPrimary,
      };

  /// Rebuilds a [Contact] from stored JSON.
  ///
  /// Missing or wrongly typed values fall back to empty strings so a single
  /// bad record can never crash the app. Missing [isPrimary] defaults to false
  /// so old saved data still loads.
  factory Contact.fromJson(Map<String, dynamic> json) {
    final isPrimaryValue = json['isPrimary'];
    final isPrimary = isPrimaryValue is bool ? isPrimaryValue : false;

    return Contact(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      relationship: json['relationship']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      isPrimary: isPrimary,
    );
  }

  /// Returns a copy of this contact with some fields changed.
  Contact copyWith({
    String? id,
    String? name,
    String? relationship,
    String? phone,
    bool? isPrimary,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      relationship: relationship ?? this.relationship,
      phone: phone ?? this.phone,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}
