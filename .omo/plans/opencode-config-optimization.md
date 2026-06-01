# OpenCode + oh-my-openagent: Config Optimization

## TL;DR

> **Quick Summary**: Optimizar la configuracion de OpenCode 1.15.13 + oh-my-openagent instalando el plugin caveman, ajustando textVerbosity en agentes, activando aggressive_truncation, y limpiando config duplicada — todo para ahorrar tokens y ser mas eficiente.
>
> **Deliverables**:
> - Plugin `@al-bashkir/opencode-caveman` instalado y configurado (nivel lite, auto-activado)
> - `textVerbosity: "low"` en agentes apropiados (excluyendo oracle y comment_checker)
> - `experimental.aggressive_truncation` y `experimental.task_system` activados
> - Baseline de tokens medido (pre/post optimizacion)
> - Config duplicada `~/.opencode/opencode.json` respaldada y eliminada
> - Backup completo de config antes de cambios
>
> **Estimated Effort**: Short
> **Parallel Execution**: NO — secuencial (cada paso requiere verificacion)
> **Critical Path**: Backup → Baseline → Caveman → textVerbosity → AggressiveTruncation → Cleanup → SmokeTest

---

## Context

### Original Request
El usuario quiere optimizar su configuracion de OpenCode + oh-my-openagent para mayor eficiencia y ahorro de tokens, con especial interes en caveman mode.

### Interview Summary
**Key Discussions**:
- OpenCode 1.15.13 con oh-my-openagent instalado
- Config actual en `~/.config/opencode/` con `opencode.jsonc`, `oh-my-openagent.json`, `tui.json`
- Config duplicada/sobrante en `~/.opencode/opencode.json` con contenido invalido: `{"plugin":["list"]}`
- Directorios `.opencode/agent/` y `.opencode/skills/` vacios

**Decisions Made**:
- **Caveman**: Plugin npm `@al-bashkir/opencode-caveman`, nivel **lite**, siempre activo
- **Optimizaciones**: Caveman + `textVerbosity` + `experimental.aggressive_truncation`
- **Task System**: Activar `experimental.task_system`
- **Oracle**: Excluir de `textVerbosity: "low"` (usar `"medium"`)
- **comment_checker**: Excluir de `textVerbosity` (ya tiene prompt de brevedad en español)
- **Config Cleanup**: Respaldar y eliminar `~/.opencode/opencode.json`
- **Baseline**: Medir consumo de tokens antes de cambios
- **TMUX**: No se usa
- **Agentes deshabilitados**: Ninguno

### Metis Review
**Identified Gaps** (addressed):
- **Gap**: No habia estrategia de verificacion → Anadida: baseline pre/post, verificacion incremental por paso
- **Gap**: `comment_checker` sin modelo asignado → No se toca (fuera de alcance)
- **Gap**: `oracle` necesita precision → Excluido de textVerbosity low
- **Gap**: Config duplicada sospechosa → Backup primero, luego eliminar
- **Gap**: Preguntas abiertas sobre task_system y baseline → Resueltas: si a task_system, si a baseline

---

## Work Objectives

### Core Objective
Reducir el consumo de tokens de OpenCode + oh-my-openagent ~40-65% mediante caveman mode, textVerbosity, y aggressive_truncation, manteniendo precision tecnica.

### Concrete Deliverables
1. `~/.config/opencode/opencode.jsonc` actualizado con plugin caveman
2. `~/.config/opencode/oh-my-openagent.json` con textVerbosity + experimental settings
3. `~/.config/opencode/node_modules/` con paquete `@al-bashkir/opencode-caveman`
4. `~/.opencode/opencode.json` respaldado como `.bak` y eliminado
5. Archivos de evidencia: `/tmp/opencode-baseline-*.txt` y `/tmp/opencode-post-*.txt`

### Must Have
- [ ] Plugin caveman instalado y cargando sin errores
- [ ] Caveman nivel lite activo por defecto al iniciar sesion
- [ ] `textVerbosity` aplicado a agentes apropiados (excluyendo oracle y comment_checker)
- [ ] `experimental.aggressive_truncation = true` en oh-my-openagent.json
- [ ] `experimental.task_system = true` en oh-my-openagent.json
- [ ] Baseline de tokens medido y guardado ANTES de cualquier cambio
- [ ] Evidencia de reduccion de tokens tras cada paso
- [ ] Smoke test final: sisyphus, oracle y explore responden correctamente

