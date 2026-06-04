import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:resume_ai/features/analysis/presentation/pages/dashboard_page.dart';
import 'package:resume_ai/features/analysis/data/models/analysis_result_model.dart';
import 'package:resume_ai/features/analysis/domain/entities/analysis_result.dart';
import '../helpers/test_helper.dart';
import 'package:resume_ai/screens/skill_details_screen.dart';

void main() {
  // Initialize DI for tests
  setUpAll(() async {
    setupMockDI(); // registers mock cubits
    setupMockAssetHandler();
  });

  // Create a minimal mock AnalysisResult needed for DashboardScreen
  final mockResult = AnalysisResultModel(
    score: 85,
    grade: 'A',
    percentileText: '85th percentile',
    skillGapChart: [],
    suggestions: ['Improve impact metrics'],
    professionalPersona: {'primary_persona': 'Technical Specialist'},
    estimatedSalary: {'estimated_range': '\$120k - \$140k'},
    careerGuidance: {'next_best_move': 'Senior Engineer', 'skill_readiness': 70, 'learning_roadmap': []},
    // other required fields with dummy data
    scoreBreakdown: {},
    matchedSkills: [],
    missingSkills: [],
    criticalMissing: [],
    gaps: [],
    verbAnalysis: {},
    jdKeywords: [],
    rawResumeText: '',
    rawJdText: '',
    missingKeywords: [],
    percentile: 85,
    jdRedFlags: [],
    authenticityCheck: AuthenticityCheckModel(score: 100, jdSimilarity: 0.0, risk: 'Low', details: const []),
    roast: [],
    negotiationScripts: [],
    outreachTemplates: [],
    cultureBio: '',
    gapProjects: [],
    coverLetter: '',
    atsParse: {},
    formatScore: {},
  );

  testWidgets('DashboardScreen displays header and cards', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: DashboardPage(result: mockResult)));
    await tester.pumpAndSettle();

    expect(find.text('Rank Analysis'), findsOneWidget);
    expect(find.text('Keywords & Gaps'), findsOneWidget);
    expect(find.text('ATS Structure Audit'), findsOneWidget);
  });

  testWidgets('Tapping Keywords & Gaps navigates to SkillDetailsScreen', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: DashboardPage(result: mockResult),
    ));
    await tester.pumpAndSettle();

    final cardFinder = find.text('Keywords & Gaps');
    await tester.ensureVisible(cardFinder);
    await tester.pumpAndSettle();

    // Tap the Keywords & Gaps card by its title text
    await tester.tap(cardFinder);
    await tester.pumpAndSettle();

    expect(find.byType(SkillDetailsScreen), findsOneWidget);
  });
}
