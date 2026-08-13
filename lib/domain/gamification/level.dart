import 'dart:math' as math;

/// Curva de níveis: XP acumulado para alcançar [level] é `25 · (L−1) · L`.
///
/// Quadrática — o primeiro cadastro já sobe dois níveis e a progressão
/// desacelera sem nunca travar. Não há nível máximo
/// (`docs/Gamificacao.md` §2).
int xpForLevel(int level) => level <= 1 ? 0 : 25 * (level - 1) * level;

/// Nível correspondente ao XP acumulado.
int levelForXp(int totalXp) {
  if (totalXp <= 0) return 1;

  // Inversa da curva; os laços corrigem erro de ponto flutuante nas bordas.
  var level = ((25 + math.sqrt(625 + 100 * totalXp)) / 50).floor();
  while (level > 1 && xpForLevel(level) > totalXp) {
    level--;
  }
  while (xpForLevel(level + 1) <= totalXp) {
    level++;
  }
  return level;
}

/// Posição do usuário na curva, pronta para a interface.
class LevelProgress {
  const LevelProgress({
    required this.level,
    required this.totalXp,
    required this.xpIntoLevel,
    required this.xpForNextLevel,
  });

  factory LevelProgress.fromXp(int totalXp) {
    final xp = totalXp < 0 ? 0 : totalXp;
    final level = levelForXp(xp);
    final floor = xpForLevel(level);
    return LevelProgress(
      level: level,
      totalXp: xp,
      xpIntoLevel: xp - floor,
      xpForNextLevel: xpForLevel(level + 1) - floor,
    );
  }

  final int level;
  final int totalXp;

  /// XP conquistado dentro do nível atual.
  final int xpIntoLevel;

  /// XP que o nível atual exige para virar o próximo.
  final int xpForNextLevel;

  int get xpRemaining => xpForNextLevel - xpIntoLevel;

  /// Fração do nível atual, de 0 a 1.
  double get fraction =>
      xpForNextLevel == 0 ? 0 : xpIntoLevel / xpForNextLevel;
}
