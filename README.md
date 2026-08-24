# Calibración · Acrosom.ai

App standalone para calibrar la escala mm/px de distintos ecógrafos, para que
el módulo de detección de folículos convierta área/diámetro en píxeles a mm reales.

## Cómo funciona

1. Subes una imagen del ecógrafo (una captura como las que ya tienes).
2. Marcas 2 puntos sobre una referencia de distancia conocida:
   - La regla de profundidad lateral (ej. 1 tick = 1 cm = 10 mm), o
   - Una línea de caliper ya puesta por el equipo (usas el valor `D: X mm` que
     aparece en pantalla).
3. Ingresas la distancia real en mm de esos 2 puntos.
4. La app calcula `escala_mm_px = distancia_real_mm / distancia_px`.
5. Guardas el perfil con marca, modelo, transductor y la profundidad ("D" en
   pantalla) — queda en Supabase, reutilizable la próxima vez que uses ese
   mismo equipo con la misma config.
6. Cualquier perfil ya guardado se puede buscar y copiar (clic en la fila copia
   la escala al portapapeles) para pasarlo al pipeline de Acrosom.ai.

Importante: la escala depende de la profundidad configurada en el equipo (el
"D" que aparece en el panel izquierdo del ecógrafo). Si cambia el zoom/D,
la escala cambia — por eso el perfil se guarda por combinación de
marca+modelo+transductor+profundidad, no solo por equipo.

## Setup

### 1. Supabase

1. Crea un proyecto en https://supabase.com (o usa uno existente).
2. Ve a **SQL Editor** y ejecuta el contenido de `supabase_schema.sql`.
3. Ve a **Settings → API** y copia:
   - `Project URL`
   - `anon public` key
4. Pégalos en `config.js`:
   ```js
   window.SUPABASE_URL = "https://tu-proyecto.supabase.co";
   window.SUPABASE_ANON_KEY = "tu-anon-key";
   ```

La policy en `supabase_schema.sql` deja la tabla abierta (`using (true)`) para
que la app funcione sin login, porque es una herramienta interna. Si en algún
momento la expones fuera de tu red o de tu equipo, cambia la policy para
requerir autenticación.

### 2. Deploy en Vercel

```bash
cd calibracion-app
npx vercel --prod
```

O conecta el repo directamente desde el dashboard de Vercel (Import Project).
No necesita build step — es HTML/JS estático.

**Importante:** `config.js` con tus credenciales quedará en el repo si lo subes
a GitHub. La `anon key` de Supabase está diseñada para exponerse en el
cliente (no es un secreto como la `service_role key`), así que esto es seguro
siempre que la RLS policy esté bien configurada.

## Próximos pasos posibles

- Auto-detección de la regla de profundidad para equipos ya mapeados (como el
  6V1 que ya calibramos), para no tener que marcar los puntos a mano cada vez.
- Soporte para leer `PixelSpacing` directo de archivos DICOM crudos, si en
  algún momento tienen acceso a eso en vez de solo capturas JPG — sería el
  método más preciso, sin calibración manual.
- Endpoint/función para que el pipeline de detección de folículos consulte
  el perfil activo automáticamente (por ejemplo si el nombre de archivo o
  metadata trae el modelo de equipo).
