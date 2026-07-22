# SDD (Spec-Driven Development) con OpenCode — Guía para el equipo

## ¿Qué es SDD?

**SDD significa "Spec-Driven Development": desarrollo guiado por especificaciones.**

Es una forma de trabajar donde, antes de escribir una sola línea de código, escribes un documento que define **exactamente** qué tiene que hacer el feature. Ese documento se llama **spec** (especificación).

Piénsalo como el plano de un edificio: no empiezas a poner ladrillos sin tener el plano. Con SDD, no empiezas a programar sin tener la spec.

---

## El problema que resuelve

### Situación típica (sin SDD)

```
Tú: "Añade autenticación JWT a la API"
OpenCode: *empieza a escribir código inmediatamente*

Resultado:
- Usa cookies en vez de headers → el frontend no funciona
- Se olvida del rate limiting → vulnerable a ataques de fuerza bruta
- Añade refresh tokens "por si acaso" → complejidad innecesaria
- El middleware es global → rompe las rutas públicas
- Los errores no tienen formato consistente → el frontend no sabe cómo manejarlos
```

**Problema real:** Revisas el código y no sabes si lo que hizo es lo que realmente querías. Tienes que leer toda la implementación para verificarlo. Y cuando encuentras algo mal, ya hay 200 líneas que corregir.

### Misma situación (con SDD)

```
Tú: "Añade autenticación JWT a la API"
OpenCode: "Antes de implementar, ¿genero una spec para definir exactamente
           qué endpoints necesitas, qué formato de errores, y qué queda fuera?"

Tú: "Sí"
OpenCode: *genera un documento specs/jwt-auth.md*

La spec define:
- 3 endpoints exactos (registro, login, perfil)
- Formato de errores para cada caso (códigos HTTP, cuerpo JSON)
- Qué SÍ incluye (JWT con Bearer tokens, bcrypt, rate limiting)
- Qué NO incluye (refresh tokens, OAuth, verificación de email)
- 16 criterios de aceptación verificables

Tú lees el documento (5 minutos). Apruebas.
OpenCode implementa EXACTAMENTE lo que dice la spec.

Resultado: 0 sorpresas. Todo coincide con lo que esperabas.
```

---

## ¿Por qué funciona mejor?

| Sin SDD | Con SDD |
|---|---|
| El agente **adivina** lo que quieres | La spec **define** lo que quieres |
| Revisas **código** (difícil, técnico) | Revisas **comportamiento** (fácil, legible) |
| Los errores se descubren **después** de implementar | Los problemas se detectan en la **spec**, antes de escribir código |
| Scope creep: el agente añade "extras" | La spec tiene una sección "Fuera de scope" que lo impide |
| Los tests se improvisan | Los tests salen de los criterios de aceptación de la spec |
| Si algo falla, no sabes si es bug o malentendido | Si algo falla, la spec te dice si es bug o no |

---

## Cómo funciona con OpenCode

Nuestra configuración de OpenCode con `oh-my-openagent` ya tiene todas las piezas. Solo hay que usarlas en el orden correcto:

```
Petición de feature
        ↓
   [Metis]       ← Analiza si hay ambigüedad, hace preguntas
        ↓
  [spec-writer]  ← Genera la spec formal (5-10 min)
        ↓
   [Momus]       ← Revisa la spec: ¿es completa? ¿es verificable? ¿hay ambigüedad?
        ↓
   [TÚ]          ← Lees la spec (5 min), apruebas o pides cambios
        ↓
  [Sisyphus]     ← Implementa siguiendo la spec. Sin improvisar.
        ↓
  [Oracle]       ← Verifica que el código cumple la spec
        ↓
  Feature terminado, verificado, sin sorpresas
```

**Cada spec vive en el repositorio del proyecto**, en una carpeta `specs/`. Así está versionada con git, igual que el código.

---

## Ejemplo real: un caso de uso completo

Imagina que estás construyendo una API de reservas de hotel. Pides:

> "Quiero que los usuarios puedan buscar hoteles disponibles por ciudad y fechas"

### Sin SDD: lo que OpenCode haría por su cuenta

El agente empieza a codificar. Decisiones que toma solo:

