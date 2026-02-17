# logit

`logit` is a clean-architecture Flutter task manager with:

- Auth flow (local demo auth, session persistence)
- Date-wise task timeline
- Subtasks and notes
- Light/Dark theme switching
- `go_router` navigation with guarded routes
- Hive local persistence designed for future remote integration

## Architecture

Authentication and Tasks both follow:

- `data` (datasources, models, repository implementations)
- `domain` (entities, repositories, usecases)
- `presentation` (Riverpod notifiers/providers + views/widgets)

## Local Storage

Hive boxes:

- `auth_box` (users + current session)
- `task_box` (tasks with subtasks)
- `settings_box` (theme + onboarding)

## Run

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

## Quality Checks

```bash
flutter analyze
flutter test
```