### Must NOT Have (Guardrails)
- No modificar `custom_prompt` de ningun agente
- No cambiar modelos asignados a agentes o categorias
- No tocar `tui.json`
- No anadir plugins adicionales (solo caveman)
- No configurar `background_task` (no decidido)
- No arreglar `comment_checker` (falta de modelo) — fuera de alcance
- No modificar config de proyectos individuales

---

## Verification Strategy

> **ZERO HUMAN INTERVENTION** — Toda la verificacion es ejecutada por el agente.
> Cada paso se verifica ANTES de pasar al siguiente.

### Test Decision
- **Infrastructure exists**: N/A (es configuracion, no codigo)
- **Automated tests**: None (config work)
- **Agent-Executed QA**: SI — obligatorio en cada paso

### QA Policy
Cada tarea incluye verificacion agente-ejecutada:
- **Pre-cambio**: Medir baseline de tokens (prompt estandar, sisyphus + oracle)
- **Post-cada paso**: Verificar cambio aplicado, medir tokens, comparar con baseline
- **Smoke test final**: sisyphus, oracle, explore — todos responden correctamente
- **Evidencia**: Archivos en `/tmp/opencode-optimization-*.txt`

---

## Execution Strategy

### Parallel Execution Waves

> Las tareas son **SECUENCIALES** — cada una depende de la anterior.
> No hay paralelismo porque cada paso modifica la config en vivo y debe verificarse antes del siguiente.

```
Wave 1 (Secuencial — cada paso verificado):
├── Task 1: Backup completo + git init + baseline measurement
├── Task 2: Instalar plugin @al-bashkir/opencode-caveman
├── Task 3: Configurar textVerbosity en agentes
├── Task 4: Activar aggressive_truncation + task_system
├── Task 5: Limpiar config duplicada (~/.opencode/)
└── Task 6: Smoke test final + comparacion de tokens

Wave FINAL (Despues de todo — revision):
├── Task F1: Compliance audit (oracle)
└── Task F2: Validacion final
```

### Dependency Matrix
- **Task 1**: None (primer paso) → Tasks 2-6
- **Task 2**: Task 1 → Task 3
- **Task 3**: Task 2 → Task 4
- **Task 4**: Task 3 → Task 5
- **Task 5**: Task 4 → Task 6
- **Task 6**: Task 5 → Final Wave
- **F1-F2**: Task 6 → user approval

### Agent Dispatch Summary
- **Wave 1**: 6 tareas secuenciales → todas `unspecified-low` (config work, no codigo complejo)
- **Wave FINAL**: F1 → `oracle`, F2 → `unspecified-high`

---

## TODOs

