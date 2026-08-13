import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../domain/identifiers.dart';
import '../../domain/models/plant_draft.dart';
import '../../domain/models/plant_enums.dart';
import '../../domain/models/plant_event.dart';
import '../../l10n/generated/app_localizations.dart';
import '../common/enum_labels.dart';
import '../common/formatting.dart';
import '../common/input_parsing.dart';
import '../common/l10n_extensions.dart';
import 'plant_created_screen.dart';
import 'wizard_widgets.dart';

/// Passos do wizard. A ordem é fixa; o conteúdo de cada passo se adapta às
/// respostas anteriores (origem, datas e fase dependem do ponto de partida).
enum WizardStep {
  start,
  identity,
  origin,
  genetics,
  dates,
  environment,
  medium,
  phase,
  irrigation,
  review,
}

/// Wizard de criação de planta: decisões curtas, quase tudo opcional.
///
/// As respostas ficam num [PlantDraft] em memória; nada é persistido antes
/// do "CRIAR PLANTA" na revisão.
class PlantWizardScreen extends StatefulWidget {
  const PlantWizardScreen({super.key});

  static const String route = '/plants/new';

  @override
  State<PlantWizardScreen> createState() => _PlantWizardScreenState();
}

class _PlantWizardScreenState extends State<PlantWizardScreen> {
  final PlantDraft _draft = PlantDraft();
  final PageController _pageController = PageController();

  static const List<WizardStep> _steps = WizardStep.values;

  int _index = 0;
  bool _creating = false;

