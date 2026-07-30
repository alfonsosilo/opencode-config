# OpenCode: Mejoras Basadas en Harness Engineering

## TL;DR

> **Quick Summary**: Reforzar la configuracion de OpenCode con principios de harness engineering del curso de Walking Labs. El foco: sistema de estado (feature_list.json, PROGRESS.md, init.sh), rutina clock-in/clock-out, division del system prompt en niveles, contratos de sprint, WIP=1, rubricas de evaluacion, skills personalizadas, y E2E testing.
>
> **Deliverables**:
> - Plantillas de estado: `feature_list.json`, `PROGRESS.md`, `init.sh` en `.omo/templates/`
> - Restriccion WIP=1 en prompt de sisyphus
> - System prompt dividido en `docs/` por niveles (router AGENTS.md + topic docs)
> - Skills: `clock-in`, `clock-out`, `init-project`, `feature-cycle`, `cleanup-session`
> - Contratos de sprint (seccion 7 en plantilla de delegacion)
> - Rubricas de evaluacion para Oracle
> - Integracion de E2E testing en pipeline de verificacion
> - Documentacion de comportamiento especifico por modelo
>
> **Estimated Effort**: Large (multi-fase, multi-sesion)
> **Parallel Execution**: SI — las fases son mayoritariamente independientes dentro de cada ola
> **Critical Path**: Estado (1-4) → Clock-in/out (5-10) → System prompt (5-10) → Skills (11-16) → E2E (11-16) → Modelos (17-18)

---

## Context

### Original Request

El usuario quiere aplicar los principios de harness engineering del curso https://github.com/walkinglabs/learn-harness-engineering a su configuracion de OpenCode + oh-my-openagent. Se realizo una auditoria completa comparando la configuracion actual contra las ensenanzas del curso, identificando 12 areas de mejora ordenadas por prioridad.

### Estado Actual de la Configuracion

**Fortalezas**:
- 14 agentes especializados con modelos optimizados por dominio
- Flujo SDD completo (Metis → spec-writer → Momus → Sisyphus → Oracle)
- Optimizaciones de tokens aplicadas (caveman, textVerbosity, aggressive_truncation)
- Team mode habilitado para ejecucion paralela
- 5 skills de usuario + skills built-in de oh-my-openagent
- 1 MCP: codebase-memory-mcp

**Debilidades identificadas**:
- Sin sistema de estado persistente entre sesiones (feature_list.json, PROGRESS.md, init.sh)
- System prompt de sisyphus es una enciclopedia (instruction bloat)
- Sin rutina estandarizada de entrada/salida de sesion
- Sin enforcement de WIP=1
- Sin contratos de sprint en delegacion
- Sin testing E2E automatizado
- Sin rubricas de evaluacion cuantificables
- Sin skills personalizadas para flujos de proyecto
- Solo 1 MCP (sin conectores externos: DB, tareas, CI/CD)
- Sin documentacion de comportamiento especifico por modelo

### Decisiones del Usuario

- **GitHub MCP**: NO se incluye. El usuario requiere que todas las subidas a GitHub sean revisadas por un humano.
- **Idioma**: El plan y las configuraciones se escriben en espanol (idioma del usuario)
- **Alcance**: Todos los cambios aplican a la configuracion global (`~/.config/opencode/`), no a proyectos individuales
- **Orden**: Implementar por fases de prioridad (Fase A → Fase B → Fase C → Fase D)

---

## Work Objectives

### Core Objective

Transformar la configuracion de OpenCode de "productiva en una sola sesion" a "fiable a traves de multiples sesiones" aplicando principios de harness engineering: estado persistente, rutinas de sesion, division de instrucciones, y verificacion multicapa.

### Concrete Deliverables

1. `.omo/templates/feature_list.json` — Plantilla de cola de features con estado, verificacion y dependencias
2. `.omo/templates/PROGRESS.md` — Plantilla de progreso con log de sesion
3. `.omo/templates/init.sh` — Plantilla de inicializacion (setup + verify)
4. `docs/guia-delegacion.md` — Reglas de delegacion extraidas del system prompt
5. `docs/phase-gates.md` — Puertas de verificacion (Intent Gate, Codebase Assessment, etc.)
6. `docs/uso-herramientas.md` — Reglas de seleccion de herramientas y ejecucion paralela
7. `docs/uso-oracle.md` — Cuando y como consultar a Oracle, Metis, Momus
8. `docs/flujo-sdd.md` — Pipeline SDD completo
9. `docs/anti-patrones.md` — Lista de anti-patrones y como evitarlos
10. Skills: `clock-in.md`, `clock-out.md`, `init-project.md`, `feature-cycle.md`, `cleanup-session.md`
11. `oh-my-openagent.json` actualizado con WIP=1, contratos de sprint, rubricas
12. `.omo/evaluator-rubric.md` — Rubrica de puntuacion para Oracle
13. `.omo/model-behavior.md` — Documentacion de comportamiento por modelo

