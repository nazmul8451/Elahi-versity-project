import 'package:flutter_test/flutter_test.dart';
import 'package:elahiversityproject/main.dart';

void main() {
  testWidgets('RigCraft App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RigCraftApp());
    expect(find.byType(RigCraftApp), findsOneWidget);
    // Advance timers so splash transitions
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