- [x] 1. Backup completo + Git init + Baseline measurement

  **What to do**:
  - Hacer backup completo de `~/.config/opencode/`:
    ```bash
    tar czf ~/opencode-config-backup-$(date +%Y%m%d).tar.gz ~/.config/opencode/
    ```
  - Inicializar git en `~/.config/opencode/` para tracking de cambios:
    ```bash
    cd ~/.config/opencode && git init && git add -A && git commit -m "pre-optimization baseline"
    ```
  - Medir baseline de tokens con prompt estandarizado en sisyphus:
    ```bash
    # Ejecutar prompt y capturar salida
    # Prompt: "Explain what a REST API is in detail, covering all HTTP methods, status codes, and best practices."
    # Guardar en: /tmp/opencode-baseline-sisyphus.txt
    ```
  - Medir baseline en oracle (mismo prompt):
    ```bash
    # Guardar en: /tmp/opencode-baseline-oracle.txt
    ```
  - Registrar longitud de caracteres de cada respuesta como metrica baseline

  **Must NOT do**:
  - No modificar ningun archivo de config aun
  - No instalar nada

  **Recommended Agent Profile**:
  - **Category**: `unspecified-low`
  - **Skills**: [`git-master`]
    - `git-master`: Necesario para git init y commit inicial
  - **Skills Evaluated but Omitted**: N/A

  **Parallelization**:
  - **Can Run In Parallel**: NO (primer paso, bloqueante)
  - **Parallel Group**: Wave 1 - Sequencial
  - **Blocks**: Tasks 2, 3, 4, 5, 6
  - **Blocked By**: None

  **References**:
  - `~/.config/opencode/opencode.jsonc` - Archivo a respaldar
  - `~/.config/opencode/oh-my-openagent.json` - Archivo a respaldar
  - `~/.config/opencode/tui.json` - Archivo a respaldar

  **Acceptance Criteria**:
  - [ ] Backup tar.gz existe en `~/opencode-config-backup-*.tar.gz`
  - [ ] `git log` en `~/.config/opencode/` muestra commit inicial
  - [ ] `/tmp/opencode-baseline-sisyphus.txt` existe y tiene contenido
  - [ ] `/tmp/opencode-baseline-oracle.txt` existe y tiene contenido
  - [ ] Se registro la longitud en caracteres de cada respuesta baseline

  **QA Scenarios**:

  ```
  Scenario: Verificar backup completo
    Tool: Bash
    Steps:
      1. ls -la ~/opencode-config-backup-*.tar.gz
      2. tar tzf ~/opencode-config-backup-*.tar.gz | grep "opencode.jsonc"
    Expected Result: Backup existe y contiene opencode.jsonc
    Evidence: /tmp/opencode-qa-task1-backup.txt

  Scenario: Verificar git init
    Tool: Bash
    Steps:
      1. cd ~/.config/opencode && git log --oneline
    Expected Result: Muestra "pre-optimization baseline"
    Evidence: /tmp/opencode-qa-task1-git.txt

  Scenario: Verificar baseline measurements
    Tool: Bash
    Steps:
      1. wc -c /tmp/opencode-baseline-sisyphus.txt
      2. wc -c /tmp/opencode-baseline-oracle.txt
    Expected Result: Ambos archivos existen con contenido sustancial (>500 chars)
    Evidence: /tmp/opencode-qa-task1-baselines.txt
  ```

  **Evidence to Capture**:
  - [ ] Backup tar.gz
  - [ ] Git log output
  - [ ] Baseline files con tamanos

  **Commit**: YES
  - Message: `chore: backup and git init before optimization`
  - Files: Initial commit (all config files)

---

- [x] 2. Instalar plugin @al-bashkir/opencode-caveman

  **What to do**:
  - Verificar que el paquete npm existe:
    ```bash
    npm view @al-bashkir/opencode-caveman
    ```
  - Instalar en `~/.config/opencode/`:
    ```bash
    cd ~/.config/opencode && npm install @al-bashkir/opencode-caveman
    ```
  - Anadir a `opencode.jsonc` en el array `plugin`:
    ```jsonc
    {
      "plugin": ["oh-my-openagent", "@al-bashkir/opencode-caveman"]
    }
    ```
  - Configurar caveman en `oh-my-openagent.json`:
    ```jsonc
    {
      "caveman": {
        "defaultMode": "lite",
        "enabled": true,
        "autoActivate": true,
        "features": {
          "caveman": true,
          "commit": true,
          "review": true
        }
      }
    }
    ```
    (Nota: La config exacta depende de la API del plugin — ajustar segun docs del paquete)
  - Verificar que opencode carga sin errores:
    ```bash
    opencode --version 2>&1
    ```
  - Ejecutar prompt de prueba en sisyphus (mismo que baseline) y medir resultado:
    ```bash
    # Guardar en: /tmp/opencode-post-caveman-sisyphus.txt
    ```

  **Must NOT do**:
  - No anadir otros plugins
  - No cambiar orden de plugins (oh-my-openagent primero, caveman segundo)

  **Recommended Agent Profile**:
  - **Category**: `unspecified-low`

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Wave 1 - Secuencial (Task 2)
  - **Blocks**: Tasks 3, 4, 5, 6
  - **Blocked By**: Task 1

  **References**:
  - `~/.config/opencode/package.json` - Donde anadir dependencia
  - `~/.config/opencode/opencode.jsonc` - Plugin array a modificar
  - `~/.config/opencode/oh-my-openagent.json` - Posible config caveman
  - External: `https://github.com/al-bashkir/opencode-caveman` - Docs del plugin

  **Acceptance Criteria**:
  - [ ] `npm view @al-bashkir/opencode-caveman` retorna informacion del paquete
  - [ ] `node_modules/@al-bashkir/opencode-caveman/` existe
  - [ ] `opencode.jsonc` contiene `"@al-bashkir/opencode-caveman"` en plugin array
  - [ ] `opencode --version` no muestra errores de plugin
  - [ ] `/tmp/opencode-post-caveman-sisyphus.txt` es >= 30% mas corto que baseline

  **QA Scenarios**:

  ```
  Scenario: Verificar instalacion del plugin
    Tool: Bash
    Steps:
      1. ls ~/.config/opencode/node_modules/@al-bashkir/opencode-caveman/
    Expected Result: Directorio existe con contenido
    Evidence: /tmp/opencode-qa-task2-install.txt

  Scenario: Verificar config de plugin
    Tool: Bash
    Steps:
      1. cat ~/.config/opencode/opencode.jsonc | grep "caveman"
    Expected Result: Contiene "@al-bashkir/opencode-caveman"
    Evidence: /tmp/opencode-qa-task2-config.txt

  Scenario: Verificar reduccion de tokens
    Tool: Bash
    Steps:
      1. wc -c /tmp/opencode-baseline-sisyphus.txt
      2. wc -c /tmp/opencode-post-caveman-sisyphus.txt
      3. Calcular diferencia porcentual
    Expected Result: Reduccion >= 30%
    Evidence: /tmp/opencode-qa-task2-reduction.txt
  ```

  **Evidence to Capture**:
  - [ ] Plugin install verification
  - [ ] Config file content
  - [ ] Token reduction comparison

  **Commit**: YES
  - Message: `feat: install @al-bashkir/opencode-caveman plugin (lite, always-on)`
  - Files: `package.json`, `package-lock.json`, `opencode.jsonc`, `oh-my-openagent.json` (si aplica)

