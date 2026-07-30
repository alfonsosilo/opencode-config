# Comportamiento por Modelo

> Basado en benchmarks del 2026-07-30. Cada modelo fue testeado en su dominio optimizado.
> Los resultados completos estan en [.omo/model-benchmarks.json](model-benchmarks.json)

## Resumen

| Modelo | Dominio | Calidad | Rushed Finish | Chars | Uso Recomendado |
|--------|---------|---------|---------------|-------|-----------------|
| deepseek-v4-pro | Coding complejo | A | No | ~500 | deep, ultrabrain, tareas criticas, sisyphus |
| deepseek-v4-flash | Coding rapido | B | Leve | ~550 | quick, explore, librarian, tareas simples |
| minimax-m3 | UI/Visual | A | No | ~950 | visual-engineering |
| qwen3.7-max | Analisis/Planificacion | B | Si (grave) | ~150 | oracle, prometheus, spec-writer (con cuidado) |
| kimi-k2.6 | Documentacion | A | No | ~1450 | docs-writer |

---

## deepseek-v4-pro

**Agentes asignados**: sisyphus, metis, momus, multimodal-looker, security-reviewer
**Categorias**: deep, ultrabrain, artistry, unspecified-high, writing

**Fortalezas**:
- Codigo idiomatico y pulido. Captura edge cases sutiles (ej: distinguir `bool` de `int` en `isinstance`).
- Respuestas completas sin truncamiento.
- Buen balance entre concision y completitud (~500 chars para tarea de coding).

**Debilidades**:
- No detectadas en benchmarks. Rendimiento solido en todos los frentes.

**Recomendaciones de configuracion**:
- Sin cambios necesarios. Modelo principal para tareas criticas.
- `textVerbosity: low` funciona bien. No necesita anti-truncamiento.
- Fallback actual: `qwen3.6-plus`. Adecuado como respaldo.

**Cuando usar**:
- Tareas de implementacion complejas (deep, ultrabrain, artistry)
- Decisiones de arquitectura y revision (metis, momus, security-reviewer)
- Orquestacion principal (sisyphus)
- Cualquier tarea donde la calidad sea prioridad sobre la velocidad

---

## deepseek-v4-flash

**Agentes asignados**: sisyphus-junior, librarian, explore, atlas, comment_checker, test-generator
**Categorias**: quick, unspecified-low

**Fortalezas**:
- Rapido. Codigo funcionalmente correcto.
- Bueno para tareas donde la velocidad > pulido.
- Docstring con detalles utiles (ej: nota sobre F(1)=1, F(2)=1).

**Debilidades**:
- **Efecto secundario no deseado**: escribio archivo a disco sin que se le pidiera.
- Menos pulido que v4-pro (omite edge cases como chequeo de `bool` en `isinstance`).
- Signos leves de rushed finish.

**Recomendaciones de configuracion**:
- Considerar anadir `permission: { edit: "ask" }` en categorias quick/unspecified-low.
- Prompt debe explicitar "no escribas archivos, solo devuelve el codigo".
- Monitorear comportamiento en sesiones largas.

**Cuando usar**:
- Tareas rapidas y simples (quick, unspecified-low)
- Busqueda y exploracion de codigo (explore, librarian)
- Generacion de tests y revision de comentarios (test-generator, comment_checker)
- No usar para tareas criticas o que requieran precision de edge cases

---

## minimax-m3

**Agentes asignados**: (ninguno directo)
**Categorias**: visual-engineering

