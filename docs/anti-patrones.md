# Anti-Patrones y Bloqueos Duros

Practicas que Sisyphus tiene **absolutamente prohibidas** y los problemas sistemicos que causan.

---

## Bloqueos duros: lo que JAMAS debes hacer

### Type safety

| Prohibido | Por que |
|-----------|---------|
| `as any` | Silencia el type checker. El error sigue ahi, solo que invisible. |
| `@ts-ignore` | Idem. El bug explota en runtime. |
| `@ts-expect-error` | Igual de malo. Si "esperas" un error, arregla el tipo. |

Si TypeScript se queja, **arregla el tipo**, no lo silencies. Agrega type guards, refinamientos, o generics. Lo que sea necesario. Pero nunca `as any`.

### Error handling

| Prohibido | Alternativa |
|-----------|-------------|
| `catch (e) {}` (vacio) | Loggea el error, relanzalo, o maneja el caso. Pero nunca tragues el error en silencio. |
| `catch (e) { /* TODO */ }` | El TODO nunca se hace. Maneja el error ahora. |
| `process.on('unhandledRejection', () => {})` | Maneja cada promesa explicitamente. |

### Testing

| Prohibido | Por que |
|-----------|---------|
| Borrar tests que fallan | Estas matando al mensajero. El test falla por algo. |
| Comentar tests que fallan | Idem. El codigo comentado es deuda que se acumula. |
| Cambiar assertions para que pasen | Si `expect(2+2).toBe(5)` te falla, no lo cambies a `toBe(4)` si el requisito real es 5. |

### Busqueda e investigacion

| Prohibido | Alternativa |
|-----------|-------------|
| Disparar un explore/librarian agent para buscar un typo de una linea | Usa `grep` o `read` directo |
| Disparar 5 explore agents para el mismo archivo | Un agente por topico, no por archivo |
| Re-hacer la busqueda que delegaste a un agente | Espera el resultado (ver [guia-delegacion.md](guia-delegacion.md)) |

### Debugging

| Prohibido | Alternativa |
|-----------|-------------|
| "Shotgun debugging" (cambiar cosas al azar hasta que funcione) | Formula hipotesis, aisla, verifica |
| Agregar `console.log` en 20 lugares | Instrumenta el punto exacto del fallo. Busca la causa raiz. |
| Reiniciar sin entender por que fallo | Si fallo una vez sin explicacion, fallara de nuevo. |

### Background tasks

| Prohibido | Alternativa |
|-----------|-------------|
| Hacer polling de `background_output` sobre tareas corriendo | Espera el system-reminder |
| `background_cancel(all=true)` | Cancela una por una, solo si es necesario |
| Disparar un background task y nunca recogerlo | Siempre recoge el resultado antes de entregar la respuesta final |

### Delegacion

| Prohibido | Alternativa |
|-----------|-------------|
| Re-ejecutar la misma busqueda que un explore/librarian | Anti-duplicacion: espera o continua con otro trabajo |
| Delegar trabajo visual a categoria que no es `visual-engineering` | UI siempre a visual-engineering |

### Oracle

| Prohibido | Alternativa |
|-----------|-------------|
| Entregar respuesta final sin recoger resultado del Oracle (si lo disparaste) | Espera y recoge |
| Consultar Oracle para "que nombre le pongo a esta variable" | Decide tu. Oracle es para decisiones de arquitectura, no de estilo. |

### Git

| Prohibido | Por que |
|-----------|---------|
| Hacer commit sin que el usuario lo pida | El usuario es dueno del historial |
| `git push --force` | Destructivo. Jamas sin aprobacion explicita. |
| `git commit --amend` en commits ya pusheados | Reescribe historia compartida. |

---

## Anti-patrones sistemicos

Estos son problemas de proceso, no de una accion puntual. Son los patrones que degradan la efectividad del agente a lo largo del tiempo.

### Instruction Bloat

Tu AGENTS.md tiene 600 lineas. La regla en la linea 300 es ignorada sistematicamente porque el modelo no puede retener todo el contexto de instrucciones a la vez.

**Solucion**: Documentacion por topico cargada bajo demanda con `skill`. Cada doc se lee solo cuando es relevante.

### Unconstrained scope

Empiezas 5 features en paralelo. Terminas 0. El WIP explota.

**Solucion**: WIP=1. Una feature activa a la vez. La delegacion paralela es solo para sub-tareas de la MISMA feature.

### Self-evaluation

El agente juzga su propio trabajo y lo declara correcto. Esto es **sobreconfianza sistematica**. Tu no puedes evaluar objetivamente lo que acabas de escribir.

**Solucion**: Delega la verificacion. Oracle revisa contra la spec. LSP diagnostics revisa contra el type system. Tests revisan contra el comportamiento esperado. Pero nunca confies en tu propio juicio como unica verificacion.

### Unit-only testing

Solo escribes tests unitarios. Los defectos de integracion entre componentes son invisibles.

**Solucion**: Para features que tocan multiples componentes, incluye al menos un test de integracion que cruce el boundary.

### No state persistence

Cada sesion empieza desde cero. Re-exploras el proyecto, re-lees los mismos archivos, re-descubres las mismas decisiones.

**Solucion**: Usa el knowledge graph (codebase-memory-mcp) para persistir descubrimientos estructurales. Lee PROGRESS.md al inicio de cada sesion.

### Rushed finish

El contexto se esta acabando. Quedan 3 verificaciones pendientes. Las omites y declaras "completado" para no perder el trabajo.

**Solucion**: Si el contexto esta bajo, **documenta el estado actual y pide continuacion**. Es mejor una sesion extra que un "completado" falso. Usa `/handoff` para crear un resumen de contexto para la siguiente sesion.

### Recursive forks

Cada sub-agente dispara sus propios sub-agentes, que disparan sus propios sub-agentes. El costo de contexto se multiplica exponencialmente.

**Solucion**: Los sub-agentes de Sisyphus no deben re-delegar. La profundidad de arbol de delegacion esta limitada. Si un sub-agente necesita ayuda, debe devolver el control a Sisyphus.

### Codebase divergence

El agente hace cambios sin leer el codigo circundante. El resultado: codigo que no sigue los patrones del proyecto, duplica utilidades existentes, o rompe convenciones de naming.

**Solucion**: Antes de escribir, lee ejemplos similares en el codebase. La regla: "match existing patterns".

---

## Referencias cruzadas

- Para la regla WIP=1 y scope management: [guia-delegacion.md](guia-delegacion.md)
- Para verificacion objetiva (no self-evaluation): [phase-gates.md](phase-gates.md)
- Para uso correcto de Oracle como verificador externo: [uso-oracle.md](uso-oracle.md)
- Para herramientas que reemplazan busqueda manual: [uso-herramientas.md](uso-herramientas.md)
