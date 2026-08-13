import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import '../../domain/models/grow_stats.dart';
import '../../domain/models/plant.dart';
import '../../domain/models/plant_enums.dart';
import '../common/enum_labels.dart';
import '../common/l10n_extensions.dart';
import '../plant_profile/plant_profile_screen.dart';
import '../plant_wizard/plant_wizard_screen.dart';

/// Home / painel: lista as plantas ou convida a cadastrar a primeira.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  static const String route = '/';

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<Plant>? _plants;
  GrowStats? _stats;
  bool _loadRequested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadRequested) {
      _loadRequested = true;
      _reload();
    }
  }

  Future<void> _reload() async {
    final repo = ref.read(plantRepositoryProvider);
    final plants = await repo.getPlants();
    final stats = await repo.getStats();
    if (mounted) {
      setState(() {
        _plants = plants;
        _stats = stats;
      });
    }
  }

  Future<void> _openWizard() async {
    await Navigator.of(context).pushNamed(PlantWizardScreen.route);
    if (mounted) {
      await _reload();
    }
  }

  Future<void> _openPlant(Plant plant) async {
    await Navigator.of(
      context,
    ).pushNamed(PlantProfileScreen.route, arguments: plant.id);
    if (mounted) {
      await _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final plants = _plants;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/export'),
          ),
        ],
      ),
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
        _ => _PlantList(plants: plants, stats: _stats, onOpenPlant: _openPlant),
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
  const _PlantList({
    required this.plants,
    this.stats,
    required this.onOpenPlant,
  });

  final List<Plant> plants;
  final GrowStats? stats;
  final ValueChanged<Plant> onOpenPlant;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasStats = stats != null;
    final offset = hasStats ? 2 : 1;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: plants.length + offset,
      itemBuilder: (context, index) {
        if (hasStats && index == 0) {
          return _StatsCard(stats: stats!);
        }

        final headerIndex = hasStats ? 1 : 0;
        if (index == headerIndex) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
            child: Text(
              l10n.homePlantsSection,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          );
        }

        final plantIndex = index - offset;
        return _PlantTile(
          plant: plants[plantIndex],
          onTap: () => onOpenPlant(plants[plantIndex]),
        );
      },
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.stats});

  final GrowStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    Widget statItem(String label, int value) {
      return Column(
        children: [
          Text(
            value.toString(),
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            statItem(l10n.statsTotalPlants, stats.totalPlants),
            statItem(l10n.statsActivePlants, stats.activePlants),
            statItem(l10n.statsTotalEvents, stats.totalEvents),
          ],
        ),
      ),
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
