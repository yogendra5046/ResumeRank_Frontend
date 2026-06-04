import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resume_ai/screens/settings_screen.dart';
import 'package:resume_ai/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:resume_ai/features/auth/presentation/bloc/auth_state.dart';
import '../helpers/test_helper.dart';

void main() {
  late MockAuthCubit mockAuthCubit;

  setUp(() {
    setupMockAssetHandler();
    mockAuthCubit = MockAuthCubit();
    // Default stub responses
    when(() => mockAuthCubit.state).thenReturn(AuthInitial());
    when(() => mockAuthCubit.stream).thenAnswer((_) => Stream.value(AuthInitial()));
    when(() => mockAuthCubit.logout()).thenAnswer((_) async {});

    // Set initial mock preferences values
    SharedPreferences.setMockInitialValues({
      'dark_mode': true,
      'notifications': false,
    });
  });

  testWidgets('SettingsScreen renders successfully and handles toggles', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        makeTestableWidget(
          child: const SettingsScreen(),
          authCubit: mockAuthCubit,
        ),
      );

      // Allow SharedPreferences mock platform channel call to complete
      await Future.delayed(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Check header title
      expect(find.text("Settings"), findsOneWidget);

      // Verify sections are visible
      expect(find.text("ACCOUNT"), findsOneWidget);
      expect(find.text("PREFERENCES"), findsOneWidget);
      expect(find.text("SUPPORT"), findsOneWidget);

      // Verify Profile Details tile is visible
      expect(find.text("Profile Details"), findsOneWidget);

      // Find switch widget for notifications
      final notificationsTile = find.ancestor(
        of: find.text("Notifications"),
        matching: find.byType(ListTile),
      );
      final notificationsFinder = find.descendant(
        of: notificationsTile,
        matching: find.byType(Switch),
      );
      expect(notificationsFinder, findsOneWidget);

      // Find dark mode switch
      final darkModeTile = find.ancestor(
        of: find.text("Dark Mode"),
        matching: find.byType(ListTile),
      );
      final darkModeFinder = find.descendant(
        of: darkModeTile,
        matching: find.byType(Switch),
      );
      expect(darkModeFinder, findsOneWidget);

      // Tap dark mode switch to toggle
      await tester.tap(darkModeFinder);
      await tester.pumpAndSettle();

      // Clean up widget tree
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });
  });

  testWidgets('SettingsScreen log out button triggers auth cubit logout', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        makeTestableWidget(
          child: const SettingsScreen(),
          authCubit: mockAuthCubit,
        ),
      );

      // Allow SharedPreferences mock platform channel call to complete
      await Future.delayed(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Drag ListView up to build and expose bottom elements
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();

      final logOutButton = find.text("Log Out");
      expect(logOutButton, findsOneWidget);
      await tester.tap(logOutButton);
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.text("Logout"), findsWidgets); // Both app bar and dialog might have the word Logout
      expect(find.text("Are you sure you want to end your session?"), findsOneWidget);

      // Tap Logout confirm button
      final confirmLogoutButton = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(ElevatedButton),
      );
      await tester.tap(confirmLogoutButton);
      await tester.pumpAndSettle();

      // Verify AuthCubit.logout() was called
      verify(() => mockAuthCubit.logout()).called(1);

      // Clean up widget tree
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });
  });
}
