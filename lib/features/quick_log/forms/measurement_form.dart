import 'package:flutter/material.dart';

import '../../../domain/models/plant_event.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../common/input_parsing.dart';
import '../../common/l10n_extensions.dart';
import 'quick_log_form_shell.dart';
import 'quick_log_input.dart';

/// Medição do ambiente e da solução. Todas as métricas são opcionais:
/// registra-se só o que foi medido, e um campo em branco não vira zero.
class MeasurementInput implements QuickLogInput {
  const MeasurementInput({
    this.temperature = '',
    this.humidity = '',
    this.ph = '',
    this.ec = '',
    this.vpd = '',
    this.dli = '',
    this.notes = '',
  });

  final String temperature;
  final String humidity;
  final String ph;
  final String ec;
  final String vpd;
  final String dli;
  final String notes;

  @override
  List<QuickLogError> validate() => const [];

  @override
  QuickLogSubmission build(QuickLogStamp stamp) => AddEventSubmission(
    MeasurementAddedEvent(
      id: stamp.eventId,
      plantId: stamp.plantId,
      occurredAt: stamp.occurredAt,
      createdAt: stamp.createdAt,
      temperatureC: parseFlexibleDouble(temperature),
      humidityPercent: parseFlexibleDouble(humidity),
      ph: parseFlexibleDouble(ph),
      ec: parseFlexibleDouble(ec),
      vpd: parseFlexibleDouble(vpd),
      dli: parseFlexibleDouble(dli),
      notes: textOrNull(notes),
    ),
  );
}

class MeasurementForm extends QuickLogFormWidget {
  const MeasurementForm({
    super.key,
    required super.plant,
    required super.onBack,
  });

  @override
  State<MeasurementForm> createState() => _MeasurementFormState();
}

class _MeasurementFormState extends QuickLogFormState<MeasurementForm> {
  final _temperature = TextEditingController();
  final _humidity = TextEditingController();
  final _ph = TextEditingController();
  final _ec = TextEditingController();
  final _vpd = TextEditingController();
  final _dli = TextEditingController();
  final _notes = TextEditingController();

  @override
  void dispose() {
    _temperature.dispose();
    _humidity.dispose();
    _ph.dispose();
    _ec.dispose();
    _vpd.dispose();
    _dli.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  String title(AppLocalizations l10n) => l10n.quickLogMeasurement;

  @override
  MeasurementInput get input => MeasurementInput(
    temperature: _temperature.text,
    humidity: _humidity.text,
    ph: _ph.text,
    ec: _ec.text,
    vpd: _vpd.text,
    dli: _dli.text,
    notes: _notes.text,
  );

  Widget _pair(
    TextEditingController a,
    String labelA,
    TextEditingController b,
    String labelB,
  ) {
    return Row(
      children: [
        Expanded(
          child: NumberField(controller: a, label: labelA),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: NumberField(controller: b, label: labelB),
        ),
      ],
    );
  }

  @override
  List<Widget> fields(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return [
      const SizedBox(height: 4),
      Text(
        l10n.measurementHint,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 16),
      _pair(
        _temperature,
        l10n.measureTemperature,
        _humidity,
        l10n.measureHumidity,
      ),
      const SizedBox(height: 16),
      _pair(_ph, l10n.measurePh, _ec, l10n.measureEc),
      const SizedBox(height: 16),
      _pair(_vpd, l10n.measureVpd, _dli, l10n.measureDli),
      const SizedBox(height: 16),
      NotesField(controller: _notes),
    ];
  }
}
