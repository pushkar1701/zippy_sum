import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zippy_sum/app/app.dart';
import 'package:zippy_sum/services/local_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      LocalStorageService.keyHasSeenOnboarding: true,
    });
  });

  testWidgets('App loads and reaches home after splash', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ZippySumApp());
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    // Pump past the 700ms splash delay + navigation + home FutureBuilder.
    // pumpAndSettle cannot be used because ArcadeBackground runs a repeating
    // animation that never settles.
    await tester.pump(); // trigger postFrameCallback
    await tester.pump(const Duration(milliseconds: 900)); // fire splash timer
    await tester.pump(); // process navigation microtasks
    await tester.pump(); // FutureBuilder resolution
    await tester.pump(const Duration(milliseconds: 100)); // widget settle

    expect(find.text('Tap fast. Sum faster.'), findsOneWidget);
  });
}
