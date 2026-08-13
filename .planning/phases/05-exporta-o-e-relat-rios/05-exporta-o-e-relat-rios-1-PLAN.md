---
wave: 5.1
depends_on: []
files_modified:
  - lib/domain/models/grow_stats.dart
  - lib/domain/repositories/plant_repository.dart
  - lib/data/sqlite_plant_repository.dart
  - lib/features/home/home_screen.dart
autonomous: true
---

# Phase 5: Estatísticas Locais

## Objective
Implementar a coleta e exibição de estatísticas locais (total de plantas, plantas ativas, e eventos registrados) de forma performática, exibindo-as no painel principal (Home).

## Tasks

```xml
<task>
  <read_first>
    - lib/domain/repositories/plant_repository.dart
  </read_first>
  <action>
    <![CDATA[
      1. Create a new file `lib/domain/models/grow_stats.dart` defining the `GrowStats` class:
         - Fields: `final int totalPlants`, `final int activePlants`, `final int totalEvents`.
         - Constructor using required named parameters.
      2. Update `lib/domain/repositories/plant_repository.dart` to import `../models/grow_stats.dart` and add the method `Future<GrowStats> getStats();` to the `PlantRepository` abstract class.
    ]]>
  </action>
  <acceptance_criteria>
    grep -q "class GrowStats" lib/domain/models/grow_stats.dart
    grep -q "Future<GrowStats> getStats();" lib/domain/repositories/plant_repository.dart
  </acceptance_criteria>
</task>

<task>
  <read_first>
    - lib/data/sqlite_plant_repository.dart
    - lib/domain/models/grow_stats.dart
  </read_first>
  <action>
    <![CDATA[
      Update `lib/data/sqlite_plant_repository.dart` to implement `getStats()`:
      1. Import `../domain/models/grow_stats.dart`.
      2. Implement `Future<GrowStats> getStats() async`:
         - Query total plants: `await _db.rawQuery('SELECT COUNT(*) FROM plants')`
         - Query active plants: `await _db.rawQuery('SELECT COUNT(*) FROM plants WHERE status = ?', [PlantStatus.active.name])`
         - Query total events: `await _db.rawQuery('SELECT COUNT(*) FROM plant_events')`
         - Use `Sqflite.firstIntValue(...) ?? 0` for parsing the COUNT result for each query.
         - Return `GrowStats(totalPlants: totalPlants, activePlants: activePlants, totalEvents: totalEvents)`.
    ]]>
  </action>
  <acceptance_criteria>
    grep -q "Future<GrowStats> getStats()" lib/data/sqlite_plant_repository.dart
    grep -q "SELECT COUNT(\*) FROM plants" lib/data/sqlite_plant_repository.dart
  </acceptance_criteria>
</task>

<task>
  <read_first>
    - lib/features/home/home_screen.dart
  </read_first>
  <action>
    <![CDATA[
      Update `lib/features/home/home_screen.dart` to fetch and display the stats:
      1. Import `../../domain/models/grow_stats.dart`.
      2. In `_HomeScreenState`, add `GrowStats? _stats;`.
      3. Update `_reload()` to fetch both `plants` and `stats` via `repo.getStats()`, then set `_stats = stats;` inside `setState`.
      4. In `build`, pass `_stats` down to `_PlantList` (e.g. `_PlantList(plants: plants, stats: _stats, onOpenPlant: _openPlant)`).
      5. Update `_PlantList` constructor to accept `final GrowStats? stats;`.
      6. In `_PlantList.build`, add a new item at the top of the `ListView` if `stats != null`. You can increase `itemCount` by 1 and handle `index == 0` for the Stats summary, `index == 1` for the "homePlantsSection" header, etc.
      7. Create a small widget `_StatsCard` or just a `Row` displaying `totalPlants`, `activePlants` and `totalEvents` with their labels, returning it at `index == 0`.
    ]]>
  </action>
  <acceptance_criteria>
    grep -q "GrowStats? _stats" lib/features/home/home_screen.dart
    grep -q "getStats" lib/features/home/home_screen.dart
  </acceptance_criteria>
</task>
```

## Verification
- Ao abrir a tela Home, os contadores de "Total de Plantas", "Plantas Ativas" e "Eventos" devem ser exibidos e bater com a realidade.
- Criar uma planta ou alterar fase/status deve atualizar os números após o reload.

## Must Haves
- As queries no SQLite devem usar `COUNT(*)` para não trafegar linhas inteiras.
- Tratamento de `_stats` null (não quebrar a UI enquanto carrega).