### Must Have

- [ ] Plantillas de estado creadas en `.omo/templates/`
- [ ] WIP=1 aplicado en prompt_append de sisyphus
- [ ] System prompt dividido: AGENTS.md router + docs/ topicos
- [ ] Skills de clock-in/clock-out funcionales
- [ ] Contratos de sprint en plantilla de delegacion
- [ ] Rubricas de evaluacion documentadas
- [ ] Skills de proyecto (init-project, feature-cycle, cleanup-session) creadas
- [ ] Integracion E2E documentada en pipeline de verificacion
- [ ] Documentacion de comportamiento por modelo

### Must NOT Have (Guardrails)

- No instalar GitHub MCP
- No modificar modelos asignados a agentes o categorias
- No cambiar la estructura del flujo SDD existente
- No eliminar agentes existentes
- No modificar `tui.json`
- No tocar configuraciones de proyecto individuales
- No desactivar optimizaciones existentes (caveman, textVerbosity, aggressive_truncation)

---

## Verification Strategy

> **ZERO HUMAN INTERVENTION** donde sea posible — verificacion ejecutada por el agente cuando aplica.
> Cambios de documentacion y configuracion se verifican manualmente (validacion de contenido).

### Test Decision
- **Infrastructure exists**: N/A (es mayoritariamente documentacion y configuracion)
- **Automated tests**: Skills pueden tener tests de validacion (el skill se carga sin errores)
- **Agent-Executed QA**: SI — para cambios en prompts y skills
- **Human QA**: SI — para revision de contenido de docs y plantillas

### QA Policy

Cada fase incluye verificacion:
- **Fase A (Estado, tareas 1-4)**: Plantillas creadas, JSON valido, init.sh ejecutable
- **Fase B (Sesion + Prompt, tareas 5-10)**: Skills cargan sin errores, sisyphus respeta WIP=1, docs enlazables
- **Fase C (Skills + Verificacion, tareas 11-16)**: Skills ejecutan su flujo completo, Oracle usa rubricas, E2E documentado
- **Fase D (Optimizacion, tareas 17-18)**: Tests A/B ejecutados, resultados documentados

---

## Execution Strategy

### Parallel Execution Waves

> Las fases tienen dependencias internas pero las olas son mayoritariamente paralelizables.
> La Fase A debe completarse antes que la B. La B antes que la C. La C antes que la D.

```
Fase A — ESTADO (Bloqueante para todo lo demas):
├── 1. Crear plantilla feature_list.json
├── 2. Crear plantilla PROGRESS.md
├── 3. Crear plantilla init.sh
└── 4. Documentar uso de plantillas en AGENTS.md

Fase B — SESION + PROMPT (Depende de Fase A, tareas 5-6 paralelizables con 7-10):
├── 5. WIP=1 en prompt_append de sisyphus
├── 6. Contratos de sprint en plantilla de delegacion
├── 7. Dividir system prompt en docs/ por niveles
├── 8. Crear AGENTS.md router (version reducida)
├── 9. Crear skill clock-in
└── 10. Crear skill clock-out

Fase C — SKILLS + VERIFICACION (Depende de Fase B, tareas paralelizables):
├── 11. Crear rubricas de evaluacion para Oracle
├── 12. Crear skill init-project
├── 13. Crear skill feature-cycle
├── 14. Crear skill cleanup-session
├── 15. Documentar integracion E2E en pipeline
└── 16. Evaluar MCPs adicionales (DB, tareas, Playwright)

Fase D — OPTIMIZACION (Depende de Fase C):
├── 17. Tests A/B por modelo
└── 18. Documentar comportamiento por modelo

Wave FINAL (Despues de todo — revision):
├── F1. Compliance audit (oracle)
└── F2. Smoke test de todas las skills
```

### Dependency Matrix
- **1-4**: Sin dependencias → Fase B (tareas 5-10)
- **5**: 1-4 → Paralelo con 6
- **6**: 1-4 → Paralelo con 5
- **7**: 1-4 → Paralelo con 5-6, 8-10
- **8**: 1-4, necesita 7 → Paralelo con 5-6, 9-10
- **9-10**: 1-4 → Paralelo entre si y con 5-8
- **11-16**: Fase B completa → Totalmente paralelizables entre si
- **17**: Fase C completa → 18
- **18**: 17 completado
- **F1-F2**: Fase D completa → Paralelo entre si

### Agent Dispatch Summary
- **Tareas 1-4**: `unspecified-low` (creacion de plantillas)
- **Tareas 5-6**: `unspecified-low` (cambios de configuracion)
- **Tareas 7-8**: `writing` (documentacion)
- **Tareas 9-10**: `deep` (skills complejas)
- **Tareas 11, 15-16**: `deep` (investigacion + documentacion)
- **Tareas 12-14**: `deep` (skills complejas)
- **Tarea 17**: `deep` (benchmarking)
- **Tarea 18**: `writing` (documentacion)
- **F1**: `oracle`
- **F2**: `unspecified-high`

