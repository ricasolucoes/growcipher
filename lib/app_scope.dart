import 'package:flutter/widgets.dart';

import 'domain/repositories/plant_repository.dart';

/// Ponto único de acesso às dependências do app (injeção sem biblioteca de
/// state management — padrão do projeto é Flutter puro).
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.plantRepository,
    required this.routeObserver,
    required super.child,
  });

  final PlantRepository plantRepository;

  /// Permite que telas de listagem recarreguem quando voltam ao topo da
  /// pilha (ver [RouteAware]).
  final RouteObserver<ModalRoute<Object?>> routeObserver;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope ausente na árvore de widgets');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      plantRepository != oldWidget.plantRepository ||
      routeObserver != oldWidget.routeObserver;
}
