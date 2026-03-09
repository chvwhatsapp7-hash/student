import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:internship_app/main.dart';

void main() {
  testWidgets('App loads test', (WidgetTester tester) async {

    await tester.pumpWidget(const TechPathApp());

    expect(find.byType(MaterialApp), findsOneWidget);

  });
}