---

## TODOs

---

### Fase A — Sistema de Estado (tareas 1-4)

- [ ] 1. Crear plantilla feature_list.json

  **What to do**:
  - Crear directorio `.omo/templates/` si no existe
  - Crear `feature_list.json` con estructura:
    ```json
    {
      "project": "nombre-del-proyecto",
      "last_updated": "YYYY-MM-DD",
      "features": [
        {
          "id": "F01",
          "title": "Nombre del feature",
          "status": "pending | active | completed | blocked",
          "priority": 1,
          "verification": "comando que demuestra completitud",
          "dependencies": ["F00"],
          "spec": "specs/nombre-spec.md",
          "assigned_session": null,
          "started_at": null,
          "completed_at": null,
          "notes": ""
        }
      ]
    }
    ```
  - Incluir campos: id, title, status, priority, verification, dependencies, spec, timestamps
  - Documentar estados validos: pending, active, completed, blocked
  - Validar que es JSON valido con `python3 -m json.tool`

  **Must NOT do**:
  - No crear features de ejemplo que puedan confundir

  **Acceptance Criteria**:
  - [ ] `.omo/templates/feature_list.json` existe
  - [ ] JSON valido sin errores de sintaxis
  - [ ] Todos los campos documentados con comentarios
  - [ ] Estados validos claramente definidos

  **Commit**: `feat: add feature_list.json template for state management`

---

- [ ] 2. Crear plantilla PROGRESS.md

  **What to do**:
  - Crear `PROGRESS.md` en `.omo/templates/`
  - Estructura:
    ```markdown
    # PROGRESS — [Nombre del Proyecto]

    **Ultima sesion:** YYYY-MM-DD | **Sesion ID:** xxx
    **Estado general:** [saludable | atencion | critico]

    ## Feature Actual
    - **ID:** F01 — [Titulo]
    - **Estado:** [active]
    - **Verificacion:** [comando]
    - **Bloqueantes:** [ninguno | F00]

    ## Log de Sesiones
    | Fecha | Sesion | Feature | Que se hizo | Build | Tests | Notas |
    |-------|--------|---------|-------------|-------|-------|-------|
    | ...   | ...    | ...     | ...         | ✅    | ✅    | ...   |

    ## Problemas Conocidos
    - [ ] [Descripcion del problema] — [plan de accion]

    ## Proxima Sesion
    1. [Proxima accion prioritaria]
    2. [Segunda accion]
    ```

  **Must NOT do**:
  - No incluir datos reales de proyectos

  **Acceptance Criteria**:
  - [ ] `.omo/templates/PROGRESS.md` existe
  - [ ] Incluye secciones: Feature Actual, Log de Sesiones, Problemas Conocidos, Proxima Sesion
  - [ ] Formato de tabla para log de sesiones

  **Commit**: `feat: add PROGRESS.md template for session continuity`

---

- [ ] 3. Crear plantilla init.sh

  **What to do**:
  - Crear `init.sh` en `.omo/templates/`
  - Debe ser ejecutable y contener el flujo estandar de inicializacion
  - Estructura:
    ```bash
    #!/usr/bin/env bash
    set -euo pipefail

    echo "=== Init: $(date) ==="

    # 1. Verificar dependencias
    echo "[1/4] Verificando dependencias..."
    # command -v node || echo "Falta node" && exit 1

    # 2. Instalar dependencias
    echo "[2/4] Instalando dependencias..."
    # npm ci  # o pip install -r requirements.txt

    # 3. Setup (migraciones, config, etc.)
    echo "[3/4] Configurando entorno..."
    # cp .env.example .env  # si no existe

    # 4. Verificar
    echo "[4/4] Ejecutando verificacion..."
    # npm test  # o pytest, go test

    echo "=== Init completado exitosamente ==="
    ```
  - Hacer ejecutable: `chmod +x .omo/templates/init.sh`

  **Must NOT do**:
  - No incluir comandos destructivos
  - No incluir comandos especificos de un proyecto real

  **Acceptance Criteria**:
  - [ ] `.omo/templates/init.sh` existe y es ejecutable
  - [ ] `bash .omo/templates/init.sh` no tiene errores de sintaxis
  - [ ] Incluye verificacion de dependencias, instalacion, setup y verificacion

  **Commit**: `feat: add init.sh template for environment bootstrap`

---

