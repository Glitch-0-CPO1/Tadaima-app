import 'package:geolocator/geolocator.dart';

/// A GPS position together with whether it is a fresh fix.
///
/// [fresh] is `true` when we just measured the position, and `false` when we
/// fell back to the phone's last known (possibly old) location. The SOS text
/// uses this to warn the reader that the location may be stale.
class LocationFix {
  const LocationFix({required this.position, required this.fresh});

  final Position position;
  final bool fresh;
}

/// Everything the app needs to get the user's location for an SOS.
///
/// The whole point of this service is to never throw: an SOS must always be
/// able to continue, even if GPS or permission fails. When we cannot get a
/// position at all, [getBestFix] returns `null` and the SMS simply says the
/// location is unavailable.
class LocationService {
  /// True when the last [getBestFix] call found the permission is permanently
  /// denied ("deny forever"). In that case the only way forward is for the user
  /// to enable it in the system settings, so the UI offers an "Open settings"
  /// button.
  bool _permissionDeniedForever = false;

  /// Whether the last [getBestFix] call hit a permanently denied permission.
  bool get permissionDeniedForever => _permissionDeniedForever;

  /// Returns the best location we can get right now, or `null` if none.
  ///
  /// Steps, in order:
  /// 1. Make sure location services are switched on.
  /// 2. Check permission and request it if it is only "denied" (not forever).
  /// 3. Try a fresh fix at the best accuracy, giving up after 30 seconds.
  /// 4. If that fails, fall back to [Geolocator.getLastKnownPosition] and mark
  ///    it as not fresh.
  /// 5. If nothing works, return `null`.
  ///
  /// Nothing here ever throws: every failure path returns `null` instead.
  Future<LocationFix?> getBestFix() async {
    _permissionDeniedForever = false;

    try {
      // 1. Location services (the phone's master GPS switch) must be on.
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // 2. Ask for permission if we have not been granted it yet.
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        // Only the system settings can change this.
        _permissionDeniedForever = true;
        return null;
      }
      if (permission == LocationPermission.denied) {
        // The user said no for now; do not block the SOS.
        return null;
      }

      // 3. Try a fresh, accurate fix. The timeLimit makes it give up after
      //    30 seconds (a TimeoutException, caught below).
      try {
        final current = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            timeLimit: Duration(seconds: 30),
          ),
        );
        return LocationFix(position: current, fresh: true);
      } catch (_) {
        // Timed out or failed; fall through to the last known position.
      }

      // 4. Use the phone's last known position, clearly marked as not fresh.
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        return LocationFix(position: lastKnown, fresh: false);
      }

      // 5. Nothing at all is available.
      return null;
    } catch (_) {
      // Any unexpected platform error: treat it as "no location".
      return null;
    }
  }

  /// Opens this app's system settings page so the user can grant a permission
  /// that was denied forever. Returns `false` if the settings could not open.
  ///
  /// This never throws.
  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (_) {
      return false;
    }
  }
}
