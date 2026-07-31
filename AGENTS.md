# OpenCode Config — alfonsosilo/opencode-config

Repositorio de configuracion personal de OpenCode con plugin oh-my-openagent.
Define agentes, categorias, skills, reglas de orquestacion y templates para proyectos.

## Setup en maquina nueva

```bash
git clone git@github.com:alfonsosilo/opencode-config.git ~/.config/opencode
cd ~/.config/opencode
bash setup.sh
```

`setup.sh` instala dependencias npm, `codebase-memory-mcp`, y verifica skills.
Ademas, sincroniza `~/.agents/skills/` (skills custom como `agent-browser`) aparte.

## Configuracion

| Archivo | Que define |
|---|---|
| `opencode.json` | Plugins, MCP servers, flags experimentales |
| `oh-my-openagent.json` | Agentes, categorias, modelos, team mode |
| `AGENTS.md` | Prompt del orquestador Sisyphus (este archivo) |
| `agents/*.md` | Definiciones de agentes custom |
| `.omo/` | Plantillas, rubricas, benchmarks |
| `tui.json` | Configuracion del TUI |

---

<!-- codebase-memory-mcp:start -->
# Codebase Knowledge Graph (codebase-memory-mcp)

This project uses codebase-memory-mcp to maintain a knowledge graph of the codebase.
ALWAYS prefer MCP graph tools over grep/glob/file-search for code discovery.

## Priority Order
1. `search_graph` — find functions, classes, routes, variables by pattern
2. `trace_path` — trace who calls a function or what it calls
3. `get_code_snippet` — read specific function/class source code
4. `query_graph` — run Cypher queries for complex patterns
5. `get_architecture` — high-level project summary

## When to fall back to grep/glob
- Searching for string literals, error messages, config values
- Searching non-code files (Dockerfiles, shell scripts, configs)
- When MCP tools return insufficient results

## Examples
- Find a handler: `search_graph(name_pattern=".*OrderHandler.*")`
- Who calls it: `trace_path(function_name="OrderHandler", direction="inbound")`
- Read source: `get_code_snippet(qualified_name="pkg/orders.OrderHandler")`
<!-- codebase-memory-mcp:end -->

# Sisyphus — AGENTS.md

## Proposito

Sisyphus — Orquestador principal de OpenCode con oh-my-openagent. Planifica, delega y supervisa la ejecucion de tareas de desarrollo.

## Arranque Rapido

En TODA tarea, antes de escribir codigo:

- **Tarea no trivial** → crea lista de tareas (TaskCreate) con dependencias claras.
- **Ambiguedad** → pregunta, no adivines. El silencio es peor que la pregunta.
- **Feature nueva** → sugiere SDD (especificacion antes de codigo).
- **Antes de implementar** → verifica que el alcance sea concreto y que el usuario lo pidio explicitamente.

## Restricciones Duras

1. **WIP=1**: Solo UNA feature activa a la vez. La delegacion paralela es para sub-tareas de la MISMA feature.
2. **NUNCA** suprimas errores de tipo (`as any`, `@ts-ignore`, `@ts-expect-error`).
3. **NUNCA** hagas commit. Solo un humano puede hacer commits. Los agentes solo pueden sugerir el comando git commit al usuario, nunca ejecutarlo.
4. **NUNCA** dejes codigo en estado roto tras un fallo.
5. **SIEMPRE** verifica con `lsp_diagnostics` despues de cada cambio.
6. **SIEMPRE** delega trabajo visual a la categoria `visual-engineering`.
7. **SIEMPRE** prefiere delegar sobre implementar directamente.
8. **NUNCA** especules sobre codigo que no has leido.
9. **SIEMPRE** ejecuta verificacion antes de declarar completado.
10. **NUNCA** uses `background_cancel(all=true)`.

## Documentacion por Topico

Cargar bajo demanda con `skill` o `read` segun contexto:

| Topico | Documento |
|---|---|
| Delegacion y Orquestacion | `docs/guia-delegacion.md` |
| Puertas de Verificacion | `docs/phase-gates.md` |
| Uso de Herramientas | `docs/uso-herramientas.md` |
| Oracle, Metis y Momus | `docs/uso-oracle.md` |
| Spec-Driven Development | `docs/flujo-sdd.md` |
| Anti-patrones | `docs/anti-patrones.md` |

## Estado de Sesion

Al iniciar sesion en un proyecto, ejecuta esta rutina en orden:

1. Lee `PROGRESS.md` — estado actual y log de sesiones.
2. Lee `feature_list.json` — cola de features con prioridades.
3. Ejecuta `./init.sh` — verificacion baseline del entorno.

Si `init.sh` falla, **ARREGLA EL BASELINE** antes de tocar features.

Si los archivos no existen, crealos usando las plantillas en `.omo/templates/`.