- [ ] 4. Documentar uso de plantillas en AGENTS.md

  **What to do**:
  - Actualizar `AGENTS.md` para incluir seccion de estado
  - Anadir al inicio (despues del bloque codebase-memory-mcp):
    ```markdown
    ## Harness de Estado (OBLIGATORIO al iniciar sesion)

    Antes de trabajar en cualquier feature, verifica que existan estos archivos
    en el proyecto. Si no existen, crealos usando las plantillas en `.omo/templates/`:

    1. `PROGRESS.md` — Leer primero. Contiene el estado actual y el log de sesiones.
    2. `feature_list.json` — Leer segundo. Define la cola de features con prioridades.
    3. `init.sh` — Ejecutar. Configura el entorno y ejecuta verificacion baseline.

    Si `init.sh` falla, ARREGLA EL BASELINE antes de tocar features.
    ```

  **Must NOT do**:
  - No eliminar el bloque codebase-memory-mcp existente
  - No hacer el AGENTS.md mas largo de 50 lineas

  **Acceptance Criteria**:
  - [ ] AGENTS.md incluye seccion "Harness de Estado"
  - [ ] Las instrucciones son claras y accionables
  - [ ] AGENTS.md no supera las 50 lineas

  **Commit**: `feat: add state harness instructions to AGENTS.md`

---

### Fase B — Sesion + System Prompt (tareas 5-10)

- [ ] 5. Aplicar WIP=1 en prompt_append de sisyphus

  **What to do**:
  - Anadir al `prompt_append` de sisyphus en `oh-my-openagent.json`:
    ```
    ## Restriccion WIP (MUST)
    - Solo UN feature/tarea en estado "active" a la vez.
    - La delegacion paralela es SOLO para sub-tareas del MISMO feature.
    - Antes de empezar un nuevo feature, el actual DEBE estar verificado completo.
    - VCR (Verified Completion Rate) = features_verificados / features_activados.
      Si VCR < 1.0, NO actives nuevos features.
    ```
  - Verificar que el JSON sigue siendo valido

  **Must NOT do**:
  - No eliminar el prompt_append existente (caveman + SDD)
  - No modificar otros agentes

  **Acceptance Criteria**:
  - [ ] prompt_append de sisyphus incluye restriccion WIP
  - [ ] JSON validado sin errores
  - [ ] En sesion de prueba, sisyphus rechaza empezar un segundo feature antes de verificar el primero

  **Commit**: `feat: add WIP=1 constraint to sisyphus prompt`

---

- [ ] 6. Anadir contratos de sprint a plantilla de delegacion

  **What to do**:
  - Anadir al `prompt_append` de sisyphus la seccion 7 en la estructura de delegacion:
    ```
    7. CONTRACT:
       - Scope: [exactamente que se construira — no mas, no menos]
       - Verification: [como demostrar que esta completado — comando especifico]
       - Exclusions: [que NO tocar aunque sea tentador — archivos, patrones, funcionalidades]
    ```
  - Si la estructura de delegacion esta en un doc aparte (post tarea 7), actualizar ese doc

  **Must NOT do**:
  - No cambiar las 6 secciones existentes de la plantilla de delegacion

  **Acceptance Criteria**:
  - [ ] Plantilla de delegacion incluye seccion 7 (CONTRACT)
  - [ ] Los campos Scope, Verification, Exclusions estan definidos

  **Commit**: `feat: add sprint contracts to delegation template`

---

- [ ] 7. Dividir system prompt en docs/ por niveles

  **What to do**:
  - Crear directorio `docs/` en `~/.config/opencode/`
  - Extraer del system prompt de sisyphus y crear estos archivos:
    - `docs/guia-delegacion.md` — Fase 2A-2B (exploracion, delegacion, categorias, skills, anti-duplicacion)
    - `docs/phase-gates.md` — Fase 0-1 (Intent Gate, clasificacion, verificacion, validacion)
    - `docs/uso-herramientas.md` — Reglas de herramientas, ejecucion paralela, restricciones
    - `docs/uso-oracle.md` — Oracle, Metis, Momus: cuando y como usar cada uno
    - `docs/flujo-sdd.md` — Pipeline SDD completo (extraer de sdd-guide-for-team.md)
    - `docs/anti-patrones.md` — Todos los anti-patrones y hard blocks del system prompt
  - Cada doc debe tener 50-200 lineas maximo
  - Usar formato markdown con headings claros

  **Must NOT do**:
  - No perder contenido — todo lo que esta en el system prompt debe estar en algun doc
  - No crear docs de mas de 200 lineas
  - No cambiar la semantica de las reglas al extraerlas

  **Recommended Agent Profile**:
  - **Category**: `writing`

  **Acceptance Criteria**:
  - [ ] Directorio `docs/` creado con 6 archivos
  - [ ] Cada archivo tiene entre 50-200 lineas
  - [ ] Todo el contenido del system prompt original esta cubierto en los docs
  - [ ] Formato markdown valido y legible

  **Commit**: `refactor: split system prompt into tiered topic docs`

---

