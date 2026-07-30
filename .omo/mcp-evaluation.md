# Evaluacion de MCPs Adicionales

> **NOTA**: Ningun MCP listado aqui ha sido instalado. Este documento es una evaluacion para decision informada.
> **Excluido**: GitHub MCP — el usuario requiere revision humana para todas las subidas a GitHub.

## Resumen Ejecutivo

Actualmente OpenCode tiene 1 MCP activo: `codebase-memory-mcp` (grafo de conocimiento del codebase).
Los MCPs evaluados a continuacion permitirian al agente interactuar con sistemas externos:
bases de datos, gestores de tareas, navegadores para testing, y notificaciones.

Con la especificacion MCP 2026-07-28 (lanzada el 28 de julio de 2026), el protocolo es ahora
stateless, soporta extensions como Tasks y MCP Apps, y escala en infraestructura HTTP estandar.
Esto reduce la friccion de integracion para todos los MCPs listados abajo.

---

## 1. Database MCP

**Proposito**: Permitir al agente inspeccionar y verificar estado de bases de datos directamente.
Ejecutar queries de solo lectura, verificar migraciones, inspeccionar datos de prueba, validar
schemas, y diagnosticar problemas de persistencia sin escribir scripts manuales.

**Ejemplos de MCPs disponibles**:
- `cnosuke/mcp-postgresql` (GitHub) — PostgreSQL maduro, read-only mode, dual transport
  (stdio + HTTP), OAuth 2.0, connection presets que ocultan passwords del LLM, soporte PG 14-19
- `devopam/MCPg` (pip install mcpg) — PostgreSQL con 254 tools: catalog introspection,
  query intelligence, natural-language SQL, structural diffs, graph queries, TimescaleDB,
  pgvector, PostGIS. Read-only default + AST validation. Multi-tenant.
- `@anthropic/mcp-server-sqlite` — SQLite ligero para desarrollo local
- MCPs comunitarios para MySQL, MongoDB (menos maduros, verificar antes de usar)

**Costo de integracion**: Bajo. Instalacion npm/pip, configuracion de connection string en
opencode.json. La mayoria soportan variables de entorno para secrets.
**Beneficio esperado**: Alto. El agente puede verificar que los datos se persisten correctamente,
que las migraciones se aplicaron, y que las queries retornan lo esperado sin intervencion humana.
**Riesgos**: Acceso de escritura debe estar deshabilitado (read-only) por defecto. Connection
string debe usar variables de entorno, nunca hardcodeado. Validar que el MCP no exponga
passwords al LLM (cnosuke/mcp-postgresql ya lo garantiza con connection presets).

**Recomendacion**: ⭐⭐⭐⭐ Instalar cuando un proyecto use base de datos activamente.
Priorizar PostgreSQL (mas soporte y madurez) o SQLite segun el stack.

---

## 2. Linear / Jira MCP

**Proposito**: Conectar al agente con el gestor de tareas. Leer tickets, actualizar estado,
vincular PRs a issues, auto-seleccionar siguiente tarea, comentar avances en el ticket.

**Ejemplos de MCPs disponibles**:
- `@linear/mcp-server` — Linear (oficial, mantenido por Linear)
- MCPs comunitarios para Jira (varios en npm, calidad variable — verificar antes de usar)

**Costo de integracion**: Medio. Requiere API key con scopes limitados y configuracion de
proyecto/workspace. Linear tiene mejor soporte nativo; Jira requiere MCP comunitario.
**Beneficio esperado**: Alto. Cierra el ciclo completo: ticket → implementacion → PR →
ticket actualizado automaticamente. El feature_list.json del proyecto podria sincronizarse
con el gestor de tareas externo. El agente puede leer la descripcion del ticket para entender
requisitos sin que el usuario los copie manualmente.
**Riesgos**: API keys deben gestionarse con cuidado (usar variables de entorno). Configurar
scopes de solo lectura para tareas de otros miembros del equipo. El MCP de Jira al ser
comunitario puede tener bugs o quedar sin mantenimiento.

**Recomendacion**: ⭐⭐⭐⭐⭐ Si usas Linear o Jira, este es el MCP de mayor impacto
despues del de base de datos. Convierte al agente en un miembro mas del equipo que
entiende el contexto de las tareas.

---

## 3. Playwright MCP

**Proposito**: Automatizacion de navegador para testing E2E, verificacion visual, exploracion
de UI, y debugging. A diferencia de la skill `/playwright` (que es interactiva y requiere
instrucciones del usuario), un MCP daria acceso programatico para que el agente verifique
su propio trabajo de forma autonoma.

**Ejemplos de MCPs disponibles**:
- `@playwright/mcp` (Microsoft, oficial) — Paquete npm. 40+ tools: navegacion, clicks,
  formularios, screenshots, network mocking, tracing, video. Usa accessibility tree
  (snapshots estructurados), no screenshots para entender la pagina (~200-400 tokens
  por snapshot vs miles de tokens del DOM). Soporta Chrome, Firefox, WebKit, Edge.
  Modo headed por defecto. Perfiles persistentes (cookies, login state).

