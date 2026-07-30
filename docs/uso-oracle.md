# Uso de Oracle, Metis y Momus

Guia para usar los tres agentes especializados de consulta y planificacion.

---

## Oracle: consultor de alto IQ (solo lectura)

Oracle es un agente de **solo lectura** con capacidad de razonamiento superior. Actua como consultor externo.

### Cuando consultar al Oracle

| Situacion | Accion |
|-----------|--------|
| Error despues de **2+ intentos fallidos** de fix | CONSULTA Oracle |
| Decision de arquitectura (patron, estructura, abstraccion) | CONSULTA Oracle |
| Preocupacion de seguridad (validacion, sanitizacion, auth) | CONSULTA Oracle |
| El usuario pide una opinion de diseno | CONSULTA Oracle |
| Code review de una implementacion significativa | CONSULTA Oracle |

### Cuando NO consultar al Oracle

- Operaciones simples (renombrar, mover, cambiar un string)
- Primer intento de fix de un bug
- Decisiones triviales (nombres de variables, formato)
- Cuando la respuesta es obvia del contexto

### Politica de background del Oracle

**Regla critica**: Si disparaste un Oracle en background, JAMAS entregues la respuesta final sin antes recoger el resultado del Oracle.

```typescript
// INCORRECTO: ignorar el Oracle
task(subagent_type="oracle", run_in_background=true, prompt="Revisa esta arquitectura")
// ... entregas tu respuesta sin esperar al Oracle

// CORRECTO: esperar y recoger
task(subagent_type="oracle", run_in_background=true, prompt="Revisa esta arquitectura")
// ... continuas con otro trabajo ...
// <system-reminder: Oracle completo>
background_output(task_id="bg_...")
// Ahora integras el feedback del Oracle en tu respuesta final
```

### Estructura de prompt para Oracle

```markdown
TASK: <problema especifico>

ARCHITECTURE GOAL: <objetivo de alto nivel>

CURRENT APPROACH: <lo que estas haciendo o planeas hacer>

SPECIFIC QUESTION: <pregunta concreta que necesitas resolver>

ALTERNATIVES CONSIDERED: <opciones que ya evaluaste>
```

## Metis: planificador pre-ejecucion

Metis analiza tareas ambiguas y produce planes de ejecucion estructurados.

### Cuando usar Metis

- Tareas **ambiguas** donde el usuario dio un objetivo difuso
- Tareas **complejas** con multiples componentes o dependencias
- Cuando no tienes claro el scope o los pasos necesarios

### Flujo tipico

```
Usuario: "Mejora el rendimiento de la API"
  → Metis analiza y propone plan concreto
    → Usuario aprueba o ajusta
      → Implementas segun el plan
```

### Lo que Metis produce

- Desglose de sub-tareas con dependencias
- Archivos y componentes afectados estimados
- Riesgos identificados
- Criterios de aceptacion

## Momus: revisor de planes

Momus revisa planes de ejecucion (especificaciones, task lists) contra criterios de calidad.

### Cuando usar Momus

- Despues de que Metis produce un plan (revision pre-aprobacion)
- Antes de ejecutar una feature compleja con spec
- Cuando el usuario pide "revisa este plan"

### Criterios de revision de Momus

- **Claridad**: Cada paso es concreto y accionable
- **Verificabilidad**: Cada paso tiene un criterio de exito medible
- **Completitud**: No faltan pasos ni casos edge
- **Dependencias**: El orden de ejecucion es correcto

## Flujo SDD con los tres agentes

El flujo completo de Spec-Driven Development integra los tres:

```
1. Metis (analizar ambiguedad, proponer enfoque)
2. spec-writer (generar spec concreta)
3. Momus (revisar spec contra criterios)
4. Usuario (aprobar spec)
5. Sisyphus (implementar segun spec)
6. Oracle (verificar implementacion contra spec)
```

Para el flujo SDD detallado, consulta [flujo-sdd.md](flujo-sdd.md).

## Disparadores y excepciones de SDD

| Gatillo | Usar SDD? |
|---------|-----------|
| Nueva feature (2+ archivos) | SI |
| Cambio de comportamiento | SI |
| Refactor con cambio de interfaces | SI |
| Integracion de API externa | SI |
| Migracion de datos | SI |
| Bug fix puntual | NO |
| Cambio de texto/config | NO |
| Renombrar variable | NO |
| Agregar log | NO |

---

## Referencias cruzadas

- Para el flujo SDD completo: [flujo-sdd.md](flujo-sdd.md)
- Para verificacion post-implementacion: [phase-gates.md](phase-gates.md)
- Para anti-patrones relacionados con Oracle: [anti-patrones.md](anti-patrones.md)
