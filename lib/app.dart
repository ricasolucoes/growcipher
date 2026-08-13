import 'package:flutter/material.dart';

import 'app_scope.dart';
import 'domain/repositories/plant_repository.dart';
import 'features/home/home_screen.dart';
import 'features/plant_profile/plant_profile_screen.dart';
import 'features/plant_wizard/plant_created_screen.dart';
import 'features/plant_wizard/plant_wizard_screen.dart';
import 'l10n/generated/app_localizations.dart';

/// Seed provisória do Material 3 — verde sóbrio, sem estética canábica.
///
/// A paleta definitiva (light/dark + `theme_color` do manifest) é entregável
/// de design, ver `docs/Design.md` §5, item 3.
const Color _seedColor = Color(0xFF2E6B4F);

class GrowCipherApp extends StatelessWidget {
  GrowCipherApp({super.key, required this.repository});

  final PlantRepository repository;

  final RouteObserver<ModalRoute<Object?>> _routeObserver =
      RouteObserver<ModalRoute<Object?>>();

  @override
  Widget build(BuildContext context) {
    return AppScope(
      plantRepository: repository,
      routeObserver: _routeObserver,
      child: MaterialApp(
        navigatorObservers: [_routeObserver],
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(Brightness.light),
        darkTheme: _buildTheme(Brightness.dark),
        // Dark mode é prioritário (uso noturno em grow room), mas o app
        // respeita a escolha do sistema.
        themeMode: ThemeMode.system,
        // pt-BR é o idioma padrão do produto; outros idiomas entram como
        // novos ARBs em lib/l10n.
        locale: const Locale('pt', 'BR'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: const [
          Locale('pt', 'BR'),
          ...AppLocalizations.supportedLocales,
        ],
        onGenerateRoute: _onGenerateRoute,
        initialRoute: HomeScreen.route,
      ),
    );
  }

  Route<Object?>? _onGenerateRoute(RouteSettings settings) {
    final builder = switch (settings.name) {
      HomeScreen.route => (_) => const HomeScreen(),
      PlantWizardScreen.route => (_) => const PlantWizardScreen(),
      PlantCreatedScreen.route => (_) => PlantCreatedScreen(
        plantId: settings.arguments as String,
      ),
      PlantProfileScreen.route => (_) => PlantProfileScreen(
        plantId: settings.arguments as String,
      ),
      _ => null,
    };
    if (builder == null) return null;
    return MaterialPageRoute<Object?>(builder: builder, settings: settings);
  }

  ThemeData _buildTheme(Brightness brightness) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: brightness,
      ),
      useMaterial3: true,
    );
  }
}