**Fortalezas**:
- Excelente en UI/UX. Agrega accesibilidad no solicitada (`focus-visible`).
- Paleta de colores profesional (#2563eb -> #1d4ed8 -> #1e40af), transiciones suaves.
- Respuesta mas completa que modelos de coding en tareas visuales (~950 chars).
- Box-shadows progresivos, estados hover/active bien diferenciados.

**Debilidades**:
- Solo testeado en tareas visuales. Comportamiento en otros dominios desconocido.
- Sin agentes asignados directamente — solo via categoria.

**Recomendaciones de configuracion**:
- Sin cambios. Usar exclusivamente para visual-engineering.
- Fallback actual: `deepseek-v4-pro`. Buen respaldo si falla.
- No reasignar a otras categorias sin testear.

**Cuando usar**:
- EXCLUSIVAMENTE para tareas visuales (UI, CSS, animaciones, diseno)
- NO usar para logica de negocio, backend, o analisis

---

## qwen3.7-max

**Agentes asignados**: oracle, prometheus, spec-writer
**Categorias**: (ninguna — solo via subagent_type)

**Fortalezas**:
- Analisis preciso. Identifico el bug off-by-one correctamente.
- Bueno para tareas de razonamiento puro y planificacion.

**Debilidades**:
- **RUSHED FINISH CONFIRMADO** — pero SOLO cuando se usa sin configuracion de agente (`agent=build`): ~150 chars, 2 oraciones.
- **CAUSA RAIZ**: qwen3.7-max necesita `textVerbosity: medium` y `prompt_append` con instrucciones de estructura. Sin ellas, el modelo hace el minimo absoluto.
- **VERIFICADO (2026-07-30)**: Con `agent=oracle` + `textVerbosity: medium` + `prompt_append`, la respuesta crece a ~500 chars con analisis estructurado, 3 bugs encontrados, y fix robusto.

**Recomendaciones de configuracion**:
- **APLICADO (2026-07-30)**: Anadida regla anti-truncamiento al prompt_append de oracle: "NUNCA des respuestas de menos de 3 parrafos. El rushed finish es inaceptable."
- Usar qwen3.7-max SIEMPRE via su agente configurado (oracle, prometheus, spec-writer). NUNCA con `agent=build`.
- Si se usa en CLI: `--agent oracle --model opencode-go/qwen3.7-max` para activar la configuracion completa.
- Si el rushed finish reaparece, bump `textVerbosity` de `"medium"` a `"high"`.

**Cuando usar**:
- Analisis y planificacion (oracle, prometheus, spec-writer)
- NO para tareas que requieran respuestas extensas sin configuracion adicional
- Monitorear longitud de respuestas — si bajan de 300 chars, investigar

---

## kimi-k2.6

**Agentes asignados**: docs-writer
**Categorias**: (ninguna — solo via subagent_type)

**Fortalezas**:
- Excelente documentacion. La respuesta mas completa de todos los modelos (~1450 chars).
- JSDoc detallado con `@param`, `@returns`, `@example`.
- Incluye ejemplos de uso (con y sin parametros opcionales).
- Notas explicativas post-JSDoc. Profesional y detallado.
- Sin rushed finish.

**Debilidades**:
- Solo testeado en documentacion. Comportamiento en coding desconocido.
- Las respuestas pueden ser excesivamente largas para contextos ajustados.

**Recomendaciones de configuracion**:
- Sin cambios. Excelente para su dominio (docs-writer).
- `textVerbosity: low` con `prompt_append` enfocado en ejemplos. Funciona bien.
- Si se usa en contextos con poco presupuesto de tokens, anadir instruccion de brevedad.

**Cuando usar**:
- Documentacion tecnica (docs-writer)
- NO para coding o analisis sin testear antes

---

## Reglas Generales de Harness por Modelo

1. **deepseek-v4-pro**: Modelo principal. Usar para todo lo critico. Sin restricciones.
2. **deepseek-v4-flash**: Restringir permisos de escritura. Usar para tareas rapidas no criticas.
3. **minimax-m3**: Exclusivo para visual. No mezclar con otros dominios.
4. **qwen3.7-max**: REQUIERE anti-truncamiento en el prompt. Monitorear longitud de respuestas.
5. **kimi-k2.6**: Excelente para docs. No probado en otros dominios.

---

## Limitaciones de los Benchmarks

- Una sola tarea por modelo. No estadisticamente significativo.
- Los modelos se ejecutaron como `agent=build`, no con su configuracion completa de agente (`prompt_append`, `textVerbosity`).
- Se necesitan mas iteraciones y tests en dominios cruzados para conclusiones solidas.
- Proxima iteracion: testear con `--agent <nombre>` para activar configuracion completa.
- Duraciones aproximadas (~60s); todas las pruebas fueron en paralelo.
