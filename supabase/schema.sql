-- Run this in Supabase SQL editor.

create table if not exists public.tasks (
  user_id uuid not null references auth.users(id) on delete cascade,
  id text not null,
  title text not null default '',
  topic text not null default '',
  note text not null default '',
  icon_key text not null default '',
  scheduled_at timestamptz not null,
  end_date timestamptz,
  start_minute_of_day integer,
  end_minute_of_day integer,
  reminders jsonb not null default '[]'::jsonb,
  reminder_date timestamptz,
  reminder_minute_of_day integer,
  repeats_daily boolean not null default false,
  is_completed boolean not null default false,
  subtasks jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  primary key (user_id, id)
);

create index if not exists idx_tasks_user_scheduled_at
  on public.tasks (user_id, scheduled_at);

create index if not exists idx_tasks_user_updated_at
  on public.tasks (user_id, updated_at);

alter table public.tasks enable row level security;

drop policy if exists "tasks_select_own" on public.tasks;
create policy "tasks_select_own"
on public.tasks
for select
using (auth.uid() = user_id);

drop policy if exists "tasks_insert_own" on public.tasks;
create policy "tasks_insert_own"
on public.tasks
for insert
with check (auth.uid() = user_id);

drop policy if exists "tasks_update_own" on public.tasks;
create policy "tasks_update_own"
on public.tasks
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "tasks_delete_own" on public.tasks;
create policy "tasks_delete_own"
on public.tasks
for delete
using (auth.uid() = user_id);
