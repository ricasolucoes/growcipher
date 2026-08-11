import 'package:flutter/material.dart';

void main() {
  runApp(const GrowCipherApp());
}

/// Seed provisória do Material 3 — verde sóbrio, sem estética canábica.
///
/// A paleta definitiva (light/dark + `theme_color` do manifest) é entregável
/// de design, ver `docs/Design.md` §5, item 3.
const Color _seedColor = Color(0xFF2E6B4F);

class GrowCipherApp extends StatelessWidget {
  const GrowCipherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GrowCipher',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
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

/// Placeholder da home / painel diário.
///
/// A tela real (plantas ativas, tarefas pendentes, últimos registros) depende
/// do cofre criptografado da Phase 2 e chega na Phase 3 do roadmap.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('GrowCipher')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.lock_outline,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Seu cultivo. Seus dados. Suas decisões.',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Cofre local em construção — o registro de plantas chega na '
                'Phase 3 do roadmap.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
