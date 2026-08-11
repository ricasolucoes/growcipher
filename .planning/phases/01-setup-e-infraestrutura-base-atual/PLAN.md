---
wave: 1
depends_on: []
files_modified:
  - pubspec.yaml
  - lib/providers.dart
  - lib/main.dart
  - lib/app.dart
  - lib/features/home/home_screen.dart
  - lib/features/plant_profile/plant_profile_screen.dart
  - lib/features/plant_wizard/plant_wizard_screen.dart
  - lib/features/plant_wizard/plant_created_screen.dart
  - lib/features/quick_log/quick_log_forms.dart
  - test/helpers/pump_app.dart
autonomous: true
---

# Phase 1: Setup Riverpod for State Management and DI

## Goal
Satisfy the Phase 1 infrastructure requirement by replacing the custom `AppScope` pure-Flutter DI with `flutter_riverpod`, which is the industry standard and requested architecture approach.

## Tasks

```xml
<task>
  <id>1</id>
  <name>Add Riverpod Dependencies</name>
  <read_first>
    - pubspec.yaml
  </read_first>
  <action>
    Add the following packages to `pubspec.yaml` under `dependencies`:
    - `flutter_riverpod: ^2.5.1` (or latest)
    - `riverpod_annotation: ^2.3.5` (or latest)
    
    Add the following packages under `dev_dependencies`:
    - `riverpod_generator: ^2.4.0` (or latest)
    - `build_runner: ^2.4.9` (or latest)
  </action>
  <acceptance_criteria>
    - grep "flutter_riverpod:" pubspec.yaml
    - grep "riverpod_annotation:" pubspec.yaml
    - grep "build_runner:" pubspec.yaml
  </acceptance_criteria>
</task>

<task>
  <id>2</id>
  <name>Create Global Providers</name>
  <read_first>
    - lib/data/app_database.dart
    - lib/data/sqlite_plant_repository.dart
  </read_first>
  <action>
    Create a new file `lib/providers.dart`.
    Add the following code to expose the AppDatabase and PlantRepository:
    ```dart
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'data/app_database.dart';
    import 'data/sqlite_plant_repository.dart';
    import 'domain/repositories/plant_repository.dart';

    final appDatabaseProvider = Provider<AppDatabase>((ref) {
      throw UnimplementedError('appDatabaseProvider must be overridden in ProviderScope');
    });

    final plantRepositoryProvider = Provider<PlantRepository>((ref) {
      final db = ref.watch(appDatabaseProvider);
      return SqlitePlantRepository(db);
    });
    ```
  </action>
  <acceptance_criteria>
    - grep "final plantRepositoryProvider = Provider<PlantRepository>" lib/providers.dart
    - grep "UnimplementedError" lib/providers.dart
  </acceptance_criteria>
</task>

<task>
  <id>3</id>
  <name>Refactor Main and App Widgets</name>
  <read_first>
    - lib/main.dart
    - lib/app.dart
  </read_first>
  <action>
    1. In `lib/main.dart`:
       - Import `package:flutter_riverpod/flutter_riverpod.dart` and `providers.dart`.
       - Change `runApp(GrowCipherApp(repository: SqlitePlantRepository(database)));` to:
         `runApp(ProviderScope(overrides: [appDatabaseProvider.overrideWithValue(database)], child: const GrowCipherApp()));`
    2. In `lib/app.dart`:
       - Remove `import 'app_scope.dart';` and `import 'domain/repositories/plant_repository.dart';`.
       - Change `class GrowCipherApp extends StatelessWidget` to remove the `repository` constructor parameter.
       - Remove the `AppScope` wrapper from the `build` method. The `build` method should directly return the `MaterialApp` widget.
    3. Delete `lib/app_scope.dart` file using terminal or standard delete.
  </action>
  <acceptance_criteria>
    - grep "ProviderScope" lib/main.dart
    - ! grep "AppScope" lib/app.dart
    - [ ! -f lib/app_scope.dart ]
  </acceptance_criteria>
</task>

<task>
  <id>4</id>
  <name>Refactor Features to use Consumer</name>
  <read_first>
    - lib/features/home/home_screen.dart
    - lib/features/plant_profile/plant_profile_screen.dart
    - lib/features/plant_wizard/plant_wizard_screen.dart
    - lib/features/plant_wizard/plant_created_screen.dart
    - lib/features/quick_log/quick_log_forms.dart
  </read_first>
  <action>
    For each of the files above:
    1. Import `package:flutter_riverpod/flutter_riverpod.dart` and `../../providers.dart` (or the correct relative path to `lib/providers.dart`).
    2. Change `StatefulWidget` to `ConsumerStatefulWidget` and `<![CDATA[State<T>]]>` to `<![CDATA[ConsumerState<T>]]>`.
    3. Replace all occurrences of `AppScope.of(context).plantRepository` with `ref.read(plantRepositoryProvider)`.
    Specific notes:
    - In `home_screen.dart`, `plant_profile_screen.dart`, `plant_created_screen.dart`, change `<![CDATA[class _HomeScreenState extends State<HomeScreen>]]>` to `<![CDATA[ConsumerState<HomeScreen>]]>`. Inside `_reload()`, use `ref.read(plantRepositoryProvider).getPlants()`.
    - In `plant_wizard_screen.dart`, change `<![CDATA[_PlantWizardScreenState extends State<PlantWizardScreen>]]>` to `<![CDATA[ConsumerState<PlantWizardScreen>]]>`. Inside `_createPlant()`, use `ref.read(plantRepositoryProvider)`.
    - In `quick_log_forms.dart`, change `<![CDATA[abstract class _EventFormState<T extends StatefulWidget> extends State<T>]]>` to `<![CDATA[ConsumerState<T>]]>` and change `PlantRepository get repository => AppScope.of(context).plantRepository;` to `PlantRepository get repository => ref.read(plantRepositoryProvider);`. Also, change all inheriting States (e.g. `<![CDATA[_WateredFormState extends _EventFormState<_WateredForm>]]>`) to ensure their generic bounds are satisfied, meaning `T extends ConsumerStatefulWidget` instead of `StatefulWidget`, and update the `QuickLogForm` subclasses to `ConsumerStatefulWidget`.
  </action>
  <acceptance_criteria>
    - ! grep -r 'AppScope' lib/
    - grep -r 'ConsumerStatefulWidget' lib/features/
    - grep -r 'plantRepositoryProvider' lib/features/
  </acceptance_criteria>
</task>

<task>
  <id>5</id>
  <name>Refactor Tests</name>
  <read_first>
    - test/helpers/pump_app.dart
  </read_first>
  <action>
    In `test/helpers/pump_app.dart`:
    - Import `package:flutter_riverpod/flutter_riverpod.dart` and `package:growcipher/providers.dart`.
    - Change `await tester.pumpWidget(GrowCipherApp(repository: repository));` to:
      ```dart
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            plantRepositoryProvider.overrideWithValue(repository),
          ],
          child: const GrowCipherApp(),
        ),
      );
      ```
  </action>
  <acceptance_criteria>
    - grep "ProviderScope" test/helpers/pump_app.dart
    - flutter test
  </acceptance_criteria>
</task>
```

## must_haves
- App architecture must utilize Riverpod for Dependency Injection.
- No `AppScope` legacy code remains in the codebase.
- Tests must pass using `ProviderScope` overrides.

## Verification
- flutter analyze
- flutter test
- ! grep -r 'AppScope' lib/
