/// Converte entrada numérica do usuário aceitando vírgula decimal (pt-BR).
double? parseFlexibleDouble(String? raw) {
  final text = raw?.trim().replaceAll(',', '.');
  if (text == null || text.isEmpty) return null;
  return double.tryParse(text);
}
