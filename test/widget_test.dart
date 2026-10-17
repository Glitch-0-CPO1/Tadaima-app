// Smoke test for the Tadaima app shell.
//
// Verifies the app builds and that all four bottom navigation tabs are shown.

import 'package:flutter_test/flutter_test.dart';

import 'package:tadaima/main.dart';

void main() {
  testWidgets('App shell shows the four tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const TadaimaApp());

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Rides'), findsOneWidget);
    expect(find.text('Contacts'), findsOneWidget);
    expect(find.text('More'), findsWidgets);
  });
}
