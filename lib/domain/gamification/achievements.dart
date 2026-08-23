/// Famílias de conquista (`docs/Gamificacao.md` §4).
enum AchievementFamily {
  cadastro,
  registro,
  consistencia,
  cuidado,
  ciclo,
  curadoria,
}

/// Contadores locais sobre os quais as conquistas são avaliadas.
///
/// Todos monotônicos, exceto [currentStreak] — conquistas de sequência olham
/// [longestStreak], para que uma sequência quebrada nunca remova uma
/// conquista já destravada.
enum AchievementMetric {
  plantsCreated,
  eventsLogged,
  detailedEvents,
  photosAdded,
  measurementsAdded,
  treatmentsApplied,
  problemsReported,
  problemsWithPhoto,
  phaseChanges,
  harvests,
  harvestsWithDryWeight,
  cyclesEnded,
  completedProfiles,
  currentStreak,
  longestStreak,
  streakRecovered,
  maxEventsOnOnePlant,
  maxPhasesOnOnePlant,
}

class Achievement {
  const Achievement({
    required this.id,
    required this.family,
    required this.metric,
    required this.threshold,
    required this.xpReward,
  });

  final String id;
  final AchievementFamily family;
  final AchievementMetric metric;
  final int threshold;
  final int xpReward;
}

