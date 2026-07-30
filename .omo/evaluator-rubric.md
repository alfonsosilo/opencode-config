# Rubrica de Evaluacion

Usar esta rubrica para puntuar implementaciones de forma objetiva.
Cada dimension se puntua A (100%), B (75%), C (50%), D (25%).

## Dimensiones

| Dimension | A (100%) | B (75%) | C (50%) | D (25%) |
|-----------|----------|---------|---------|----------|
| Correccion | Todos los tests pasan. Edge cases y error cases cubiertos. | Flujo principal pasa. Edge cases parciales. | Solo happy path funciona. | Build falla o errores en runtime. |
| Arquitectura | Sigue todos los patrones del proyecto. Sin violaciones de capa ni dependencias circulares. | Sigue la mayoria de patrones. Desviaciones menores y documentadas. | Violaciones obvias de patrones establecidos o capas mezcladas. | Rompe la arquitectura (dependencias circulares, god objects, capas invertidas). |
| Cobertura tests | Happy path + edge cases + error cases. Usa mocks/fixtures del proyecto. | Solo flujo principal. Sin edge cases. | Esqueleto de tests sin asserts significativos. | Sin tests o tests que no prueban nada. |
| Calidad codigo | Limpio, idiomatico, naming claro, sin deuda tecnica. | Problemas menores (nombres ambiguos, formato). | Varios problemas (funciones >50 lineas, duplicacion, magic numbers). | Anti-patrones (god functions, comentarios en vez de codigo claro, anidamiento >4). |
| Scope | Exactamente lo pedido en la spec/contrato. Nada mas, nada menos. | Scope respetado. Un extra menor no solicitado pero util. | Scope creep evidente (features o endpoints no pedidos). | Fuera de scope -- construyo algo distinto a lo solicitado. |
| Verificabilidad | Cada criterio de aceptacion tiene un comando especifico que lo verifica. | La mayoria de criterios son verificables. | Algunos criterios son verificables, otros vagos ("funciona bien"). | Sin criterios de verificacion o todos son subjetivos. |

## Como puntuar

Para cada dimension, leer el codigo y la spec. Asignar la puntuacion que mejor describa lo observado. Si hay duda entre dos niveles, elegir el mas bajo (pesimista).

## Veredicto

- **APPROVE**: Minimo B en Correccion y Scope. Minimo C en el resto.
- **REVISE**: Alguna dimension con D (excepto Correccion o Scope con D → REJECT)
- **REJECT**: Correccion o Scope con D. La implementacion no cumple lo basico.

## Formato de salida

```
=== EVALUACION ===
Correccion:     [A/B/C/D] -- [justificacion 1 frase]
Arquitectura:   [A/B/C/D] -- [justificacion 1 frase]
Cobertura:      [A/B/C/D] -- [justificacion 1 frase]
Calidad:        [A/B/C/D] -- [justificacion 1 frase]
Scope:          [A/B/C/D] -- [justificacion 1 frase]
Verificabilidad:[A/B/C/D] -- [justificacion 1 frase]

VEREDICTO: [APPROVE | REVISE | REJECT]
```