---

- [x] 3. Configurar textVerbosity en agentes

  **What to do**:
  - Anadir `textVerbosity` a los agentes en `oh-my-openagent.json`:
    - **`textVerbosity: "low"`**: sisyphus, sisyphus-junior, prometheus, librarian, explore, atlas, momus, metis, multimodal-looker
    - **`textVerbosity: "medium"`**: oracle (excluido de "low" para mantener precision)
    - **NO tocar**: comment_checker (ya tiene custom_prompt pidiendo brevedad en español)
    - **NO tocar**: Agentes de categorias (quick, deep, etc.) — se hereda del agente principal
  - Formato en JSON:
    ```jsonc
    "sisyphus": {
      "model": "opencode-go/deepseek-v4-flash",
      "textVerbosity": "low",
      "fallback_models": [...]
    }
    ```
  - Verificar que el JSON sigue siendo valido:
    ```bash
    python3 -m json.tool ~/.config/opencode/oh-my-openagent.json
    ```
  - Ejecutar prompt de prueba en sisyphus, oracle y explore

  **Must NOT do**:
  - No aplicar `textVerbosity: "low"` a oracle
  - No tocar `comment_checker`
  - No modificar `custom_prompt` de ningun agente
  - No cambiar modelos

  **Recommended Agent Profile**:
  - **Category**: `unspecified-low`

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Wave 1 - Secuencial (Task 3)
  - **Blocks**: Tasks 4, 5, 6
  - **Blocked By**: Task 2

  **References**:
  - `~/.config/opencode/oh-my-openagent.json` - Archivo a modificar
  - `https://github.com/code-yeongyu/oh-my-openagent/blob/dev/docs/reference/configuration.md` - Documentacion de textVerbosity

  **Acceptance Criteria**:
  - [ ] `oh-my-openagent.json` tiene `textVerbosity` en todos los agentes aplicables
  - [ ] Oracle tiene `textVerbosity: "medium"` (no "low")
  - [ ] comment_checker NO tiene `textVerbosity`
  - [ ] `python3 -m json.tool` valida el JSON sin errores
  - [ ] Sisyphus responde correctamente con output mas corto que baseline
  - [ ] Oracle responde correctamente con analisis completo (no truncado)

  **QA Scenarios**:

  ```
  Scenario: Verificar JSON valido
    Tool: Bash
    Steps:
      1. python3 -m json.tool ~/.config/opencode/oh-my-openagent.json
    Expected Result: No errors, JSON formateado correctamente
    Evidence: /tmp/opencode-qa-task3-json.txt

  Scenario: Verificar sisyphus con textVerbosity low
    Tool: Bash
    Steps:
      1. Ejecutar prompt estandar en sisyphus
      2. wc -c output
    Expected Result: Output existe, mas corto que baseline pero funcional
    Evidence: /tmp/opencode-qa-task3-sisyphus.txt

  Scenario: Verificar oracle con textVerbosity medium
    Tool: Bash
    Steps:
      1. Ejecutar prompt estandar en oracle
      2. wc -c output
    Expected Result: Output existe, mas completo que sisyphus pero mas corto que baseline
    Evidence: /tmp/opencode-qa-task3-oracle.txt

  Scenario: Verificar comment_checker no tocado
    Tool: Bash
    Steps:
      1. grep -A5 "comment_checker" ~/.config/opencode/oh-my-openagent.json
    Expected Result: No contiene "textVerbosity"
    Evidence: /tmp/opencode-qa-task3-comment-checker.txt
  ```

  **Evidence to Capture**:
  - [ ] JSON validation output
  - [ ] Sisyphus response
  - [ ] Oracle response

  **Commit**: YES
  - Message: `perf: add textVerbosity to agents (low for most, medium for oracle)`
  - Files: `oh-my-openagent.json`

