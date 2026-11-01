import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_/main.dart';
import 'package:app_/screens/main_navigation_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App smoke test: loads MainApp', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());
    expect(find.byType(MaterialApp), findsOneWidget);
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