- [ ] 8. Crear AGENTS.md router (version reducida)

  **What to do**:
  - Reescribir AGENTS.md como router de maximo 150 lineas
  - Estructura:
    ```markdown
    # Sisyphus — OpenCode Agent Configuration

    ## Proposito
    Orquestador principal de OpenCode. Planifica, delega y supervisa.

    ## Comandos de Arranque
    - Ante cualquier tarea no trivial: `TaskCreate` para planificar
    - Ante ambiguedad: preguntar, no adivinar
    - Ante features nuevos: sugerir SDD (spec primero)

    ## Restricciones Duras (MUST/MUST NOT)
    1. WIP=1: Solo UN feature activo a la vez
    2. NUNCA suprimir errores de tipo (as any, @ts-ignore)
    3. NUNCA commit sin autorizacion explicita
    4. NUNCA dejar codigo en estado roto tras fallos
    5. SIEMPRE verificar con lsp_diagnostics tras cada cambio
    6. SIEMPRE delegar trabajo visual a visual-engineering
    7. SIEMPRE preferir delegacion sobre implementacion directa
    8. NUNCA especular sobre codigo no leido
    9. SIEMPRE ejecutar verificacion antes de declarar completitud
    10. NUNCA usar background_cancel(all=true)

    ## Documentacion por Topico (cargar bajo demanda)
    - Delegacion: `docs/guia-delegacion.md`
    - Verificacion: `docs/phase-gates.md`
    - Herramientas: `docs/uso-herramientas.md`
    - Oracle/Metis/Momus: `docs/uso-oracle.md`
    - SDD: `docs/flujo-sdd.md`
    - Anti-patrones: `docs/anti-patrones.md`

    ## Estado de Sesion
    - Leer PROGRESS.md al iniciar
    - Leer feature_list.json para cola de tareas
    - Ejecutar init.sh para verificacion baseline
    ```
  - El prompt_append de sisyphus en oh-my-openagent.json debe referenciar estos docs
  - Mantener el bloque codebase-memory-mcp

  **Must NOT do**:
  - No superar 150 lineas
  - No perder las restricciones duras esenciales
  - No eliminar el prompt_append existente (caveman + SDD + WIP) en oh-my-openagent.json

  **Recommended Agent Profile**:
  - **Category**: `writing`

  **Acceptance Criteria**:
  - [ ] AGENTS.md tiene maximo 150 lineas
  - [ ] Incluye secciones: Proposito, Comandos de Arranque, Restricciones Duras, Docs por Topico, Estado de Sesion
  - [ ] Todas las restricciones duras esenciales estan presentes
  - [ ] Los enlaces a docs/ son correctos

  **Commit**: `refactor: create AGENTS.md router with progressive disclosure`

---

- [ ] 9. Crear skill clock-in

  **What to do**:
  - Crear skill `clock-in` como archivo markdown en `~/.config/opencode/agents/` o via el sistema de skills
  - La skill debe ejecutar esta rutina al inicio de cada sesion:
    1. `pwd` — confirmar raiz del repo
    2. Leer `PROGRESS.md`
    3. Leer `feature_list.json`
    4. Revisar `git log --oneline -5`
    5. Ejecutar `./init.sh`
    6. Si init.sh falla → arreglar baseline antes de continuar
    7. Seleccionar el feature no terminado de mayor prioridad
    8. Reportar: "Sesion lista. Feature activo: F0X — [titulo]. VCR: X/X"

  **Must NOT do**:
  - No empezar a trabajar en features hasta completar la rutina
  - No modificar archivos durante clock-in

  **Recommended Agent Profile**:
  - **Category**: `deep`
  - **Skills**: [`git-master`]

  **Acceptance Criteria**:
  - [ ] Skill clock-in existe y es invocable
  - [ ] Ejecuta los 8 pasos en orden
  - [ ] Detecta init.sh fallido y bloquea el inicio de trabajo

  **Commit**: `feat: add clock-in skill for session startup routine`

---

- [ ] 10. Crear skill clock-out

  **What to do**:
  - Crear skill `clock-out` con rutina de cierre de sesion:
    1. Actualizar `PROGRESS.md` con lo hecho en esta sesion
    2. Ejecutar verificacion completa (tests + lint + typecheck)
    3. Si el contexto esta al 80%+, escribir `session-handoff.md`
    4. Hacer commit de codigo funcional
    5. Chequeo de estado limpio:
       - Sin codigo de debug (`console.log`, `print(...)`, `TODO`)
       - Sin archivos temporales (`*.tmp`, `*.bak`)
       - Sin codigo comentado
    6. Actualizar `feature_list.json` (marcar completados)
    7. Reportar: "Sesion cerrada. Build: ✅ | Tests: ✅ | Proximo: F0X"

  **Must NOT do**:
  - No hacer force push
  - No commitear secrets o archivos de config personal

  **Recommended Agent Profile**:
  - **Category**: `deep`
  - **Skills**: [`git-master`]

  **Acceptance Criteria**:
  - [ ] Skill clock-out existe y es invocable
  - [ ] Ejecuta los 7 pasos en orden
  - [ ] Detecta estado sucio y lo reporta

  **Commit**: `feat: add clock-out skill for session cleanup routine`