**Costo de integracion**: Medio. Requiere `npx @playwright/mcp@latest` + navegador
(chromium incluido en la instalacion de Playwright). Configuracion en opencode.json.
**Beneficio esperado**: Alto para proyectos con frontend. Permite al agente: abrir la app,
navegar el flujo que construyo, verificar que el resultado coincide con lo esperado,
y reportar sin intervencion humana. Cierra el loop "codigo → ejecutar → verificar".
Para proyectos solo API, el beneficio es bajo.
**Riesgos**: Consume recursos (navegador headless/headed). Tiempo de ejecucion puede ser
significativo (segundos por accion). No reemplaza tests unitarios o de integracion — es
para verificacion exploratoria y E2E ad-hoc, no para CI. El MCP ejecuta en el entorno
del servidor, requiere display o configuracion headless en CI.

**Recomendacion**: ⭐⭐⭐ Instalar para proyectos con frontend. Para proyectos solo API,
usar curl + jq en su lugar (ver `.omo/e2e-testing-guide.md`). Configurar en modo headless
para uso en background tasks.

---

## 4. Slack MCP

**Proposito**: Notificaciones automatizadas. Alertar al equipo cuando un feature se completa,
cuando hay errores, cuando se necesita revision humana, o cuando el agente termina una
tarea en modo autonomo (loop).

**Ejemplos de MCPs disponibles**:
- `@anthropic/mcp-server-slack` — Slack (oficial)
- MCPs comunitarios para Discord, Telegram (si se prefiere otra plataforma)

**Costo de integracion**: Bajo. Bot token + channel ID. Configuracion minima en opencode.json.
**Beneficio esperado**: Medio. Reduce la necesidad de revisar el agente manualmente.
El agente avisa cuando termina, cuando encuentra un error, o cuando necesita decision humana.
Util para modo loop/autonomo donde el usuario no esta mirando el chat.
**Riesgos**: Puede generar ruido si no se configura con filtros. Limitar a eventos
significativos: feature completado, error critico, necesidad de revision humana.
No usar para logs de debug o progreso incremental.

**Recomendacion**: ⭐⭐⭐ Instalar cuando el agente se use en modo loop/autonomo
(ej. `/ralph-loop`, `/ulw-loop`). Para uso interactivo, el usuario ya ve los
resultados en el chat y Slack agregaria friccion innecesaria.

---

## Prioridades de Instalacion

| Prioridad | MCP | Condicion | Impacto |
|-----------|-----|-----------|---------|
| 1 | Linear / Jira | Si usas gestor de tareas | Maximo — cierra el ciclo ticket→codigo→ticket |
| 2 | Database | Si el proyecto usa DB | Alto — verificacion de datos sin scripts |
| 3 | Playwright | Si el proyecto tiene frontend | Alto — E2E testing y auto-verificacion |
| 4 | Slack | Si usas modo loop/autonomo | Medio — notificaciones sin supervision |

## Proceso de Instalacion (para cualquier MCP)

1. **Investigar** el MCP especifico: `npm view [nombre]`, GitHub releases, documentacion,
   fecha del ultimo commit (descartar si >6 meses sin actividad)
2. **Leer el README** del repositorio — verificar requisitos, variables de entorno, y
   compatibilidad con la especificacion MCP actual (2026-07-28)
3. **Anadir a opencode.json** en la seccion `mcp`:
   ```json
   {
     "mcp": {
       "nombre-mcp": {
         "enabled": true,
         "type": "local",
         "command": ["ruta/al/bin"],
         "env": { "API_KEY": "${NOMBRE_VAR_ENTORNO}" }
       }
     }
   }
   ```
4. **Probar en un proyecto de prueba** antes de usarlo en produccion. Verificar que:
   - Las tools aparecen en `list_mcp_resources`
   - Las tools funcionan sin errores
   - No hay leaks de secrets en logs o respuestas
5. **Documentar** en PROGRESS.md del proyecto que MCPs estan activos y para que sirven

## MCPs No Evaluados (bajo monitoreo)

- **Notion MCP** — potencial para documentacion vinculada a tickets. Comunidad temprana.
- **Filesystem MCP** — redundante con herramientas nativas de OpenCode (Read, Write, Glob).
- **Memory MCP** — redundante con codebase-memory-mcp ya instalado.
- **Docker MCP** — util para entornos de prueba aislados. Evaluar cuando se necesite CI local.
- **Sentry MCP** — util para debug de errores en produccion. Evaluar cuando el proyecto
  tenga monitoreo de errores activo.

---

*Evaluacion generada el 2026-07-30. Los MCPs, versiones y su disponibilidad pueden haber
cambiado. Re-evaluar antes de instalar cualquier MCP listado aqui. Verificar compatibilidad
con la especificacion MCP vigente (actualmente 2026-07-28).*
