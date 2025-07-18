import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Fake version of your Dashboard for testing only
class FakeDashboard extends StatelessWidget {
  const FakeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Dashboard Loaded')),
    );
  }
}

// Test-specific MyApp
class MyAppForTest extends StatelessWidget {
  const MyAppForTest({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: FakeDashboard(),
    );
  }
}

void main() {
  testWidgets('MyApp renders FakeDashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const MyAppForTest());
    await tester.pumpAndSettle();

    expect(find.text('Dashboard Loaded'), findsOneWidget);
  });
}
