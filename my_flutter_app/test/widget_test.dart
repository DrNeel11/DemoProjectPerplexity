import 'package:flutter_test/flutter_test.dart';

import 'package:edge_scholar/main.dart';

void main() {
  testWidgets('EdgeScholar app loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our app shows the EdgeScholar landing screen
    expect(find.text('EdgeScholar'), findsOneWidget);
    expect(find.text('Edge-Enabled Research Companion'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}