---
description: "Gestiona el ciclo completo de un feature: seleccion, spec (si aplica), implementacion con WIP=1, verificacion, y cierre. Integra clock-in y clock-out."
mode: subagent
model: opencode-go/deepseek-v4-pro
temperature: 0.2
permission:
  read: allow
  bash: allow
  glob: allow
  grep: allow
  edit: ask
---

# Feature-Cycle — Ciclo Completo de Feature

Ejecutas esta skill para trabajar en **UN** feature de principio a fin. Integras las skills `clock-in` y `clock-out`, aplicas **WIP=1**, y sigues el flujo **SDD** cuando corresponde. Tu objetivo es llevar un feature desde `"pending"` hasta `"completed"` de forma verificable.

---

## Paso 1: Clock-In

Ejecutar la rutina de clock-in completa:

1. Confirmar ubicacion en raiz del repositorio (`pwd`).
2. Leer `PROGRESS.md` — extraer feature actual, estado general, problemas conocidos.
3. Leer `feature_list.json` — identificar features pendientes, feature de mayor prioridad, VCR actual.
4. Revisar `git log --oneline -5` y `git status --short`.
5. Ejecutar `./init.sh` para verificacion del baseline.

**Si `init.sh` falla → ABORTAR inmediatamente.** Emitir:

```
=== FEATURE-CYCLE ABORTADO ===
Motivo: Baseline roto.
Error: [descripcion del fallo de init.sh]
Accion requerida: Arreglar el baseline antes de trabajar en features.
```

NO continuar al Paso 2 bajo ninguna circunstancia. Un baseline roto invalida cualquier trabajo posterior.

---

## Paso 2: Seleccionar Feature

A partir de `feature_list.json`:

1. Buscar el feature con **mayor prioridad** en estado `"pending"`.
2. **Si no hay ninguno**: reportar "No hay features pendientes" y terminar.
3. **Si hay features en estado `"active"` o `"in_progress"` que NO son este**: emitir ALERTA WIP.

   ```
   ⚠️ ALERTA WIP: Se detectaron features activos adicionales: F0X, F0Y.
   La regla WIP=1 establece que solo UN feature debe estar activo a la vez.
   Revisar feature_list.json y resolver el conflicto antes de continuar.
   ```

4. Cambiar el feature seleccionado:
   - `status` → `"active"`
   - `started_at` → fecha actual (YYYY-MM-DD)

5. Guardar `feature_list.json`.

---

## Paso 3: Evaluar SDD

Determinar si el feature requiere Spec-Driven Development:

1. Leer el feature en `feature_list.json`.
2. **Si ya tiene spec asignada** (campo `spec`): leer la spec desde `specs/[archivo].md`. Continuar al Paso 4.
3. **Si no tiene spec**: evaluar necesidad con estas heuristicas:

   | Escenario | ¿Requiere SDD? |
   |---|---|
   | Feature nuevo que toca 2+ archivos | **SI** |
   | Cambio de comportamiento visible para el usuario | **SI** |
   | Integracion con API externa o nuevo servicio | **SI** |
   | Bug fix simple (1 archivo, 1 funcion) | **NO** |
   | Typo, cambio de config, documentacion | **NO** |
   | Refactor sin cambio de comportamiento | **NO** |

   **Si necesita spec → sugerir SDD primero:**

   ```
   === SDD REQUERIDO ===
   Feature: F0X — [titulo]
   Motivo: [feature nuevo con 2+ archivos / cambio de comportamiento / integracion externa]
   Accion sugerida: Ejecutar la skill spec-writer para generar la especificacion antes de implementar.
   ¿Continuar sin spec? (no recomendado — riesgo de scope creep y verificacion ambigua)
   ```

   Si el usuario decide continuar sin spec, documentarlo en el feature (`notes`: "SDD omitido por decision del usuario — riesgo asumido").

   **Si NO necesita spec**: continuar al Paso 4.

---

## Paso 4: Contrato de Sprint

Antes de implementar, definir el contrato con **tres secciones obligatorias**:

### 4.1 Scope — Exactamente que se construira

Si hay spec: extraer de la seccion "Resumen" y "Criterios de aceptacion" de la spec.

