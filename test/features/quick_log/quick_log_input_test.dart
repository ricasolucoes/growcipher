import 'package:flutter_test/flutter_test.dart';
import 'package:growcipher/domain/models/plant_enums.dart';
import 'package:growcipher/domain/models/plant_event.dart';
import 'package:growcipher/features/quick_log/forms/end_plant_form.dart';
import 'package:growcipher/features/quick_log/forms/fed_form.dart';
import 'package:growcipher/features/quick_log/forms/harvest_form.dart';
import 'package:growcipher/features/quick_log/forms/measurement_form.dart';
import 'package:growcipher/features/quick_log/forms/observation_form.dart';
import 'package:growcipher/features/quick_log/forms/phase_change_form.dart';
import 'package:growcipher/features/quick_log/forms/problem_form.dart';
import 'package:growcipher/features/quick_log/forms/quick_log_input.dart';
import 'package:growcipher/features/quick_log/forms/task_done_form.dart';
import 'package:growcipher/features/quick_log/forms/transplant_form.dart';
import 'package:growcipher/features/quick_log/forms/treatment_form.dart';
import 'package:growcipher/features/quick_log/forms/watered_form.dart';

final _stamp = QuickLogStamp(
  plantId: 'plant-1',
  eventId: 'event-1',
  occurredAt: DateTime(2026, 8, 20, 21, 14),
  createdAt: DateTime(2026, 8, 23, 9),
);

/// Desembrulha a submissão de um formulário que só grava um evento.
T _event<T extends PlantEvent>(QuickLogInput input) {
  final submission = input.build(_stamp);
  expect(submission, isA<AddEventSubmission>());
  final event = (submission as AddEventSubmission).event;
  expect(event, isA<T>());
  return event as T;
}

