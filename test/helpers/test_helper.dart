import 'dart:convert';

import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:resume_ai/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:resume_ai/features/auth/presentation/bloc/auth_state.dart';
import 'package:resume_ai/features/analysis/presentation/bloc/analysis_cubit.dart';
import 'package:resume_ai/features/history/presentation/bloc/history_cubit.dart';
import 'package:resume_ai/models/analysis_result.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:resume_ai/providers/theme_provider.dart';
import 'package:resume_ai/screens/dashboard_screen.dart';

// Mock AssetBundle for Lottie and other json assets
class TestAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    if (key == 'AssetManifest.bin') {
      final WriteBuffer buffer = WriteBuffer();
      const StandardMessageCodec().writeValue(buffer, <String, List<Object>>{
        'assets/app_icon.png': <Object>[],
      });
      return buffer.done();
    }
    if (key == 'AssetManifest.json') {
      const manifest = {
        'assets/app_icon.png': [],
        'google_fonts/PlusJakartaSans-Regular.ttf': [],
        'google_fonts/PlusJakartaSans-Bold.ttf': [],
        'google_fonts/PlusJakartaSans-Italic.ttf': [],
        'google_fonts/PlusJakartaSans-BoldItalic.ttf': [],
        'google_fonts/PlusJakartaSans-Medium.ttf': [],
        'google_fonts/PlusJakartaSans-SemiBold.ttf': [],
        'google_fonts/Inter-Regular.ttf': [],
        'google_fonts/Inter-Bold.ttf': [],
        'google_fonts/Outfit-Regular.ttf': [],
        'google_fonts/Outfit-Bold.ttf': [],
      };
      final jsonStr = json.encode(manifest);
      return ByteData.sublistView(Uint8List.fromList(utf8.encode(jsonStr)));
    }
    if (key.endsWith('.json')) {
      const jsonStr =
          '{"v":"4.8.0","meta":{},"fr":30,"ip":0,"op":30,"w":100,"h":100,"nm":"Test","ddd":0,"assets":[],"layers":[]}';
      return ByteData.sublistView(Uint8List.fromList(utf8.encode(jsonStr)));
    }
    if (key.endsWith('.ttf') || key.endsWith('.otf')) {
      return ByteData(1);
    }
    if (key.endsWith('.png') || key.endsWith('.jpg') || key.endsWith('.jpeg')) {
      return ByteData.sublistView(Uint8List.fromList(transparentImage));
    }
    throw Exception('Asset not found: $key');
  }
}

// Mock Classes
class MockAuthCubit extends Mock implements AuthCubit {}

class MockAnalysisCubit extends Mock implements AnalysisCubit {}

class MockHistoryCubit extends Mock implements HistoryCubit {}

