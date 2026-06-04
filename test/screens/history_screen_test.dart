import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:resume_ai/screens/history_screen.dart';
import 'package:resume_ai/services/history_service.dart';
import 'package:resume_ai/models/analysis_history.dart';
import 'package:resume_ai/models/analysis_history_adapter.dart';
import 'package:resume_ai/screens/dashboard_screen.dart';
import '../helpers/test_helper.dart';

void main() {
  late Directory tempDir;
  late Box<AnalysisHistory> historyBox;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_test');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AnalysisHistoryAdapter());
    }
  });

  setUp(() async {
    setupMockAssetHandler();
    if (Hive.isBoxOpen(HistoryService.boxName)) {
      await Hive.box<AnalysisHistory>(HistoryService.boxName).clear();
      historyBox = Hive.box<AnalysisHistory>(HistoryService.boxName);
    } else {
      historyBox = await Hive.openBox<AnalysisHistory>(HistoryService.boxName);
    }
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  testWidgets('HistoryScreen renders empty state when no history exists', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        makeTestableWidget(
          child: const HistoryScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("No history found"), findsOneWidget);
      expect(find.byIcon(Icons.history_rounded), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });
  });

  testWidgets('HistoryScreen renders history items and supports search filtering', (WidgetTester tester) async {
    await tester.runAsync(() async {
      // Add mock data to the open Box
      final item1 = AnalysisHistory(
        id: "1",
        fileName: "resume_software_engineer.pdf",
        score: 85,
        percentile: 90,
        date: DateTime(2026, 5, 20),
        missingKeywords: ["Dart", "Flutter"],
        suggestions: ["Add project links"],
      );
      final item2 = AnalysisHistory(
        id: "2",
        fileName: "cv_product_manager.pdf",
        score: 65,
        percentile: 70,
        date: DateTime(2026, 5, 21),
        missingKeywords: ["Agile", "Scrum"],
        suggestions: ["Add metrics"],
      );

      await historyBox.put(item1.id, item1);
      await historyBox.put(item2.id, item2);

      await tester.pumpWidget(
        makeTestableWidget(
          child: const HistoryScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify both items render
      expect(find.text("resume_software_engineer.pdf"), findsOneWidget);
      expect(find.text("cv_product_manager.pdf"), findsOneWidget);
      expect(find.text("85%"), findsOneWidget);
      expect(find.text("65%"), findsOneWidget);

      // Search for product manager
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, "product");
      await tester.pumpAndSettle();

      // Only PM cv should be visible
      expect(find.text("resume_software_engineer.pdf"), findsNothing);
      expect(find.text("cv_product_manager.pdf"), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });
  });

  testWidgets('HistoryScreen clear all button shows confirmation and clears history', (WidgetTester tester) async {
    await tester.runAsync(() async {
      final item = AnalysisHistory(
        id: "1",
        fileName: "resume.pdf",
        score: 90,
        date: DateTime.now(),
        missingKeywords: [],
        suggestions: [],
      );
      await historyBox.put(item.id, item);

      await tester.pumpWidget(
        makeTestableWidget(
          child: const HistoryScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("resume.pdf"), findsOneWidget);

      // Tap clear all button in AppBar
      final clearAllButton = find.byIcon(Icons.delete_sweep_rounded);
      expect(clearAllButton, findsOneWidget);
      await tester.tap(clearAllButton);
      await tester.pumpAndSettle();

      // Verify confirmation dialog shows
      expect(find.text("Clear History?"), findsOneWidget);

      // Tap Clear All in dialog
      final confirmButton = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(TextButton, "Clear All"),
      );
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      // Yield to real event loop to allow Hive asynchronous file I/O to complete
      await Future.delayed(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Verify screen is empty now
      expect(find.text("resume.pdf"), findsNothing);
      expect(find.text("No history found"), findsOneWidget);

      // Verify Hive is empty
      expect(historyBox.length, 0);

      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });
  });

  testWidgets('Tapping a history item navigates to DashboardScreen', (WidgetTester tester) async {
    await tester.runAsync(() async {
      final item = AnalysisHistory(
        id: "1",
        fileName: "resume_engineer.pdf",
        score: 85,
        percentile: 88,
        date: DateTime.now(),
        missingKeywords: ["Testing"],
        suggestions: ["Improve layout"],
      );
      await historyBox.put(item.id, item);

      await tester.pumpWidget(
        makeTestableWidget(
          child: const HistoryScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final listItem = find.text("resume_engineer.pdf");
      expect(listItem, findsOneWidget);

      // Tap item to navigate
      await tester.tap(listItem);
      await tester.pumpAndSettle();

      // Verify DashboardScreen is pushed
      expect(find.byType(DashboardScreen), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });
  });
}
