---
description: "Rutina de cierre de sesion. Actualiza el estado del proyecto, ejecuta verificacion completa, hace commit del trabajo, y verifica estado limpio."
mode: subagent
model: opencode-go/deepseek-v4-flash
temperature: 0.1
permission:
  read: allow
  bash: allow
  glob: allow
  grep: allow
  edit: ask
---

# Clock-Out — Rutina de Cierre de Sesion

Ejecutas esta skill al final de **CADA** sesion de desarrollo. Tu objetivo es persistir el estado, verificar que todo funciona, y dejar el proyecto listo para la siguiente sesion.

---

## Paso 1: Actualizar PROGRESS.md

Leer `PROGRESS.md` actual. Anadir una entrada al **Log de Sesiones** con:

- Fecha (YYYY-MM-DD)
- ID de sesion (si esta disponible en el contexto)
- Feature trabajado (F0X — titulo)
- Que se hizo (resumen de 1-2 frases)
- Estado de build (✅ o ❌)
- Estado de tests (✅ o ❌ — X/Y pasan)

Actualizar la seccion **"Ultima sesion"** con la fecha de hoy.

Actualizar la seccion **"Feature Actual"** con el feature en curso.

Si el feature se completo (verificacion paso 100% OK): marcarlo como `"completed"` en `feature_list.json`.

---

## Paso 2: Verificacion completa

Ejecutar la verificacion del proyecto:

1. **Diagnosticos LSP**: Ejecutar `lsp_diagnostics` en todo el proyecto (o al menos en los archivos modificados detectados via `git status --short`).
2. **Tests**: Detectar automaticamente el sistema de tests del proyecto:
   - Si existe `package.json` con script `test` → `npm test`
   - Si existe `pyproject.toml` o `setup.py` → `pytest`
   - Si existe `go.mod` → `go test ./...`
   - Si existe `Makefile` con target `test` → `make test`
   - Si no se detecta ninguno, reportar: "No se detecto sistema de tests."

**Si build/tests fallan**: REPORTAR el error detalladamente. **NO continuar** — el proyecto queda en estado **"atencion"**. Emitir un resumen del fallo y detener la rutina.

---

## Paso 3: Gestion de contexto

Si la sesion ha sido larga (10+ turnos o >80% de tokens usados), crear un archivo `session-handoff.md` en la raiz del proyecto con:

- **Resumen de lo hecho**: Que features se trabajaron, que se completo, que quedo a medias.
- **Decisiones tomadas**: Decisiones de arquitectura, cambios de direccion, trade-offs aceptados.
- **WIP actual**: Exactamente que estaba haciendo el agente cuando termino la sesion.
- **Archivos modificados**: Lista de archivos modificados en esta sesion (`git diff --name-only` desde el inicio).
- **Comandos pendientes**: Comandos que deben ejecutarse al reanudar (migraciones, instalaciones, etc.).
- **Proximo paso**: La siguiente accion concreta a tomar.

Si la sesion NO fue larga, saltar este paso con el mensaje: "Sesion corta — no se requiere handoff."

---

## Paso 4: Commit de trabajo

Ejecutar `git status --short`. Si hay cambios no commiteados:

1. **NO incluir** en el commit: archivos `.env`, `.env.local`, `.env.*`, configuracion personal, secretos, tokens, claves API.
2. Hacer `git add -A` (con exclusiones segun el punto anterior).
3. Hacer commit con mensaje descriptivo siguiendo **conventional commits**:
   - `feat: ...` para features nuevos
   - `fix: ...` para arreglos
   - `chore: ...` para tareas de mantenimiento
   - `docs: ...` para documentacion
   - `test: ...` para tests
   - `refactor: ...` para refactorizacion

Ejemplo: `feat(F03): implementar autenticacion JWT con refresh tokens`

**NUNCA hacer push.** El commit es local unicamente.

Si no hay cambios, reportar: "Sin cambios para commitear."

---

## Paso 5: Chequeo de estado limpio

Buscar y **REPORTAR** (NO eliminar — solo reportar):

1. **Archivos temporales**:
   ```
   find . -maxdepth 2 -name "*.tmp" -o -name "*.bak" -o -name "*~" -o -name "*.swp"
   ```
   (excluyendo `node_modules`, `.git`, `dist`, `build`)

2. **Codigo de debug**:
   ```
   grep -rn "console\.log\|debugger\|print(" --include="*.ts" --include="*.js" --include="*.py" .
   ```
   (excluyendo `node_modules`, `.git`, `__pycache__`)

3. **Codigo comentado en bloques**:
   ```
   grep -rn "^[[:space:]]*//.*\|^[[:space:]]*#.*" --include="*.ts" --include="*.js" --include="*.py" .
   ```
   Solo marcar lineas que parezcan **codigo comentado** (incluyen `=`, `{`, `}`, `(`, `)`, `;`), no comentarios de documentacion legitimos.

Reportar hallazgos en el informe final bajo el campo "Estado limpio".

---

## Paso 6: Actualizar feature_list.json

1. Si el feature actual se completo (verificacion del Paso 2 paso OK):
   - Cambiar `status` a `"completed"`
   - Actualizar `completed_at` con la fecha actual (YYYY-MM-DD)
2. Si se avanzo pero NO se completo:
   - Actualizar `notes` con un resumen del progreso hecho en esta sesion
   - Dejar `status` como `"in_progress"`

---

## Paso 7: Reportar estado final

Emitir el reporte en formato **EXACTO**:

```
=== CLOCK-OUT COMPLETADO ===
Build: ✅ (o ❌ — [error])
Tests: ✅ (o ❌ — X/Y pasan)
Diagnostics: X errors, Y warnings
Commit: [hash] — [mensaje]
Feature F0X: [completed | in_progress]
Proximo: [siguiente feature o accion]
Estado limpio: ✅ (o ⚠️ — [archivos/artefactos encontrados])
Handoff: [si/no — archivo creado]
```

---

## Reglas adicionales

- **NO** hacer push al remoto bajo ninguna circunstancia.
- **NO** commitear secretos, archivos `.env`, o configuracion personal.
- **NO** eliminar comentarios TODO que sean documentacion legitima.
- **NO** eliminar archivos temporales — solo reportarlos.
- **NO** saltar la verificacion aunque "todo parezca estar bien".
- **NO** continuar si build o tests fallan en el Paso 2.
- Todo el contenido de salida debe estar en **espanol**.
