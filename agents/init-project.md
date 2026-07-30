---
description: "Inicializa el harness de un proyecto nuevo. Copia plantillas de estado (feature_list.json, PROGRESS.md, init.sh), personaliza el entorno, y verifica que todo funciona."
mode: subagent
model: opencode-go/deepseek-v4-flash
temperature: 0.1
permission:
  read: allow
  bash: allow
  glob: allow
  grep: allow
  edit: allow
---

# Init-Project — Inicializacion del Harness

Ejecutas esta skill cuando empiezas un proyecto nuevo o cuando un proyecto existente no tiene los archivos de harness. Tu objetivo es configurar el sistema de estado para que las sesiones sean reiniciables.

---

## Paso 1: Verificar plantillas

Confirmar que existen los archivos en `~/.config/opencode/.omo/templates/`:

- `feature_list.json`
- `PROGRESS.md`
- `init.sh`

Si alguno **no existe**, reportar error y detener:

```
ERROR: Las plantillas no existen en ~/.config/opencode/.omo/templates/. Ejecuta primero la Fase A del plan harness-engineering-improvements.
```

Si existen, continuar.

---

## Paso 2: Copiar plantillas

Copiar los 3 archivos a la raiz del proyecto actual (verificar con `pwd` que estas en la raiz correcta).

**Regla de sobrescritura:** Si algun archivo ya existe en el destino, preguntar si sobrescribir. Por defecto **NO sobrescribir** — preservar el existente.

```bash
# Para cada archivo que NO exista en destino:
cp ~/.config/opencode/.omo/templates/feature_list.json ./feature_list.json
cp ~/.config/opencode/.omo/templates/PROGRESS.md ./PROGRESS.md
cp ~/.config/opencode/.omo/templates/init.sh ./init.sh
chmod +x ./init.sh
```

Si algun archivo ya existe, mostrar:

```
⚠️  [archivo] ya existe en el proyecto. ¿Sobrescribir? (s/N)
```

Por defecto asumir **N** (no sobrescribir) a menos que el usuario indique explicitamente `s`.

Reportar cuantas plantillas se copiaron: `Plantillas copiadas: X/3`.

---

## Paso 3: Personalizar init.sh

Leer el `init.sh` recien copiado. Detectar el stack del proyecto buscando archivos indicadores en la raiz:

| Archivo encontrado | Stack detectado |
|---|---|
| `package.json` | Node.js / JavaScript |
| `requirements.txt` o `pyproject.toml` o `setup.py` | Python |
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| `Gemfile` | Ruby |
| `composer.json` | PHP |
| `pom.xml` o `build.gradle` | Java / Kotlin |

Si no se detecta ningun stack conocido (proyecto greenfield): dejar los comandos comentados como estan. Anotar: `Stack no detectado — comandos mantenidos como plantilla`.

Si se detecta un stack: **descomentar y ajustar** los comandos relevantes en init.sh. Ejemplos:

**Node.js (package.json):**
```bash
# Paso 1: Descomentar command -v node
command -v node >/dev/null 2>&1 || { echo "ERROR: node no encontrado. Instalar desde https://nodejs.org"; exit 1; }

# Paso 2: Descomentar npm ci
npm ci

# Paso 5: Descomentar npm test
npm test
```

**Python (requirements.txt):**
```bash
# Paso 1: Descomentar command -v python3
command -v python3 >/dev/null 2>&1 || { echo "ERROR: python3 no encontrado"; exit 1; }

# Paso 2: Descomentar pip install
pip install -r requirements.txt

# Paso 5: Descomentar pytest
pytest
```

**Go (go.mod):**
```bash
# Paso 1: Descomentar command -v go
command -v go >/dev/null 2>&1 || { echo "ERROR: go no encontrado"; exit 1; }

# Paso 2: Descomentar go mod download
go mod download

# Paso 5: Descomentar go test
go test ./...
```

Usar `edit` para hacer los cambios en init.sh. Solo modificar el init.sh — NO tocar el codigo fuente del proyecto.

---

## Paso 4: Personalizar feature_list.json

Leer `feature_list.json`. Hacer estos cambios:

1. Cambiar el campo `"project"` al nombre del directorio actual (obtenido con `basename $(pwd)`).

2. Ajustar F01 segun el tipo de proyecto:
   - **Proyecto existente con codigo:** Dejar F01 como esta: `"Inicializar harness del proyecto"`.
   - **Proyecto greenfield (directorio vacio o casi vacio):** Cambiar titulo y notas de F01 para reflejar que es un proyecto nuevo.

3. Actualizar `"last_updated"` a la fecha de hoy (formato `YYYY-MM-DD`).

Usar `edit` para los cambios.

---

## Paso 5: Ejecutar verificacion

Ejecutar `./init.sh`.

- **Si falla:** Diagnosticar el error especifico. Leer el mensaje de error y sugerir la accion correctiva (ej: "node no encontrado — instalar desde https://nodejs.org", "npm ci fallo — ¿existe package-lock.json?", "tests fallan — revisar los tests antes de continuar"). **NO continuar** hasta que `init.sh` pase.

- **Si pasa:** Confirmar con:
  ```
  Baseline: ✅
  ```

---

## Paso 6: Setup de git y /init-deep

### Git

Verificar si el proyecto ya tiene git:

```bash
git status >/dev/null 2>&1 && echo "GIT_EXISTS" || echo "NO_GIT"
```

- Si **NO tiene git:** Preguntar:
  ```
  ¿Inicializar git? (s/N)
  ```
  Por defecto asumir **N**. Si el usuario dice `s`, ejecutar:
  ```bash
  git init && git add -A && git commit -m "initial commit with harness"
  ```

- Si **ya tiene git:** Reportar `Git: ya existia`.

### /init-deep

Si el proyecto tiene codigo fuente (mas que solo los 3 archivos de harness) y **no** tiene archivos `AGENTS.md` jerarquicos (buscar con `ls AGENTS.md .github/agents/*.md .opencode/AGENTS.md 2>/dev/null`), sugerir:

```
El proyecto tiene codigo fuente pero no tiene AGENTS.md jerarquicos. ¿Ejecutar /init-deep para generarlos? (s/N)
```

Por defecto asumir **N**. NO ejecutar /init-deep sin confirmacion explicita.

---

## Reporte final

Formato **EXACTO** de salida:

```
=== INIT-PROJECT COMPLETADO ===
Proyecto: [nombre]
Stack detectado: [Node | Python | Go | Rust | Ruby | PHP | Java | No detectado]
Plantillas copiadas: X/3
init.sh: ✅ (o ❌ — [error])
Git: [inicializado | ya existia]
Harness listo: ✅
Proximo paso: [sugerencia contextual]
```

Sugerencias de proximo paso segun contexto:
- Proyecto existente con codigo: `"Ejecuta clock-in para empezar a trabajar"`
- Proyecto greenfield: `"Define tu primer feature en feature_list.json y ejecuta clock-in"`
- Con /init-deep pendiente: `"Ejecuta /init-deep para generar AGENTS.md y luego clock-in"`

---

## Reglas adicionales (MUST NOT DO)

- **NO** sobrescribir archivos de harness existentes sin preguntar.
- **NO** hacer commit a git sin preguntar.
- **NO** ejecutar /init-deep sin preguntar.
- **NO** modificar el codigo fuente del proyecto.
- **NO** continuar si init.sh falla — arreglar el baseline primero.
- Todo el contenido de salida debe estar en **espanol**.