- Asume que los resultados van paginados de 10 en 10 (no lo pediste)
- Crea un endpoint `GET /hoteles/search?ciudad=X&checkin=Y&checkout=Z` (nombres en español mezclados, formato de fechas sin definir)
- No maneja el caso "no hay hoteles disponibles"
- No filtra hoteles que están completos, solo mira si existen
- Devuelve TODOS los campos del hotel (incluidos campos internos como `profit_margin`)

**Tardas 30 minutos revisando código para encontrar 5 problemas.**

### Con SDD: el proceso real

**Paso 1 — Metis analiza la petición**

Antes de escribir la spec, Metis detecta ambigüedad y te pregunta:

> "Algunas dudas antes de generar la spec:
> 1. ¿El formato de fechas es ISO 8601 (2026-07-15)?
> 2. ¿Los resultados deben ir paginados? Si sí, ¿cuántos por página?
> 3. ¿Qué información del hotel debe devolverse? (nombre, precio, estrellas, fotos...)
> 4. ¿Qué pasa si no hay hoteles disponibles? ¿Array vacío o error?"

Respondes en 2 minutos. Metis pasa el contexto a spec-writer.

**Paso 2 — spec-writer genera la spec**

En menos de un minuto, spec-writer escribe `specs/hotel-search.md`:

```markdown
# Spec: Búsqueda de hoteles disponibles

**Status:** draft | **Author:** @carlos | **Date:** 2026-07-08

## Resumen
Los usuarios pueden buscar hoteles disponibles filtrando por ciudad y rango de fechas
(check-in / check-out). El sistema devuelve solo hoteles con disponibilidad real en
esas fechas, con info relevante para el usuario. Sin filtros avanzados en esta iteración.

## Endpoints

### GET /hotels/search

**Input (query params):**
- city: string — nombre de la ciudad (obligatorio)
- checkin: string — fecha ISO 8601 (YYYY-MM-DD), obligatorio
- checkout: string — fecha ISO 8601 (YYYY-MM-DD), obligatorio
- page: number — opcional, default 1
- limit: number — opcional, default 20, máximo 50

**Validación:**
- checkin debe ser >= hoy
- checkout debe ser > checkin
- limit entre 1 y 50

**Output (éxito, 200):**
{
  "results": [
    {
      "id": "abc123",
      "name": "Hotel Playa",
      "stars": 4,
      "pricePerNight": 120.00,
      "currency": "EUR",
      "mainPhoto": "https://..."
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 45,
    "totalPages": 3
  }
}

**Errores:**
- 400 Fechas inválidas → { error: "INVALID_DATES", detail: "checkout debe ser posterior a checkin" }
- 400 Parámetros faltantes → { error: "MISSING_PARAMS", fields: ["city"] }
- 200 Sin resultados → { results: [], pagination: { total: 0, ... } }

**Edge cases:**
- Ciudad no existe en la DB → resultados vacíos (no error)
- Hotel con solo 3 días disponibles en un rango de 5 → NO se muestra
- checkin = checkout → error 400
- Fechas en pasado → error 400 si checkin < hoy

## Reglas de negocio
- Solo hoteles con >= 1 habitación disponible TODOS los días del rango
- Precio por noche, EUR, impuestos incluidos
- Resultados ordenados por precio (más barato primero)
- No se muestran campos internos (profit_margin, owner_id, etc.)

## Criterios de aceptación
- [ ] GET /hotels/search?city=Barcelona&checkin=2026-08-01&checkout=2026-08-05 → hoteles disponibles
- [ ] GET /hotels/search?city=Barcelona&checkin=2026-08-01&checkout=2026-07-30 → 400 INVALID_DATES
- [ ] GET /hotels/search?city=CiudadQueNoExiste&checkin=2026-08-01&checkout=2026-08-05 → 200 con results: []
- [ ] Hotel con disponibilidad parcial → NO aparece
- [ ] Respuesta NO incluye campos internos
- [ ] Paginación: page=2&limit=10 devuelve segunda página correctamente
- [ ] limit=100 → 400 (máximo es 50)

## Fuera de scope
- Filtros adicionales (precio máximo, estrellas, servicios)
- Ordenación por otros criterios (estrellas, distancia)
- Fotos adicionales (solo mainPhoto)
- Mapa / geolocalización
```

