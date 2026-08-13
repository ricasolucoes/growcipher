import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/security/local_auth_service.dart';
import 'core/security/secure_storage_service.dart';
import 'features/home/home_screen.dart';
import 'features/settings/export_screen.dart';
import 'features/plant_profile/plant_profile_screen.dart';
import 'features/plant_wizard/plant_created_screen.dart';
import 'features/plant_wizard/plant_wizard_screen.dart';
import 'l10n/generated/app_localizations.dart';

/// Seed provisória do Material 3 — verde sóbrio, sem estética canábica.
///
/// A paleta definitiva (light/dark + `theme_color` do manifest) é entregável
/// de design, ver `docs/Design.md` §5, item 3.
const Color _seedColor = Color(0xFF2E6B4F);

class GrowCipherApp extends StatefulWidget {
  const GrowCipherApp({super.key});

  @override
  State<GrowCipherApp> createState() => _GrowCipherAppState();
}

class _GrowCipherAppState extends State<GrowCipherApp>
    with WidgetsBindingObserver {
  final _localAuthService = LocalAuthService();
  final _secureStorageService = const SecureStorageService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      final biometricEnabled = await _secureStorageService.isBiometricEnabled();
      if (biometricEnabled) {
        final authenticated = await _localAuthService.authenticate();
        if (!authenticated) {
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      ExportScreen.route => (_) => const ExportScreen(),
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
