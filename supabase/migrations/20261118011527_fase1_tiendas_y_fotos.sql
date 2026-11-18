-- Fase 1 de cuentas: cada persona tiene una copia completa de su tienda en la nube
-- (una por versión: la normal y la beta nunca se mezclan). Las fotos van aparte, en Storage.
-- Aplicada al proyecto Supabase "stok" (São Paulo) el 2026-11-18.

create table public.tiendas (
  id           uuid primary key default gen_random_uuid(),
  dueno        uuid not null default auth.uid() references auth.users(id) on delete cascade,
  canal        text not null default 'stable' check (canal in ('stable','beta')),
  nombre       text not null default 'Mi Tienda' check (char_length(nombre) <= 120),
  datos        jsonb not null default '{}'::jsonb check (octet_length(datos::text) < 8000000),
  version      bigint not null default 1,
  dispositivo  text check (char_length(dispositivo) <= 120),
  creada       timestamptz not null default now(),
  actualizada  timestamptz not null default now(),
  unique (dueno, canal)
);
comment on table public.tiendas is 'Copia en la nube de cada tienda de Stok (fase 1: un documento por tienda y versión).';

-- Cada guardado sube el número de versión: así un teléfono sabe si otro guardó algo más nuevo.
create function public.tiendas_nueva_version() returns trigger
language plpgsql set search_path = '' as $$
begin
  new.version := old.version + 1;
  new.actualizada := now();
  new.dueno := old.dueno;   -- nadie puede pasar su tienda a otra persona
  new.canal := old.canal;
  new.creada := old.creada;
  return new;
end $$;
create trigger tiendas_version before update on public.tiendas
  for each row execute function public.tiendas_nueva_version();

-- Seguridad: cada persona solo ve y cambia su propia tienda.
alter table public.tiendas enable row level security;
create policy "ver mi tienda"      on public.tiendas for select to authenticated using (dueno = (select auth.uid()));
create policy "crear mi tienda"    on public.tiendas for insert to authenticated with check (dueno = (select auth.uid()));
create policy "guardar mi tienda"  on public.tiendas for update to authenticated using (dueno = (select auth.uid())) with check (dueno = (select auth.uid()));
create policy "borrar mi tienda"   on public.tiendas for delete to authenticated using (dueno = (select auth.uid()));
revoke all on public.tiendas from anon;

-- Fotos: carpeta privada por persona  fotos/<usuario>/<versión>/<clave>.jpg
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('fotos', 'fotos', false, 1048576, array['image/jpeg','image/png','image/webp']);

create policy "ver mis fotos"    on storage.objects for select to authenticated
  using (bucket_id = 'fotos' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "subir mis fotos"  on storage.objects for insert to authenticated
  with check (bucket_id = 'fotos' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "cambiar mis fotos" on storage.objects for update to authenticated
  using (bucket_id = 'fotos' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "borrar mis fotos" on storage.objects for delete to authenticated
  using (bucket_id = 'fotos' and (storage.foldername(name))[1] = (select auth.uid())::text);
