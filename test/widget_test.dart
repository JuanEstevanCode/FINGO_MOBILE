import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fingo_mobile/features/movements/screens/home_page.dart';
import 'package:fingo_mobile/main.dart';

void main() {
  testWidgets('El inicio requiere autenticaciÃ³n del backend', (WidgetTester tester) async {
    await tester.pumpWidget(const FingoApp());
    expect(find.text('FINGO'), findsOneWidget);
    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
  });

  testWidgets('La pantalla de movimientos existente sigue disponible', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));

    expect(find.text('Movimientos'), findsOneWidget);
    expect(find.text('Historial financiero'), findsOneWidget);
    expect(find.text('Balance total'), findsOneWidget);
  });
}


