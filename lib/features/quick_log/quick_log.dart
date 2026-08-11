import 'package:flutter/material.dart';

import '../../domain/models/plant.dart';
import '../common/l10n_extensions.dart';
import 'quick_log_forms.dart';

/// Ações do registro rápido. Cada uma gera um `PlantEvent` (ou, no caso de
/// fase/encerramento, passa pelo repositório para snapshot + evento).
enum QuickLogAction {
  watered,
  fed,
  treatment,
  measurement,
  transplant,
  phaseChange,
  photo,
  observation,
  problem,
  taskDone,
  harvest,
  endPlant,
}

/// Abre o registro rápido para [plant]. Retorna `true` se um evento foi
/// salvo (e mostra o aviso "Registro salvo").
Future<bool> showQuickLog(BuildContext context, Plant plant) async {
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) => QuickLogSheet(plant: plant),
  );

  if (saved == true && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.eventSaved)));
  }
  return saved == true;
}

/// Bottom sheet do registro rápido: menu "O que aconteceu?" e, ao escolher,
/// o formulário mínimo da ação — salvar só com data/hora já é válido.
class QuickLogSheet extends StatefulWidget {
  const QuickLogSheet({super.key, required this.plant});

  final Plant plant;

  @override
  State<QuickLogSheet> createState() => _QuickLogSheetState();
}

class _QuickLogSheetState extends State<QuickLogSheet> {
  QuickLogAction? _selected;

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 100),
      padding: EdgeInsets.only(bottom: viewInsets),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: _selected == null
              ? _QuickLogMenu(
                  onSelect: (action) => setState(() => _selected = action),
                )
              : QuickLogForm(
                  action: _selected!,
                  plant: widget.plant,
                  onBack: () => setState(() => _selected = null),
                ),
        ),
      ),
    );
  }
}

class _QuickLogMenu extends StatelessWidget {
  const _QuickLogMenu({required this.onSelect});

  final ValueChanged<QuickLogAction> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    final entries = <(_ActionSpec, QuickLogAction)>[
      (
        _ActionSpec(l10n.quickLogWatered, Icons.water_drop_outlined),
        QuickLogAction.watered,
      ),
      (
        _ActionSpec(l10n.quickLogFed, Icons.science_outlined),
        QuickLogAction.fed,
      ),
      (
        _ActionSpec(l10n.quickLogTreatment, Icons.healing_outlined),
        QuickLogAction.treatment,
      ),
      (
        _ActionSpec(l10n.quickLogMeasurement, Icons.thermostat_outlined),
        QuickLogAction.measurement,
      ),
      (
        _ActionSpec(l10n.quickLogTransplant, Icons.yard_outlined),
        QuickLogAction.transplant,
      ),
      (
        _ActionSpec(l10n.quickLogPhaseChange, Icons.trending_up),
        QuickLogAction.phaseChange,
      ),
      (
        _ActionSpec(
          l10n.quickLogPhoto,
          Icons.photo_camera_outlined,
          sublabel: l10n.quickLogPhotoComingSoon,
          enabled: false,
        ),
        QuickLogAction.photo,
      ),
      (
        _ActionSpec(l10n.quickLogObservation, Icons.notes_outlined),
        QuickLogAction.observation,
      ),
      (
        _ActionSpec(l10n.quickLogProblem, Icons.report_problem_outlined),
        QuickLogAction.problem,
      ),
      (
        _ActionSpec(l10n.quickLogTaskDone, Icons.check_circle_outline),
        QuickLogAction.taskDone,
      ),
      (
        _ActionSpec(l10n.quickLogHarvest, Icons.agriculture_outlined),
        QuickLogAction.harvest,
      ),
      (
        _ActionSpec(
          l10n.quickLogEndPlant,
          Icons.flag_outlined,
          destructive: true,
        ),
        QuickLogAction.endPlant,
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 16),
          child: Text(l10n.quickLogTitle, style: theme.textTheme.titleLarge),
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.4,
          children: [
            for (final (spec, action) in entries)
              _ActionCell(spec: spec, onTap: () => onSelect(action)),
          ],
        ),
      ],
    );
  }
}

class _ActionSpec {
  const _ActionSpec(
    this.label,
    this.icon, {
    this.sublabel,
    this.enabled = true,
    this.destructive = false,
  });

  final String label;
  final IconData icon;
  final String? sublabel;
  final bool enabled;
  final bool destructive;
}

class _ActionCell extends StatelessWidget {
  const _ActionCell({required this.spec, required this.onTap});

  final _ActionSpec spec;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final disabledColor = colors.onSurface.withValues(alpha: 0.38);
    final iconColor = !spec.enabled
        ? disabledColor
        : spec.destructive
        ? colors.error
        : colors.primary;

    return Material(
      color: colors.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: spec.enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(spec.icon, size: 22, color: iconColor),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      spec.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: spec.enabled ? colors.onSurface : disabledColor,
                      ),
                    ),
                    if (spec.sublabel != null)
                      Text(
                        spec.sublabel!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: disabledColor,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
