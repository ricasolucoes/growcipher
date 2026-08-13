import 'achievements.dart';
import 'level.dart';

/// Estado da progressão local. Derivado da linha do tempo: apagar tudo isto
/// não perde um único dado de cultivo (`docs/Principios.md` → Progressão
/// local).
class GamificationState {
  const GamificationState({
    this.totalXp = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActivityDay,
    this.counters = const {},
    this.unlockedAchievementIds = const {},
  });

  static const GamificationState empty = GamificationState();

  final int totalXp;

  /// Dias consecutivos com pelo menos um registro.
  final int currentStreak;

  final int longestStreak;

  /// Dia (meia-noite local) do último registro.
  final DateTime? lastActivityDay;

  final Map<AchievementMetric, int> counters;

  final Set<String> unlockedAchievementIds;

  LevelProgress get level => LevelProgress.fromXp(totalXp);

  int counter(AchievementMetric metric) => counters[metric] ?? 0;

  GamificationState copyWith({
    int? totalXp,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActivityDay,
    Map<AchievementMetric, int>? counters,
    Set<String>? unlockedAchievementIds,
  }) {
    return GamificationState(
      totalXp: totalXp ?? this.totalXp,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActivityDay: lastActivityDay ?? this.lastActivityDay,
      counters: counters ?? this.counters,
      unlockedAchievementIds:
          unlockedAchievementIds ?? this.unlockedAchievementIds,
    );
  }
}
