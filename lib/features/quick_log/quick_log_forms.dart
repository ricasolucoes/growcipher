import 'package:flutter/material.dart';

import '../../domain/models/plant.dart';
import 'forms/end_plant_form.dart';
import 'forms/fed_form.dart';
import 'forms/harvest_form.dart';
import 'forms/measurement_form.dart';
import 'forms/observation_form.dart';
import 'forms/phase_change_form.dart';
import 'forms/photo_form.dart';
import 'forms/problem_form.dart';
import 'forms/task_done_form.dart';
import 'forms/transplant_form.dart';
import 'forms/treatment_form.dart';
import 'forms/watered_form.dart';
import 'quick_log.dart';

/// Escolhe o formulário da ação escolhida no menu "O que aconteceu?".
///
/// Cada tipo de acontecimento mora em `forms/`, num arquivo só dele: a
/// entrada pura que valida e materializa a gravação (`QuickLogInput`) e o
/// widget que a preenche. A moldura comum — voltar, "Quando aconteceu",
/// botão Salvar, tratamento de erro de escrita — está em
/// `forms/quick_log_form_shell.dart`.
class QuickLogForm extends StatelessWidget {
  const QuickLogForm({
    super.key,
    required this.action,
    required this.plant,
    required this.onBack,
  });

  final QuickLogAction action;
  final Plant plant;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return switch (action) {
      QuickLogAction.watered => WateredForm(plant: plant, onBack: onBack),
      QuickLogAction.fed => FedForm(plant: plant, onBack: onBack),
      QuickLogAction.treatment => TreatmentForm(plant: plant, onBack: onBack),
      QuickLogAction.measurement => MeasurementForm(
        plant: plant,
        onBack: onBack,
      ),
      QuickLogAction.transplant => TransplantForm(plant: plant, onBack: onBack),
      QuickLogAction.phaseChange => PhaseChangeForm(
        plant: plant,
        onBack: onBack,
      ),
      // Foto fica desabilitada no menu até a galeria privada existir.
      QuickLogAction.photo => const PhotoForm(),
      QuickLogAction.observation => ObservationForm(
        plant: plant,
        onBack: onBack,
      ),
      QuickLogAction.problem => ProblemForm(plant: plant, onBack: onBack),
      QuickLogAction.taskDone => TaskDoneForm(plant: plant, onBack: onBack),
      QuickLogAction.harvest => HarvestForm(plant: plant, onBack: onBack),
      QuickLogAction.endPlant => EndPlantForm(plant: plant, onBack: onBack),
    };
  }
}
