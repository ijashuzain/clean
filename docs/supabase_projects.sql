-- Projects feature migration for LogIt
-- Run this in Supabase SQL editor before using project sync on devices.

begin;

create table if not exists public.projects (
  id text not null,
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  description text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint projects_pk primary key (user_id, id)
);

create index if not exists projects_user_name_idx
  on public.projects (user_id, name);

create table if not exists public.task_projects (
  user_id uuid not null references auth.users(id) on delete cascade,
  task_id text not null,
  project_id text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint task_projects_pk primary key (user_id, task_id),
  constraint task_projects_project_fk
    foreign key (user_id, project_id)
    references public.projects (user_id, id)
    on delete cascade,
  constraint task_projects_task_fk
    foreign key (user_id, task_id)
    references public.tasks (user_id, id)
    on delete cascade
);

create index if not exists task_projects_user_project_idx
  on public.task_projects (user_id, project_id);

alter table public.projects enable row level security;
alter table public.task_projects enable row level security;

drop policy if exists projects_select_own on public.projects;
create policy projects_select_own
on public.projects
for select
using (auth.uid() = user_id);

drop policy if exists projects_insert_own on public.projects;
create policy projects_insert_own
on public.projects
for insert
with check (auth.uid() = user_id);

drop policy if exists projects_update_own on public.projects;
create policy projects_update_own
on public.projects
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists projects_delete_own on public.projects;
create policy projects_delete_own
on public.projects
for delete
using (auth.uid() = user_id);

drop policy if exists task_projects_select_own on public.task_projects;
create policy task_projects_select_own
on public.task_projects
for select
using (auth.uid() = user_id);

drop policy if exists task_projects_insert_own on public.task_projects;
create policy task_projects_insert_own
on public.task_projects
for insert
with check (auth.uid() = user_id);

drop policy if exists task_projects_update_own on public.task_projects;
create policy task_projects_update_own
on public.task_projects
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists task_projects_delete_own on public.task_projects;
create policy task_projects_delete_own
on public.task_projects
for delete
using (auth.uid() = user_id);

commit;
