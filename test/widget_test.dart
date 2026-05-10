import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zippy_sum/app/app.dart';

void main() {
  testWidgets('App loads and reaches home after splash', (WidgetTester tester) async {
    await tester.pumpWidget(const ZippySumApp());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Tap fast. Sum faster.'), findsOneWidget);
  });
}
