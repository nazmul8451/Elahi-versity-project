import 'package:flutter_test/flutter_test.dart';
import 'package:elahiversityproject/main.dart';

void main() {
  testWidgets('RigCraft App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RigCraftApp());
    expect(find.byType(RigCraftApp), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });
}