  late final TextEditingController _nameController;
  late final TextEditingController _originDetailsController;
  late final TextEditingController _strainController;
  late final TextEditingController _environmentNameController;
  late final TextEditingController _containerTypeController;
  late final TextEditingController _containerVolumeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController()
      ..addListener(() => _draft.displayName = _nameController.text);
    _originDetailsController = TextEditingController()
      ..addListener(() => _draft.originDetails = _originDetailsController.text);
    _strainController = TextEditingController()
      ..addListener(() => _draft.strain = _strainController.text);
    _environmentNameController = TextEditingController()
      ..addListener(
        () => _draft.environmentName = _environmentNameController.text,
      );
    _containerTypeController = TextEditingController()
      ..addListener(() => _draft.containerType = _containerTypeController.text);
    _containerVolumeController = TextEditingController()
      ..addListener(
        () => _draft.containerVolumeLiters = parseFlexibleDouble(
          _containerVolumeController.text,
        ),
      );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _originDetailsController.dispose();
    _strainController.dispose();
    _environmentNameController.dispose();
    _containerTypeController.dispose();
    _containerVolumeController.dispose();
    super.dispose();
  }

  WizardStep get _currentStep => _steps[_index];

  void _goToIndex(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  void _next() {
    if (_index < _steps.length - 1) {
      _goToIndex(_index + 1);
    }
  }

  void _back() {
    if (_index > 0) {
      _goToIndex(_index - 1);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _goToStep(WizardStep step) => _goToIndex(_steps.indexOf(step));

  String _progressLabel(AppLocalizations l10n) =>
      l10n.stepProgress(_index + 1, _steps.length - 1);

  // --- criação ---

  Future<void> _createPlant() async {
    if (_creating || !_draft.canCreate) return;
    setState(() => _creating = true);

    final repository = AppScope.of(context).plantRepository;
    final now = DateTime.now();
    final plant = _draft.toPlant(id: generateLocalId(), now: now);

    // Datas conhecidas no cadastro viram eventos da linha do tempo.
    final extraEvents = <PlantEvent>[
      if (_draft.germinationDate != null)
        GerminatedEvent(
          id: generateLocalId(),
          plantId: plant.id,
          occurredAt: _draft.germinationDate!,
          createdAt: now,
        ),
    ];

    try {
      await repository.createPlant(plant, extraEvents: extraEvents);
    } catch (_) {
      // Falha de escrita local: devolve o botão ao usuário em vez de deixar
      // a revisão travada em "criando".
      if (mounted) setState(() => _creating = false);
      rethrow;
    }

    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacementNamed(PlantCreatedScreen.route, arguments: plant.id);
  }

  // --- build ---

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final showBottomBar =
        _currentStep != WizardStep.start && _currentStep != WizardStep.review;

    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.wizardTitle),
          leading: _index == 0
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  tooltip: l10n.actionBack,
                  onPressed: _back,
                ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: l10n.actionCancel,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(value: (_index + 1) / _steps.length),
          ),
        ),
        body: SafeArea(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) => setState(() => _index = index),
            children: [
              _buildStart(l10n),
              _buildIdentity(l10n),
              _buildOrigin(l10n),
              _buildGenetics(l10n),
              _buildDates(l10n),
              _buildEnvironment(l10n),
              _buildMedium(l10n),
              _buildPhase(l10n),
              _buildIrrigation(l10n),
              _buildReview(l10n),
            ],
          ),
        ),
        bottomNavigationBar: showBottomBar ? _buildBottomBar(l10n) : null,
      ),
    );
  }

  /// O passo atual já tem resposta? Controla a exibição do "Pular".
  bool get _currentStepHasAnswer => switch (_currentStep) {
    WizardStep.origin => _draft.origin != null,
    WizardStep.genetics => _draft.knowsGenetics != null,
    WizardStep.dates => _draft.startDate != null || _draft.startDateUnknown,
    WizardStep.environment => _draft.environment != null,
    WizardStep.medium => _draft.growingMedium != null,
    WizardStep.irrigation => _draft.irrigationMode != null,
    // Identificação sempre tem o código; fase sempre tem sugestão.
    _ => true,
  };

  Widget _buildBottomBar(AppLocalizations l10n) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Row(
          children: [
            if (!_currentStepHasAnswer)
              TextButton(onPressed: _next, child: Text(l10n.actionSkip)),
            const Spacer(),
            FilledButton(onPressed: _next, child: Text(l10n.actionContinue)),
          ],
        ),
      ),
    );
  }

  // --- passo 1: ponto de partida ---

  Widget _buildStart(AppLocalizations l10n) {
    void select(PlantStartingPoint value) {
      setState(() {
        if (_draft.startingPoint != value) {
          _draft.startingPoint = value;
          // Respostas dependentes do ponto de partida deixam de valer — o
          // detalhe da origem também, já que a origem escolhida some.
          _draft.origin = null;
          _originDetailsController.clear();
          _draft.seedObtainedDate = null;
          _draft.germinationDate = null;
          _draft.rootedDate = null;
          _draft.phase = null;
        }
      });
      _next();
    }

    return WizardStepScaffold(
      progressLabel: _progressLabel(l10n),
      title: l10n.wizardStartTitle,
      children: [
        for (final value in PlantStartingPoint.values)
          WizardOptionCard(
            title: l10n.startingPointLabel(value),
            description: switch (value) {
              PlantStartingPoint.seed => l10n.startingPointSeedDesc,
              PlantStartingPoint.seedling => l10n.startingPointSeedlingDesc,
              PlantStartingPoint.clone => l10n.startingPointCloneDesc,
              PlantStartingPoint.inProgress => l10n.startingPointInProgressDesc,
            },
            selected: _draft.startingPoint == value,
            onTap: () => select(value),
          ),
      ],
    );
  }

  // --- passo 2: identificação ---

  Widget _buildIdentity(AppLocalizations l10n) {
    final theme = Theme.of(context);

    return WizardStepScaffold(
      progressLabel: _progressLabel(l10n),
      title: l10n.wizardIdentityTitle,
      children: [
        TextField(
          controller: _nameController,
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
                        _draft.privacyCode,
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
                  onPressed: () => setState(
                    () => _draft.privacyCode = generatePrivacyCode(),
                  ),
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

  // --- passo 3: origem ---

  static List<PlantOrigin> _originOptionsFor(PlantStartingPoint? point) {
    return switch (point) {
      PlantStartingPoint.seed => const [
        PlantOrigin.purchased,
        PlantOrigin.ownProduction,
        PlantOrigin.giftOrTrade,
        PlantOrigin.foundSeed,
        PlantOrigin.other,
        PlantOrigin.unknown,
      ],
      PlantStartingPoint.clone => const [
        PlantOrigin.ownProduction,
        PlantOrigin.receivedClone,
        PlantOrigin.purchased,
        PlantOrigin.other,
        PlantOrigin.unknown,
      ],
      _ => const [
        PlantOrigin.purchased,
        PlantOrigin.ownProduction,
        PlantOrigin.giftOrTrade,
        PlantOrigin.other,
        PlantOrigin.unknown,
      ],
    };
  }

  Widget _buildOrigin(AppLocalizations l10n) {
    final options = _originOptionsFor(_draft.startingPoint);
    final showDetails =
        _draft.origin != null && _draft.origin != PlantOrigin.unknown;

    return WizardStepScaffold(
      progressLabel: _progressLabel(l10n),
      title: l10n.wizardOriginTitle,
      children: [
        for (final value in options)
          WizardOptionCard(
            title: l10n.originLabel(value, startingPoint: _draft.startingPoint),
            selected: _draft.origin == value,
            onTap: () => setState(() => _draft.origin = value),
          ),
        if (showDetails) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _originDetailsController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: l10n.originDetailsLabel,
              helperText: l10n.originDetailsHelper,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ],
    );
  }

  // --- passo 4: genética ---

  Widget _buildGenetics(AppLocalizations l10n) {
    final theme = Theme.of(context);

    return WizardStepScaffold(
      progressLabel: _progressLabel(l10n),
      title: l10n.wizardGeneticsTitle,
      children: [
        WizardOptionCard(
          title: l10n.geneticsKnown,
          selected: _draft.knowsGenetics == true,
          onTap: () => setState(() => _draft.knowsGenetics = true),
        ),
        WizardOptionCard(
          title: l10n.dontKnow,
          selected: _draft.knowsGenetics == false,
          onTap: () {
            setState(() => _draft.knowsGenetics = false);
            _next();
          },
        ),
        if (_draft.knowsGenetics == true) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _strainController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: l10n.strainLabel,
              helperText: l10n.strainHelper,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.geneticTypeQuestion, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          for (final value in PlantGeneticType.values)
            WizardOptionCard(
              title: l10n.geneticTypeLabel(value),
              selected: _draft.geneticType == value,
              onTap: () => setState(() => _draft.geneticType = value),
            ),
        ],
      ],
    );
  }

  // --- passo 5: datas ---

  String _datesTitle(AppLocalizations l10n) => switch (_draft.startingPoint) {
    PlantStartingPoint.seed => l10n.datesTitleSeed,
    PlantStartingPoint.seedling => l10n.datesTitleSeedling,
    PlantStartingPoint.clone => l10n.datesTitleClone,
    PlantStartingPoint.inProgress || null => l10n.datesTitleInProgress,
  };

  Future<DateTime?> _pickDate({String? helpText, DateTime? initial}) {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      helpText: helpText,
    );
  }

  Widget _buildDates(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final today = DateUtils.dateOnly(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));

    final isToday =
        !_draft.startDateUnknown &&
        !_draft.startDateIsApproximate &&
        _draft.startDate != null &&
        DateUtils.isSameDay(_draft.startDate, today);
    final isYesterday =
        !_draft.startDateUnknown &&
        !_draft.startDateIsApproximate &&
        _draft.startDate != null &&
        DateUtils.isSameDay(_draft.startDate, yesterday);
    final isPicked =
        !_draft.startDateUnknown &&
        !_draft.startDateIsApproximate &&
        _draft.startDate != null &&
        !isToday &&
        !isYesterday;
    final isApproximate =
        !_draft.startDateUnknown && _draft.startDateIsApproximate;

    void setExact(DateTime date) {
      setState(() {
        _draft.startDate = date;
        _draft.startDateIsApproximate = false;
        _draft.startDateUnknown = false;
      });
    }

    final extras = <(String, DateTime?, void Function(DateTime?))>[
      if (_draft.startingPoint == PlantStartingPoint.seed)
        (
          l10n.extraDateSeedObtained,
          _draft.seedObtainedDate,
          (d) => _draft.seedObtainedDate = d,
        ),
      if (_draft.startingPoint == PlantStartingPoint.seed ||
          _draft.startingPoint == PlantStartingPoint.seedling)
        (
          l10n.extraDateGermination,
          _draft.germinationDate,
          (d) => _draft.germinationDate = d,
        ),
      if (_draft.startingPoint == PlantStartingPoint.clone)
        (l10n.extraDateRooted, _draft.rootedDate, (d) => _draft.rootedDate = d),
    ];

    return WizardStepScaffold(
      progressLabel: _progressLabel(l10n),
      title: _datesTitle(l10n),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: Text(l10n.dateToday),
              selected: isToday,
              onSelected: (_) => setExact(today),
            ),
            ChoiceChip(
              label: Text(l10n.dateYesterday),
              selected: isYesterday,
              onSelected: (_) => setExact(yesterday),
            ),
            ChoiceChip(
              label: Text(l10n.datePick),
              selected: isPicked,
              onSelected: (_) async {
                final date = await _pickDate(initial: _draft.startDate);
                if (date != null) setExact(date);
              },
            ),
            ChoiceChip(
              label: Text(l10n.dateApproximate),
              selected: isApproximate,
              onSelected: (_) async {
                final date = await _pickDate(
                  helpText: l10n.dateApproximate,
                  initial: _draft.startDate,
                );
                if (date != null) {
                  setState(() {
                    _draft.startDate = date;
                    _draft.startDateIsApproximate = true;
                    _draft.startDateUnknown = false;
                  });
                }
              },
            ),
            ChoiceChip(
              label: Text(l10n.dontKnow),
              selected: _draft.startDateUnknown,
              onSelected: (_) {
                setState(() {
                  _draft.startDate = null;
                  _draft.startDateIsApproximate = false;
                  _draft.startDateUnknown = true;
                });
              },
            ),
          ],
        ),
        if (_draft.startDate != null) ...[
          const SizedBox(height: 16),
          Text(
            formatDate(
              context,
              _draft.startDate!,
              approximate: _draft.startDateIsApproximate,
            ),
            style: theme.textTheme.titleMedium,
          ),
        ],
        if (extras.isNotEmpty) ...[
          const SizedBox(height: 28),
          Text(
            l10n.extraDatesLabel,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          for (final (label, value, setter) in extras)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: Text(label),
              subtitle: value == null ? null : Text(formatDate(context, value)),
              trailing: value == null
                  ? const Icon(Icons.add)
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => setter(null)),
                    ),
              onTap: () async {
                final date = await _pickDate(helpText: label, initial: value);
                if (date != null) setState(() => setter(date));
              },
            ),
        ],
      ],
    );
  }

  // --- passo 6: ambiente ---

  static List<EnvironmentPlace> _placesFor(GrowingEnvironment environment) {
    return switch (environment) {
      GrowingEnvironment.indoor => const [
        EnvironmentPlace.growTent,
        EnvironmentPlace.room,
        EnvironmentPlace.greenhouse,
        EnvironmentPlace.other,
      ],
      GrowingEnvironment.outdoor => const [
        EnvironmentPlace.pot,
        EnvironmentPlace.soilGround,
        EnvironmentPlace.greenhouse,
        EnvironmentPlace.other,
      ],
      _ => EnvironmentPlace.values,
    };
  }

  Widget _buildEnvironment(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final environment = _draft.environment;

    return WizardStepScaffold(
      progressLabel: _progressLabel(l10n),
      title: l10n.wizardEnvironmentTitle,
      children: [
        for (final value in const [
          GrowingEnvironment.indoor,
          GrowingEnvironment.outdoor,
          GrowingEnvironment.mixed,
        ])
          WizardOptionCard(
            title: l10n.environmentLabel(value),
            selected: environment == value,
            onTap: () => setState(() {
              if (_draft.environment != value) {
                _draft.environment = value;
                _draft.environmentPlace = null;
              }
            }),
          ),
        if (environment != null &&
            environment != GrowingEnvironment.unknown) ...[
          const SizedBox(height: 16),
          Text(
            '${l10n.environmentDetailLabel} (${l10n.optionalTag})',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final place in _placesFor(environment))
                ChoiceChip(
                  label: Text(l10n.environmentPlaceLabel(place)),
                  selected: _draft.environmentPlace == place,
                  onSelected: (selected) => setState(() {
                    _draft.environmentPlace = selected ? place : null;
                  }),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _environmentNameController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: l10n.environmentNameLabel,
              helperText: l10n.environmentNameHelper,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ],
    );
  }

  // --- passo 7: meio de cultivo ---

  Widget _buildMedium(AppLocalizations l10n) {
    return WizardStepScaffold(
      progressLabel: _progressLabel(l10n),
      title: l10n.wizardMediumTitle,
      children: [
        for (final value in GrowingMedium.values)
          WizardOptionCard(
            title: l10n.growingMediumLabel(value),
            selected: _draft.growingMedium == value,
            onTap: () => setState(() => _draft.growingMedium = value),
          ),
        const SizedBox(height: 12),
        TextField(
          controller: _containerTypeController,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: l10n.containerTypeLabel,
            helperText: l10n.containerTypeHelper,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _containerVolumeController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: l10n.containerVolumeLabel,
            helperText: l10n.containerVolumeHelper,
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  // --- passo 8: fase ---

  Widget _buildPhase(AppLocalizations l10n) {
    final selected = _draft.phase ?? _draft.suggestedPhase;

    return WizardStepScaffold(
      progressLabel: _progressLabel(l10n),
      title: l10n.wizardPhaseTitle,
      subtitle: l10n.phaseSuggestedHint,
      children: [
        for (final value in PlantPhase.values)
          WizardOptionCard(
            title: l10n.phaseLabel(value),
            selected: selected == value,
            onTap: () => setState(() => _draft.phase = value),
          ),
      ],
    );
  }

  // --- passo 9: irrigação ---

  Widget _buildIrrigation(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final mode = _draft.irrigationMode;
    final showSystems =
        mode == IrrigationMode.automatic || mode == IrrigationMode.mixed;

    return WizardStepScaffold(
      progressLabel: _progressLabel(l10n),
      title: l10n.wizardIrrigationTitle,
      children: [
        for (final value in const [
          IrrigationMode.manual,
          IrrigationMode.automatic,
          IrrigationMode.mixed,
          IrrigationMode.undefined,
        ])
          WizardOptionCard(
            title: l10n.irrigationModeLabel(value),
            selected: mode == value,
            onTap: () {
              setState(() {
                _draft.irrigationMode = value;
                if (value == IrrigationMode.manual ||
                    value == IrrigationMode.undefined) {
                  _draft.irrigationSystem = null;
                }
              });
              if (value == IrrigationMode.manual ||
                  value == IrrigationMode.undefined) {
                _next();
              }
            },
          ),
        if (showSystems) ...[
          const SizedBox(height: 16),
          Text(
            '${l10n.irrigationSystemLabel} (${l10n.optionalTag})',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final system in IrrigationSystem.values)
                ChoiceChip(
                  label: Text(l10n.irrigationSystemOptionLabel(system)),
                  selected: _draft.irrigationSystem == system,
                  onSelected: (selected) => setState(() {
                    _draft.irrigationSystem = selected ? system : null;
                  }),
                ),
            ],
          ),
        ],
      ],
    );
  }

  // --- revisão ---

  Widget _buildReview(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final draft = _draft;

    final sections = <Widget>[];

    void addSection(String title, WizardStep step, List<Widget> rows) {
      if (rows.isEmpty) return;
      sections.add(
        _ReviewSection(
          title: title,
          onTap: () => _goToStep(step),
          children: rows,
        ),
      );
    }

    Widget row(String? label, String value) =>
        _ReviewRow(label: label, value: value);

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
      if (draft.startDateUnknown) row(_datesTitle(l10n), l10n.dontKnow),
      if (draft.startDate != null)
        row(
          _datesTitle(l10n),
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
      row(null, l10n.phaseLabel(draft.phase ?? draft.suggestedPhase)),
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
            onPressed: _creating || !_draft.canCreate ? null : _createPlant,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _creating
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
