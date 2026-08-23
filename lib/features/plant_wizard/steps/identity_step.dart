import 'package:flutter/material.dart';

import '../../common/l10n_extensions.dart';
import '../wizard_machine.dart';
import '../wizard_widgets.dart';

/// Passo 2 — identificação. O nome é opcional: o código local `GC-XXXX`
/// sempre existe, para quem prefere não nomear a planta.
class IdentityStep extends StatelessWidget {
  const IdentityStep({
    super.key,
    required this.machine,
    required this.progressLabel,
    required this.onTransition,
    required this.nameController,
  });

  final WizardMachine machine;
  final String progressLabel;
  final ValueChanged<WizardNavigation> onTransition;
  final TextEditingController nameController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return WizardStepScaffold(
      progressLabel: progressLabel,
      title: l10n.wizardIdentityTitle,
      children: [
        TextField(
          controller: nameController,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: l10n.plantNameLabel,
            helperText: l10n.plantNameHelper,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        Material(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.privacyCodeLabel,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        machine.draft.privacyCode,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.privacyCodeHelper,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: l10n.regeneratePrivacyCode,
                  onPressed: () =>
                      onTransition(machine.regeneratePrivacyCode()),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Captura de foto chega com a galeria privada (fase futura do
        // roadmap); o domínio já aceita photoRef.
        ListTile(
          enabled: false,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          leading: const Icon(Icons.photo_camera_outlined),
          title: Text('${l10n.photoLabel} (${l10n.optionalTag})'),
          subtitle: Text(l10n.photoComingSoon),
        ),
      ],
    );
  }
}
