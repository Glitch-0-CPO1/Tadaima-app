import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/ride.dart';

/// Holds the list of logged rides and keeps it saved on the phone.
///
/// The UI never touches storage directly: it calls [load], [add] and [delete]
/// here. All data lives in [SharedPreferences] as one JSON string, so the app
/// is fully offline. Only the newest [maxRides] rides are kept, newest first.
class RidesProvider extends ChangeNotifier {
  /// Key used in SharedPreferences. Changing it would "lose" saved rides,
  /// so keep it stable.
  static const String _storageKey = 'ride_log';

  /// How many rides we keep at most. Older ones are dropped on save.
  static const int maxRides = 30;

  /// A ride older than this does not count as "recent" for the SOS plate.
  static const Duration recentWindow = Duration(hours: 12);

  final List<Ride> _rides = <Ride>[];
  bool _isLoaded = false;

  /// A read-only view of the rides, newest first. Screens should not mutate.
  List<Ride> get rides => List<Ride>.unmodifiable(_rides);

  /// True once [load] has finished at least once.
  bool get isLoaded => _isLoaded;

  /// True when there are no saved rides (used for the empty state).
  bool get isEmpty => _rides.isEmpty;

  /// The newest ride if it was logged within the last 12 hours, else null.
  ///
  /// The list is kept newest first, so if the first ride is too old, every
  /// other ride is too.
  Ride? get latestRecentRide {
    if (_rides.isEmpty) {
      return null;
    }
    final newest = _rides.first;
    final age = DateTime.now().difference(newest.createdAt);
    return age <= recentWindow ? newest : null;
  }

  /// Reads the saved rides from the phone.
  ///
  /// This never throws. If nothing is saved, or the saved text is corrupted,
  /// we simply start with an empty list and (for corruption) clear the bad
  /// data so it cannot break future runs.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);

      _rides
        ..clear()
        ..addAll(_decode(raw));

      if (raw != null && _rides.isEmpty) {
        // The text existed but we could not read any ride: it is corrupted.
        // Remove it so the next save starts clean.
        await prefs.remove(_storageKey);
      }
    } catch (_) {
      // Storage is unavailable for some reason. Fall back to an empty list
      // instead of crashing.
      _rides.clear();
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  /// Adds a new ride at the top of the list and saves.
  ///
  /// [plate] should already be trimmed and upper-cased by the caller; we
  /// trim again anyway to be safe.
  Future<void> add({
    required String vehicleType,
    required String plate,
    String? driverName,
  }) async {
    final ride = Ride(
      id: _newId(),
      vehicleType: vehicleType.trim(),
      plate: plate.trim(),
      driverName: driverName?.trim() ?? '',
      createdAt: DateTime.now(),
    );

    _rides.insert(0, ride);
    if (_rides.length > maxRides) {
      _rides.removeRange(maxRides, _rides.length);
    }
    notifyListeners();
    await _save();
  }

  /// Deletes the ride with [id] and saves the list.
  Future<void> delete(String id) async {
    final lengthBefore = _rides.length;
    _rides.removeWhere((r) => r.id == id);
    if (_rides.length == lengthBefore) {
      return;
    }
    notifyListeners();
    await _save();
  }

  /// Builds a new unique id without extra packages.
  String _newId() {
    // Microseconds since epoch is already unique enough, and the counter
    // guards against two rides created in the very same microsecond.
    final base = DateTime.now().microsecondsSinceEpoch;
    return '${base}_${_rides.length}';
  }

  /// Turns the raw saved string into a list of rides, ignoring bad entries.
  List<Ride> _decode(String? raw) {
    if (raw == null || raw.isEmpty) {
      return <Ride>[];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return <Ride>[];
    }

    final result = <Ride>[];
    for (final item in decoded) {
      if (item is Map) {
        result.add(Ride.fromJson(Map<String, dynamic>.from(item)));
      }
    }
    // Defensive sort: newest first, no matter how they were stored.
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  /// Writes the current list back to the phone as a JSON string.
  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(
        _rides.map((r) => r.toJson()).toList(),
      );
      await prefs.setString(_storageKey, encoded);
    } catch (_) {
      // If saving fails we keep the change in memory so the UI still works.
      // The user can try again; we never crash over a storage problem.
    }
  }
}
