-- MERCH CREATIVITY - SUPABASE SETUP
-- Jalankan file ini di Supabase > SQL Editor > New query > Run.
-- Login admin default di aplikasi tetap memakai username/password yang kamu minta,
-- tapi password tidak ditaruh di file index.html, hanya hash-nya yang disimpan di database.

create extension if not exists pgcrypto;

create table if not exists public.app_users (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  username text not null unique,
  password_hash text not null,
  role text not null check (role in ('admin','pegawai')),
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  price integer not null default 0,
  image text,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.reports (
  id uuid primary key default gen_random_uuid(),
  report_date date not null,
  worker_id uuid references public.app_users(id) on delete set null,
  worker_name text not null,
  total integer not null default 0,
  cash integer not null default 0,
  qris integer not null default 0,
  diff integer not null default 0,
  status text not null default 'Cocok',
  created_by uuid references public.app_users(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.report_items (
  id uuid primary key default gen_random_uuid(),
  report_id uuid not null references public.reports(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null,
  product_name text not null,
  qty integer not null default 0,
  price integer not null default 0,
  subtotal integer not null default 0
);

create table if not exists public.cash_entries (
  id uuid primary key default gen_random_uuid(),
  entry_date date not null,
  type text not null check (type in ('income','expense')),
  category text not null,
  amount integer not null default 0,
  note text,
  created_by uuid references public.app_users(id) on delete set null,
  created_at timestamptz not null default now()
);

-- RLS prototype: dipakai supaya browser/anon key bisa baca-tulis sesuai aplikasi.
-- Untuk produksi beneran, sebaiknya ganti ke Supabase Auth + Edge Function.
alter table public.app_users enable row level security;
alter table public.products enable row level security;
alter table public.reports enable row level security;
alter table public.report_items enable row level security;
alter table public.cash_entries enable row level security;

drop policy if exists "mc_app_users_select" on public.app_users;
drop policy if exists "mc_app_users_insert" on public.app_users;
drop policy if exists "mc_app_users_update" on public.app_users;
drop policy if exists "mc_app_users_delete" on public.app_users;

drop policy if exists "mc_products_select" on public.products;
drop policy if exists "mc_products_insert" on public.products;
drop policy if exists "mc_products_update" on public.products;
drop policy if exists "mc_products_delete" on public.products;

drop policy if exists "mc_reports_select" on public.reports;
drop policy if exists "mc_reports_insert" on public.reports;
drop policy if exists "mc_reports_update" on public.reports;
drop policy if exists "mc_reports_delete" on public.reports;

drop policy if exists "mc_items_select" on public.report_items;
drop policy if exists "mc_items_insert" on public.report_items;
drop policy if exists "mc_items_update" on public.report_items;
drop policy if exists "mc_items_delete" on public.report_items;

drop policy if exists "mc_cash_select" on public.cash_entries;
drop policy if exists "mc_cash_insert" on public.cash_entries;
drop policy if exists "mc_cash_update" on public.cash_entries;
drop policy if exists "mc_cash_delete" on public.cash_entries;

create policy "mc_app_users_select" on public.app_users for select to anon using (true);
create policy "mc_app_users_insert" on public.app_users for insert to anon with check (true);
create policy "mc_app_users_update" on public.app_users for update to anon using (true) with check (true);
create policy "mc_app_users_delete" on public.app_users for delete to anon using (true);

create policy "mc_products_select" on public.products for select to anon using (true);
create policy "mc_products_insert" on public.products for insert to anon with check (true);
create policy "mc_products_update" on public.products for update to anon using (true) with check (true);
create policy "mc_products_delete" on public.products for delete to anon using (true);

create policy "mc_reports_select" on public.reports for select to anon using (true);
create policy "mc_reports_insert" on public.reports for insert to anon with check (true);
create policy "mc_reports_update" on public.reports for update to anon using (true) with check (true);
create policy "mc_reports_delete" on public.reports for delete to anon using (true);

create policy "mc_items_select" on public.report_items for select to anon using (true);
create policy "mc_items_insert" on public.report_items for insert to anon with check (true);
create policy "mc_items_update" on public.report_items for update to anon using (true) with check (true);
create policy "mc_items_delete" on public.report_items for delete to anon using (true);

create policy "mc_cash_select" on public.cash_entries for select to anon using (true);
create policy "mc_cash_insert" on public.cash_entries for insert to anon with check (true);
create policy "mc_cash_update" on public.cash_entries for update to anon using (true) with check (true);
create policy "mc_cash_delete" on public.cash_entries for delete to anon using (true);

insert into public.app_users (name, username, password_hash, role)
values ('Team Creativity Admin', 'teamcreativity', '91e22009d555a548c40a91c299eb0347ff3ccd1d980728ca0bed58da4b5a9308', 'admin')
on conflict (username) do update set
  name = excluded.name,
  password_hash = excluded.password_hash,
  role = excluded.role,
  is_active = true;

insert into public.products (name, price, image)
values
('Ganci Akrilik Karambit Blue', 18000, 'assets/product_blue.png'),
('Ganci Akrilik Karambit Pink', 18000, 'assets/product_pink.png'),
('Ganci Akrilik Karambit Monochrome', 17000, 'assets/product_monochrome.png')
on conflict do nothing;