void main() {
  group('contrato comum', () {
    test('formulário de rotina salva sem nenhum campo preenchido', () {
      // O registro rápido existe para caber em segundos: só a data/hora, que
      // já vem como "Agora", basta para todos os tipos exceto três.
      const routine = <QuickLogInput>[
        WateredInput(),
        FedInput(),
        TreatmentInput(),
        MeasurementInput(),
        TransplantInput(),
        ProblemInput(),
        TaskDoneInput(),
        HarvestInput(),
      ];

      for (final input in routine) {
        expect(
          input.validate(),
          isEmpty,
          reason: '${input.runtimeType} deveria salvar em branco',
        );
        expect(input.isValid, isTrue);
      }
    });

    test('os três tipos com resposta obrigatória reprovam em branco', () {
      expect(const PhaseChangeInput().validate(), [
        QuickLogError.phaseRequired,
      ]);
      expect(const ObservationInput().validate(), [
        QuickLogError.observationRequired,
      ]);
      expect(const EndPlantInput().validate(), [
        QuickLogError.endReasonRequired,
      ]);
    });

    test('carimbo de identidade e tempo entra igual em todos os eventos', () {
      final events = <PlantEvent>[
        _event<WateredEvent>(const WateredInput()),
        _event<FedEvent>(const FedInput()),
        _event<TreatmentAppliedEvent>(const TreatmentInput()),
        _event<MeasurementAddedEvent>(const MeasurementInput()),
        _event<TransplantedEvent>(const TransplantInput()),
        _event<ObservationAddedEvent>(const ObservationInput(text: 'oi')),
        _event<ProblemReportedEvent>(const ProblemInput()),
        _event<TaskCompletedEvent>(const TaskDoneInput()),
        _event<HarvestedEvent>(const HarvestInput()),
      ];

      for (final event in events) {
        expect(event.id, 'event-1');
        expect(event.plantId, 'plant-1');
        expect(event.occurredAt, _stamp.occurredAt);
        expect(event.createdAt, _stamp.createdAt);
      }
    });
  });

  group('rega', () {
    test('texto em branco vira null, nunca string vazia', () {
      final event = _event<WateredEvent>(
        const WateredInput(unit: '   ', solutionType: '', notes: '\n'),
      );

      expect(event.amount, isNull);
      expect(event.unit, isNull);
      expect(event.solutionType, isNull);
      expect(event.notes, isNull);
    });

    test('aceita vírgula decimal e apara os espaços', () {
      final event = _event<WateredEvent>(
        const WateredInput(
          amount: ' 1,5 ',
          unit: ' L ',
          solutionType: ' Água de torneira ',
          notes: ' folhas caídas ',
        ),
      );

      expect(event.amount, 1.5);
      expect(event.unit, 'L');
      expect(event.solutionType, 'Água de torneira');
      expect(event.notes, 'folhas caídas');
    });

    test('número inválido não vira zero', () {
      expect(
        _event<WateredEvent>(const WateredInput(amount: 'meio')).amount,
        isNull,
      );
    });
  });

  group('alimentação', () {
    test('produto e quantidade chegam ao FedEvent', () {
      final event = _event<FedEvent>(
        const FedInput(product: ' Grow A+B ', amount: '2,25', unit: 'ml'),
      );

      expect(event.product, 'Grow A+B');
      expect(event.amount, 2.25);
      expect(event.unit, 'ml');
      expect(event.type, PlantEventType.fed);
    });
  });

  group('tratamento', () {
    test('é TreatmentApplied, não Fed', () {
      final event = _event<TreatmentAppliedEvent>(
        const TreatmentInput(treatmentType: TreatmentType.pestControl),
      );

      expect(event.type, PlantEventType.treatmentApplied);
      expect(event.treatmentType, TreatmentType.pestControl);
    });

    test('tipo genérico é o padrão do formulário', () {
      expect(
        _event<TreatmentAppliedEvent>(const TreatmentInput()).treatmentType,
        TreatmentType.treatment,
      );
    });

    test('método e produto são opcionais', () {
      final event = _event<TreatmentAppliedEvent>(
        const TreatmentInput(method: ' pulverização ', amount: '10'),
      );

      expect(event.method, 'pulverização');
      expect(event.product, isNull);
      expect(event.amount, 10);
    });
  });

  group('medição', () {
    test('só o que foi medido entra; o resto fica null', () {
      final event = _event<MeasurementAddedEvent>(
        const MeasurementInput(temperature: '24,5', ph: '6.2'),
      );

      expect(event.temperatureC, 24.5);
      expect(event.ph, 6.2);
      expect(event.humidityPercent, isNull);
      expect(event.ec, isNull);
      expect(event.vpd, isNull);
      expect(event.dli, isNull);
    });

    test('as seis métricas chegam nos campos certos', () {
      final event = _event<MeasurementAddedEvent>(
        const MeasurementInput(
          temperature: '24',
          humidity: '55',
          ph: '6',
          ec: '1,2',
          vpd: '0,9',
          dli: '35',
        ),
      );

      expect(event.temperatureC, 24);
      expect(event.humidityPercent, 55);
      expect(event.ph, 6);
      expect(event.ec, 1.2);
      expect(event.vpd, 0.9);
      expect(event.dli, 35);
    });
  });

  group('transplante', () {
    test('recipiente e volume são opcionais', () {
      final event = _event<TransplantedEvent>(
        const TransplantInput(
          containerType: ' Vaso 11L ',
          containerVolume: '11',
        ),
      );

      expect(event.containerType, 'Vaso 11L');
      expect(event.containerVolumeLiters, 11);
      expect(
        _event<TransplantedEvent>(const TransplantInput()).containerType,
        isNull,
      );
    });
  });

  group('mudança de fase', () {
    test('sem a nova fase não salva', () {
      expect(const PhaseChangeInput().isValid, isFalse);
      expect(
        const PhaseChangeInput(newPhase: PlantPhase.flowering).isValid,
        isTrue,
      );
    });

    test('vai pelo repositório, não pela linha do tempo direto', () {
      final submission = const PhaseChangeInput(
        newPhase: PlantPhase.flowering,
        notes: ' pistilos ',
      ).build(_stamp);

      expect(submission, isA<ChangePhaseSubmission>());
      final change = submission as ChangePhaseSubmission;
      expect(change.plantId, 'plant-1');
      expect(change.newPhase, PlantPhase.flowering);
      expect(change.occurredAt, _stamp.occurredAt);
      expect(change.notes, 'pistilos');
    });
  });

  group('observação', () {
    test('espaço em branco não é observação', () {
      expect(const ObservationInput(text: '   \n ').isValid, isFalse);
      expect(const ObservationInput(text: 'a').isValid, isTrue);
    });

    test('o texto vira as notas do evento', () {
      expect(
        _event<ObservationAddedEvent>(
          const ObservationInput(text: ' cheiro forte hoje '),
        ).notes,
        'cheiro forte hoje',
      );
    });
  });

  group('problema', () {
    test('categoria padrão é "não sei"', () {
      expect(
        _event<ProblemReportedEvent>(const ProblemInput()).category,
        ProblemCategory.unknown,
      );
    });

    test('descrição vira notas e a categoria escolhida é preservada', () {
      final event = _event<ProblemReportedEvent>(
        const ProblemInput(
          category: ProblemCategory.deficiency,
          description: ' pontas amarelas ',
        ),
      );

      expect(event.category, ProblemCategory.deficiency);
      expect(event.notes, 'pontas amarelas');
    });
  });

  group('tarefa concluída', () {
    test('descrição e notas são campos distintos', () {
      final event = _event<TaskCompletedEvent>(
        const TaskDoneInput(description: ' poda ', notes: ' 3 folhas '),
      );

      expect(event.taskDescription, 'poda');
      expect(event.notes, '3 folhas');
    });
  });

  group('colheita', () {
    test('sem encerrar o ciclo é só o evento de colheita', () {
      final submission = const HarvestInput(
        wetWeight: '120,5',
        dryWeight: '31',
        unit: 'g',
      ).build(_stamp);

      expect(submission, isA<AddEventSubmission>());
      final event = (submission as AddEventSubmission).event as HarvestedEvent;
      expect(event.wetWeight, 120.5);
      expect(event.dryWeight, 31);
      expect(event.unit, 'g');
    });

    test('encerrando o ciclo, colhe primeiro e encerra depois', () {
      final submission = const HarvestInput(endCycle: true).build(_stamp);

      expect(submission, isA<CompositeSubmission>());
      final parts = (submission as CompositeSubmission).parts;
      expect(parts, hasLength(2));
      expect(parts.first, isA<AddEventSubmission>());
      expect((parts.first as AddEventSubmission).event, isA<HarvestedEvent>());

      final end = parts.last as EndPlantSubmission;
      expect(end.reason, PlantEndReason.harvestCompleted);
      expect(end.plantId, 'plant-1');
      expect(end.occurredAt, _stamp.occurredAt);
      expect(end.cause, isNull);
      expect(end.notes, isNull);
    });
  });

  group('encerramento', () {
    test('sem motivo não salva', () {
      expect(const EndPlantInput().isValid, isFalse);
      expect(
        const EndPlantInput(reason: PlantEndReason.discarded).isValid,
        isTrue,
      );
    });

    test('a causa acompanha apenas a morte', () {
      final died =
          const EndPlantInput(
                reason: PlantEndReason.died,
                cause: PlantEndCause.pest,
              ).build(_stamp)
              as EndPlantSubmission;
      expect(died.cause, PlantEndCause.pest);

      // Escolher "morreu · praga" e depois trocar o motivo não pode levar a
      // praga junto para "descartada".
      final discarded =
          const EndPlantInput(
                reason: PlantEndReason.discarded,
                cause: PlantEndCause.pest,
              ).build(_stamp)
              as EndPlantSubmission;
      expect(discarded.cause, isNull);
    });

    test('notas em branco não viram string vazia', () {
      final submission =
          const EndPlantInput(
                reason: PlantEndReason.other,
                notes: '  ',
              ).build(_stamp)
              as EndPlantSubmission;

      expect(submission.notes, isNull);
    });
  });
}
