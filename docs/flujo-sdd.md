# Flujo SDD (Spec-Driven Development)

SDD invierte el orden tradicional: **especificacion antes que codigo**. La spec es el contrato. El codigo se revisa contra la spec, no al reves.

---

## Que es SDD

En lugar de:

```
Usuario pide → Implementas → Usuario revisa → Corriges → Revisa → ...
```

SDD propone:

```
Usuario pide → Generas spec → Usuario APRUEBA spec → Implementas → Verificas contra spec
```

La spec actua como contrato inmutable. Una vez aprobada, no se cambia sin re-aprobacion.

## Cuando usar SDD

### Usar SDD (OBLIGATORIO)

- Features nuevas que tocan **2 o mas archivos**
- Cambios de **comportamiento** visible (no solo estructura interna)
- Refactors que modifican **interfaces publicas** (APIs, exports, tipos compartidos)
- Integraciones con **APIs externas** (nuevos endpoints, webhooks, servicios)
- **Migraciones de datos** (schema changes, transformaciones)

### NO usar SDD

- Bug fixes puntuales (arreglar una condicion, un typo, un null check)
- Cambios de texto, labels, mensajes
- Tweaks de configuracion
- Renombrar variables locales
- Agregar/eliminar logs o comentarios

## El pipeline SDD paso a paso

```
Paso 1: Metis analiza la ambiguedad
        ↓
Paso 2: spec-writer genera la especificacion
        ↓
Paso 3: Momus revisa la especificacion
        ↓
Paso 4: Usuario aprueba o rechaza
        ↓ (si aprueba)
Paso 5: Sisyphus implementa segun la spec
        ↓
Paso 6: Oracle verifica implementacion contra spec
```

### Paso 1: Metis (analisis de ambiguedad)

Ante una solicitud ambigua, Metis:
- Clarifica el alcance real
- Identifica dependencias ocultas
- Propone enfoques alternativos

### Paso 2: spec-writer (generacion de spec)

Genera la especificacion usando la plantilla en `.omo/spec-template.md`.

### Paso 3: Momus (revision)

Momus revisa la spec contra los criterios de calidad:
- Cada requisito es medible?
- Los casos edge estan cubiertos?
- Las dependencias son explicitas?

### Paso 4: Aprobacion del usuario

**El usuario DEBE aprobar explicitamente la spec** antes de escribir una linea de codigo. No asumas aprobacion por silencio.

### Paso 5: Implementacion

Sisyphus implementa siguiendo la spec como unica fuente de verdad. Si surge un conflicto entre la spec y la intuicion, **gana la spec**. Si la spec parece incorrecta, vuelve al paso 2 (re-especificar), no al paso 5.

### Paso 6: Verificacion Oracle

Oracle compara la implementacion final contra la spec. Responde:
- La implementacion satisface todos los criterios de aceptacion?
- Hay desviaciones no documentadas?
- La spec necesita actualizarse para reflejar la realidad?

## Estructura de la especificacion

Toda spec generada debe contener estas secciones:

```markdown
# [Titulo de la feature]

## Resumen
Descripcion concisa de la feature en 2-3 parrafos.

## Endpoints / Interfaces
- Nuevos endpoints, signatures de funciones publicas, tipos exportados.

## Modelos de datos
- Schemas, tipos, validaciones. Cambios en la base de datos.

## Reglas de negocio
- Validaciones, restricciones, flujos condicionales.

## Criterios de aceptacion
- Lista de escenarios verificables (Given/When/Then o bullets concretos).

## Fuera de scope
- Lo que explicitamente NO incluye esta feature.

## Dependencias
- Otras features, librerias, servicios externos necesarios.
```

## Ubicacion de specs

- **Plantilla**: `.omo/spec-template.md` (en el repositorio del proyecto)
- **Specs**: `specs/` (directorio en el repositorio del proyecto, no en `.config/opencode`)
- **Nombrado**: `specs/YYYY-MM-DD-nombre-feature.md`

## Reglas del contrato

1. La spec aprobada es **inmutable** durante la implementacion
2. Si necesitas cambiar algo, **re-especifica y re-aprueba**
3. No hay "mini-desviaciones justificadas". Cambio = re-aprobacion
4. El Oracle verifica contra la spec, no contra tu intencion

## Excepciones de emergencia

Si durante la implementacion encuentras un **bloqueo critico** que la spec no preve:

1. Documenta el bloqueo
2. Propone el cambio minimo necesario
3. Pide aprobacion del usuario para el cambio puntual
4. Actualiza la spec
5. Continua

No te saltes la spec "solo por esta vez".

---

## Referencias cruzadas

- Para los agentes del pipeline (Metis, Momus, Oracle): [uso-oracle.md](uso-oracle.md)
- Para las puertas de verificacion de cada paso: [phase-gates.md](phase-gates.md)
- Para la estructura de delegacion en la implementacion: [guia-delegacion.md](guia-delegacion.md)
