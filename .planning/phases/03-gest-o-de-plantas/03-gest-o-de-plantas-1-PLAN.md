---
wave: 1
depends_on: []
files_modified:
  - "lib/domain/repositories/plant_repository.dart"
  - "lib/data/sqlite_plant_repository.dart"
  - "lib/features/plant_profile/plant_profile_screen.dart"
  - "lib/features/quick_log/quick_log_forms.dart"
autonomous: true
---

# Phase 3: Gestão de Plantas - Wave 1

This plan implements the remaining decisions from the context: adding pagination to the timeline and migrating the quick log forms to Riverpod ephemeral state. The database bindings and screen integrations mentioned in the context are already present in the codebase.

<tasks>

<task>
<id>3-1-1</id>
<title>Add pagination to PlantRepository getEvents</title>
<description>
Update the `PlantRepository` interface and the `SqlitePlantRepository` implementation to support pagination parameters for `getEvents`.
1. In `lib/domain/repositories/plant_repository.dart`, modify `getEvents(String plantId)` to accept optional `limit` and `offset` arguments.
2. In `lib/data/sqlite_plant_repository.dart`, update the `getEvents` implementation to use the `limit` and `offset` parameters in the `_db.query` call.
</description>
<read_first>
- lib/domain/repositories/plant_repository.dart
- lib/data/sqlite_plant_repository.dart
</read_first>
<action>
Modify `lib/domain/repositories/plant_repository.dart` and `lib/data/sqlite_plant_repository.dart` to support limit and offset in getEvents.
</action>
<acceptance_criteria>
grep -q "limit" lib/domain/repositories/plant_repository.dart
grep -q "limit:" lib/data/sqlite_plant_repository.dart
grep -q "offset:" lib/data/sqlite_plant_repository.dart
</acceptance_criteria>
</task>

<task>
<id>3-1-2</id>
<title>Implement timeline pagination in PlantProfileScreen</title>
<description>
Update `PlantProfileScreen` to load plant events progressively instead of loading them all at once.
1. Add a `ScrollController` to `_PlantProfileScreenState` and attach it to the `ListView`.
2. Implement logic to load an initial `limit` of events (e.g., 20).
3. Listen to the scroll controller and fetch the next page of events (using `offset`) when the user scrolls near the bottom of the list.
4. Append newly loaded events to the `_events` list and use `setState`.
</description>
<read_first>
- lib/features/plant_profile/plant_profile_screen.dart
</read_first>
<action>
Refactor `_PlantProfileScreenState` in `lib/features/plant_profile/plant_profile_screen.dart` to use a ScrollController for pagination instead of loading all events at once.
</action>
<acceptance_criteria>
grep -q "ScrollController" lib/features/plant_profile/plant_profile_screen.dart
grep -q "offset" lib/features/plant_profile/plant_profile_screen.dart
</acceptance_criteria>
</task>

<task>
<id>3-1-3</id>
<title>Refactor QuickLog forms state to Riverpod</title>
<description>
Refactor the state management in `quick_log_forms.dart` as requested by the Phase 3 Context decisions.
Currently, `_EventFormState` handles `occurredAt`, `saving`, and controllers locally.
1. Create a Riverpod `AutoDisposeNotifier` or `AutoDisposeStateProvider` to manage the common ephemeral state (like `occurredAt` and `saving`) for the forms.
2. Refactor `_EventFormState` (or remove it entirely if converting to a ConsumerWidget) to rely on the Riverpod provider.
3. Ensure the SnackBar success behavior on pop remains intact.
</description>
<read_first>
- lib/features/quick_log/quick_log_forms.dart
</read_first>
<action>
Refactor the internal state of forms in `lib/features/quick_log/quick_log_forms.dart` to use a Riverpod `AutoDisposeNotifier` or `AutoDisposeStateProvider` for managing the ephemeral state (`occurredAt`, `saving`).
</action>
<acceptance_criteria>
grep -E -q "Notifier|StateProvider" lib/features/quick_log/quick_log_forms.dart
grep -q "AutoDispose" lib/features/quick_log/quick_log_forms.dart || grep -q "autoDispose" lib/features/quick_log/quick_log_forms.dart
</acceptance_criteria>
</task>

</tasks>

## Verification
- [ ] `PlantRepository.getEvents` can be queried with limits and offsets.
- [ ] `PlantProfileScreen` successfully paginates events when scrolling down.
- [ ] `QuickLogForm` states are ephemeral and managed via Riverpod Notifiers/StateProviders that auto-dispose.
- [ ] Existing functionality to save plants and show snackbars remains intact.

<must_haves>
- Timeline in `PlantProfileScreen` correctly fetches data in chunks.
- Quick Log forms use Riverpod for state.
</must_haves>
