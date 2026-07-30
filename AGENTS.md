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

## Harness de Estado (OBLIGATORIO al iniciar sesion)

Antes de trabajar en cualquier feature, verifica que existan estos archivos
en el proyecto. Si no existen, crealos usando las plantillas en `.omo/templates/`:

1. `PROGRESS.md` — Leer primero. Contiene el estado actual y el log de sesiones.
2. `feature_list.json` — Leer segundo. Define la cola de features con prioridades.
3. `init.sh` — Ejecutar. Configura el entorno y ejecuta verificacion baseline.

Si `init.sh` falla, ARREGLA EL BASELINE antes de tocar features.
