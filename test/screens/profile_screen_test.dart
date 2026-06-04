import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:resume_ai/screens/profile_screen.dart';
import 'package:resume_ai/features/auth/presentation/bloc/auth_state.dart';
import 'package:resume_ai/features/auth/domain/entities/user.dart';
import '../helpers/test_helper.dart';

void main() {
  late MockAuthCubit mockAuthCubit;
  late User testUser;

  setUp(() {
    setupMockAssetHandler();
    mockAuthCubit = MockAuthCubit();

    testUser = const User(
      id: "user-123",
      email: "test@example.com",
      fullName: "John Doe",
      bio: "Senior Flutter Dev\nLoving clean code.",
      targetSalary: "\$150k/yr",
      workPreference: "Remote",
      experience: [
        {
          "company": "Tech Corp",
          "role": "Flutter Lead",
          "period": "2022 - Present",
          "description": "Architected resume app."
        }
      ],
      education: [
        {
          "institution": "MIT",
          "degree": "B.S. Computer Science",
          "year": "2020"
        }
      ],
    );

    when(() => mockAuthCubit.state).thenReturn(Authenticated(testUser));
    when(() => mockAuthCubit.stream).thenAnswer((_) => Stream.value(Authenticated(testUser)));
    when(() => mockAuthCubit.logout()).thenAnswer((_) async {});
    when(() => mockAuthCubit.updateProfile(
      fullName: any(named: 'fullName'),
      bio: any(named: 'bio'),
      targetSalary: any(named: 'targetSalary'),
      workPreference: any(named: 'workPreference'),
      experience: any(named: 'experience'),
      education: any(named: 'education'),
    )).thenAnswer((_) async {});
  });

  testWidgets('ProfileScreen renders user information successfully', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        makeTestableWidget(
          child: const ProfileScreen(),
          authCubit: mockAuthCubit,
        ),
      );
      await tester.pumpAndSettle();



      // Verify basic user details
      expect(find.text("John Doe"), findsOneWidget);
      expect(find.text("Senior Flutter Dev"), findsOneWidget);
      expect(find.text("\$150k/yr"), findsOneWidget);
      expect(find.text("Remote"), findsOneWidget);

      // Verify bio, experience, and education headers/cards
      expect(find.text("CAREER STORY"), findsOneWidget);
      expect(find.text("Loving clean code."), findsOneWidget);

      expect(find.text("WORK EXPERIENCE"), findsOneWidget);
      expect(find.text("Flutter Lead"), findsOneWidget);
      expect(find.text("Tech Corp"), findsOneWidget);

      expect(find.text("EDUCATION"), findsOneWidget);
      expect(find.text("B.S. Computer Science"), findsOneWidget);
      expect(find.text("MIT"), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });
  });

  testWidgets('ProfileScreen logout button triggers auth cubit logout', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        makeTestableWidget(
          child: const ProfileScreen(),
          authCubit: mockAuthCubit,
        ),
      );
      await tester.pumpAndSettle();

      // Tap logout action button in AppBar
      final logoutButton = find.byTooltip("Logout");
      expect(logoutButton, findsOneWidget);
      await tester.tap(logoutButton);
      await tester.pumpAndSettle();

      // Confirm logout in dialog
      final confirmLogoutButton = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(ElevatedButton, "Logout"),
      );
      await tester.tap(confirmLogoutButton);
      await tester.pumpAndSettle();

      verify(() => mockAuthCubit.logout()).called(1);

      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });
  });

  testWidgets('ProfileScreen triggers updateProfile when editing personal info', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        makeTestableWidget(
          child: const ProfileScreen(),
          authCubit: mockAuthCubit,
        ),
      );
      await tester.pumpAndSettle();

      // Tap Edit button on Basic Info card
      final editButton = find.byIcon(Icons.edit_rounded);
      expect(editButton, findsWidgets); // it's present in two places now (avatar and career story)
      await tester.tap(editButton.first);
      await tester.pumpAndSettle();

      // Check dialog input fields
      expect(find.text("Edit Preferences"), findsOneWidget);
      final nameField = find.widgetWithText(TextField, "Full Name");
      expect(nameField, findsOneWidget);

      // Enter new name
      await tester.enterText(nameField, "Jane Doe");
      await tester.pumpAndSettle();

      // Tap Save
      final saveButton = find.text("Save Changes");
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Verify updateProfile call with updated name
      verify(() => mockAuthCubit.updateProfile(
        fullName: "Jane Doe",
        bio: "Senior Flutter Dev\nLoving clean code.",
        targetSalary: "\$150k/yr",
        workPreference: "Remote",
        experience: any(named: 'experience'),
        education: any(named: 'education'),
      )).called(1);

      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });
  });
}
