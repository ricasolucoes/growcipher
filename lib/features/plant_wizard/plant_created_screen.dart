import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../domain/models/plant.dart';
import '../../domain/models/plant_enums.dart';
import '../common/enum_labels.dart';
import '../common/formatting.dart';
import '../common/l10n_extensions.dart';
import '../plant_profile/plant_profile_screen.dart';
import '../quick_log/quick_log.dart';

/// Tela de sucesso pós-criação: resumo + convite para o primeiro registro.
class PlantCreatedScreen extends StatefulWidget {
  const PlantCreatedScreen({super.key, required this.plantId});

  static const String route = '/plants/created';

  final String plantId;

  @override
  State<PlantCreatedScreen> createState() => _PlantCreatedScreenState();
}

class _PlantCreatedScreenState extends State<PlantCreatedScreen> {
  Plant? _plant;
  bool _loadRequested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadRequested) {
      _loadRequested = true;
      _load();
    }
  }

  Future<void> _load() async {
    final plant = await AppScope.of(
      context,
    ).plantRepository.getPlant(widget.plantId);
    if (mounted) {
      setState(() => _plant = plant);
    }
  }

  void _goToPlant() {
    Navigator.of(
      context,
    ).pushReplacementNamed(PlantProfileScreen.route, arguments: widget.plantId);
  }

  Future<void> _registerFirstActivity() async {
    final plant = _plant;
    if (plant == null) return;

    final saved = await showQuickLog(context, plant);
    if (!mounted) return;
    if (saved) {
      _goToPlant();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final plant = _plant;

    return Scaffold(
      body: SafeArea(
        child: plant == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                children: [
                  Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        size: 44,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.successTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.successSubtitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _SummaryCard(plant: plant),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: _registerFirstActivity,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(l10n.registerFirstActivity),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _goToPlant,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(l10n.goToPlant),
                  ),
                ],
              ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.plant});

  final Plant plant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    final chips = <String>[
      if (plant.phase != PlantPhase.unknown) l10n.phaseLabel(plant.phase),
      if (plant.environment != GrowingEnvironment.unknown)
        l10n.environmentLabel(plant.environment),
      if (plant.growingMedium != GrowingMedium.unknown)
        l10n.growingMediumLabel(plant.growingMedium),
      if (plant.strain != null) plant.strain!,
    ];

    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plant.displayLabel, style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              plant.privacyCode,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (plant.startDate != null) ...[
              const SizedBox(height: 4),
              Text(
                formatDate(
                  context,
                  plant.startDate!,
                  approximate: plant.startDateIsApproximate,
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (chips.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final label in chips)
                    Chip(
                      label: Text(label),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
