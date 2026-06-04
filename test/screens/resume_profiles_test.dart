import 'package:flutter_test/flutter_test.dart';
import 'package:resume_ai/features/analysis/domain/entities/analysis_result.dart';
import 'package:resume_ai/features/analysis/data/models/analysis_result_model.dart';
import 'package:resume_ai/features/analysis/presentation/pages/dashboard_page.dart';
import 'package:resume_ai/screens/ats_checklist_screen.dart';
import 'package:resume_ai/screens/ats_xray_screen.dart';
import 'package:resume_ai/screens/authenticity_check_screen.dart';
import 'package:resume_ai/screens/career_accelerator_screen.dart';
import 'package:resume_ai/screens/cover_letter_screen.dart';
import 'package:resume_ai/screens/linkedin_hub_screen.dart';

import '../helpers/test_helper.dart';

// Helper to generate custom AnalysisResults
AnalysisResultModel createCustomMockResult({
  required int score,
  required String grade,
  required Map<String, dynamic> formatScore,
  required Map<String, dynamic> atsParse,
  required double jdSimilarity,
  required String rawResumeText,
  required List<String> jdKeywords,
  required List<String> missingKeywords,
  required Map<String, dynamic> careerGuidance,
  required List<CriticalSkillModel> criticalMissing,
  required String coverLetter,
}) {
  return AnalysisResultModel(
    score: score,
    grade: grade,
    scoreBreakdown: {
      'keywords': score > 70 ? 80 : 40,
      'experience': score > 70 ? 85 : 50,
      'verbs': score > 70 ? 75 : 45,
      'format': formatScore['score'] ?? 50,
    },
    matchedSkills: jdKeywords.where((k) => !missingKeywords.contains(k)).map((k) => {'name': k, 'weight': 5, 'context': 'Used in project'}).toList(),
    missingSkills: missingKeywords.map((k) => {'name': k, 'weight': 8, 'context': 'Missing'}).toList(),
    skillGapChart: const [
      SkillGapDataModel(name: 'Backend', matched: 2, total: 4, percent: 50, status: 'Average'),
      SkillGapDataModel(name: 'Frontend', matched: 0, total: 2, percent: 0, status: 'Poor'),
    ],
    criticalMissing: criticalMissing,
    suggestions: const ['Improve resume'],
    gaps: const ['Missing skills'],
    verbAnalysis: {'ratio': score > 70 ? 80 : 30, 'strong': 10, 'weak': 5},
    jdKeywords: jdKeywords,
    rawResumeText: rawResumeText,
    rawJdText: 'Job description text',
    missingKeywords: missingKeywords,
    estimatedSalary: {'estimated_range': '10-20 LPA'},
    professionalPersona: {'primary_persona': 'Developer'},
    careerGuidance: careerGuidance,
    percentile: score,
    percentileText: 'Top ${100 - score}%',
    jdRedFlags: const [],
    authenticityCheck: AuthenticityCheckModel(score: 100 - (jdSimilarity * 100).toInt(), jdSimilarity: jdSimilarity, risk: jdSimilarity > 0.8 ? 'High' : 'Low', details: const []),
    roast: const ['Needs work'],
    negotiationScripts: const [],
    outreachTemplates: const [],
    cultureBio: 'Culture fit',
    gapProjects: const [],
    coverLetter: coverLetter,
    atsParse: atsParse,
    formatScore: formatScore,
  );
}

