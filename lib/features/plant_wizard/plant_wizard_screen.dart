import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../domain/identifiers.dart';
import '../../domain/models/plant_event.dart';
import '../../l10n/generated/app_localizations.dart';
import '../common/input_parsing.dart';
import '../common/l10n_extensions.dart';
import 'plant_created_screen.dart';
import 'steps/dates_step.dart';
import 'steps/environment_step.dart';
import 'steps/genetics_step.dart';
import 'steps/identity_step.dart';
import 'steps/irrigation_step.dart';
import 'steps/medium_step.dart';
import 'steps/origin_step.dart';
import 'steps/phase_step.dart';
import 'steps/review_step.dart';
import 'steps/start_step.dart';
import 'wizard_machine.dart';

/// Wizard de criação de planta: decisões curtas, quase tudo opcional.
///
/// Esta tela é só a moldura — barra de progresso, `PageView`, barra inferior
/// e a gravação final. Quem decide o que cada passo mostra é a
/// [WizardMachine]; quem desenha são os widgets de `steps/`.
///
/// As respostas ficam num `PlantDraft` em memória, dentro da máquina; nada é
/// persistido antes do "CRIAR PLANTA" na revisão.
class PlantWizardScreen extends StatefulWidget {
  const PlantWizardScreen({super.key});

  static const String route = '/plants/new';

  @override
  State<PlantWizardScreen> createState() => _PlantWizardScreenState();
}

class _PlantWizardScreenState extends State<PlantWizardScreen> {
  final WizardMachine _machine = WizardMachine();
  final PageController _pageController = PageController();

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
    final draft = _machine.draft;
    _nameController = TextEditingController()
      ..addListener(() => draft.displayName = _nameController.text);
    _originDetailsController = TextEditingController()
      ..addListener(() => draft.originDetails = _originDetailsController.text);
    _strainController = TextEditingController()
      ..addListener(() => draft.strain = _strainController.text);
    _environmentNameController = TextEditingController()
      ..addListener(
        () => draft.environmentName = _environmentNameController.text,
      );
    _containerTypeController = TextEditingController()
      ..addListener(() => draft.containerType = _containerTypeController.text);
    _containerVolumeController = TextEditingController()
      ..addListener(
        () => draft.containerVolumeLiters = parseFlexibleDouble(
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

  // --- navegação ---

  void _goToIndex(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  void _next() {
    final index = _machine.nextIndex;
    if (index != null) _goToIndex(index);
  }

  void _back() {
    final index = _machine.previousIndex;
    if (index != null) {
      _goToIndex(index);
    } else {
      Navigator.of(context).pop();
    }
  }

  /// Fecha o ciclo de uma resposta: redesenha, realinha os campos de texto
  /// com o rascunho (uma transição pode ter limpado algum) e avança quando a
  /// própria resposta encerra o passo.
  void _onTransition(WizardNavigation navigation) {
    setState(_syncControllers);
    if (navigation == WizardNavigation.advance) _next();
  }

  /// Só escreve quando o valor mudou de fato: atribuir a `text` reposiciona
  /// o cursor, e o usuário pode estar digitando.
  void _syncControllers() {
    final draft = _machine.draft;
    void sync(TextEditingController controller, String? value) {
      final text = value ?? '';
      if (controller.text != text) controller.text = text;
    }

    sync(_nameController, draft.displayName);
    sync(_originDetailsController, draft.originDetails);
    sync(_strainController, draft.strain);
    sync(_environmentNameController, draft.environmentName);
    sync(_containerTypeController, draft.containerType);
  }

  // --- criação ---

  Future<void> _createPlant() async {
    if (_creating || !_machine.canCreate) return;
    setState(() => _creating = true);

    final draft = _machine.draft;
    final repository = AppScope.of(context).plantRepository;
    final now = DateTime.now();
    final plant = draft.toPlant(id: generateLocalId(), now: now);

    // Datas conhecidas no cadastro viram eventos da linha do tempo.
    final extraEvents = <PlantEvent>[
      if (draft.germinationDate != null)
        GerminatedEvent(
          id: generateLocalId(),
          plantId: plant.id,
          occurredAt: draft.germinationDate!,
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
    final progressLabel = l10n.stepProgress(
      _machine.questionNumber,
      _machine.questionCount,
    );

    return PopScope(
      canPop: _machine.canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.wizardTitle),
          leading: _machine.canPop
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
            child: LinearProgressIndicator(value: _machine.progress),
          ),
        ),
        body: SafeArea(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) =>
                setState(() => _machine.syncToPage(index)),
            children: [
              StartStep(
                machine: _machine,
                progressLabel: progressLabel,
                onTransition: _onTransition,
              ),
              IdentityStep(
                machine: _machine,
                progressLabel: progressLabel,
                onTransition: _onTransition,
                nameController: _nameController,
              ),
              OriginStep(
                machine: _machine,
                progressLabel: progressLabel,
                onTransition: _onTransition,
                detailsController: _originDetailsController,
              ),
              GeneticsStep(
                machine: _machine,
                progressLabel: progressLabel,
                onTransition: _onTransition,
                strainController: _strainController,
              ),
              DatesStep(
                machine: _machine,
                progressLabel: progressLabel,
                onTransition: _onTransition,
              ),
              EnvironmentStep(
                machine: _machine,
                progressLabel: progressLabel,
                onTransition: _onTransition,
                nameController: _environmentNameController,
              ),
              MediumStep(
                machine: _machine,
                progressLabel: progressLabel,
                onTransition: _onTransition,
                containerTypeController: _containerTypeController,
                containerVolumeController: _containerVolumeController,
              ),
              PhaseStep(
                machine: _machine,
                progressLabel: progressLabel,
                onTransition: _onTransition,
              ),
              IrrigationStep(
                machine: _machine,
                progressLabel: progressLabel,
                onTransition: _onTransition,
              ),
              ReviewStep(
                machine: _machine,
                creating: _creating,
                onEditStep: (step) => _goToIndex(_machine.indexOf(step)),
                onCreate: _createPlant,
              ),
            ],
          ),
        ),
        bottomNavigationBar: _machine.showsBottomBar
            ? _buildBottomBar(l10n)
            : null,
      ),
    );
  }

  Widget _buildBottomBar(AppLocalizations l10n) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Row(
          children: [
            if (!_machine.currentStepHasAnswer)
              TextButton(onPressed: _next, child: Text(l10n.actionSkip)),
            const Spacer(),
            FilledButton(onPressed: _next, child: Text(l10n.actionContinue)),
          ],
        ),
      ),
    );
  }
}
