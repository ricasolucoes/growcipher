import 'dart:math';

const String _codeAlphabet = '23456789ABCDEFGHJKMNPQRSTUVWXYZ';

final Random _secureRandom = Random.secure();

/// Gera um código local discreto para identificar a planta sem nome, no
/// formato `GC-7F2A`.
///
/// Usa [Random.secure] e um alfabeto sem caracteres ambíguos (0/O, 1/I/L):
/// o código pode servir de identificação visual em modo discreto, então não
/// deve ser uma sequência previsível.
String generatePrivacyCode({int length = 4}) {
  final buffer = StringBuffer('GC-');
  for (var i = 0; i < length; i++) {
    buffer.write(_codeAlphabet[_secureRandom.nextInt(_codeAlphabet.length)]);
  }
  return buffer.toString();
}

/// Gera um id único local (sem servidor): instante em micros + sufixo
/// aleatório para evitar colisão de registros criados no mesmo instante.
String generateLocalId() {
  final micros = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  final suffix = List.generate(
    8,
    (_) => _codeAlphabet[_secureRandom.nextInt(_codeAlphabet.length)],
  ).join();
  return '$micros-$suffix';
}