---

### Fase C — Skills + Verificacion (tareas 11-16)

- [ ] 11. Crear rubricas de evaluacion para Oracle

  **What to do**:
  - Crear `.omo/evaluator-rubric.md` con scoring A-D:
    ```markdown
    # Rubrica de Evaluacion

    Usar esta rubrica para puntuar implementaciones de forma objetiva.
    Cada dimension se puntua A (100%), B (75%), C (50%), D (25%).

    | Dimension | A (100%) | B (75%) | C (50%) | D (25%) |
    |-----------|----------|---------|---------|----------|
    | Correccion | Todos los tests pasan. Edge cases cubiertos. | Flujo principal pasa. Edge cases parciales. | Solo happy path funciona. | Build falla o errores en runtime. |
    | Arquitectura | Sigue todos los patrones del proyecto. Sin violaciones de capa. | Sigue la mayoria de patrones. Desviaciones menores documentadas. | Violaciones obvias de patrones establecidos. | Rompe la arquitectura (dependencias circulares, capas mezcladas). |
    | Cobertura tests | Happy path + edge cases + error cases. | Solo flujo principal. | Esqueleto de tests sin asserts significativos. | Sin tests. |
    | Calidad codigo | Limpio, idiomatico, sin deuda tecnica. | Problemas menores (nombres poco claros, formato). | Varios problemas (funciones largas, duplicacion). | Anti-patrones claros (god functions, magic numbers). |
    | Scope | Exactamente lo pedido. Nada mas, nada menos. | Scope respetado. Un extra menor no solicitado. | Scope creep evidente (features no pedidas). | Fuera de scope — construyo algo distinto. |
    | Verificabilidad | Cada criterio de aceptacion tiene un comando de verificacion. | Mayoria de criterios verificables. | Algunos criterios verificables. | Sin criterios de verificacion. |

    ## Veredicto
    - **APPROVE**: Minimo B en Correccion y Scope, minimo C en el resto
    - **REVISE**: Alguna dimension con D
    - **REJECT**: Correccion o Scope con D
    ```
  - Anadir al prompt_append de Oracle la instruccion de usar esta rubrica

  **Must NOT do**:
  - No hacer la rubrica demasiado compleja (max 8 dimensiones)

  **Acceptance Criteria**:
  - [ ] `.omo/evaluator-rubric.md` existe
  - [ ] 6 dimensiones definidas con criterios A-D
  - [ ] Veredictos claros (APPROVE/REVISE/REJECT)
  - [ ] Oracle instruido para usar la rubrica

  **Commit**: `feat: add evaluator rubric for objective quality scoring`

---

- [ ] 12. Crear skill init-project

  **What to do**:
  - Crear skill que, al ejecutarse en un proyecto nuevo, configure el harness completo:
    1. Copiar plantillas de `.omo/templates/` al directorio raiz del proyecto:
       - `feature_list.json`
       - `PROGRESS.md`
       - `init.sh`
    2. Personalizar `init.sh` con los comandos reales del proyecto
    3. Ejecutar `chmod +x init.sh`
    4. Ejecutar `./init.sh` para verificar que funciona
    5. Si es proyecto git, hacer commit inicial del harness
    6. Ejecutar `/init-deep` si el proyecto tiene codigo

  **Recommended Agent Profile**:
  - **Category**: `deep`
  - **Skills**: [`git-master`]

  **Acceptance Criteria**:
  - [ ] Skill init-project existe
  - [ ] Copia y personaliza las 3 plantillas
  - [ ] Verifica que init.sh funciona antes de declarar exito

  **Commit**: `feat: add init-project skill for harness bootstrap`

---

- [ ] 13. Crear skill feature-cycle

  **What to do**:
  - Crear skill que gestione el ciclo completo de un feature:
    1. `clock-in` (rutina de inicio)
    2. Seleccionar feature de mayor prioridad en `feature_list.json`
    3. Si tiene spec → leerla. Si no → sugerir SDD primero
    4. Marcar feature como `active` en feature_list.json
    5. Implementar siguiendo contrato de sprint
    6. Verificar con comando del feature
    7. Si pasa → marcar `completed`. Si no → iterar (max 3 intentos, luego pedir ayuda)
    8. `clock-out` (rutina de cierre)

  **Recommended Agent Profile**:
  - **Category**: `deep`

  **Acceptance Criteria**:
  - [ ] Skill feature-cycle existe
  - [ ] Integra clock-in y clock-out
  - [ ] Respeta WIP=1 (solo un feature activo)
  - [ ] Maximo 3 intentos de fix antes de escalar

  **Commit**: `feat: add feature-cycle skill for end-to-end feature workflow`

---