void main() {
  setUpAll(() async {
    setupMockDI();
    setupMockAssetHandler();
  });

  final profiles = {
    '1_PerfectCandidate': createCustomMockResult(
      score: 95,
      grade: 'S',
      formatScore: {'score': 95},
      atsParse: {'section_audit': {'found': ['Experience', 'Education', 'Skills']}},
      jdSimilarity: 0.15,
      rawResumeText: 'Experienced developer with Flutter and Dart. Contact: user@email.com +1234567890. Achieved great results.',
      jdKeywords: const ['Flutter', 'Dart', 'Firebase'],
      missingKeywords: const [],
      careerGuidance: const {'next_best_move': 'Tech Lead', 'skill_readiness': 95, 'learning_roadmap': [{'skill': 'Management', 'topics': ['Leadership']}]},
      criticalMissing: const [],
      coverLetter: 'Dear hiring manager, I am perfect for this role...',
    ),
    '2_MissingHardSkills': createCustomMockResult(
      score: 65,
      grade: 'C',
      formatScore: {'score': 85},
      atsParse: {'section_audit': {'found': ['Experience', 'Education', 'Skills']}},
      jdSimilarity: 0.20,
      rawResumeText: 'Experienced developer. Contact: user@email.com +1234567890. Managed teams.',
      jdKeywords: const ['Flutter', 'Dart', 'Firebase', 'GCP'],
      missingKeywords: const ['Flutter', 'Dart', 'Firebase'],
      careerGuidance: const {'next_best_move': 'Mobile Developer', 'skill_readiness': 40, 'learning_roadmap': [{'skill': 'Flutter', 'topics': ['State Management']}]},
      criticalMissing: const [CriticalSkillModel(name: 'Flutter', weight: 10, jobs: '90%', points: 15)],
      coverLetter: 'Dear hiring manager, I am eager to learn...',
    ),
    '3_BadFormatting': createCustomMockResult(
      score: 45,
      grade: 'D',
      formatScore: {'score': 20}, // Bad format
      atsParse: {'section_audit': {'found': []}}, // Missing sections
      jdSimilarity: 0.10,
      rawResumeText: 'just some text without clear structure. email@email.com',
      jdKeywords: const ['Java', 'Spring'],
      missingKeywords: const ['Spring'],
      careerGuidance: const {'next_best_move': 'Junior Dev', 'skill_readiness': 50, 'learning_roadmap': []},
      criticalMissing: const [],
      coverLetter: '',
    ),
    '4_SuspiciousHighRisk': createCustomMockResult(
      score: 80,
      grade: 'B',
      formatScore: {'score': 90},
      atsParse: {'section_audit': {'found': ['Experience', 'Education', 'Skills']}},
      jdSimilarity: 0.95, // High similarity
      rawResumeText: 'Text copied directly from JD. Contact: user@email.com +1234567890.',
      jdKeywords: const ['Python', 'Django'],
      missingKeywords: const [],
      careerGuidance: const {'next_best_move': 'Senior Dev', 'skill_readiness': 80, 'learning_roadmap': []},
      criticalMissing: const [],
      coverLetter: 'Dear hiring manager...',
    ),
    '5_EntryLevelEmpty': createCustomMockResult(
      score: 30,
      grade: 'F',
      formatScore: {'score': 50},
      atsParse: const {}, // Empty parse data
      jdSimilarity: 0.05,
      rawResumeText: 'Student looking for job.',
      jdKeywords: const ['C++', 'Algorithms'],
      missingKeywords: const ['C++', 'Algorithms'],
      careerGuidance: const {}, // Empty guidance
      criticalMissing: const [CriticalSkillModel(name: 'C++', weight: 10, jobs: '80%', points: 20)],
      coverLetter: '',
    ),
  };

  for (final profileEntry in profiles.entries) {
    final profileName = profileEntry.key;
    final result = profileEntry.value;

    group('Profile: $profileName', () {
      testWidgets('DashboardScreen renders without crashing', (tester) async {
        await tester.pumpWidget(makeTestableWidget(child: DashboardPage(result: result)));
        await tester.pumpAndSettle();
        expect(find.text('Rank Analysis'), findsOneWidget);
      });

      testWidgets('ATSChecklistScreen handles data correctly', (tester) async {
        await tester.pumpWidget(makeTestableWidget(child: ATSChecklistScreen(result: result.toOldModel())));
        await tester.pumpAndSettle();
        expect(find.text('ATS Structural & Format Audit'), findsOneWidget);
      });

      testWidgets('ATSXRayScreen renders highlighted text', (tester) async {
        await tester.pumpWidget(makeTestableWidget(child: ATSXRayScreen(result: result.toOldModel())));
        await tester.pumpAndSettle();
        expect(find.text('ATS System View'), findsOneWidget);
      });

      testWidgets('AuthenticityCheckScreen normalizes jdSimilarity', (tester) async {
        await tester.pumpWidget(makeTestableWidget(child: AuthenticityCheckScreen(result: result.toOldModel())));
        await tester.pumpAndSettle();
        expect(find.text('Authenticity Check'), findsOneWidget);
        
        // jdSimilarity should be displayed as a clamped percentage (0-100%)
        final percentage = (result.authenticityCheck.jdSimilarity * 100).toInt();
        expect(find.text('$percentage%'), findsOneWidget);
      });

      testWidgets('CoverLetterScreen handles missing letter gracefully', (tester) async {
        await tester.pumpWidget(makeTestableWidget(child: CoverLetterScreen(result: result.toOldModel())));
        await tester.pumpAndSettle();
        
        if (result.coverLetter.isEmpty) {
          expect(find.text('No cover letter generated'), findsOneWidget);
        } else {
          expect(find.text('Custom Draft'), findsOneWidget);
        }
      });

      testWidgets('CareerAcceleratorScreen handles empty states', (tester) async {
        await tester.pumpWidget(makeTestableWidget(child: CareerAcceleratorScreen(result: result.toOldModel())));
        await tester.pumpAndSettle();
        
        expect(find.text('Career Accelerator'), findsOneWidget);
      });

      testWidgets('LinkedinHubScreen renders optimization content correctly', (tester) async {
        await tester.pumpWidget(makeTestableWidget(child: LinkedinHubScreen(result: result.toOldModel())));
        await tester.pumpAndSettle();
        expect(find.text('PROFILE BRANDING'), findsOneWidget);
        expect(find.text('OUTREACH PLAYBOOK'), findsOneWidget);
      });
      
    });
  }
}
