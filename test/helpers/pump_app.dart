import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growcipher/app.dart';
import 'package:growcipher/domain/repositories/plant_repository.dart';
import 'package:growcipher/providers.dart';

/// Sobe o app com viewport de celular alto (evita precisar rolar nos passos
/// do wizard durante os testes).
Future<void> pumpApp(WidgetTester tester, PlantRepository repository) async {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        plantRepositoryProvider.overrideWithValue(repository),
      ],
      child: const GrowCipherApp(),
    ),
  );
  await tester.pumpAndSettle();
}