/// Catálogo completo. Os textos exibidos vivem no ARB, indexados por [id] —
/// o domínio não carrega string de interface.
const List<Achievement> achievementCatalog = [
  // Cadastro
  Achievement(
    id: 'first_plant',
    family: AchievementFamily.cadastro,
    metric: AchievementMetric.plantsCreated,
    threshold: 1,
    xpReward: 25,
  ),
  Achievement(
    id: 'plants_3',
    family: AchievementFamily.cadastro,
    metric: AchievementMetric.plantsCreated,
    threshold: 3,
    xpReward: 50,
  ),
  Achievement(
    id: 'plants_10',
    family: AchievementFamily.cadastro,
    metric: AchievementMetric.plantsCreated,
    threshold: 10,
    xpReward: 100,
  ),
  Achievement(
    id: 'plants_25',
    family: AchievementFamily.cadastro,
    metric: AchievementMetric.plantsCreated,
    threshold: 25,
    xpReward: 200,
  ),
  Achievement(
    id: 'profile_complete_1',
    family: AchievementFamily.cadastro,
    metric: AchievementMetric.completedProfiles,
    threshold: 1,
    xpReward: 75,
  ),
  Achievement(
    id: 'profile_complete_5',
    family: AchievementFamily.cadastro,
    metric: AchievementMetric.completedProfiles,
    threshold: 5,
    xpReward: 150,
  ),

  // Registro
  Achievement(
    id: 'first_log',
    family: AchievementFamily.registro,
    metric: AchievementMetric.eventsLogged,
    threshold: 1,
    xpReward: 15,
  ),
  Achievement(
    id: 'logs_10',
    family: AchievementFamily.registro,
    metric: AchievementMetric.eventsLogged,
    threshold: 10,
    xpReward: 30,
  ),
  Achievement(
    id: 'logs_100',
    family: AchievementFamily.registro,
    metric: AchievementMetric.eventsLogged,
    threshold: 100,
    xpReward: 100,
  ),
  Achievement(
    id: 'logs_500',
    family: AchievementFamily.registro,
    metric: AchievementMetric.eventsLogged,
    threshold: 500,
    xpReward: 250,
  ),
  Achievement(
    id: 'logs_1000',
    family: AchievementFamily.registro,
    metric: AchievementMetric.eventsLogged,
    threshold: 1000,
    xpReward: 500,
  ),
  Achievement(
    id: 'detailed_50',
    family: AchievementFamily.registro,
    metric: AchievementMetric.detailedEvents,
    threshold: 50,
    xpReward: 200,
  ),

  // Consistência
  Achievement(
    id: 'streak_3',
    family: AchievementFamily.consistencia,
    metric: AchievementMetric.longestStreak,
    threshold: 3,
    xpReward: 30,
  ),
  Achievement(
    id: 'streak_7',
    family: AchievementFamily.consistencia,
    metric: AchievementMetric.longestStreak,
    threshold: 7,
    xpReward: 60,
  ),
  Achievement(
    id: 'streak_30',
    family: AchievementFamily.consistencia,
    metric: AchievementMetric.longestStreak,
    threshold: 30,
    xpReward: 200,
  ),
  Achievement(
    id: 'streak_100',
    family: AchievementFamily.consistencia,
    metric: AchievementMetric.longestStreak,
    threshold: 100,
    xpReward: 500,
  ),
  Achievement(
    id: 'streak_recovered',
    family: AchievementFamily.consistencia,
    metric: AchievementMetric.streakRecovered,
    threshold: 1,
    xpReward: 40,
  ),

  // Cuidado
  Achievement(
    id: 'photos_5',
    family: AchievementFamily.cuidado,
    metric: AchievementMetric.photosAdded,
    threshold: 5,
    xpReward: 30,
  ),
  Achievement(
    id: 'photos_25',
    family: AchievementFamily.cuidado,
    metric: AchievementMetric.photosAdded,
    threshold: 25,
    xpReward: 80,
  ),
  Achievement(
    id: 'photos_100',
    family: AchievementFamily.cuidado,
    metric: AchievementMetric.photosAdded,
    threshold: 100,
    xpReward: 200,
  ),
  Achievement(
    id: 'measurements_10',
    family: AchievementFamily.cuidado,
    metric: AchievementMetric.measurementsAdded,
    threshold: 10,
    xpReward: 40,
  ),
  Achievement(
    id: 'measurements_50',
    family: AchievementFamily.cuidado,
    metric: AchievementMetric.measurementsAdded,
    threshold: 50,
    xpReward: 120,
  ),
  Achievement(
    id: 'measurements_200',
    family: AchievementFamily.cuidado,
    metric: AchievementMetric.measurementsAdded,
    threshold: 200,
    xpReward: 300,
  ),
  Achievement(
    id: 'treatments_10',
    family: AchievementFamily.cuidado,
    metric: AchievementMetric.treatmentsApplied,
    threshold: 10,
    xpReward: 60,
  ),

  // Ciclo
  Achievement(
    id: 'first_phase_change',
    family: AchievementFamily.ciclo,
    metric: AchievementMetric.phaseChanges,
    threshold: 1,
    xpReward: 25,
  ),
  Achievement(
    id: 'phases_one_plant',
    family: AchievementFamily.ciclo,
    metric: AchievementMetric.maxPhasesOnOnePlant,
    threshold: 5,
    xpReward: 150,
  ),
  Achievement(
    id: 'first_harvest',
    family: AchievementFamily.ciclo,
    metric: AchievementMetric.harvests,
    threshold: 1,
    xpReward: 100,
  ),
  Achievement(
    id: 'harvests_5',
    family: AchievementFamily.ciclo,
    metric: AchievementMetric.harvests,
    threshold: 5,
    xpReward: 300,
  ),
  Achievement(
    id: 'harvest_dry_weight',
    family: AchievementFamily.ciclo,
    metric: AchievementMetric.harvestsWithDryWeight,
    threshold: 1,
    xpReward: 80,
  ),

  // Curadoria
  Achievement(
    id: 'problems_5',
    family: AchievementFamily.curadoria,
    metric: AchievementMetric.problemsReported,
    threshold: 5,
    xpReward: 60,
  ),
  Achievement(
    id: 'problem_documented',
    family: AchievementFamily.curadoria,
    metric: AchievementMetric.problemsWithPhoto,
    threshold: 1,
    xpReward: 50,
  ),
  Achievement(
    id: 'dense_plant_100',
    family: AchievementFamily.curadoria,
    metric: AchievementMetric.maxEventsOnOnePlant,
    threshold: 100,
    xpReward: 250,
  ),
  Achievement(
    id: 'comparable_cycles_3',
    family: AchievementFamily.curadoria,
    metric: AchievementMetric.cyclesEnded,
    threshold: 3,
    xpReward: 200,
  ),
];

Achievement? achievementById(String id) {
  for (final achievement in achievementCatalog) {
    if (achievement.id == id) return achievement;
  }
  return null;
}

/// Conquistas cujo limite foi atingido e que ainda não estavam destravadas.
List<Achievement> evaluateAchievements({
  required int Function(AchievementMetric metric) counterOf,
  required Set<String> unlockedIds,
}) {
  return achievementCatalog
      .where(
        (achievement) =>
            !unlockedIds.contains(achievement.id) &&
            counterOf(achievement.metric) >= achievement.threshold,
      )
      .toList();
}
