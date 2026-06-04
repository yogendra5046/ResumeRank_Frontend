import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resume_ai/screens/help_center_screen.dart';
import '../helpers/test_helper.dart';

void main() {
  setUp(() {
    setupMockAssetHandler();
  });

  testWidgets('HelpCenterScreen renders successfully and allows FAQ expansion', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        makeTestableWidget(
          child: const HelpCenterScreen(),
        ),
      );

      // Verify title and search box
      expect(find.text("Help Center"), findsOneWidget);
      expect(find.text("Search help articles..."), findsOneWidget);

      // Verify presence of FAQ question
      const question = "How is the ATS score calculated?";
      const answer = "Our AI parses your resume and compares it against 50,000+ industry-specific keywords and weighting patterns.";
      
      expect(find.text(question), findsOneWidget);
      // Answer should not be visible initially (or at least, we can tap to expand)
      
      await tester.tap(find.text(question));
      await tester.pumpAndSettle();

      // Answer should be visible after expansion
      expect(find.text(answer), findsOneWidget);

      // Verify support contact card
      expect(find.text("Still need help?"), findsOneWidget);
      expect(find.text("Contact Support"), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });
  });
}
