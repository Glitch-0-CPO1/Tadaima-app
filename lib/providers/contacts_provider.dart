import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/contact.dart';

/// Holds the list of trusted contacts and keeps it saved on the phone.
///
/// This is the single source of truth for contacts. The UI never touches
/// storage directly: it calls [load], [add] and [delete] here. All data lives
/// in [SharedPreferences] as one JSON string, so the app is fully offline.
class ContactsProvider extends ChangeNotifier {
  /// Key used in SharedPreferences. Changing it would "lose" saved contacts,
  /// so keep it stable.
  static const String _storageKey = 'trusted_contacts';

  final List<Contact> _contacts = <Contact>[];
  bool _isLoaded = false;

  /// A read-only view of the contacts. Screens should not mutate this list.
  List<Contact> get contacts => List<Contact>.unmodifiable(_contacts);

  /// True once [load] has finished at least once.
  bool get isLoaded => _isLoaded;

  /// True when there are no saved contacts (used for the empty state).
  bool get isEmpty => _contacts.isEmpty;

  /// Reads the saved contacts from the phone.
  ///
  /// This never throws. If nothing is saved, or the saved text is corrupted,
  /// we simply start with an empty list and (for corruption) clear the bad
  /// data so it cannot break future runs.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);

      _contacts
        ..clear()
        ..addAll(_decode(raw));

      if (raw != null && _contacts.isEmpty) {
        // The text existed but we could not read any contact: it is corrupted.
        // Remove it so the next save starts clean.
        await prefs.remove(_storageKey);
      }
    } catch (_) {
      // Storage is unavailable for some reason. Fall back to an empty list
      // instead of crashing.
      _contacts.clear();
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  /// Adds a new contact and saves the list.
  ///
  /// Returns the created [Contact] so the caller can use its id if needed.
  Future<Contact> add({
    required String name,
    required String relationship,
    required String phone,
  }) async {
    final contact = Contact(
      id: _newId(),
      name: name.trim(),
      relationship: relationship.trim(),
      phone: phone.trim(),
    );

    _contacts.add(contact);
    notifyListeners();
    await _save();
    return contact;
  }

  /// Deletes the contact with [id] and saves the list.
  Future<void> delete(String id) async {
    final lengthBefore = _contacts.length;
    _contacts.removeWhere((c) => c.id == id);
    if (_contacts.length == lengthBefore) {
      return;
    }
    notifyListeners();
    await _save();
  }

  /// Builds a new unique id without extra packages.
  String _newId() {
    // Microseconds since epoch is already unique enough, and the counter
    // guards against two contacts created in the very same microsecond.
    final base = DateTime.now().microsecondsSinceEpoch;
    return '${base}_${_contacts.length}';
  }

  /// Turns the raw saved string into a list of contacts, ignoring bad entries.
  List<Contact> _decode(String? raw) {
    if (raw == null || raw.isEmpty) {
      return <Contact>[];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return <Contact>[];
    }

    final result = <Contact>[];
    for (final item in decoded) {
      if (item is Map) {
        result.add(Contact.fromJson(Map<String, dynamic>.from(item)));
      }
    }
    return result;
  }

  /// Writes the current list back to the phone as a JSON string.
  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(
        _contacts.map((c) => c.toJson()).toList(),
      );
      await prefs.setString(_storageKey, encoded);
    } catch (_) {
      // If saving fails we keep the change in memory so the UI still works.
      // The user can try again; we never crash over a storage problem.
    }
  }
}
