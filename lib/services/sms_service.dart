import 'package:url_launcher/url_launcher.dart';

import 'location_service.dart';

/// Builds the SOS text and hands it to the phone's SMS app.
///
/// We do not send anything ourselves: the app opens a pre-filled SMS and the
/// user taps Send. This keeps the app offline and avoids needing SMS
/// permissions. Every method here swallows its errors so an SOS attempt can
/// never crash the app.
class SmsService {
  SmsService._();

  /// The line used when we have no location at all.
  static const String noLocationLine =
      'Location: unavailable (GPS or permission problem)';

  /// Builds the exact SOS message text.
  ///
  /// - [name] falls back to "not set" when missing or blank.
  /// - [plate] is the latest recent ride's plate, or null when there is none.
  /// - [plateLoggedAt] is when that plate was logged, shown as `(logged HH:MM)`.
  /// - [fix] is the location, or `null` when GPS is unavailable.
  ///
  /// With a fresh fix the accuracy line reads `Accuracy: about <n> m`. With a
  /// last-known fix it reads `LAST KNOWN location, may be old ...`. With no fix
  /// the three location lines are replaced by a single "unavailable" line.
  static String buildSosMessage({
    String? name,
    LocationFix? fix,
    String? plate,
    DateTime? plateLoggedAt,
  }) {
    final safeName = _orDefault(name, 'not set');
    final safePlate = plate?.trim() ?? '';

    final lines = <String>[
      'SOS - I need help.',
      'Name: $safeName',
      'Time: ${_formatTime(DateTime.now())}',
    ];

    if (fix == null) {
      // No location: one honest line instead of the usual three.
      lines.add(noLocationLine);
    } else {
      final lat = fix.position.latitude.toStringAsFixed(5);
      final lng = fix.position.longitude.toStringAsFixed(5);
      final accuracy = fix.position.accuracy.round();

      lines
        ..add('Location: https://maps.google.com/?q=$lat,$lng')
        ..add('Lat/Long: $lat, $lng');

      if (fix.fresh) {
        lines.add('Accuracy: about $accuracy m');
      } else {
        lines.add('LAST KNOWN location, may be old (accuracy about $accuracy m)');
      }
    }

    if (safePlate.isEmpty) {
      lines.add('Plate: not logged');
    } else if (plateLoggedAt != null) {
      lines.add('Plate: $safePlate (logged ${_formatTime(plateLoggedAt)})');
    } else {
      lines.add('Plate: $safePlate');
    }
    return lines.join('\n');
  }

  /// Builds the "I'm home safe" message sent by the Tadaima flow.
  ///
  /// - [name] falls back to "not set" when missing or blank.
  ///
  /// The text is fixed apart from the name and the time, so it is easy to
  /// check in a viva.
  static String buildHomeSafeMessage(String? name) {
    final safeName = _orDefault(name, 'not set');
    return "Tadaima! I'm home safe.\n"
        'From: $safeName\n'
        'Time: ${_formatTime(DateTime.now())}';
  }

  /// Opens the SMS app pre-filled with [body] addressed to [phone].
  ///
  /// Pass an empty [phone] to let the user pick a recipient in the SMS app.
  /// Returns `true` if the SMS app opened, `false` otherwise. Never throws.
  static Future<bool> openSms(String phone, String body) async {
    try {
      final target = phone.replaceAll(RegExp(r'\s+'), '');
      // `Uri.encodeComponent` makes the text safe to put inside the URI. The
      // body is percent-encoded, so newlines, spaces and `:` all survive.
      final uri = Uri.parse('sms:$target?body=${Uri.encodeComponent(body)}');
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  /// Opens the phone dialer with 911 typed in. Never dials by itself.
  ///
  /// Returns `true` if the dialer opened, `false` otherwise. Never throws.
  static Future<bool> openDialer911() async {
    try {
      return await launchUrl(
        Uri.parse('tel:911'),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      return false;
    }
  }

  /// Returns [value] trimmed, or [fallback] when it is null or blank.
  static String _orDefault(String? value, String fallback) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? fallback : trimmed;
  }

  /// Formats [time] as a 24-hour HH:MM string with leading zeros.
  static String _formatTime(DateTime time) {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}
