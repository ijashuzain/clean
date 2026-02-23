# logit

`logit` is a clean-architecture Flutter task manager with:

- Auth flow (Supabase with local fallback, session persistence)
- Date-wise task timeline
- Subtasks and notes
- Light/Dark theme switching
- `go_router` navigation with guarded routes
- Hive local persistence with optional Supabase sync/auth integration

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

## Supabase Setup (Optional but recommended)

1. Create a Supabase project.
2. Run SQL in `supabase/schema.sql`.
3. Run the app with Supabase credentials:

```bash
flutter run \
  --dart-define=SUPABASE_URL=YOUR_SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

Without these `--dart-define` values, app falls back to local auth/tasks.

## Quality Checks

```bash
flutter analyze
flutter test
```
