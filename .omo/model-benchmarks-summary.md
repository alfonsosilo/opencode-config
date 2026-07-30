# Model Benchmarks Summary

**Date:** 2026-07-30  
**Methodology:** Each model tested on its optimized domain via `opencode run --model <model> --pure --auto`. Parallel execution. Evaluated with `.omo/evaluator-rubric.md` criteria.

## Results Matrix

| # | Model | Task | Domain | Correccion | Calidad | Overall | Rushed? | Response (chars) |
|---|-------|------|--------|------------|---------|---------|---------|------------------|
| 1 | **deepseek-v4-pro** | Fibonacci (Python) | Coding (deep) | A | A | **A** | No | ~500 |
| 2 | **deepseek-v4-flash** | Fibonacci (Python) | Coding (quick) | A | B | **B** | Yes | ~550 |
| 3 | **minimax-m3** | HTML Button + CSS | UI (visual-engineering) | A | A | **A** | No | ~950 |
| 4 | **qwen3.7-max** | Bug analysis (JS) | Analysis (oracle) | A | C | **B** | **Yes** | ~150 |
| 5 | **kimi-k2.6** | JSDoc documentation | Docs (docs-writer) | A | A | **A** | No | ~1450 |

## Key Observations

### Strengths by Domain

- **deepseek-v4-pro** (deep/ultrabrain): Produjo codigo Python idiomatico con edge cases sutiles (bool check en isinstance). Calidad A consistente. Excelente para tareas de coding complejas.
- **deepseek-v4-flash** (quick): Codigo correcto pero con efectos secundarios no deseados (escribio archivo en disco). Menos pulido que v4-pro. Bueno para tareas rapidas donde la perfeccion no es critica.
- **minimax-m3** (visual-engineering): Sobresaliente en UI. Agrego accesibilidad (focus-visible) no solicitada. Paleta de colores profesional con transiciones. Claramente el mejor para tareas visuales.
- **qwen3.7-max** (oracle): Preciso en el analisis pero **extremadamente conciso**. Identifico el bug correctamente en 2 oraciones. No elaboro, no sugirio fixes. Posible rushed finish.
- **kimi-k2.6** (docs-writer): Excelente documentacion JSDoc con ejemplos, parametros detallados, notas explicativas. La respuesta mas completa. Ideal para documentacion tecnica.

### Rushed Finish Detection

- **qwen3.7-max** muestra el patron mas claro de "rushed finish": solo 150 caracteres (~2 oraciones) para una tarea de analisis. Posible causa: configuracion `textVerbosity: "medium"` en agente oracle, pero al ejecutarse como `agent=build` (sin configuracion especifica de verbosity), el modelo puede haber usado un modo mas agresivo de truncamiento.
- **deepseek-v4-flash** muestra signos leves: escribio archivo a disco (side effect) en vez de solo devolver codigo, y omitio chequeo de bool.
- Los demas modelos no mostraron rushed finish.

### Model-Specific Harness Recommendations

1. **deepseek-v4-pro**: Sin cambios. Rendimiento solido. Usar para tareas deep/ultrabrain/criticas.
2. **deepseek-v4-flash**: Agregar `permission: { edit: "ask" }` para evitar efectos secundarios no deseados. Considerar prompt que explicite "no escribas archivos".
3. **minimax-m3**: Sin cambios. Excelente en UI/visual.
4. **qwen3.7-max**: Investigar si el rushed finish es por configuracion de agente (oracle tiene `textVerbosity: medium`, pero al usar `agent=build` esto no aplica). Recomendacion: aumentar verbosity en su configuracion de agente y anadir prompt anti-truncamiento.
5. **kimi-k2.6**: Sin cambios. Excelente en documentacion.

## Limitations

- Todas las pruebas usaron `agent=build` (default de `opencode run`) en vez del agente configurado especifico. Esto significa que los modelos NO usaron sus `prompt_append` ni configuraciones de `textVerbosity` personalizadas. Pruebas futuras deberian usar `--agent <name>` para activar la configuracion completa.
- Duracion estimada (~60s) es aproximada; todas las pruebas se lanzaron en paralelo.
- Muestra pequena (1 tarea por modelo). Para conclusiones estadisticamente significativas se necesitan mas iteraciones.