- [ ] 14. Crear skill cleanup-session

  **What to do**:
  - Crear skill de limpieza post-sesion que:
    1. Buscar y eliminar artefactos temporales (`*.tmp`, `*.bak`, `*~`)
    2. Buscar codigo de debug (`console.log`, `debugger`, `print(`, `TODO`)
    3. Buscar codigo comentado en bloques grandes (>5 lineas)
    4. Ejecutar `lsp_diagnostics` en todo el proyecto
    5. Ejecutar suite de tests completa
    6. Reportar: "Limpieza completada. N artefactos eliminados. Diagnostics: X errors. Tests: Y/Z pasan."

  **Must NOT do**:
  - No eliminar `TODO` en comentarios de documentacion legitimos
  - No modificar codigo fuente — solo reportar hallazgos de debug code

  **Recommended Agent Profile**:
  - **Category**: `deep`

  **Acceptance Criteria**:
  - [ ] Skill cleanup-session existe
  - [ ] Detecta artefactos temporales y codigo de debug
  - [ ] Reporta diagnosticos y resultados de tests

  **Commit**: `feat: add cleanup-session skill for post-session hygiene`

---

- [ ] 15. Documentar integracion E2E en pipeline de verificacion

  **What to do**:
  - Crear `.omo/e2e-testing-guide.md` documentando:
    - Cuando usar E2E vs unit tests
    - Como integrar Playwright (skill existente) en el flujo de verificacion
    - Patron: unit tests → integration tests → E2E smoke tests → Oracle review
    - Ejemplo de test E2E minimo para API (curl + jq)
    - Ejemplo de test E2E para frontend (Playwright script)
  - Actualizar `docs/phase-gates.md` para incluir E2E como puerta
  - Actualizar spec-writer para que los criterios de aceptacion incluyan verificacion E2E donde aplique

  **Must NOT do**:
  - No requerir E2E para cambios triviales (tipos, config)

  **Acceptance Criteria**:
  - [ ] `.omo/e2e-testing-guide.md` existe
  - [ ] Pipeline de verificacion documentado con E2E
  - [ ] Spec-writer considera E2E en criterios de aceptacion

  **Commit**: `feat: document E2E testing integration in verification pipeline`

---

- [ ] 16. Evaluar MCPs adicionales

  **What to do**:
  - Investigar y documentar MCPs utiles segun el curso:
    - **Database MCP**: Para verificar estado de datos, ejecutar migraciones
    - **Linear/Jira MCP**: Si el usuario usa gestor de tareas
    - **Playwright MCP**: Separado de la skill, para testing automatizado
    - **Slack MCP**: Para notificaciones de completitud/fallos
  - Para cada uno, documentar: proposito, costo de integracion, beneficio esperado
  - NO instalar — solo evaluar y recomendar
  - Guardar en `.omo/mcp-evaluation.md`

  **Must NOT do**:
  - No instalar ningun MCP sin aprobacion explicita
  - No evaluar GitHub MCP (descartado por el usuario)

  **Recommended Agent Profile**:
  - **Category**: `deep`

  **Acceptance Criteria**:
  - [ ] `.omo/mcp-evaluation.md` existe
  - [ ] Cada MCP evaluado con proposito, costo, beneficio
  - [ ] Recomendaciones claras priorizadas

  **Commit**: `docs: evaluate additional MCP options for extended capabilities`

---

### Fase D — Optimizacion por Modelo (tareas 17-18)

- [ ] 17. Ejecutar tests A/B por modelo

  **What to do**:
  - Disenar un test A/B estandarizado:
    - Misma tarea (ej: "Implementa un endpoint GET /api/health que devuelva `{status: 'ok'}`")
    - Mismo prompt, mismo proyecto
    - Ejecutar con cada modelo: deepseek-v4-pro, qwen3.7-max, deepseek-v4-flash, kimi-k2.6, minimax-m3
  - Medir para cada modelo:
    - Tiempo hasta primera respuesta
    - Longitud de respuesta (tokens)
    - Calidad (usando rubrica de la tarea 11)
    - Comportamiento en sesiones largas (5+ turnos)
    - ¿Muestra "rushed finish" al acercarse al limite de contexto?
  - Guardar resultados en `.omo/model-benchmarks.json`

  **Must NOT do**:
  - No usar tareas reales de produccion como test

  **Recommended Agent Profile**:
  - **Category**: `deep`

  **Acceptance Criteria**:
  - [ ] Tests ejecutados para los 5 modelos principales
  - [ ] `.omo/model-benchmarks.json` existe con resultados
  - [ ] Cada modelo tiene puntuacion en las 5 metricas

  **Commit**: `perf: run A/B tests across models for behavior benchmarking`

---