// Reusable Mock Result Creator
AnalysisResult createMockAnalysisResult() {
  return AnalysisResult(
    score: 85,
    grade: 'A',
    scoreBreakdown: {
      'keywords': 35,
      'relevance': 15,
      'impact': 20,
      'presentation': 15,
    },
    matchedSkills: [
      {
        'name': 'Python',
        'weight': 9,
        'context': '6 years experience',
        'importance': 'High',
      },
      {
        'name': 'FastAPI',
        'weight': 8,
        'context': 'REST APIs',
        'importance': 'High',
      },
    ],
    missingSkills: [
      {
        'name': 'Docker',
        'weight': 7,
        'context': 'Missing in resume',
        'importance': 'Medium',
      },
      {
        'name': 'Kubernetes',
        'weight': 9,
        'context': 'Missing in resume',
        'importance': 'Critical',
      },
    ],
    skillGapChart: [
      SkillGapData(
        name: 'Languages',
        matched: 2,
        total: 3,
        percent: 66,
        status: 'Good',
      ),
      SkillGapData(
        name: 'DevOps',
        matched: 0,
        total: 2,
        percent: 0,
        status: 'Needs Improvement',
      ),
    ],
    criticalMissing: [
      CriticalSkill(name: 'Kubernetes', weight: 9, jobs: '90%', points: 9),
    ],
    suggestions: [
      'Add containerization details.',
      'Show metrics in past experience.',
    ],
    gaps: ['Missing DevOps tools.'],
    verbAnalysis: {'strong': 12, 'weak': 2, 'ratio': 85},
    jdKeywords: ['Python', 'FastAPI', 'Docker', 'Kubernetes'],
    rawResumeText: 'Experienced Python Developer with FastAPI skills.',
    rawJdText:
        'Looking for a developer with Python, FastAPI, Docker, and Kubernetes.',
    missingKeywords: ['Docker', 'Kubernetes'],
    estimatedSalary: const {
      'category': 'Backend',
      'estimated_range': '\$120k - \$140k',
      'experience_detected': '5+ Years',
      'seniority': 'Senior',
    },
    professionalPersona: {
      'primary_persona': 'Technical Specialist',
      'description': 'Deep engineering focus with API optimization skills.',
    },
    careerGuidance: {
      'current_role': 'Software Engineer',
      'next_best_move': 'Senior Software Engineer',
      'skill_readiness': 75,
      'learning_roadmap': [
        'Master Docker containerization',
        'Build Kubernetes orchestration projects',
      ],
    },
    percentile: 88,
    percentileText: 'Better than 88% of applicants.',
    jdRedFlags: [
      JDRedFlag(
        flag: 'Unrealistic Expectations',
        description: 'Requires 10+ years in Flutter',
        severity: 'Medium',
      ),
    ],
    authenticityCheck: const AuthenticityCheck(
      score: 95,
      jdSimilarity: 0.25,
      risk: 'Low',
      details: [
        'No matching phrases over threshold.',
        'Document looks authentic.',
      ],
    ),
    roast: [
      'Your summary is as dry as a cracker.',
      'Containerization is not optional in 2026.',
    ],
    negotiationScripts: [
      {
        'scenario': 'Initial Offer',
        'script': 'Thank you for the offer. I would like to discuss...',
      },
    ],
    outreachTemplates: [
      {'type': 'LinkedIn', 'message': 'Hi, I saw your job posting...'},
    ],
    cultureBio:
        'Thrives in collaborative, fast-paced startups with modular codebase architectures.',
    gapProjects: [
      {
        'skill': 'Docker',
        'project': 'Dockerize FastAPI microservices',
        'spec': 'Create a multi-stage Dockerfile',
      },
    ],
    coverLetter:
        'Dear Hiring Manager,\n\nI am writing to express my interest in the position...',
    atsParse: {
      'score': 85,
      'details': [
        'Found contact details',
        'Standard section headers detected',
        'Standard fonts used',
      ],
    },
    formatScore: {
      'score': 90,
      'details': ['Single page layout', 'ATS-friendly margin safety'],
    },
  );
}

// Wrapper Helper to build a testable widget tree
Widget makeTestableWidget({
  required Widget child,
  AuthCubit? authCubit,
  AnalysisCubit? analysisCubit,
  HistoryCubit? historyCubit,
}) {
  // Prevent GoogleFonts from fetching fonts over the network in tests
  GoogleFonts.config.allowRuntimeFetching = false;

  // Initialize mock shared preferences values if not already done
  SharedPreferences.setMockInitialValues({});

  final sl = GetIt.instance;

  // Use provided mock or fallback to registered mock or default Mock
  final finalAuth =
      authCubit ??
      (sl.isRegistered<AuthCubit>() ? sl<AuthCubit>() : MockAuthCubit());
  final finalAnalysis =
      analysisCubit ??
      (sl.isRegistered<AnalysisCubit>()
          ? sl<AnalysisCubit>()
          : MockAnalysisCubit());
  final finalHistory =
      historyCubit ??
      (sl.isRegistered<HistoryCubit>()
          ? sl<HistoryCubit>()
          : MockHistoryCubit());

  // Setup fallback stub responses if mock hasn't been stubbed yet
  if (authCubit == null && finalAuth is MockAuthCubit) {
    try {
      when(() => finalAuth.state).thenReturn(AuthInitial());
      when(
        () => finalAuth.stream,
      ).thenAnswer((_) => Stream.value(AuthInitial()));
    } catch (_) {}
  }
  if (analysisCubit == null && finalAnalysis is MockAnalysisCubit) {
    try {
      when(() => finalAnalysis.state).thenReturn(AnalysisInitial());
      when(
        () => finalAnalysis.stream,
      ).thenAnswer((_) => Stream.value(AnalysisInitial()));
    } catch (_) {}
  }
  if (historyCubit == null && finalHistory is MockHistoryCubit) {
    try {
      when(() => finalHistory.state).thenReturn(HistoryInitial());
      when(
        () => finalHistory.stream,
      ).thenAnswer((_) => Stream.value(HistoryInitial()));
    } catch (_) {}
  }

  return MultiBlocProvider(
    providers: [
      BlocProvider<AuthCubit>.value(value: finalAuth),
      BlocProvider<AnalysisCubit>.value(value: finalAnalysis),
      BlocProvider<HistoryCubit>.value(value: finalHistory),
    ],
    child: ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(),
      child: DefaultAssetBundle(
        bundle: TestAssetBundle(),
        child: MaterialApp(
          home: child,
          routes: {
            '/home': (context) => const Scaffold(body: Text('Home Screen Mock')),
            '/login': (context) =>
                const Scaffold(body: Text('Login Screen Mock')),
            '/signup': (context) =>
                const Scaffold(body: Text('Signup Screen Mock')),
            '/onboarding': (context) =>
                const Scaffold(body: Text('Onboarding Screen Mock')),
            '/dashboard': (context) => const DashboardScreen(),
          },
        ),
      ),
    ),
  );
}