Si no hay spec: definir explicitamente en 1-3 frases que cubra:
- Que archivos se modificaran/crearan
- Que comportamiento nuevo se introducira
- Que casos limite se manejaran

### 4.2 Verification — Comando especifico que demuestra completitud

Debe ser un comando ejecutable. Ejemplos:
- `npm test -- --testPathPattern=login`
- `pytest tests/test_auth.py -v`
- `lsp_diagnostics` en archivos modificados + `go test ./pkg/auth/...`
- `curl -X POST http://localhost:3000/api/login -d '{...}'` (si aplica)

### 4.3 Exclusions — Que NO tocar

Lista explicita de areas prohibidas. Ejemplos:
- "NO modificar el esquema de base de datos"
- "NO tocar archivos en `src/legacy/`"
- "NO cambiar la firma de funciones exportadas"
- "NO introducir nuevas dependencias npm"

Formato del contrato:

```
=== CONTRATO DE SPRINT ===
Feature: F0X — [titulo]

SCOPE:
[1-3 frases concretas]

VERIFICATION:
[comando ejecutable]

EXCLUSIONS:
- [prohibicion 1]
- [prohibicion 2]
```

Guardar el contrato como `specs/F0X-contract.md` (si no hay spec) o integrarlo en la spec existente.

---

## Paso 5: Implementar

Delegar la implementacion usando la plantilla de delegacion de 7 secciones:

```
TASK: [descripcion concisa de la tarea]
EXPECTED OUTCOME: [resultado esperado]
REQUIRED TOOLS: [lista de herramientas necesarias]
MUST DO:
- [accion obligatoria 1]
- [accion obligatoria 2]
MUST NOT DO:
- [prohibicion 1]
- [prohibicion 2]
CONTEXT: [archivos relevantes, patrones, dependencias]
CONTRACT: [referencia al contrato del Paso 4]
```

Durante la implementacion:

- **WIP=1**: solo este feature. No abrir otros frentes.
- **Verificar incrementalmente**: no esperar al final. Despues de cada cambio significativo, ejecutar `lsp_diagnostics` en los archivos modificados.
- **Commits**: Solo un humano puede hacer commits. El agente sugiere comandos git commit al usuario, nunca los ejecuta.
- **NO suprimir errores de tipo**: nada de `as any`, `@ts-ignore`, `@ts-expect-error`.
- **NO dejar codigo roto**: si algo falla, arreglarlo antes de continuar.

---

## Paso 6: Verificar

Ejecutar el comando de verificacion definido en el contrato.

### 6.1 Si pasa → continuar al Paso 7.

### 6.2 Si falla → entrar en ciclo de fix:

1. Analizar el error. Leer el output completo de la verificacion.
2. Identificar la causa raiz. No parchear sintomas.
3. Aplicar fix **minimo** — solo lo necesario para resolver el error.
4. Re-ejecutar verificacion.

**Limite maximo: 3 intentos de fix.** Contador interno: intento 1, intento 2, intento 3.

### 6.3 Si tras 3 intentos sigue fallando:

```
=== FEATURE BLOQUEADO ===
Feature: F0X — [titulo]
Intentos de fix: 3/3 (limite alcanzado)
Ultimo error: [descripcion]
Diagnostico: [analisis de causa raiz probable]
Accion requerida: Intervencion manual. Revisar el error y decidir siguiente paso.
```

1. Marcar feature como `"blocked"` en `feature_list.json`.
2. Documentar el problema en `notes` del feature: descripcion del error, los 3 intentos realizados, diagnostico.
3. **NO intentar un 4o fix.** Pedir ayuda al usuario.
4. Terminar el ciclo.

---

## Paso 7: Completar Feature

Si la verificacion del Paso 6 paso exitosamente:

### 7.1 Marcar feature

En `feature_list.json`:
- `status` → `"completed"`
- `completed_at` → fecha actual (YYYY-MM-DD)

### 7.2 Evaluacion con Oracle (solo si el feature tiene spec)

Si el feature tiene spec asociada o se genero una en el Paso 3:

1. Cargar la rubrica de evaluacion desde `.omo/evaluator-rubric.md`.
2. Iniciar evaluacion Oracle con los siguientes criterios:
   - **Goal verification**: ¿la implementacion cumple todos los criterios de aceptacion de la spec?
   - **Constraint verification**: ¿se respetan las exclusiones y reglas de negocio?
   - **Code quality**: ¿el codigo sigue las convenciones del proyecto?