- [ ] 18. Documentar comportamiento por modelo

  **What to do**:
  - Crear `.omo/model-behavior.md` basado en resultados de la tarea 17:
    ```markdown
    # Comportamiento por Modelo

    ## deepseek-v4-pro (sisyphus, oracle, deep, metis, momus)
    - Contexto largo: [resultado]
    - Rushed finish: [si/no/condiciones]
    - Calidad en tareas complejas: [A/B/C/D]
    - Recomendado para: [tipo de tareas]

    ## qwen3.7-max (oracle, prometheus, spec-writer)
    - ...

    ## deepseek-v4-flash (quick, explore, librarian, sisyphus-junior)
    - ...
    ```
  - Incluir recomendaciones de configuracion especifica por modelo:
    - Que modelos necesitan `aggressive_truncation`
    - Que modelos necesitan context reset vs compaction
    - Que modelos son mejores para tareas cortas vs largas

  **Must NOT do**:
  - No hacer afirmaciones sin datos de la tarea 17 que las respalden

  **Recommended Agent Profile**:
  - **Category**: `writing`

  **Acceptance Criteria**:
  - [ ] `.omo/model-behavior.md` existe
  - [ ] Cada modelo documentado con hallazgos de la tarea 17
  - [ ] Recomendaciones de configuracion especificas por modelo

  **Commit**: `docs: document model-specific behavior and configuration recommendations`

---

## Final Verification Wave (MANDATORY — after ALL implementation tasks)

> 2 review agents run in PARALLEL. ALL must APPROVE.

- [ ] F1. **Plan Compliance Audit** — `oracle`
  Leer el plan de principio a fin. Para cada "Must Have": verificar que la implementacion existe (leer archivo, validar). Para cada "Must NOT Have": buscar patrones prohibidos — rechazar con archivo:linea si se encuentra.
  Output: `Must Have [N/N] | Must NOT Have [N/N] | Tasks [N/N] | VERDICT: APPROVE/REJECT`

- [ ] F2. **Smoke Test de Skills** — `unspecified-high`
  Verificar que todas las skills creadas cargan sin errores y ejecutan su flujo basico:
  - `clock-in` — ejecuta rutina de inicio sin errores
  - `clock-out` — ejecuta rutina de cierre sin errores
  - `init-project` — crea harness en proyecto de prueba
  - `feature-cycle` — ejecuta ciclo completo en feature de prueba
  - `cleanup-session` — detecta artefactos correctamente
  Output: `Skills [N/N] cargan | [N/N] ejecutan | VERDICT: APPROVE/REJECT`

---

## Commit Strategy

- **Tarea 1**: `feat: add feature_list.json template for state management`
- **Tarea 2**: `feat: add PROGRESS.md template for session continuity`
- **Tarea 3**: `feat: add init.sh template for environment bootstrap`
- **Tarea 4**: `feat: add state harness instructions to AGENTS.md`
- **Tarea 5**: `feat: add WIP=1 constraint to sisyphus prompt`
- **Tarea 6**: `feat: add sprint contracts to delegation template`
- **Tarea 7**: `refactor: split system prompt into tiered topic docs`
- **Tarea 8**: `refactor: create AGENTS.md router with progressive disclosure`
- **Tarea 9**: `feat: add clock-in skill for session startup routine`
- **Tarea 10**: `feat: add clock-out skill for session cleanup routine`
- **Tarea 11**: `feat: add evaluator rubric for objective quality scoring`
- **Tarea 12**: `feat: add init-project skill for harness bootstrap`
- **Tarea 13**: `feat: add feature-cycle skill for end-to-end feature workflow`
- **Tarea 14**: `feat: add cleanup-session skill for post-session hygiene`
- **Tarea 15**: `feat: document E2E testing integration in verification pipeline`
- **Tarea 16**: `docs: evaluate additional MCP options for extended capabilities`
- **Tarea 17**: `perf: run A/B tests across models for behavior benchmarking`
- **Tarea 18**: `docs: document model-specific behavior and configuration recommendations`

---

## Success Criteria

### Final Checklist
- [ ] Plantillas de estado creadas (feature_list.json, PROGRESS.md, init.sh)
- [ ] AGENTS.md funciona como router (<150 lineas, enlaces a docs/)
- [ ] WIP=1 aplicado en sisyphus
- [ ] Contratos de sprint en plantilla de delegacion
- [ ] System prompt dividido en 6 topic docs
- [ ] Skills clock-in y clock-out funcionales
- [ ] Rubricas de evaluacion para Oracle
- [ ] Skills de proyecto: init-project, feature-cycle, cleanup-session
- [ ] E2E testing documentado en pipeline
- [ ] MCPs adicionales evaluados (sin instalar sin aprobacion)
- [ ] Tests A/B ejecutados para modelos principales
- [ ] Comportamiento por modelo documentado
- [ ] Todas las fases commiteadas individualmente
- [ ] Compliance audit aprobado
- [ ] Smoke test de skills aprobado

---

*Generado el 2026-07-30 — Basado en auditoria de harness engineering del curso Walking Labs*
