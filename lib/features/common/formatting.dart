import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'l10n_extensions.dart';

/// Data curta pt-BR (ex.: "11 de ago. de 2026"), com sufixo quando o usuário
/// marcou a data como aproximada.
String formatDate(
  BuildContext context,
  DateTime date, {
  bool approximate = false,
}) {
  final locale = Localizations.localeOf(context).toString();
  final formatted = DateFormat.yMMMd(locale).format(date);
  return approximate
      ? '$formatted (${context.l10n.approximateTag})'
      : formatted;
}

/// Data e hora para a linha do tempo (ex.: "11 de ago. de 2026 · 21:14").
String formatDateTime(BuildContext context, DateTime dateTime) {
  final locale = Localizations.localeOf(context).toString();
  final date = DateFormat.yMMMd(locale).format(dateTime);
  final time = DateFormat.Hm(locale).format(dateTime);
  return '$date · $time';
}

/// Número sem zeros decimais supérfluos ("500" em vez de "500.0").
String formatNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toString();
}
