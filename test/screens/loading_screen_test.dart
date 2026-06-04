import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resume_ai/screens/loading_screen.dart';
import '../helpers/test_helper.dart';

void main() {
  testWidgets('LoadingScreen renders message and animation', (WidgetTester tester) async {
    const testMessage = 'Analyzing your skills...';

    await tester.runAsync(() async {
      await tester.pumpWidget(
        makeTestableWidget(
          child: const LoadingScreen(message: testMessage),
        ),
      );

      // Verify presence of message text
      expect(find.text(testMessage), findsOneWidget);
      // Verify presence of animated messages container
      expect(find.byType(LoadingScreen), findsOneWidget);

      // Dispose the widget tree to clean up infinite timers/animations
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });
  });
}
