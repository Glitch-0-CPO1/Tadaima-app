# Tadaima App Audit Report

## Flutter analyze
`
Analyzing Tadaima-app...                                        
No issues found! (ran in 5.6s)
`

## Issues found

| file | line | issue | severity | suggested fix |
|---|---|---|---|---|
| lib/widgets/sos_button.dart | 159 | Uses \withValues(alpha: 0.30)\ which requires newer Flutter versions. | medium | Replace with \withOpacity(0.30)\ for better compatibility. |
| lib/screens/sos_confirm_screen.dart | 400 | Invalid Dart syntax \?child,\ in collection literal. | high | Replace with \if (child != null) child,\. |
| lib/screens/more_screen.dart | 139-147 | TextButton in ListTile may not meet 48x48 minimum tap target. | medium | Add \minimumSize: Size(48,48)\ or use IconButton. |
| lib/screens/contacts_screen.dart | 89-99 | AlertDialog TextButtons may be below 48x48. | medium | Add \minimumSize: const Size(64, AppTheme.buttonHeight)\ or ensure >=48. |
| lib/screens/rides_screen.dart | 82-98 | AlertDialog TextButtons may be below 48x48. | medium | Add \minimumSize: const Size(64, AppTheme.buttonHeight)\ or ensure >=48. |
| lib/data/safe_places_data.dart | 5 | TODO about replacing placeholders with real verified places. | low | Remove or track in backlog. |
| lib/data/safety_tips_data.dart | 9 | TODO about verifying tips against official sources. | low | Remove or track in backlog. |

## SOS reliability check
- Location: handles denied, deniedForever (shows settings), services off, timeout (30s) with fallback to last known, no location → sends with "unavailable". Never blocks SOS. ✓
- Permissions: checks and requests as needed. ✓
- 0 contacts: shows warning with "Add contact" and "Choose recipient in SMS app" fallback. ✓
- Screen navigation during async: checks mounted before using context. ✓
- Hold-to-confirm: 3s hold with progress ring, cancels on release. ✓

## Design tokens
- Colors from AppColors only. sosRed only used for SOS elements. ✓
- Text sizes ≥14. ✓
- 8pt grid spacing used. ✓
- Tap targets mostly ≥48 (SosButton 200x200, buttons have height 48). Some TextButtons need adjustment. ⚠

## Accessibility
- Semantics on SosButton. ✓
- Icons + text for status (not color-only). ✓
- Filter chips use checkmark. ✓

## Top fixes first
1. Fix syntax error in \lib/screens/sos_confirm_screen.dart:400\
2. Replace \withValues()\ in \lib/widgets/sos_button.dart:159\
3. Ensure all tap targets ≥48x48
4. Clean up TODOs
