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

    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Tap fast. Sum faster.'), findsOneWidget);
  });
}
