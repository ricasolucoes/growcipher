import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:growcipher/app.dart';
import 'package:growcipher/domain/repositories/plant_repository.dart';

/// Sobe o app com viewport de celular. O padrão é alto o bastante para não
/// precisar rolar nos passos do wizard; [size] permite testar telas pequenas.
Future<void> pumpApp(
  WidgetTester tester,
  PlantRepository repository, {
  Size size = const Size(800, 1600),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(GrowCipherApp(repository: repository));
  await tester.pumpAndSettle();
}
