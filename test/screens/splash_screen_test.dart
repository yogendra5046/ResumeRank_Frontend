
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:resume_ai/screens/splash_screen.dart';

import 'package:resume_ai/features/auth/presentation/bloc/auth_state.dart';
import 'package:resume_ai/features/auth/domain/entities/user.dart';
import '../helpers/test_helper.dart';

void main() {
  late MockAuthCubit mockAuthCubit;
  const testUser = User(id: '1', email: 'test@example.com', fullName: 'Test User');

  setUp(() {
    setupMockAssetHandler();
    mockAuthCubit = MockAuthCubit();
    // Default initial state
    when(() => mockAuthCubit.state).thenReturn(AuthInitial());
    when(() => mockAuthCubit.stream).thenAnswer((_) => Stream.value(AuthInitial()));
  });

  testWidgets('SplashScreen renders successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      makeTestableWidget(
        child: const SplashScreen(),
        authCubit: mockAuthCubit,
      ),
    );

    // Verify presence of title and subtitle text
    expect(find.text('RESUME RANK'), findsOneWidget);
    expect(find.text('Rank Up Your Resume. Land The Job.'), findsOneWidget);

    // Let any pending timers run out to prevent test failure
    await tester.pump(const Duration(milliseconds: 2600));
  });

  testWidgets('SplashScreen navigates to /home if Authenticated after delay', (WidgetTester tester) async {
    when(() => mockAuthCubit.state).thenReturn(AuthInitial());
    when(() => mockAuthCubit.stream).thenAnswer((_) => Stream.value(const Authenticated(testUser)));

    await tester.pumpWidget(
      makeTestableWidget(
        child: const SplashScreen(),
        authCubit: mockAuthCubit,
      ),
    );

    // Let the stream emit the Authenticated state
    await tester.pump();

    // Advance time by 2.5 seconds (2500ms delay in splash screen)
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pumpAndSettle();

    expect(find.text('Home Screen Mock'), findsOneWidget);
  });

  testWidgets('SplashScreen navigates to /onboarding if Unauthenticated after delay', (WidgetTester tester) async {
    when(() => mockAuthCubit.state).thenReturn(AuthInitial());
    when(() => mockAuthCubit.stream).thenAnswer((_) => Stream.value(Unauthenticated()));

    await tester.pumpWidget(
      makeTestableWidget(
        child: const SplashScreen(),
        authCubit: mockAuthCubit,
      ),
    );

    // Let the stream emit the Unauthenticated state
    await tester.pump();

    // Advance time by 2.5 seconds
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pumpAndSettle();

    expect(find.text('Onboarding Screen Mock'), findsOneWidget);
  });
}
