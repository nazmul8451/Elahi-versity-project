import 'package:flutter_test/flutter_test.dart';
import 'package:elahiversityproject/main.dart';

void main() {
  testWidgets('PC Builder App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PCBuilderApp());
    expect(find.byType(PCBuilderApp), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });
}