// Setup and teardown DI registration helper
void setupMockDI({
  AuthCubit? authCubit,
  AnalysisCubit? analysisCubit,
  HistoryCubit? historyCubit,
}) {
  final sl = GetIt.instance;
  sl.reset();

  final actualAuth = authCubit ?? MockAuthCubit();
  final actualAnalysis = analysisCubit ?? MockAnalysisCubit();
  final actualHistory = historyCubit ?? MockHistoryCubit();

  if (actualAuth is MockAuthCubit) {
    when(() => actualAuth.state).thenReturn(AuthInitial());
    when(
      () => actualAuth.stream,
    ).thenAnswer((_) => const Stream<AuthState>.empty());
    when(() => actualAuth.checkAuthStatus()).thenAnswer((_) async {});
    when(() => actualAuth.close()).thenAnswer((_) async {});
  }

  if (actualAnalysis is MockAnalysisCubit) {
    when(() => actualAnalysis.state).thenReturn(AnalysisInitial());
    when(
      () => actualAnalysis.stream,
    ).thenAnswer((_) => const Stream<AnalysisState>.empty());
    when(() => actualAnalysis.close()).thenAnswer((_) async {});
  }

  if (actualHistory is MockHistoryCubit) {
    when(() => actualHistory.state).thenReturn(HistoryInitial());
    when(
      () => actualHistory.stream,
    ).thenAnswer((_) => const Stream<HistoryState>.empty());
    when(() => actualHistory.loadHistory()).thenAnswer((_) async {});
    when(() => actualHistory.close()).thenAnswer((_) async {});
  }

  sl.registerFactory<AuthCubit>(() => actualAuth);
  sl.registerFactory<AnalysisCubit>(() => actualAnalysis);
  sl.registerFactory<HistoryCubit>(() => actualHistory);
}

