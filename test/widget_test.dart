import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_/screens/main_navigation_screen.dart';
import 'package:app_/services/match_journal_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('MatchJournalService normalizes Russian and lowercase sport names to English', () {
    expect(MatchJournalService.normalizeSport('\u0424\u0443\u0442\u0431\u043e\u043b'), equals('Football'));
    expect(MatchJournalService.normalizeSport('\u0444\u0443\u0442\u0431\u043e\u043b'), equals('Football'));
    expect(MatchJournalService.normalizeSport('\u0425\u043e\u043a\u043a\u0435\u0439'), equals('Hockey'));
    expect(MatchJournalService.normalizeSport('\u0445\u043e\u043a\u043a\u0435\u0439'), equals('Hockey'));
    expect(MatchJournalService.normalizeSport('\u0411\u0430\u0441\u043a\u0435\u0442\u0431\u043e\u043b'), equals('Basketball'));
    expect(MatchJournalService.normalizeSport('\u0431\u0430\u0441\u043a\u0435\u0442\u0431\u043e\u043b'), equals('Basketball'));
    expect(MatchJournalService.normalizeSport('\u0422\u0435\u043d\u043d\u0438\u0441'), equals('Tennis'));
    expect(MatchJournalService.normalizeSport('\u0442\u0435\u043d\u043d\u0438\u0441'), equals('Tennis'));
    expect(MatchJournalService.normalizeSport('\u0412\u043e\u043b\u0435\u0439\u0431\u043e\u043b'), equals('Volleyball'));
    expect(MatchJournalService.normalizeSport('\u0432\u043e\u043b\u0435\u0439\u0431\u043e\u043b'), equals('Volleyball'));
    expect(MatchJournalService.normalizeSport('Football'), equals('Football'));
  });

  testWidgets('MainNavigationScreen has 3 tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MainNavigationScreen(),
      ),
    );
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('Statistics'), findsOneWidget);
  });
}
