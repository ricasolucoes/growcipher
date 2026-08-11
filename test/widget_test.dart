import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:growcipher/l10n/generated/app_localizations.dart';

import 'helpers/fake_plant_repository.dart';
import 'helpers/pump_app.dart';

void main() {
  testWidgets('pt-BR é o idioma padrão do app', (tester) async {
    await pumpApp(tester, FakePlantRepository());

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.locale, const Locale('pt', 'BR'));
    expect(app.supportedLocales, contains(const Locale('pt', 'BR')));

    final context = tester.element(find.byType(Scaffold));
    expect(Localizations.localeOf(context).languageCode, 'pt');
    expect(AppLocalizations.of(context).appTitle, 'GrowCipher');
  });

  testWidgets('home vazia convida a cadastrar a primeira planta em português', (
    tester,
  ) async {
    await pumpApp(tester, FakePlantRepository());

    expect(find.text('Vamos cadastrar sua planta'), findsOneWidget);
    expect(find.text('Adicionar planta'), findsOneWidget);
    expect(
      find.text('Seu cultivo. Seus dados. Suas decisões.'),
      findsOneWidget,
    );
  });

  testWidgets('tema usa Material 3 sem a seed padrão do template', (
    tester,
  ) async {
    await pumpApp(tester, FakePlantRepository());

    final theme = Theme.of(tester.element(find.byType(Scaffold)));
    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.primary, isNot(Colors.deepPurple));
  });
}
