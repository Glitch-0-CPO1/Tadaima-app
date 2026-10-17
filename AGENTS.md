# Tadaima: Project Brief for AI Coding Assistants

Read this file before writing or changing any code in this repository.

## What we are building
Tadaima is an Android app for students who commute, especially girls commuting home late who face harassment from drivers. It helps them prepare before a ride and ask for help fast. "Tadaima" is Japanese for "I'm home".

Course: ITMSD1 Inter-Class Mobile Hackathon. Team F-7. SDG 5 (Gender Equality).
Judges grade design, stable code, and AI transparency. A small app that works and never crashes beats a big app that is buggy.

## Hard rules
- **Offline-first. No backend, no login, no accounts, no analytics, no ads.** All data stays on the phone.
- **Android only.** Target a real device (Infinix, Android 15). Test with `flutter run -d <device-id>`.
- **Keep it simple.** Build only what is asked. No extra features, no extra packages without asking.
- **Never crash.** Handle denied permissions, missing GPS, empty lists, and bad input with a friendly message.
- **Use only these packages:** `provider`, `shared_preferences`, `geolocator`, `url_launcher`. Ask before adding any other.
- **Null safety, `flutter analyze` must pass with no errors** before you finish a task.
- **Explain your work in plain language** after each task: what files changed and why, so a student can defend it in a viva. Add short comments to non-obvious code.
- Follow the design tokens below exactly. Do not invent colors, fonts, or spacing.

## Tech stack
Flutter (Dart), Material 3, Provider for state, `shared_preferences` for local storage.

## Folder structure
```
lib/
  main.dart            // app entry, providers, theme
  models/              // Contact, RideLog, SafePlace
  providers/           // ContactsProvider, RidesProvider, ...
  services/            // location_service.dart, sms_service.dart, storage_service.dart
  screens/             // one file per screen
  widgets/             // reusable components (buttons, cards, banners)
  theme/               // app_colors.dart, app_text_styles.dart, app_theme.dart
```
Keep business logic in providers and services, not inside widgets.

## Design tokens (from our Figma design system)
Colors:
- primary `#0B6E6E`, primary-dark `#084F4F`, primary-tint `#E1F1F1`
- sos-red `#C62828` (ONLY for SOS-related elements), danger `#B3261E`, danger-bg `#FDE8E6`
- success `#1B6E2F`, success-bg `#E3F3E6`
- warning `#8A5300`, warning-bg `#FFF1D6`
- bg `#FAF7F2`, surface `#FFFFFF`
- text-primary `#1B2A2F`, text-secondary `#4A5A5F`
- border-input `#78888C`, divider `#D6DCDD`
- disabled-bg `#E9EDEE`, disabled-text `#6B7B80`
- on-primary `#FFFFFF`, on-sos `#FFFFFF`

Text styles (font: Inter, or the default font if Inter is not bundled):
Display 32/40 Bold, Title 24/32 Semibold, Heading 20/28 Semibold, Body 16/24 Regular, Body-Strong 16/24 Semibold, Button 16/24 Semibold, Caption 14/20 Regular. Never use text smaller than 14.

Spacing: 8pt grid (4, 8, 16, 24, 32, 40, 48). Screen side padding 16.
Radius: card 12, input 12, chip 20, button 24 (height 48), bottom sheet top 24, SOS button circle.
Accessibility: every tap target at least 48x48, text contrast WCAG AA, never rely on color alone (add icon and text for status).

## Navigation and screens
Bottom navigation with 4 tabs: **Home, Rides, Contacts, More**.
- **Home:** greeting, big SOS button (hold 3 seconds), "Tadaima, I'm home safe" button, quick links to Safe places and Safety tips, link to check-in timer.
- **Rides:** log a ride (vehicle type, plate or body number, optional driver name) and a list of recent rides.
- **Contacts:** trusted contacts (name, relationship, phone), add and delete, empty state.
- **More:** permissions status, emergency numbers, safety tips, about.
- **SOS Confirm:** hold-to-confirm with progress, preview of the SMS, cancel.
- **SOS Sent:** success message, Call 911 button, back to Home.
- **Safe Places:** static list of places with filters (placeholder data we replace with real local places).
- **Safety Tips:** static tip cards.
- **Check-in timer (optional, only after everything else works).**

## Behavior rules that matter
**SOS message** is a pre-filled SMS opened with `url_launcher` (`sms:` URI). The user taps Send. Format:
```
SOS - I need help.
Name: <student name>
Time: HH:MM
Location: https://maps.google.com/?q=<lat>,<lng>
Lat/Long: <lat>, <lng>
Accuracy: about <n> m   (or "LAST KNOWN location, may be old" if not fresh)
Plate: <latest logged plate> (logged HH:MM)   (or "Plate: not logged" if no ride in the last 12 hours)
```
Use `Uri.encodeComponent` for the body. Send to all trusted contacts the app has saved.

**Location:**
1. Check that location services are on and permission is granted (request it if needed).
2. Try a fresh fix (`LocationAccuracy.best`, up to 30 seconds).
3. If that fails, use `getLastKnownPosition()` and LABEL it as last known and possibly old.
4. If nothing is available, still open the SMS with "Location: unavailable". **GPS failure must never block an SOS.**

**Call 911:** `launchUrl(Uri.parse('tel:911'))` opens the dialer only. Do not request CALL_PHONE. Never auto-dial.

**"Tadaima" button:** opens a pre-filled SMS "Tadaima. I'm home safe." to the trusted contacts.

**SOS button:** requires holding for 3 seconds to prevent accidents, with a visible progress ring. Releasing early cancels.

**Honest limits (show in the UI where relevant):** works without mobile data but needs cellular signal and load to send SMS. The app does not replace calling emergency services.

## Android manifest (already configured)
Location permissions and the `sms` and `tel` intent queries are declared. Do not remove them.

## How we work
- Build one screen or feature at a time, in this order: theme and navigation, Contacts, Home with SOS, SOS flow, Rides, Safe Places and Tips, optional extras.
- After each task: run `flutter analyze`, test on the phone, and make a small Git commit.
- Every use of AI is logged in `AI_DISCLOSURE_LOG.md` by the team.
