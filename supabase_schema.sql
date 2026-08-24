-- Tabla de perfiles de calibración para Acrosom.ai
-- Ejecutar esto en el SQL Editor de tu proyecto Supabase

create table if not exists calibration_profiles (
  id uuid primary key default gen_random_uuid(),
  marca text not null,
  modelo text not null,
  transductor text not null default '',
  profundidad_cm numeric not null,
  escala_mm_px numeric not null,
  metodo text not null default 'manual', -- 'manual' | 'dicom' | 'auto_detectado'
  notas text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Evita duplicar el mismo equipo+config; un guardado nuevo actualiza el existente
-- (transductor nunca es null, por eso el índice no necesita coalesce; esto
-- permite usar upsert(..., { onConflict: 'marca,modelo,transductor,profundidad_cm' }))
create unique index if not exists calibration_profiles_unique_equipo
  on calibration_profiles (marca, modelo, transductor, profundidad_cm);

-- Row Level Security: habilitado, con policy abierta para lectura/escritura.
-- Ajusta esto si vas a exponer la app fuera de tu red interna.
alter table calibration_profiles enable row level security;

create policy "allow all - internal tool"
  on calibration_profiles
  for all
  using (true)
  with check (true);
