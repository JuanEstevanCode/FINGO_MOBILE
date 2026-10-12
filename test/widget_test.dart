
import 'package:flutter_test/flutter_test.dart';
import 'package:fingo_mobile/main.dart';

void main() {
  testWidgets('La pantalla principal de FINGO se muestra', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FingoApp());

    expect(find.text('FINGO'), findsOneWidget);
    expect(find.text('Tus finanzas, más claras.'), findsOneWidget);
    expect(find.text('Movimientos'), findsOneWidget);

    // Desplaza la pantalla hasta que el botón sea visible.
    await tester.ensureVisible(find.text('Registrar movimiento'));
    await tester.pumpAndSettle();

    expect(find.text('Registrar movimiento'), findsOneWidget);
  });
}
