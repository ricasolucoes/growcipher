import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:growcipher/main.dart';

void main() {
  testWidgets('app inicia na home', (WidgetTester tester) async {
    await tester.pumpWidget(const GrowCipherApp());

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Seu cultivo. Seus dados. Suas decisões.'), findsOneWidget);
  });

  testWidgets('tema usa Material 3 sem a seed padrão do template',
      (WidgetTester tester) async {
    await tester.pumpWidget(const GrowCipherApp());

    final theme = Theme.of(tester.element(find.byType(HomeScreen)));
    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.primary, isNot(Colors.deepPurple));
  });
}
