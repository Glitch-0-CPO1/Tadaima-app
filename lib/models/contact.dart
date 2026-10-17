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
  });

  /// Unique id for this contact. Used to delete the right card later.
  final String id;

  final String name;
  final String relationship;
  final String phone;

  /// Converts the contact to a plain map so it can be saved as JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'relationship': relationship,
        'phone': phone,
      };

  /// Rebuilds a [Contact] from stored JSON.
  ///
  /// Missing or wrongly typed values fall back to empty strings so a single
  /// bad record can never crash the app.
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      relationship: json['relationship']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
    );
  }
}