**Paso 3 — Momus revisa la spec**

Momus detecta:

- "La spec no dice si el precio es por noche o total. Asumo por noche, pero confírmalo."
- "Falta el edge case: ¿qué pasa si la ciudad tiene espacios? ('New York' vs 'New+York')"
- "Los criterios de aceptación no cubren el caso de checkout = checkin."

Añades esas correcciones en 1 minuto. Spec lista.

**Paso 4 — Tú apruebas la spec**

Lees el documento (menos de 5 minutos). Ves que:
- Las fechas van en ISO 8601 (no hay ambigüedad)
- Sabes exactamente qué campos devuelve cada hotel
- Sabes que los hoteles sin disponibilidad NO aparecen
- Sabes que los filtros avanzados van en otra spec

**Das el OK.**

**Paso 5 — Sisyphus implementa**

Sisyphus recibe la spec y la usa como guía. No improvisa:
- Crea exactamente el endpoint descrito
- Valida exactamente los casos de error descritos
- No añade filtros extra "por si acaso"
- No expone campos internos

**Paso 6 — Oracle verifica**

Oracle compara el código implementado con la spec y confirma:
- Todos los endpoints devuelven los códigos y cuerpos descritos
- Los edge cases están cubiertos
- Los campos internos no se filtran
- El scope se respetó (sin filtros extra)

**Resultado: feature implementado en ~15 minutos de tu tiempo (vs 45+ sin SDD). Sin sorpresas. Sin retrabajo.**

---

## Comparación de tiempo real

| Fase | Sin SDD | Con SDD |
|---|---|---|
| Definir qué quieres | 1 min (una frase) | 3 min (responder preguntas de Metis) |
| Revisar | 30 min (leer código) | 5 min (leer spec) |
| Corregir malentendidos | 20 min (reescribir código) | 2 min (editar spec) |
| Implementar | 5 min (automático) | 5 min (automático) |
| Verificar | 10 min (testear manualmente) | 0 min (Oracle lo verifica) |
| **Total TU tiempo** | **~65 min** | **~10 min** |

El tiempo del agente es el mismo (~5 min). La diferencia está en **tu tiempo de revisión y corrección**.

---

## Cómo configurarlo (para quien no lo tenga aún)

Si tienes OpenCode + oh-my-openagent, necesitas añadir 3 cosas:

### 1. Crear el agente spec-writer

Crear el archivo `~/.config/opencode/agents/spec-writer.md` con este contenido:

```markdown
---
description: "Genera especificaciones formales (SDD) a partir de peticiones de features"
mode: subagent
model: opencode-go/qwen3.7-max
temperature: 0.2
permission:
  read: allow
  glob: allow
  grep: allow
  edit: ask
  bash: deny
---

Eres un escritor de especificaciones para Spec-Driven Development.
Tu función es convertir peticiones de features en especificaciones formales,
detalladas y verificables. La spec es un contrato: define QUÉ (no CÓMO).

## Filosofía

Una buena spec debe permitir que cualquier desarrollador o agente implemente
exactamente lo esperado sin ambigüedad. La spec es la fuente de verdad.

## Cuándo intervenir

Cuando el usuario pide un feature nuevo:
1. Haz preguntas aclaratorias si hay ambigüedad
2. Genera la spec siguiendo la estructura estándar
3. Espera aprobación antes de implementar

## Estructura obligatoria de la spec

Toda spec debe tener:

### Resumen
2-4 frases explicando qué hace el feature y para quién.

### Endpoints / Interfaces
Para cada endpoint o componente:
- Input (tipos, validaciones)
- Output éxito (código, cuerpo, formato)
- Errores (cada caso con código y cuerpo)
- Side effects (qué cambia en el sistema)
- Edge cases (casos límite específicos)

### Modelos de datos
Schemas, tipos o interfaces nuevas.

### Reglas de negocio
Cada regla como bullet point verificable.

### Criterios de aceptación (OBLIGATORIO)
Checklist de cosas medibles. Nada de "funciona bien".
Cosas como: "POST /login con credenciales correctas devuelve 200 y token JWT"

### Fuera de scope (OBLIGATORIO)
Lo que NO se implementa en esta spec. Previene scope creep.

### Dependencias
Librerías, APIs externas, variables de entorno necesarias.

## Reglas

- SÉ EXHAUSTIVO: cada endpoint debe tener TODOS los campos
- DETECTA AMBIGÜEDAD: si algo no está claro, PREGUNTA antes de generar la spec
- PIENSA EN EDGE CASES: inputs vacíos, nulos, límites, concurrencia, fallos externos
- NO IMPLEMENTES: tu trabajo termina cuando la spec está aprobada
- USA EL IDIOMA DEL USUARIO
```