// Global helper to setup mock binary messenger asset interceptor
void setupMockAssetHandler() {
  HttpOverrides.global = TestHttpOverrides();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (ByteData? message) async {
        if (message == null) return null;
        final key = utf8.decode(
          message.buffer.asUint8List(
            message.offsetInBytes,
            message.lengthInBytes,
          ),
        );

        if (key == 'AssetManifest.json') {
          const manifest = {
            'assets/app_icon.png': [],
            'google_fonts/PlusJakartaSans-Regular.ttf': [],
            'google_fonts/PlusJakartaSans-Bold.ttf': [],
            'google_fonts/PlusJakartaSans-Italic.ttf': [],
            'google_fonts/PlusJakartaSans-BoldItalic.ttf': [],
            'google_fonts/PlusJakartaSans-Medium.ttf': [],
            'google_fonts/PlusJakartaSans-SemiBold.ttf': [],
            'google_fonts/PlusJakartaSans-ExtraBold.ttf': [],
            'google_fonts/PlusJakartaSans-Light.ttf': [],
            'google_fonts/PlusJakartaSans-ExtraLight.ttf': [],
            'google_fonts/PlusJakartaSans-Thin.ttf': [],
            'google_fonts/Inter-Regular.ttf': [],
            'google_fonts/Inter-Bold.ttf': [],
            'google_fonts/Inter-Medium.ttf': [],
            'google_fonts/Inter-SemiBold.ttf': [],
            'google_fonts/Inter-ExtraBold.ttf': [],
            'google_fonts/Outfit-Regular.ttf': [],
            'google_fonts/Outfit-Bold.ttf': [],
            'google_fonts/Outfit-Medium.ttf': [],
            'google_fonts/Outfit-SemiBold.ttf': [],
            'google_fonts/Outfit-ExtraBold.ttf': [],
            'google_fonts/Roboto-Regular.ttf': [],
            'google_fonts/Roboto-Bold.ttf': [],
            'google_fonts/Roboto-Medium.ttf': [],
          };
          final jsonStr = json.encode(manifest);
          return ByteData.sublistView(Uint8List.fromList(utf8.encode(jsonStr)));
        }

        if (key == 'AssetManifest.bin') {
          const manifest = {
            'assets/app_icon.png': [],
            'google_fonts/PlusJakartaSans-Regular.ttf': [],
            'google_fonts/PlusJakartaSans-Bold.ttf': [],
            'google_fonts/PlusJakartaSans-Italic.ttf': [],
            'google_fonts/PlusJakartaSans-BoldItalic.ttf': [],
            'google_fonts/PlusJakartaSans-Medium.ttf': [],
            'google_fonts/PlusJakartaSans-SemiBold.ttf': [],
            'google_fonts/PlusJakartaSans-ExtraBold.ttf': [],
            'google_fonts/PlusJakartaSans-Light.ttf': [],
            'google_fonts/PlusJakartaSans-ExtraLight.ttf': [],
            'google_fonts/PlusJakartaSans-Thin.ttf': [],
            'google_fonts/Inter-Regular.ttf': [],
            'google_fonts/Inter-Bold.ttf': [],
            'google_fonts/Inter-Medium.ttf': [],
            'google_fonts/Inter-SemiBold.ttf': [],
            'google_fonts/Inter-ExtraBold.ttf': [],
            'google_fonts/Outfit-Regular.ttf': [],
            'google_fonts/Outfit-Bold.ttf': [],
            'google_fonts/Outfit-Medium.ttf': [],
            'google_fonts/Outfit-SemiBold.ttf': [],
            'google_fonts/Outfit-ExtraBold.ttf': [],
            'google_fonts/Roboto-Regular.ttf': [],
            'google_fonts/Roboto-Bold.ttf': [],
            'google_fonts/Roboto-Medium.ttf': [],
          };
          final encoded = const StandardMessageCodec().encodeMessage(manifest);
          return ByteData.sublistView(
            encoded!.buffer.asUint8List(
              encoded.offsetInBytes,
              encoded.lengthInBytes,
            ),
          );
        }

        if (key.endsWith('.json')) {
          const jsonStr =
              '{"v":"4.8.0","meta":{},"fr":30,"ip":0,"op":30,"w":100,"h":100,"nm":"Test","ddd":0,"assets":[],"layers":[]}';
          return ByteData.sublistView(Uint8List.fromList(utf8.encode(jsonStr)));
        }

        if (key.endsWith('.ttf') || key.endsWith('.otf')) {
          return ByteData(1);
        }

        if (key.endsWith('.png') ||
            key.endsWith('.jpg') ||
            key.endsWith('.jpeg')) {
          return ByteData.sublistView(Uint8List.fromList(transparentImage));
        }

        return null;
      });
}

// Custom HTTP Overrides for serving a mock network image transparent PNG
class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return MockHttpClient();
  }
}

class MockHttpClient extends Mock implements HttpClient {
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return MockHttpClientRequest(url);
  }

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return MockHttpClientRequest(url);
  }

  @override
  Future<HttpClientRequest> postUrl(Uri url) async {
    return MockHttpClientRequest(url);
  }
}

class MockHttpClientRequest extends Mock implements HttpClientRequest {
  final Uri url;
  MockHttpClientRequest(this.url);

  @override
  Future<HttpClientResponse> close() async {
    return FakeHttpClientResponse(url);
  }

  @override
  HttpHeaders get headers => FakeHttpHeaders();

  @override
  void add(List<int> data) {}

  @override
  void write(Object? obj) {}

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future addStream(Stream<List<int>> stream) async {}

  @override
  Future flush() async {}
}

class FakeHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  final Uri requestUrl;
  late final List<int> bodyBytes;
  late final Stream<List<int>> _delegateStream;

  FakeHttpClientResponse(this.requestUrl) {
    bodyBytes = _getBodyBytes();
    _delegateStream = Stream.fromIterable([bodyBytes]);
  }

  List<int> _getBodyBytes() {
    final path = requestUrl.path;
    if (path.contains('compare-multiple')) {
      return utf8.encode(
        jsonEncode({
          "comparison_report": [
            {
              "filename": "test_resume.pdf",
              "overall_score": 85,
              "grade": "A",
              "salary_est": "\$150k",
              "top_skills": ["Flutter", "Dart"],
            },
          ],
          "best_fit_candidate": "test_resume.pdf",
          "recommendation": "test_resume.pdf is the best candidate",
        }),
      );
    } else if (path.contains('analyze')) {
      return utf8.encode(
        jsonEncode({
          "score": 85,
          "percentile": 90,
          "missingKeywords": ["GraphQL", "CI/CD"],
          "suggestions": [
            "Add links to projects",
            "Detail state management usage",
          ],
        }),
      );
    } else if (path.contains('rewrite')) {
      return utf8.encode(
        jsonEncode({
          "improved_text": "Successfully refactored Flutter applications.",
          "explanation": "Added action verbs and metrics.",
        }),
      );
    } else if (path.contains('audit')) {
      return utf8.encode(
        jsonEncode({
          "grammar_score": 95,
          "formatting_score": 90,
          "impact_score": 88,
          "red_flags": ["Avoid resume length over 2 pages"],
        }),
      );
    } else if (path.contains('job-matches')) {
      return utf8.encode(
        jsonEncode({
          "matches": [
            {
              "title": "Senior Flutter Engineer",
              "company": "Google",
              "match_rate": 92,
            },
          ],
        }),
      );
    } else if (path.contains('insights/market')) {
      return utf8.encode(
        jsonEncode({
          "hiring_index": 82,
          "average_salary": "\$140k",
          "trending_skills": ["Flutter", "Rust", "Go"],
        }),
      );
    }
    return transparentImage;
  }

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _delegateStream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  Stream<R> cast<R>() => _delegateStream.cast<R>();

  @override
  int get statusCode => 200;

  @override
  HttpHeaders get headers => FakeHttpHeaders();

  @override
  int get contentLength => bodyBytes.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  bool get isRedirect => false;

  @override
  List<RedirectInfo> get redirects => [];

  @override
  Future<HttpClientResponse> redirect([
    String? method,
    Uri? url,
    bool? followLoops,
  ]) async {
    return this;
  }

  @override
  late bool persistentConnection = true;

  @override
  late String reasonPhrase = "OK";

  @override
  X509Certificate? get certificate => null;

  @override
  HttpConnectionInfo? get connectionInfo => null;

  @override
  List<Cookie> get cookies => [];

  @override
  Future<Socket> detachSocket() async {
    throw UnimplementedError();
  }
}

class FakeHttpHeaders implements HttpHeaders {
  final Map<String, List<String>> _headers = {};

  FakeHttpHeaders() {
    _headers['content-type'] = ['application/json; charset=utf-8'];
  }

  @override
  List<String>? operator [](String name) => _headers[name.toLowerCase()];

  @override
  void noFolding(String name) {}

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {
    _headers.putIfAbsent(name.toLowerCase(), () => []).add(value.toString());
  }

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    _headers[name.toLowerCase()] = [value.toString()];
  }

  @override
  String? value(String name) {
    final list = _headers[name.toLowerCase()];
    if (list == null || list.isEmpty) return null;
    return list.first;
  }

  @override
  late bool chunkedTransferEncoding = false;

  @override
  late int contentLength = -1;

  @override
  ContentType? contentType = ContentType.json;

  @override
  late DateTime? date;

  @override
  late DateTime? expires;

  @override
  late String? host;

  @override
  late DateTime? ifModifiedSince;

  @override
  late int? port;

  @override
  void clear() => _headers.clear();

  @override
  void forEach(void Function(String name, List<String> values) action) {
    _headers.forEach(action);
  }

  @override
  bool get persistentConnection => true;
  @override
  set persistentConnection(bool persistentConnection) {}

  @override
  void remove(String name, Object value) {
    _headers[name.toLowerCase()]?.remove(value.toString());
  }

  @override
  void removeAll(String name) {
    _headers.remove(name.toLowerCase());
  }

  @override
  List<String> get(String name) => _headers[name.toLowerCase()] ?? [];

  @override
  String toString() => _headers.toString();
}

final List<int> transparentImage = [
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
];
