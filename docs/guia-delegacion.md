# Guia de Delegacion

Reglas que gobiernan cuando y como Sisyphus delega trabajo a subagentes.

---

## Clasificacion de tareas

Ante cualquier solicitud del usuario, clasifica la tarea en una de estas categorias:

| Tipo | Descripcion | Ejemplos |
|------|-------------|----------|
| **Trivial** | Una linea, obvio | Arreglar un typo, cambiar un string |
| **Explicito** | Instrucciones precisas del usuario | "Cambia X por Y en Z.ts" |
| **Exploratorio** | Requiere buscar en el codebase | "Donde se define el logger?" |
| **Abierto** | Objetivo claro, camino ambiguo | "Agrega autenticacion JWT" |
| **Ambiguo** | Objetivo difuso, alta incertidumbre | "Mejora el rendimiento" |

## Regla de oro: DELEGAR por defecto

El sesgo por defecto de Sisyphus es **DELEGAR**. La unica excepcion es cuando:

- La tarea es **trivial** (menos de 3 pasos, sin ambiguedad)
- El usuario da instrucciones **explicitas** y acotadas
- Es una operacion de lectura simple (leer un archivo conocido)

En cualquier otro caso, delega. Si dudas, delega.

## Estructura del prompt de delegacion

Todo prompt de delegacion debe seguir esta estructura de 6 secciones:

```markdown
TASK: <descripcion de una linea>

EXPECTED OUTCOME: <que debe producir el agente, formato concreto>

REQUIRED TOOLS: <herramientas especificas que debe usar>

MUST DO:
- <accion obligatoria>
- <accion obligatoria>

MUST NOT DO:
- <accion prohibida>
- <accion prohibida>

CONTEXT: <informacion relevante del proyecto, archivos, dependencias>
```

### Reglas por seccion

- **TASK**: Una sola frase. Sin ambiguedad.
- **EXPECTED OUTCOME**: Describe el artefacto concreto (archivo, lista, booleano). No digas "analizar" di "devolver lista de archivos que..."
- **REQUIRED TOOLS**: Nombra herramientas exactas del toolset del agente receptor.
- **MUST DO**: Verbos en imperativo. Acciones atomicas.
- **MUST NOT DO**: Prohibiciones explicitas. Lo que el agente jamas debe hacer.
- **CONTEXT**: Rutas de archivos, convenciones del proyecto, decisiones previas.

## Seleccion de categoria

Al delegar, asigna una categoria. La categoria determina el perfil del agente:

| Categoria | Perfil | Cuando usarla |
|-----------|--------|---------------|
| `visual-engineering` | UI/UX | Tareas de frontend, CSS, componentes visuales |
| `ultrabrain` | Logica dura | Algoritmos complejos, optimizacion, arquitectura |
| `deep` | Investigacion autonoma | Tareas abiertas que requieren exploracion multi-paso |
| `quick` | Trivial | Cambios simples, una funcion, un archivo |
| `explore` | Busqueda contextual | Encontrar definiciones, patrones, callers en el codebase |
| `librarian` | Referencia externa | Buscar docs de librerias, APIs, ejemplos de GitHub |

## Carga de skills

Antes de delegar, SIEMPRE evalua todas las skills disponibles en el proyecto:

1. Revisa la lista completa de skills (built-in y de usuario)
2. Identifica cuales son relevantes para la tarea
3. Carga las skills relevantes con `load_skills=['skill-name', ...]`
4. Pasa las skills al agente delegado

**Skills comunes a considerar:**
- `git-master`: Para commits, rebase, blame, bisect
- `playwright`: Para interaccion con navegador
- `frontend-ui-ux`: Para trabajo visual
- `debugging`: Para debugging runtime
- `review-work`: Para revision post-implementacion

## Regla anti-duplicacion (CRITICA)

**JAMAS repitas el trabajo que delegaste a un agente explore/librarian.**

Cuando disparas un agente en background con `subagent_type="explore"` o `subagent_type="librarian"`:

- NO hagas grep/manual search del mismo tema
- NO "revises rapidamente" los mismos archivos
- NO re-ejecutes la misma busqueda

En su lugar:

- Continua con trabajo no relacionado (otros archivos, preparacion)
- Si necesitas los resultados y no estan listos, **termina tu respuesta y espera**
- El sistema te notificara cuando el agente termine
- Recoge resultados con `background_output(task_id="bg_...")`

## Reglas de sesion con subagentes

- **Continuidad**: Siempre usa `session_id` para dar seguimiento a un agente existente. No crees un agente nuevo para continuar trabajo previo.
- **Task ID**: Usa `task_id` para referenciar al agente en llamadas posteriores.
- **Background tasks**: Dispara agentes en paralelo SIEMPRE que sea posible. No los serialices si no tienen dependencias entre si.

## Flujo de trabajo con background tasks

```
1. Dispara N agentes en paralelo con run_in_background=true
2. Continua con trabajo no dependiente
3. Termina tu respuesta (no hagas polling)
4. El sistema te notifica cuando un agente completa
5. Recoge con background_output(task_id="bg_...")
```

**NUNCA hagas polling** con `background_output` sobre una tarea que sigue corriendo. Espera la notificacion del sistema.

---

## Referencias cruzadas

- Para el flujo SDD con delegacion estructurada: [flujo-sdd.md](flujo-sdd.md)
- Para reglas de verificacion post-delegacion: [phase-gates.md](phase-gates.md)
- Para uso del Oracle como consultor: [uso-oracle.md](uso-oracle.md)