---

- [x] 4. Activar aggressive_truncation + task_system

  **What to do**:
  - Anadir seccion `experimental` en `oh-my-openagent.json` (si no existe):
    ```jsonc
    {
      // ... existing config ...
      "experimental": {
        "aggressive_truncation": true,
        "task_system": true
      }
    }
    ```
  - Verificar posicion correcta en el JSON (al mismo nivel que `agents`, `categories`)
  - Validar JSON:
    ```bash
    python3 -m json.tool ~/.config/opencode/oh-my-openagent.json
    ```
  - Probar sesion multi-turno (5+ interacciones) para verificar que aggressive_truncation no rompe coherencia:
    ```bash
    # Session de prueba con sisyphus - 5 preguntas secuenciales
    ```
  - Verificar que sisyphus puede lanzar tareas en segundo plano (task_system)

  **Must NOT do**:
  - No anadir otras opciones experimentales no solicitadas
  - No modificar estructura existente del JSON

  **Recommended Agent Profile**:
  - **Category**: `unspecified-low`

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Wave 1 - Secuencial (Task 4)
  - **Blocks**: Tasks 5, 6
  - **Blocked By**: Task 3

  **References**:
  - `~/.config/opencode/oh-my-openagent.json` - Archivo a modificar
  - `https://github.com/code-yeongyu/oh-my-openagent/blob/dev/docs/reference/configuration.md#experimental` - Docs de experimental settings

  **Acceptance Criteria**:
  - [ ] `oh-my-openagent.json` contiene seccion `experimental` con ambas opciones en true
  - [ ] JSON validado sin errores
  - [ ] Sesion multi-turno (5+ turnos) se mantiene coherente
  - [ ] No hay errores de plugin al cargar

  **QA Scenarios**:

  ```
  Scenario: Verificar experimental config
    Tool: Bash
    Steps:
      1. grep -A5 "experimental" ~/.config/opencode/oh-my-openagent.json
    Expected Result: Muestra aggressive_truncation: true, task_system: true
    Evidence: /tmp/opencode-qa-task4-experimental.txt

  Scenario: Verificar multi-turno coherente
    Tool: Bash
    Steps:
      1. Ejecutar 5 prompts secuenciales con sisyphus
      2. Verificar que el contexto se mantiene (ej: preguntar "como se llama el proyecto?" en turno 3)
    Expected Result: Respuestas coherentes a traves de los turnos
    Evidence: /tmp/opencode-qa-task4-multiturn.txt
  ```

  **Evidence to Capture**:
  - [ ] Experimental section in config
  - [ ] Multi-turn conversation log

  **Commit**: YES
  - Message: `perf: enable experimental.aggressive_truncation and experimental.task_system`
  - Files: `oh-my-openagent.json`

---

