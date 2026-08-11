import 'package:flutter/material.dart';

/// Layout comum dos passos do wizard: rótulo de progresso, pergunta em
/// destaque e conteúdo rolável (telas pequenas precisam rolar).
class WizardStepScaffold extends StatelessWidget {
  const WizardStepScaffold({
    super.key,
    required this.progressLabel,
    required this.title,
    this.subtitle,
    required this.children,
  });

  final String progressLabel;
  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        Text(
          progressLabel,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(title, style: theme.textTheme.headlineSmall),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 24),
        ...children,
      ],
    );
  }
}

/// Opção de resposta com alvo de toque generoso, título e descrição
/// opcional. Estado selecionado usa o container secundário do tema.
class WizardOptionCard extends StatelessWidget {
  const WizardOptionCard({
    super.key,
    required this.title,
    this.description,
    this.selected = false,
    this.enabled = true,
    required this.onTap,
  });

  final String title;
  final String? description;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected
            ? colors.secondaryContainer
            : colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: enabled
                                ? (selected
                                      ? colors.onSecondaryContainer
                                      : colors.onSurface)
                                : colors.onSurface.withValues(alpha: 0.38),
                          ),
                        ),
                        if (description != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            description!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: enabled
                                  ? colors.onSurfaceVariant
                                  : colors.onSurface.withValues(alpha: 0.38),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (selected)
                    Icon(Icons.check_circle, color: colors.primary, size: 22),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