### 2. Crear la plantilla de spec

Crear el archivo `~/.config/opencode/.omo/spec-template.md` (copia el ejemplo de arriba, el de búsqueda de hoteles, como referencia).

### 3. Actualizar oh-my-openagent.json

Añadir el agente `spec-writer` en la sección `agents`:

```json
"spec-writer": {
  "model": "opencode-go/qwen3.7-max",
  "textVerbosity": "medium",
  "permission": {
    "edit": "ask",
    "bash": "deny"
  },
  "prompt_append": "Eres un escritor de especificaciones para SDD. Genera specs formales, detalladas y verificables. La spec es un contrato: define QUÉ (no CÓMO). Usa la plantilla de .omo/spec-template.md."
}
```

Y añadir esto al final del `prompt_append` del agente `sisyphus` (después del texto de Caveman):

```
SDD WORKFLOW: Cuando el usuario pida un feature nuevo, sugiere crear una spec primero.
Flujo: Metis → spec-writer → Momus → aprobación → implementar → Oracle.
Triggers: "añadir feature", "crear nuevo", "implementar X", "haz un".
Excepciones: bugs, typos, cambios de una línea → sin spec.
NUNCA implementes un feature no trivial sin ofrecer spec primero.
```

---

## Cuándo usar SDD (y cuándo no)

### Usar SDD para:

- Features nuevos (cualquier cosa que implique 2+ archivos)
- Cambios de comportamiento (la API devuelve cosas distintas)
- Refactors con cambio de interfaz
- Integraciones con APIs externas
- Migraciones de datos

### NO usar SDD para:

- Arreglar un bug (el comportamiento ya está definido, solo está roto)
- Cambiar un texto o traducción
- Ajustar configuraciones
- Renombrar variables
- Añadir un log

**Regla general:** si puedes describir el cambio en una frase sin ambigüedad, no necesitas spec. Si necesitas 2+ frases para explicarlo, mejor haz spec.

---

## Preguntas frecuentes

### "¿No es más lento hacer una spec primero?"

Al revés. La spec tarda 5-10 minutos en generarse (lo hace spec-writer solo). El tiempo que ganas al NO tener que revisar código ni corregir malentendidos es mucho mayor. En el ejemplo de arriba: 10 min con SDD vs 65 min sin SDD.

### "¿Qué pasa si la spec no cubre algo que descubro durante la implementación?"

Actualizas la spec. Es un documento vivo. Lo importante es que el cambio se documenta y se aprueba ANTES de implementarse, no después.

### "¿Las specs no se quedan obsoletas?"

Al contrario. Como la spec es el contrato que Oracle usa para verificar, si el código no coincide con la spec, Oracle te lo dice. La spec solo se actualiza cuando el comportamiento cambia intencionadamente.

### "¿Tengo que escribir la spec yo?"

No. Se la pides a OpenCode: "Genera una spec para X". El agente spec-writer la crea. Tú solo la revisas y apruebas.

### "¿Esto funciona con cualquier proyecto?"

Sí. La spec es un documento markdown en tu repo. Funciona con APIs REST, GraphQL, frontend, CLI tools, librerías, lo que sea. Solo cambia la sección "Endpoints" por "Interfaces", "Componentes" o lo que corresponda.

---

## Resumen en 3 frases

1. **Spec primero, código después.** Define QUÉ antes de decidir CÓMO.
2. **La spec es un contrato.** Si el código la cumple, el feature está bien. Si no, no.
3. **Tú revisas specs (5 min), no código (30 min).** El tiempo lo ganas en revisión, no en generación.
