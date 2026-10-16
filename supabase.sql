-- المشروع النهائي: الميري ستور | البرمجة والتطوير: حمادي ستور | 0946678902
-- حمادي ستور: جداول لوحة الإدارة + صلاحيات RLS
-- مهم: استبدل/عدّل الجداول إذا كانت لديك جداول موجودة بأسماء مختلفة.

create table if not exists public.admin_users (
  id uuid primary key default gen_random_uuid(),
  user_id uuid unique references auth.users(id) on delete cascade,
  email text,
  role text not null default 'moderator' check (role in ('owner','admin','moderator')),
  active boolean not null default true,
  created_at timestamptz not null default now()
);

alter table public.site_settings add column if not exists tagline text;
alter table public.site_settings add column if not exists hero_title text;
alter table public.site_settings add column if not exists hero_description text;
alter table public.site_settings add column if not exists whatsapp text;
alter table public.site_settings add column if not exists logo_url text;
alter table public.site_settings add column if not exists hero_image_url text;
alter table public.site_settings add column if not exists cta_text text;
alter table public.site_settings add column if not exists accounts_cta text;
alter table public.site_settings add column if not exists footer_text text;
alter table public.site_settings add column if not exists meta_title text;
alter table public.site_settings add column if not exists copyright text;
alter table public.site_settings add column if not exists maintenance_message text;

alter table public.games add column if not exists image_url text;
alter table public.games add column if not exists visible boolean default true;

alter table public.packages add column if not exists image_url text;
alter table public.packages add column if not exists visible boolean default true;

alter table public.accounts add column if not exists featured boolean default false;
alter table public.accounts add column if not exists images text[] default '{}';
alter table public.accounts add column if not exists description text;

create table if not exists public.offers (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  discount numeric(6,2) default 0,
  image_url text,
  active boolean default true,
  created_at timestamptz default now()
);

create table if not exists public.payment_methods (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  identifier text,
  instructions text,
  active boolean default true,
  created_at timestamptz default now()
);

create table if not exists public.reviews (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  customer_name text,
  rating integer check (rating between 1 and 5),
  comment text,
  approved boolean default false,
  created_at timestamptz default now()
);

create table if not exists public.memberships (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  price numeric(12,2) default 0,
  duration text,
  description text,
  active boolean default true,
  created_at timestamptz default now()
);

alter table public.admin_users enable row level security;
alter table public.site_settings enable row level security;
alter table public.games enable row level security;
alter table public.packages enable row level security;
alter table public.accounts enable row level security;
alter table public.orders enable row level security;
alter table public.offers enable row level security;
alter table public.payment_methods enable row level security;
alter table public.reviews enable row level security;
alter table public.memberships enable row level security;

create or replace function public.is_admin()
returns boolean language sql security definer set search_path=public
as $$ select exists(select 1 from public.admin_users a where a.user_id=auth.uid() and a.active=true); $$;

create or replace function public.is_owner()
returns boolean language sql security definer set search_path=public
as $$ select exists(select 1 from public.admin_users a where a.user_id=auth.uid() and a.active=true and a.role='owner'); $$;

-- اقرأ/اكتب لوحة الإدارة فقط للمشرفين
drop policy if exists admin_users_admin on public.admin_users;
create policy admin_users_admin on public.admin_users for all to authenticated
using (public.is_admin()) with check (public.is_admin());

drop policy if exists site_admin on public.site_settings;
create policy site_admin on public.site_settings for all to authenticated
using (public.is_admin()) with check (public.is_admin());

drop policy if exists games_admin on public.games;
create policy games_admin on public.games for all to authenticated
using (public.is_admin()) with check (public.is_admin());

drop policy if exists packages_admin on public.packages;
create policy packages_admin on public.packages for all to authenticated
using (public.is_admin()) with check (public.is_admin());

drop policy if exists accounts_admin on public.accounts;
create policy accounts_admin on public.accounts for all to authenticated
using (public.is_admin()) with check (public.is_admin());

drop policy if exists orders_admin on public.orders;
create policy orders_admin on public.orders for all to authenticated
using (public.is_admin()) with check (public.is_admin());

drop policy if exists offers_admin on public.offers;
create policy offers_admin on public.offers for all to authenticated
using (public.is_admin()) with check (public.is_admin());

drop policy if exists payment_admin on public.payment_methods;
create policy payment_admin on public.payment_methods for all to authenticated
using (public.is_admin()) with check (public.is_admin());

drop policy if exists reviews_admin on public.reviews;
create policy reviews_admin on public.reviews for all to authenticated
using (public.is_admin()) with check (public.is_admin());

drop policy if exists memberships_admin on public.memberships;
create policy memberships_admin on public.memberships for all to authenticated
using (public.is_admin()) with check (public.is_admin());

-- بعد إنشاء حسابك في Authentication > Users:
-- استبدل UUID التالي بـ User ID الخاص بحسابك ثم نفّذ:
-- insert into public.admin_users(user_id,email,role) values ('YOUR-USER-UUID','you@example.com','owner');

-- ملاحظة: لا تضع service_role key داخل HTML أو JavaScript.