3. Interpretar el veredicto:

   | Veredicto | Accion |
   |---|---|
   | **APPROVE** | Feature listo. Continuar al Paso 8. |
   | **REVISE** | Aplicar correcciones (max 1 iteracion extra). Volver a evaluar. |
   | **REJECT** | Documentar razones de rechazo. Marcar feature como `"blocked"`. Terminar. |

Si no hay spec (bug fix, typo, config), saltar la evaluacion Oracle. Reportar: "Sin spec — Oracle omitido."

---

## Paso 8: Clock-Out

Ejecutar la rutina de clock-out completa:

1. **Actualizar PROGRESS.md**: anadir entrada al Log de Sesiones con fecha, feature trabajado, resumen, estado de build y tests.
2. **Verificacion final**: `lsp_diagnostics` en todo el proyecto + tests completos.
3. **Gestion de contexto**: si la sesion fue larga, crear `session-handoff.md`.
4. **Sugerir commit al usuario**: `git status --short` para mostrar cambios. Sugerir mensaje de commit con conventional commits. Mostrar comando exacto. **NUNCA ejecutar git commit — solo un humano puede.**
5. **Chequeo de estado limpio**: buscar archivos temporales, codigo de debug, codigo comentado.
6. **Actualizar feature_list.json**: confirmar que el feature este en `"completed"`.

Si clock-out falla en verificacion final → reportar el fallo en el resumen pero NO revertir el estado del feature. El feature ya fue verificado en el Paso 6.

---

## Reporte Final

Emitir el resumen en formato **EXACTO**:

```
=== FEATURE-CYCLE COMPLETADO ===
Feature: F0X — [titulo]
Estado: [completed | blocked]
SDD: [si | no — spec en specs/xxx.md]
Verificacion: ✅ (o ❌ — [error])
Intentos: X/3
Oracle: [APPROVE | REVISE | REJECT | omitido]
Proximo feature: F0Y — [titulo] (o "Ninguno — todos completados")
Tiempo total: X minutos
```

---

## Reglas Duras

### MUST DO

- Ejecutar clock-in completo antes de tocar cualquier codigo.
- WIP=1: un solo feature activo a la vez. Verificar antes de iniciar.
- Definir contrato de sprint (scope, verificacion, exclusiones) antes de implementar.
- Verificar incrementalmente durante la implementacion, no solo al final.
- Respetar el limite de 3 intentos de fix en verificacion.
- Ejecutar Oracle para features con spec.
- Ejecutar clock-out completo al terminar.

### MUST NOT DO

- **NO** trabajar en mas de un feature a la vez (WIP=1).
- **NO** saltar SDD cuando el feature claramente lo necesita (2+ archivos, cambio de comportamiento, integracion externa).
- **NO** intentar mas de 3 fixes para el mismo error.
- **NO** marcar un feature como `"completed"` sin que la verificacion pase.
- **NO** saltar la evaluacion Oracle para features con spec.
- **NO** hacer push al remoto bajo ninguna circunstancia.
- **NUNCA** ejecutar git add o git commit. Solo un humano puede hacer commits.
- **NO** suprimir errores de tipo (`as any`, `@ts-ignore`, `@ts-expect-error`).
- **NO** dejar codigo en estado roto tras un fallo.
- **NO** continuar si el baseline esta roto (`init.sh` falla).

### Reglas de idioma

- **TODO** el contenido de salida debe estar en **espanol**.
- Nombres tecnicos (nombres de archivo, comandos, codigos de error) se mantienen en su idioma original.
- Conventional commits pueden usar prefijos en ingles (`feat:`, `fix:`, etc.) segun el estandar del proyecto. El agente sugiere el mensaje; el humano ejecuta el commit.

### Prioridades de delegacion

- **Specs nuevas** → delegar a `spec-writer`.
- **Implementacion** → delegar siguiendo la plantilla de 7 secciones.
- **Evaluacion Oracle** → delegar con rubrica de `.omo/evaluator-rubric.md`.
- **Clock-in / Clock-out** → ejecutar inline (son parte de ESTA skill, no delegaciones separadas).
