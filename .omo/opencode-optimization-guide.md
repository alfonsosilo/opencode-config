# Guía de Optimización de OpenCode

> Documentación de los cambios aplicados a la configuración de OpenCode
> para reducir consumo de tokens y mejorar eficiencia general.

---

## Resumen

Se aplicaron **4 optimizaciones principales** que redujeron el consumo de tokens
de salida en ~**52%** en el agente principal (sisyphus) y ~**33%** en oracle,
sin pérdida de precisión técnica.

| Métrica | Antes | Después | Reducción |
|---------|-------|---------|-----------|
| Sisyphus (response chars) | 22,251 | 10,887 | **52%** |
| Oracle (response chars) | 20,354 | 13,679 | **33%** |

---

## Cambios Realizados

### 1. Plugin Caveman (`@al-bashkir/opencode-caveman`)

**Qué hace**: Hace que el agente responda de forma más concisa, eliminando
relleno, cortesías y rodeos. Mantiene la precisión técnica intacta.
(Creado originalmente por [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman),
adaptado a OpenCode por [al-bashkir](https://github.com/al-bashkir/opencode-caveman).)

**Archivos modificados**:
- `~/.config/opencode/opencode.jsonc` — Añadido al array `plugin`
- `~/.config/opencode/oh-my-openagent.json` — Añadido `prompt_append` a sisyphus
  con instrucciones "Caveman Lite" para activación permanente desde el primer mensaje

**Instalación**:
```bash
cd ~/.config/opencode && npm install @al-bashkir/opencode-caveman
```

**Config** (`opencode.jsonc`):
```jsonc
{
  "plugin": ["oh-my-openagent", "@al-bashkir/opencode-caveman"],
  "$schema": "https://opencode.ai/config.json"
}
```

**Prompt siempre activo** (`oh-my-openagent.json` → `agents.sisyphus.prompt_append`):
```
RESPONSE MODE: Caveman Lite. Keep full sentences and grammar but drop filler,
pleasantries, and hedging. Be professional but tight. Technical substance exact.
Code blocks unchanged. Pattern: [thing] [action] [reason]. Stay in this mode
every response. User can switch levels with /caveman or say "stop caveman" to
disable.
```

**Niveles disponibles**: Lite (usado), Full, Ultra, Wenyan (clásico chino)

---

### 2. textVerbosity + prompt_append por Agente

**Qué hace**: Controla la longitud de las respuestas de cada agente.
`"low"` para agentes de ejecución, `"medium"` para oracle (el agente
de razonamiento, donde la precisión es crítica).

**Archivo modificado**: `~/.config/opencode/oh-my-openagent.json`

### textVerbosity

| textVerbosity | Agentes |
|--------------|---------|
| `"low"` | sisyphus, sisyphus-junior, prometheus, librarian, explore, atlas, momus, metis, multimodal-looker |
| `"medium"` | oracle |
| *(excluido)* | comment_checker (ya tenía prompt de brevedad en español) |

### prompt_append

Se añadieron instrucciones personalizadas a agentes clave para mejorar la calidad de sus respuestas:

| Agente | prompt_append |
|--------|---------------|
| **sisyphus** (ya existente) | Caveman Lite: respuestas concisas, sin relleno, siempre activo |
| **oracle** | Estructurar análisis en secciones: validar supuestos → trazar problema → soluciones con tradeoffs |
| **prometheus** | Planes estructurados: Contexto, Objetivos, Estrategia, Preguntas Abiertas, Criterios de Éxito |
| **atlas** | Leer plan completo antes de delegar, desglosar en subtareas granulares, verificar cada paso |
| **librarian** | Priorizar documentación oficial, devolver findings accionables con URLs, no adivinar |
| **explore** | Ser exhaustivo, revisar múltiples ángulos, reportar rutas con contexto, distinguir exacto de aproximado |

```jsonc
// Ejemplo: oracle con textVerbosity + prompt_append
"oracle": {
  "model": "opencode-go/deepseek-v4-pro",
  "textVerbosity": "medium",
  "prompt_append": "Structure your analysis with clear sections. First validate assumptions, then trace the problem, then propose solutions with tradeoffs. Be thorough but precise — every sentence should add value.",
  "fallback_models": [{ "model": "opencode-go/kimi-k2.6" }]
}
```

---

### 3. Experimental Settings

**Qué hace**: Activa dos optimizaciones del plugin oh-my-openagent:

- **`aggressive_truncation`**: Trunca el contexto de forma más agresiva cuando
  la conversación se alarga, evitando que se dispare el consumo de tokens.
- **`task_system`**: Habilita el sistema de tareas en segundo plano de oh-my-openagent.

**Archivo modificado**: `~/.config/opencode/oh-my-openagent.json`

```jsonc
{
  "experimental": {
    "aggressive_truncation": true,
    "task_system": true
  }
}
```

---

### 4. Limpieza de Config Duplicada

**Qué se hizo**: El archivo `~/.opencode/opencode.json` contenía
`{"plugin": ["list"]}` — un valor inválido "list" que no es un plugin real.
Posible resto de una migración o config corrompida.

**Acción**: Se respaldó como `.bak`, se verificó que OpenCode siguiera
funcionando sin él, y se eliminó.

---

### 5. Agentes Custom (`~/.opencode/agent/`)

**Qué hace**: Agentes especializados que puedes invocar con `@nombre` desde
cualquier sesión de OpenCode. Cada uno tiene un rol, modelo y permisos específicos.

**Archivos creados**: `~/.config/opencode/agents/` (3 archivos — ubicación global)

| Agente | Modelo | Rol | Permisos | Ubicación |
|--------|--------|-----|----------|-----------|
| `@security-reviewer` | deepseek-v4-pro | Revisa código buscando vulnerabilidades de seguridad | Solo lectura | `~/.config/opencode/agents/` + `oh-my-openagent.json` |
| `@test-generator` | deepseek-v4-flash | Genera tests automatizados siguiendo convenciones del proyecto | Lectura + edición | `~/.config/opencode/agents/` + `oh-my-openagent.json` |
| `@docs-writer` | kimi-k2.6 | Escribe documentación técnica para APIs y componentes | Lectura + edición | `~/.config/opencode/agents/` + `oh-my-openagent.json` |

**Doble registro**: Los agentes están registrados en dos sitios:
1. **`~/.config/opencode/agents/*.md`** — Para que tú puedas invocarlos con `@nombre` desde el chat
2. **`~/.config/opencode/oh-my-openagent.json`** — Para que Sisyphus pueda delegarles tareas vía `task(subagent_type="...")`

**Uso**:
```
@security-reviewer Revisa este archivo en busca de vulnerabilidades
@test-generator Genera tests para src/services/auth.ts
@docs-writer Documenta la API de src/routes/users.ts
```

**Estructura de un agente custom** (Markdown con frontmatter YAML):
```markdown
---
description: "Descripción breve del agente"
mode: subagent
model: opencode-go/deepseek-v4-pro
permission:
  edit: deny
  bash: deny
---

Eres un agente especializado en...
```

Los agentes se auto-descubren al colocar los archivos `.md` en `~/.opencode/agent/`.
No requieren configuración adicional.

---

### 6. `/init-deep` para Proyectos (AGENTS.md Jerárquicos)

**Qué hace**: Escanea la estructura de un proyecto, analiza su código, y genera
archivos `AGENTS.md` jerárquicos para que el agente entienda la arquitectura
sin tener que leer todo el código cada vez.

**Uso básico** (desde la raíz del proyecto):
```bash
/init-deep                   # Analiza y genera/actualiza AGENTS.md
/init-deep --create-new      # Regenera desde cero
/init-deep --max-depth=3     # Limita profundidad (default: 3)
```

**Qué genera**:
- `./AGENTS.md` — Visión general del proyecto, stack, estructura, convenciones
- `./src/hooks/AGENTS.md` — Por subdirectorio, solo si tiene suficiente complejidad
- Cada archivo incluye: overview, estructura, dónde buscar, convenciones y anti-patrones

**Beneficio**: Cada vez que abres una sesión en el proyecto, el agente ya conoce
la arquitectura sin necesidad de que expliques el contexto manualmente.
Ahorra tokens y tiempo en cada sesión.

---

## Archivos Modificados (Resumen)

| Archivo | Acción | Descripción |
|---------|--------|-------------|
| `~/.config/opencode/opencode.jsonc` | Modificado | Añadido caveman al array plugin |
| `~/.config/opencode/oh-my-openagent.json` | Modificado | textVerbosity + prompt_append + experimental |
| `~/.config/opencode/package.json` | Modificado | Dependencia @al-bashkir/opencode-caveman |
| `~/.config/opencode/package-lock.json` | Modificado | Lockfile actualizado |
| `~/.config/opencode/node_modules/@al-bashkir/opencode-caveman/` | Nuevo | Plugin instalado |
| `~/.opencode/opencode.json` | Eliminado | Config corrupta/sobrante |
| `~/.config/opencode/agents/security-reviewer.md` | Nuevo | Agente custom: revisor de seguridad |
| `~/.config/opencode/agents/test-generator.md` | Nuevo | Agente custom: generador de tests |
| `~/.config/opencode/agents/docs-writer.md` | Nuevo | Agente custom: escritor técnico |

---

## Recursos Utilizados

### Plugins Instalados

| Plugin | Versión | Propósito |
|--------|---------|-----------|
| `oh-my-openagent` | latest | Multi-agente Sisyphus para OpenCode |
| `@al-bashkir/opencode-caveman` | 0.1.0 | Compresión de tokens estilo caveman |

### Agentes Custom Creados

| Archivo | Propósito |
|---------|-----------|
| `~/.config/opencode/agents/security-reviewer.md` | Revisor de seguridad especializado |
| `~/.config/opencode/agents/test-generator.md` | Generador automatizado de tests |
| `~/.config/opencode/agents/docs-writer.md` | Escritor técnico de documentación |

### Comandos Disponibles — Lista Completa

#### 🧭 OpenCode Nativos

| Comando | Función |
|---------|---------|
| `/init` | Generar AGENTS.md analizando el repositorio actual |
| `/help` | Mostrar comandos disponibles y atajos de teclado |
| `/share` | Generar URL pública del transcript de la sesión |
| `/undo` | Revertir la última acción del agente |
| `/redo` | Re-aplicar la última acción revertida |
| `/connect` | Cambiar de proveedor de modelos |
| `/sessions` | Listar todas las sesiones |
| `/new` | Crear nueva sesión |
| `/clear` | Limpiar sesión actual (volver a empezar) |
| `/timeline` | Ver timeline de la sesión |
| `/export` | Exportar sesión a JSON |
| `/compact` | Comprimir contexto de conversación |
| `/copy` | Copiar al portapapeles |
| `/editor` | Abrir el editor (Ctrl+E) |
| `/themes` | Cambiar tema visual (Ctrl+T) |
| `/status` | Ver estado de la sesión (Ctrl+S) |
| `/agents` | Lista de agentes disponibles (Ctrl+A) |
| `/models` | Cambiar modelo LLM |
| `/context` | Ver uso de tokens actual |
| `/skills` | Listar skills disponibles |

#### 📋 oh-my-openagent

| Comando | Función |
|---------|---------|
| `/start-work` | Iniciar sesión de trabajo desde plan de Prometheus |
| `/hyperplan` | Planificación multi-agente adversarial (5 agentes critican, lead sintetiza) |
| `/init-deep` | Generar AGENTS.md jerárquicos en todo el proyecto |
| `/ralph-loop` | Bucle de desarrollo auto-referencial hasta completar |
| `/ulw-loop` | Bucle ultrawork — modo máximo rendimiento |
| `/cancel-ralph` | Cancelar bucle activo (ralph o ulw) |
| `/stop-continuation` | Detener todos los mecanismos de continuación |
| `/refactor` | Refactorización inteligente con LSP, AST-grep, codemap y TDD |
| `/remove-ai-slops` | Eliminar code smells generados por IA |
| `/handoff` | Crear resumen de contexto para continuar en nueva sesión |

#### 🗿 Caveman

| Comando | Función |
|---------|---------|
| `/caveman` | Activar modo caveman (default: full) |
| `/caveman lite` | Modo profesional sin relleno |
| `/caveman full` | Fragmentos, sin artículos |
| `/caveman ultra` | Máxima compresión, telegráfico |
| `/caveman wenyan` | Chino clásico (文言文) |
| `/caveman normal` | Desactivar modo caveman |
| `/caveman-commit` | Generar commit message convencional y conciso |
| `/caveman-review` | Revisión de diff concisa (formato: `L42: 🔴 bug: ...`) |
| `/caveman:compress <arch>` | Comprimir archivo de memoria (AGENTS.md, CLAUDE.md) → ~46% tokens input |

#### 🛠 Skills

| Comando | Función |
|---------|---------|
| `/playwright` | Automatización de navegador (testing, scraping, screenshots) |
| `/frontend-ui-ux` | Diseño UI/UX sin mockups — código visual de calidad |
| `/git-master` | Operaciones git avanzadas (commits atómicos, rebase, blame) |
| `/review-work` | Revisión post-implementación con 5 agentes en paralelo |

#### 🤖 Agentes Custom

| Invocación | Rol |
|------------|-----|
| `@security-reviewer` | Revisar código buscando vulnerabilidades de seguridad |
| `@test-generator` | Generar tests automatizados según convenciones del proyecto |
| `@docs-writer` | Escribir documentación técnica de APIs y componentes |

### 🔌 MCPs Activos

oh-my-openagent incluye 5 MCPs (Model Context Protocol) que los agentes usan automáticamente. No requieren configuración manual.

| MCP | Herramienta | Qué hace | Cuándo se usa |
|-----|-------------|----------|---------------|
| **AST-Grep** | `ast_grep_search`, `ast_grep_replace` | Búsqueda y reemplazo estructural de código usando patrones AST (no regex). Soporta 25 lenguajes. | Refactorizaciones precisas, encontrar patrones de código por estructura (ej: todas las funciones que devuelven `JSX.Element`), reemplazos seguros que respetan la sintaxis. |
| **Context7** | `context7_resolve-library-id`, `context7_query-docs` | Consulta documentación oficial y ejemplos de código actualizados para cualquier librería o framework. | "¿Cómo se configura JWT en Express?", "Necesito la API de React 19 para Server Components". Va directo a la doc oficial, no a blogs. |
| **Grep.App** | `grep_app_searchGitHub` | Busca patrones literales de código en millones de repositorios públicos de GitHub. | "¿Cómo usan otros `useOptimistic` en producción?", "Muéstrame ejemplos reales de `middleware` en Next.js". Encuentra implementaciones reales, no tutoriales. |
| **LSP** | `lsp_diagnostics`, `lsp_goto_definition`, `lsp_find_references`, `lsp_rename`, `lsp_symbols` | Language Server Protocol: diagnósticos en vivo, ir a definición, referencias, renombrado seguro, símbolos del workspace. | Refactorización segura (renombrar variables), navegar código (ir a definición), ver errores/warnings en archivos. |
| **Web Search** | `websearch_web_search_exa`, `webfetch` | Búsqueda web semántica con Exa + fetching de URLs. Resultados limpios, no solo keywords. | Información actualizada, noticias, documentación de versiones recientes, búsqueda de soluciones a errores. |

#### 🤖 Agentes de oh-my-openagent — Definidos en `oh-my-openagent.json`

| Agente | Modelo | Rol |
|--------|--------|-----|
| **sisyphus** | deepseek-v4-pro | **Orquestador principal.** Planifica, delega y supervisa la ejecución. Es quien habla contigo en el chat. Tiene Caveman Lite + textVerbosity low activados. |
| **oracle** | deepseek-v4-pro | **Consultor de arquitectura.** Análisis profundo, debugging complejo, decisiones de diseño. Solo lectura (lee, analiza, recomienda). textVerbosity medium para mantener precisión. |
| **librarian** | deepseek-v4-flash | **Investigador.** Busca documentación oficial, analiza repos remotos, encuentra ejemplos de implementación en GitHub. |
| **explore** | deepseek-v4-flash | **Rastreador de código.** Búsqueda contextual de patrones, estructuras de archivos, descubrimiento de código en el codebase. |
| **multimodal-looker** | minimax-m3 | **Analizador de imágenes/PDFs.** Extrae información de capturas, diagramas, documentos. |
| **prometheus** | deepseek-v4-flash | **Planificador.** Entrevista al usuario, identifica alcance, produce planes estructurados. Se activa con Tab o `/start-work`. |
| **metis** | deepseek-v4-pro | **Consultor pre-plan.** Analiza requisitos antes de generar un plan, detecta ambigüedades y puntos ciegos. |
| **momus** | glm-5.1 | **Crítico de planes.** Revisa planes contra criterios de claridad, verificabilidad y completitud. |
| **atlas** | deepseek-v4-flash | **Ejecutor de planes.** Lee el plan, desglosa en tareas, delega. Se activa con `/start-work` después de Prometheus. |
| **sisyphus-junior** | kimi-k2.6 | **Ejecutor genérico.** Spawneado por `task(category="...")`. Hereda el modelo de la categoría asignada. |
| **comment_checker** | deepseek-v4-flash | **Revisor de comentarios.** Analiza comentarios en el código, identifica los críticos y sugiere mejoras. |
| **security-reviewer** | deepseek-v4-pro | **Revisor de seguridad.** Busca vulnerabilidades: inyecciones, auth bypass, datos expuestos, dependencias. Solo lectura. |
| **test-generator** | deepseek-v4-flash | **Generador de tests.** Crea tests siguiendo el framework y convenciones del proyecto. |
| **docs-writer** | kimi-k2.6 | **Escritor técnico.** Documenta APIs, componentes y módulos. Conciso, con ejemplos, sin duplicar. |

### 📊 Categorías de Delegación

Cuando Sisyphus delega una tarea, elige una categoría que determina el modelo y el prompt del subagente (`sisyphus-junior`):

| Categoría | Modelo | Para qué sirve |
|-----------|--------|----------------|
| `quick` | deepseek-v4-flash | Tareas triviales: cambios de un archivo, correcciones de typo |
| `unspecified-low` | deepseek-v4-flash | Tareas moderadas que no encajan en otras categorías |
| `unspecified-high` | deepseek-v4-pro | Tareas complejas que requieren un modelo potente |
| `visual-engineering` | kimi-k2.6 | Frontend, UI/UX, CSS, diseño, animaciones |
| `ultrabrain` | deepseek-v4-pro | Lógica dura, decisiones de arquitectura, algoritmos |
| `deep` | deepseek-v4-pro | Problemas autónomos que requieren investigación profunda |
| `artistry` | kimi-k2.6 | Enfoques creativos no convencionales |
| `writing` | kimi-k2.6 | Documentación, prosa, escritura técnica |

### Repositorios de Referencia

- **oh-my-openagent**: https://github.com/code-yeongyu/oh-my-openagent
- **Caveman original**: https://github.com/JuliusBrussee/caveman
- **Caveman para OpenCode**: https://github.com/al-bashkir/opencode-caveman
- **Documentación oh-my-openagent**: https://github.com/code-yeongyu/oh-my-openagent/blob/dev/docs/reference/configuration.md
- **Documentación de agentes OpenCode**: https://opencode.ai/docs/agents/

---

## Cómo Replicar en Otro Entorno

Para aplicar esta misma configuración en otro equipo:

```bash
# 1. Asegurar que oh-my-openagent está instalado
# (añadir "oh-my-openagent" al plugin array en opencode.json)

# 2. Instalar caveman
cd ~/.config/opencode && npm install @al-bashkir/opencode-caveman

# 3. Actualizar opencode.jsonc
# Añadir "@al-bashkir/opencode-caveman" al array plugin

# 4. Añadir textVerbosity + prompt_append + experimental a oh-my-openagent.json
# (copiar las entradas de este documento)

# 5. Backup de seguridad antes de cambios
tar czf ~/opencode-config-backup-$(date +%Y%m%d).tar.gz ~/.config/opencode/

# 6. Inicializar git (opcional pero recomendado)
cd ~/.config/opencode && git init && git add -A && git commit -m "baseline config"

# 7. (Opcional) Crear agentes custom copiando los archivos .md a ~/.opencode/agent/
# cp security-reviewer.md test-generator.md docs-writer.md ~/.opencode/agent/

# 8. (Opcional) En cada proyecto, ejecutar /init-deep para generar AGENTS.md
# cd /ruta/del/proyecto && /init-deep
```

---

## Verificación

Para comprobar que las optimizaciones funcionan:

```bash
# Verificar que el plugin carga
opencode --version

# Verificar configuración
python3 -m json.tool ~/.config/opencode/oh-my-openagent.json
cat ~/.config/opencode/opencode.jsonc

# Probar reducción de tokens
# Prompt de prueba: "Explain what a REST API is in detail, covering all
# HTTP methods, status codes, and best practices."
# Comparar salida con y sin optimizaciones
```

---

## Historial de Commits

```
6cb64a6 feat: add prompt_append to oracle, prometheus, atlas, librarian, explore
7d7ca6c optimization: caveman + textVerbosity + aggressive_truncation + cleanup
d4e0af9 perf: enable experimental.aggressive_truncation and experimental.task_system
0d46f80 perf: add textVerbosity to agents (low for most, medium for oracle)
60ff304 feat: install @al-bashkir/opencode-caveman plugin (lite, always-on)
b49b89d pre-optimization baseline
```

---

## Resumen de Archivos

```
~/.config/opencode/             # Configuración principal (git tracking activo)
  ├── opencode.jsonc             # Plugin array con oh-my-openagent + caveman
  ├── oh-my-openagent.json       # textVerbosity, prompt_append, experimental
  ├── tui.json                   # Sin cambios
  ├── package.json               # Dependencia caveman añadida
  └── .omo/                      # Planes, drafts, guías

~/.config/opencode/              # Config global de OpenCode
  ├── agents/                    # Agentes custom (3 — funcionan en cualquier proyecto)
  │   ├── security-reviewer.md
  │   ├── test-generator.md
  │   └── docs-writer.md
  ├── opencode.jsonc             # Plugin array
  ├── oh-my-openagent.json       # textVerbosity, prompt_append, experimental
  ├── tui.json                   # Sin cambios
  ├── package.json               # Dependencias
  └── .omo/                      # Planes, guías, drafts
```

---

*Generado el 2026-06-01 — OpenCode 1.15.13 + oh-my-openagent*
