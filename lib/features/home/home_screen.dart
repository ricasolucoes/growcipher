import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../domain/models/plant.dart';
import '../../domain/models/plant_enums.dart';
import '../common/enum_labels.dart';
import '../common/l10n_extensions.dart';
import '../plant_profile/plant_profile_screen.dart';
import '../plant_wizard/plant_wizard_screen.dart';

/// Home / painel: lista as plantas ou convida a cadastrar a primeira.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String route = '/';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  List<Plant>? _plants;
  bool _loadRequested = false;
  RouteObserver<ModalRoute<Object?>>? _routeObserver;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadRequested) {
      _loadRequested = true;
      _reload();
    }

    // O wizard troca a própria rota pela tela de sucesso e depois pelo
    // perfil (pushReplacement), então esperar o Future do pushNamed traria a
    // lista já defasada. Recarregar em didPopNext cobre qualquer retorno.
    final observer = AppScope.of(context).routeObserver;
    final route = ModalRoute.of(context);
    if (observer != _routeObserver && route != null) {
      _routeObserver?.unsubscribe(this);
      _routeObserver = observer..subscribe(this, route);
    }
  }

  @override
  void dispose() {
    _routeObserver?.unsubscribe(this);
    super.dispose();
  }

  /// Uma rota empilhada sobre a home foi fechada — os dados podem ter mudado.
  @override
  void didPopNext() => _reload();

  Future<void> _reload() async {
    final plants = await AppScope.of(context).plantRepository.getPlants();
    if (mounted) {
      setState(() => _plants = plants);
    }
  }

  void _openWizard() {
    Navigator.of(context).pushNamed(PlantWizardScreen.route);
  }

  void _openPlant(Plant plant) {
    Navigator.of(
      context,
    ).pushNamed(PlantProfileScreen.route, arguments: plant.id);
  }

  @override
  Widget build(BuildContext context) {
    final plants = _plants;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.appTitle)),
      floatingActionButton: (plants == null || plants.isEmpty)
          ? null
          : FloatingActionButton.extended(
              onPressed: _openWizard,
              icon: const Icon(Icons.add),
              label: Text(context.l10n.addPlant),
            ),
      body: switch (plants) {
        null => const Center(child: CircularProgressIndicator()),
        [] => _EmptyState(onAddPlant: _openWizard),
        _ => _PlantList(plants: plants, onOpenPlant: _openPlant),
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddPlant});

  final VoidCallback onAddPlant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.spa_outlined,
                    size: 56,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.homeEmptyTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.homeEmptyBody,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: onAddPlant,
                    icon: const Icon(Icons.add),
                    label: Text(l10n.addPlant),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                l10n.homeTagline,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlantList extends StatelessWidget {
  const _PlantList({required this.plants, required this.onOpenPlant});

  final List<Plant> plants;
  final ValueChanged<Plant> onOpenPlant;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: plants.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
            child: Text(
              l10n.homePlantsSection,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          );
        }
        return _PlantTile(
          plant: plants[index - 1],
          onTap: () => onOpenPlant(plants[index - 1]),
        );
      },
    );
  }
}

class _PlantTile extends StatelessWidget {
  const _PlantTile({required this.plant, required this.onTap});

  final Plant plant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    final details = <String>[
      if (plant.phase != PlantPhase.unknown) l10n.phaseLabel(plant.phase),
      if (plant.startDate != null)
        l10n.plantAgeDays(DateTime.now().difference(plant.startDate!).inDays),
      if (plant.displayName != null) plant.privacyCode,
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
          child: const Icon(Icons.spa_outlined),
        ),
        title: Text(plant.displayLabel),
        subtitle: details.isEmpty ? null : Text(details.join(' · ')),
        trailing: plant.status == PlantStatus.active
            ? const Icon(Icons.chevron_right)
            : Text(
                l10n.statusLabel(plant.status),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
      ),
    );
  }
}
