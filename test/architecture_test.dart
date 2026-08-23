import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// As peças que decidem o que a tela mostra ficam em código puro.
///
/// É a promessa que sustenta a decisão de não usar biblioteca de gerência de
/// estado (`docs/gerencia-de-estado.md`): a regra sai do `State` e vira Dart
/// comum, testável sem subir árvore de widgets. Um `import` de Flutter aqui
/// é o primeiro passo de volta para a tela gigante, então ele reprova.
void main() {
  test(
    'a máquina do wizard e o contrato do registro rápido não usam Flutter',
    () {
      const pure = [
        'lib/features/plant_wizard/wizard_machine.dart',
        'lib/features/quick_log/forms/quick_log_input.dart',
      ];

      for (final path in pure) {
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: '$path sumiu');
        expect(
          file.readAsStringSync(),
          isNot(contains('package:flutter/')),
          reason: '$path precisa continuar puro',
        );
      }
    },
  );
}
