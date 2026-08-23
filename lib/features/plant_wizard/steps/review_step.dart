import 'package:flutter/material.dart';

import '../../common/enum_labels.dart';
import '../../common/formatting.dart';
import '../../common/l10n_extensions.dart';
import '../wizard_labels.dart';
import '../wizard_machine.dart';

/// Revisão — mostra só o que foi respondido, e cada seção volta ao passo que
/// a originou. É a última tela antes de qualquer coisa ir para o banco.
class ReviewStep extends StatelessWidget {
  const ReviewStep({
    super.key,
    required this.machine,
    required this.creating,
    required this.onEditStep,
    required this.onCreate,
  });

  final WizardMachine machine;

  /// Gravação em andamento: trava o botão e mostra o indicador.
  final bool creating;

  final ValueChanged<WizardStep> onEditStep;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final draft = machine.draft;

    final sections = <Widget>[];

    void addSection(String title, WizardStep step, List<Widget> rows) {
      if (rows.isEmpty) return;
      sections.add(
        _ReviewSection(
          title: title,
          onTap: () => onEditStep(step),
          children: rows,
        ),
      );
    }

    Widget row(String? label, String value) =>
        _ReviewRow(label: label, value: value);

    final datesTitle = l10n.datesQuestionTitle(machine.datesQuestion);

    // Ponto de partida
    addSection(l10n.reviewSectionStart, WizardStep.start, [
      if (draft.startingPoint != null)
        row(null, l10n.startingPointLabel(draft.startingPoint!)),
    ]);

    // Identificação
    addSection(l10n.reviewSectionIdentity, WizardStep.identity, [
      if (draft.displayName?.trim().isNotEmpty ?? false)
        row(l10n.plantNameLabel, draft.displayName!.trim()),
      row(l10n.privacyCodeLabel, draft.privacyCode),
    ]);

    // Origem
    addSection(l10n.reviewSectionOrigin, WizardStep.origin, [
      if (draft.origin != null)
        row(
          null,
          l10n.originLabel(draft.origin!, startingPoint: draft.startingPoint),
        ),
      if (draft.originDetails?.trim().isNotEmpty ?? false)
        row(l10n.originDetailsLabel, draft.originDetails!.trim()),
    ]);

    // Genética
    addSection(l10n.reviewSectionGenetics, WizardStep.genetics, [
      if (draft.knowsGenetics == false) row(null, l10n.dontKnow),
      if (draft.knowsGenetics == true &&
          (draft.strain?.trim().isNotEmpty ?? false))
        row(l10n.strainLabel, draft.strain!.trim()),
      if (draft.knowsGenetics == true && draft.geneticType != null)
        row(null, l10n.geneticTypeLabel(draft.geneticType!)),
    ]);

    // Datas
    addSection(l10n.reviewSectionDates, WizardStep.dates, [
      if (draft.startDateUnknown) row(datesTitle, l10n.dontKnow),
      if (draft.startDate != null)
        row(
          datesTitle,
          formatDate(
            context,
            draft.startDate!,
            approximate: draft.startDateIsApproximate,
          ),
        ),
      if (draft.seedObtainedDate != null)
        row(
          l10n.extraDateSeedObtained,
          formatDate(context, draft.seedObtainedDate!),
        ),
      if (draft.germinationDate != null)
        row(
          l10n.extraDateGermination,
          formatDate(context, draft.germinationDate!),
        ),
      if (draft.rootedDate != null)
        row(l10n.extraDateRooted, formatDate(context, draft.rootedDate!)),
    ]);

    // Ambiente
    addSection(l10n.reviewSectionEnvironment, WizardStep.environment, [
      if (draft.environment != null)
        row(
          null,
          [
            l10n.environmentLabel(draft.environment!),
            if (draft.environmentPlace != null)
              l10n.environmentPlaceLabel(draft.environmentPlace!),
          ].join(' · '),
        ),
      if (draft.environmentName?.trim().isNotEmpty ?? false)
        row(l10n.environmentNameLabel, draft.environmentName!.trim()),
    ]);

    // Meio
    addSection(l10n.reviewSectionMedium, WizardStep.medium, [
      if (draft.growingMedium != null)
        row(null, l10n.growingMediumLabel(draft.growingMedium!)),
      if (draft.containerType?.trim().isNotEmpty ?? false)
        row(l10n.containerTypeLabel, draft.containerType!.trim()),
      if (draft.containerVolumeLiters != null)
        row(l10n.containerVolumeLabel, '${draft.containerVolumeLiters} L'),
    ]);

    // Fase (resolvida: escolhida ou sugerida)
    addSection(l10n.reviewSectionPhase, WizardStep.phase, [
      row(null, l10n.phaseLabel(machine.selectedPhase)),
    ]);

    // Irrigação
    addSection(l10n.reviewSectionIrrigation, WizardStep.irrigation, [
      if (draft.irrigationMode != null)
        row(
          null,
          [
            l10n.irrigationModeLabel(draft.irrigationMode!),
            if (draft.irrigationSystem != null)
              l10n.irrigationSystemOptionLabel(draft.irrigationSystem!),
          ].join(' · '),
        ),
    ]);

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      children: [
        Text(l10n.reviewTitle, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          l10n.reviewHint,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        ...sections,
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: creating || !machine.canCreate ? null : onCreate,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: creating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.createPlantCta),
          ),
        ),
      ],
    );
  }
}

/// Bloco de uma seção da revisão: toca e volta ao passo correspondente.
class _ReviewSection extends StatelessWidget {
  const _ReviewSection({
    required this.title,
    required this.onTap,
    required this.children,
  });

  final String title;
  final VoidCallback onTap;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Linha da revisão: rótulo à esquerda (quando faz falta) e valor à direita.
class _ReviewRow extends StatelessWidget {
  const _ReviewRow({this.label, required this.value});

  final String? label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: label == null
          ? Text(value, style: theme.textTheme.bodyLarge)
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    label!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(value, style: theme.textTheme.bodyMedium),
                ),
              ],
            ),
    );
  }
}
