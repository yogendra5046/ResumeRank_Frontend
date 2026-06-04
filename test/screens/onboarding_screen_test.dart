import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resume_ai/screens/onboarding_screen.dart';
import '../helpers/test_helper.dart';

void main() {
  setUp(() {
    setupMockAssetHandler();
  });

  testWidgets('OnboardingScreen renders first page successfully', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        makeTestableWidget(
          child: const OnboardingScreen(),
        ),
      );

      expect(find.text("AI Resume Analysis"), findsOneWidget);
      expect(find.text("Skip"), findsOneWidget);
      expect(find.text("Next"), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });
  });

  testWidgets('OnboardingScreen skip button navigates to /login', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        makeTestableWidget(
          child: const OnboardingScreen(),
        ),
      );

      await tester.tap(find.text("Skip"));
      await tester.pumpAndSettle();

      expect(find.text('Login Screen Mock'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });
  });

  testWidgets('OnboardingScreen next button pages through and shows Get Started', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        makeTestableWidget(
          child: const OnboardingScreen(),
        ),
      );

      // Verify first page text
      expect(find.text("AI Resume Analysis"), findsOneWidget);

      // Tap Next
      await tester.tap(find.text("Next"));
      await tester.pumpAndSettle();

      // Verify second page text
      expect(find.text("Skill Gap Discovery"), findsOneWidget);

      // Tap Next
      await tester.tap(find.text("Next"));
      await tester.pumpAndSettle();

      // Verify third page text
      expect(find.text("1-Click AI Rewrite"), findsOneWidget);
      expect(find.text("Get Started"), findsOneWidget);

      // Tap Get Started
      await tester.tap(find.text("Get Started"));
      await tester.pumpAndSettle();

      // Verify final navigation
      expect(find.text('Login Screen Mock'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });
  });
}