- [x] 5. Limpiar config duplicada (~/.opencode/opencode.json)

  **What to do**:
  - Respaldar el archivo sospechoso:
    ```bash
    mv ~/.opencode/opencode.json ~/.opencode/opencode.json.bak
    ```
  - Ejecutar smoke test rapido para verificar que opencode sigue funcionando:
    ```bash
    opencode run --agent sisyphus "Hello, respond with one word: okay"
    # Expected: "okay"
    ```
  - Si el smoke test pasa, eliminar el .bak:
    ```bash
    rm ~/.opencode/opencode.json.bak
    ```
  - Si el smoke test falla, restaurar:
    ```bash
    mv ~/.opencode/opencode.json.bak ~/.opencode/opencode.json
    ```
  - Verificar que el directorio `~/.opencode/` queda limpio (solo bin/ y node_modules/)

  **Must NOT do**:
  - No eliminar el archivo sin hacer smoke test primero
  - No modificar otros archivos en `~/.opencode/`
  - No tocar `~/.opencode/bin/opencode` (el binario)

  **Recommended Agent Profile**:
  - **Category**: `unspecified-low`

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Wave 1 - Secuencial (Task 5)
  - **Blocks**: Task 6
  - **Blocked By**: Task 4

  **References**:
  - `~/.opencode/opencode.json` - Archivo a respaldar/eliminar

  **Acceptance Criteria**:
  - [ ] `~/.opencode/opencode.json.bak` existe (o fue eliminado tras verify exitoso)
  - [ ] Smoke test con sisyphus responde "okay"
  - [ ] `opencode --version` funciona sin errores despues de la limpieza

  **QA Scenarios**:

  ```
  Scenario: Verificar backup y smoke test
    Tool: Bash
    Steps:
      1. ls -la ~/.opencode/opencode.json*
      2. opencode run --agent sisyphus "Respond with one word: okay"
    Expected Result: opencode funciona, respuesta contiene "okay"
    Evidence: /tmp/opencode-qa-task5-smoke.txt
  ```

  **Evidence to Capture**:
  - [ ] Directory listing of ~/.opencode/
  - [ ] Smoke test output

  **Commit**: YES (groups with Task 6)
  - Message: `chore: cleanup redundant ~/.opencode/opencode.json config`
  - Files: `~/.opencode/opencode.json` (deleted/moved)

---

- [ ] 6. Smoke test final + comparacion de tokens

  **What to do**:
  - Ejecutar smoke test completo con los 3 agentes principales:
    - `sisyphus`: Prompt estandar de REST API (mismo que baseline)
    - `oracle`: Prompt estandar de REST API (mismo que baseline)
    - `explore`: "Find all TypeScript files in ~/.config/opencode/"
  - Guardar outputs en:
    - `/tmp/opencode-final-sisyphus.txt`
    - `/tmp/opencode-final-oracle.txt`
    - `/tmp/opencode-final-explore.txt`
  - Comparar tamanos con baseline:
    ```bash
    echo "=== SISYPHUS ==="
    echo "Baseline: $(wc -c < /tmp/opencode-baseline-sisyphus.txt) chars"
    echo "Final:    $(wc -c < /tmp/opencode-final-sisyphus.txt) chars"
    echo "Reduction: $(( 100 - ($(wc -c < /tmp/opencode-final-sisyphus.txt) * 100 / $(wc -c < /tmp/opencode-baseline-sisyphus.txt)) ))%"
    echo ""
    echo "=== ORACLE ==="
    echo "Baseline: $(wc -c < /tmp/opencode-baseline-oracle.txt) chars"
    echo "Final:    $(wc -c < /tmp/opencode-final-oracle.txt) chars"
    echo "Reduction: $(( 100 - ($(wc -c < /tmp/opencode-final-oracle.txt) * 100 / $(wc -c < /tmp/opencode-baseline-oracle.txt)) ))%"
    ```
  - Hacer commit final con todos los cambios:
    ```bash
    cd ~/.config/opencode && git add -A && git commit -m "optimization: caveman + textVerbosity + aggressive_truncation"
    ```

  **Must NOT do**:
  - No modificar nada mas (es solo verificacion)
  - No cambiar prompts respecto al baseline

  **Recommended Agent Profile**:
  - **Category**: `unspecified-low`

  **Parallelization**:
  - **Can Run In Parallel**: NO (ultimo paso)
  - **Parallel Group**: Wave 1 - Secuencial (Task 6)
  - **Blocks**: Final Verification Wave
  - **Blocked By**: Task 5

  **References**:
  - `/tmp/opencode-baseline-sisyphus.txt` - Baseline pre-cambio
  - `/tmp/opencode-baseline-oracle.txt` - Baseline pre-cambio

  **Acceptance Criteria**:
  - [ ] Sisyphus final output existe y es >= 30% mas corto que baseline
  - [ ] Oracle final output existe y es >= 15% mas corto que baseline
  - [ ] Explore responde correctamente
  - [ ] Todos los outputs son funcionales (codigo valido, analisis completo)
  - [ ] Git commit final registrado

  **QA Scenarios**:

  ```
  Scenario: Comparacion sisyphus baseline vs final
    Tool: Bash
    Steps:
      1. wc -c /tmp/opencode-baseline-sisyphus.txt
      2. wc -c /tmp/opencode-final-sisyphus.txt
      3. Calcular reduccion
    Expected Result: Reduccion >= 30%
    Evidence: /tmp/opencode-qa-task6-sisyphus.txt

  Scenario: Comparacion oracle baseline vs final
    Tool: Bash
    Steps:
      1. wc -c /tmp/opencode-baseline-oracle.txt
      2. wc -c /tmp/opencode-final-oracle.txt
      3. Calcular reduccion
    Expected Result: Reduccion >= 15% (oracle tiene textVerbosity medium, no low)
    Evidence: /tmp/opencode-qa-task6-oracle.txt

  Scenario: Explore funciona correctamente
    Tool: Bash
    Steps:
      1. cat /tmp/opencode-final-explore.txt
    Expected Result: Contiene resultados de archivos TypeScript encontrados
    Evidence: /tmp/opencode-qa-task6-explore.txt

  Scenario: Git log muestra todos los cambios
    Tool: Bash
    Steps:
      1. cd ~/.config/opencode && git log --oneline -5
    Expected Result: Muestra los 4 commits de optimizacion
    Evidence: /tmp/opencode-qa-task6-git.txt
  ```

  **Evidence to Capture**:
  - [ ] Final outputs para sisyphus, oracle, explore
  - [ ] Comparacion de tamanos
  - [ ] Git log

  **Commit**: YES
  - Message: `optimization: caveman + textVerbosity + aggressive_truncation + cleanup`
  - Files: All changed files

