/// The student's own profile.
///
/// Right now it only holds the student's [name], which is used to sign the
/// SOS text (`Name: <student name>`). It is stored on the phone only, so the
/// model also knows how to turn itself into JSON and back.
class Profile {
  const Profile({this.name = ''});

  /// The student's display name. Empty when the user has not set one yet.
  final String name;

  /// True when a usable (non-blank) name has been saved.
  bool get hasName => name.trim().isNotEmpty;

  /// Converts the profile to a plain map so it can be saved as JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{'name': name};

  /// Rebuilds a [Profile] from stored JSON.
  ///
  /// Missing or wrongly typed values fall back to an empty name so bad saved
  /// data can never crash the app.
  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(name: json['name']?.toString() ?? '');
  }
}
