import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/profile.dart';

/// Holds the student's profile (currently just their name) and keeps it saved
/// on the phone.
///
/// The UI never touches storage directly: it reads [name] / [hasName] and
/// calls [load] and [saveName] here. All data lives in [SharedPreferences],
/// so the app stays fully offline. Like [ContactsProvider], this never throws:
/// if storage is unavailable we simply behave as if no name was saved.
class ProfileProvider extends ChangeNotifier {
  /// Key used in SharedPreferences. Keep it stable so we do not "lose" the
  /// saved name in a future version of the app.
  static const String _storageKey = 'student_name';
  static const String _onboardingKey = 'onboarding_done';

  Profile _profile = const Profile();
  bool _isLoaded = false;
  bool _onboardingDone = false;

  /// The saved name, or an empty string if none has been set.
  String get name => _profile.name;

  /// True once [load] has finished at least once.
  bool get isLoaded => _isLoaded;

  /// True when a usable (non-blank) name has been saved.
  bool get hasName => _profile.hasName;

  /// Whether the first-run onboarding flow has been completed.
  bool get onboardingDone => _onboardingDone;

  /// Reads the saved name and onboarding state from the phone. Never throws.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _profile = Profile(name: prefs.getString(_storageKey)?.trim() ?? '');
      _onboardingDone = prefs.getBool(_onboardingKey) ?? false;
    } catch (_) {
      // Storage is unavailable for some reason. Fall back to defaults instead
      // of crashing.
      _profile = const Profile();
      _onboardingDone = false;
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  /// Saves [name] and updates the UI.
  ///
  /// A blank name is ignored (the caller validates first, but this guards the
  /// provider too). Saving errors are swallowed so the app never crashes; the
  /// name still updates in memory for the current session.
  Future<void> saveName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return;
    }

    _profile = Profile(name: trimmed);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, trimmed);
    } catch (_) {
      // If saving fails we keep the change in memory so the UI still works.
    }
  }

  /// Marks onboarding as completed and persists the flag.
  Future<void> markOnboardingDone() async {
    _onboardingDone = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, true);
    } catch (_) {
      // If saving fails we keep the change in memory so the UI still works.
    }
  }
}