---

## Final Verification Wave (MANDATORY — after ALL implementation tasks)

> 2 review agents run in SEQUENCE. ALL must APPROVE.

- [ ] F1. **Plan Compliance Audit** — `oracle`
  Read the plan end-to-end. For each "Must Have": verify implementation exists (read file, curl endpoint, run command). For each "Must NOT Have": search config for forbidden patterns — reject with file:line if found. Check evidence files exist. Compare deliverables against plan.
  Output: `Must Have [N/N] | Must NOT Have [N/N] | Tasks [N/N] | VERDICT: APPROVE/REJECT`

- [ ] F2. **Validacion Final** — `unspecified-high`
  Verificar que todos los cambios estan aplicados:
  - `opencode.jsonc` tiene ambos plugins en orden correcto
  - `oh-my-openagent.json` tiene textVerbosity, experimental settings
  - Git log muestra todos los commits esperados (backup, caveman, textVerbosity, experimental, cleanup, final)
  - `/tmp/` tiene archivos de evidencia para cada paso
  Output: `[N/N] checks pass | VERDICT: APPROVE/REJECT`

---

## Commit Strategy

- **Task 1**: `chore: backup and git init before optimization` - all config files (initial commit)
- **Task 2**: `feat: install @al-bashkir/opencode-caveman plugin (lite, always-on)` - package.json, package-lock.json, opencode.jsonc, oh-my-openagent.json
- **Task 3**: `perf: add textVerbosity to agents (low for most, medium for oracle)` - oh-my-openagent.json
- **Task 4**: `perf: enable experimental.aggressive_truncation and experimental.task_system` - oh-my-openagent.json
- **Task 5**: Groups with Task 6
- **Task 6**: `optimization: caveman + textVerbosity + aggressive_truncation + cleanup` - all files

---

## Success Criteria

### Final Checklist
- [ ] Plugin caveman instalado y funcionando (nivel lite, siempre activo)
- [ ] textVerbosity configurado en todos los agentes aplicables
- [ ] aggressive_truncation y task_system activados
- [ ] Config duplicada ~/.opencode/opencode.json limpiada
- [ ] Reduccion de tokens >= 30% en sisyphus, >= 15% en oracle
- [ ] Git tracking activo con todos los cambios commiteados
- [ ] Backup disponible para rollback si es necesario
