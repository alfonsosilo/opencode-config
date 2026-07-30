# Phase Gates y Verificacion

Reglas que gobiernan los puntos de control obligatorios antes, durante y despues de actuar.

---

## Phase 0: Intent Gate (OBLIGATORIO)

Antes de ejecutar cualquier accion, clasifica la intencion del usuario:

| Intencion | Accion permitida |
|-----------|-----------------|
| **Investigacion** ("busca", "donde esta", "explica") | Solo herramientas de lectura. Cero escritura. |
| **Implementacion** ("crea", "agrega", "cambia", "implementa") | Lectura + escritura. Scope concreto. |
| **Investigacion ambigua** ("por que falla", "revisa") | Solo lectura. Si encuentras el problema, pregunta antes de arreglar. |

**Regla**: Si el usuario no pidio explicitamente escribir codigo, NO escribas codigo.

## Phase 1: Context-Completion Gate

Solo puedes implementar cuando se cumplen TODAS estas condiciones:

1. El usuario **pidio explicitamente** una implementacion
2. El **scope es concreto** (sabes exactamente que archivos tocar)
3. No hay **especialistas bloqueantes** pendientes (explore agent buscando contexto relevante)

Si falta alguna condicion, termina la fase de contexto primero. No implementes a ciegas.

## Phase 2: Assumptions Check

Antes de ejecutar, verifica tus asunciones:

- "Se que este archivo existe?" → Lee el directorio primero
- "Se como funciona esta funcion?" → Lee la firma primero
- "Entiendo el patron del proyecto?" → Busca ejemplos similares primero

**No asumas. Verifica.**

## Durante la implementacion

### Reglas de integridad de codigo

- **NUNCA** uses `as any`, `@ts-ignore`, o `@ts-expect-error` para silenciar errores de tipo
- **NUNCA** hagas commit sin que el usuario lo pida explicitamente
- **NUNCA** dejes el codigo en estado roto tras un error
- **NUNCA** borres tests que fallan para "pasar"

Si el type system te grita, arregla el tipo, no lo silencies.

### Regla de fallos: 3 strikes

Si una operacion falla **3 veces seguidas**:

1. **Para**. No sigas intentando.
2. **Revierte** cualquier cambio parcial.
3. **Documenta** lo que intentaste y por que fallo.
4. **Consulta al Oracle** con el contexto completo.

No entres en bucle de fix-fail-fix-fail.

## Verificacion post-implementacion (COMPLETION GATE)

Despues de cada unidad logica de trabajo, ejecuta esta checklist:

### Checklist obligatorio

- [ ] `lsp_diagnostics` limpio en TODOS los archivos modificados
- [ ] Build pasa (si aplica)
- [ ] Tests pasan (si aplica)
- [ ] Resultados de delegaciones recogidos y verificados
- [ ] No hay `as any`, `@ts-ignore`, ni catch blocks vacios en el diff

### LSP diagnostics

Corre `lsp_diagnostics` en los archivos modificados DESPUES de cada unidad logica de codigo. No esperes al final. Unidad logica = una funcion completa, un componente terminado, un archivo cerrado.

```bash
# Ejemplo: despues de editar user.service.ts
lsp_diagnostics(filePath="src/users/user.service.ts", severity="error")
```

Si hay errores, arreglalos inmediatamente. No acumules deuda.

### Regla de bugfix

Cuando arreglas un bug:

- **Arregla MINIMAMENTE**. Solo las lineas necesarias.
- **NO refactorices** mientras arreglas. Fix primero, refactor despues (en commit separado).
- **NO "aproveches"** para limpiar codigo cercano. Un cambio = un proposito.

## Puertas de seguridad

### Operaciones destructivas

Antes de cualquier operacion destructiva (`rm -rf`, `git reset --hard`, `DROP TABLE`):

1. Muestra el comando exacto al usuario
2. Explica que se perdera
3. Espera confirmacion explicita

### Commits

JAMAS hagas commit sin que el usuario lo pida. Ni siquiera "para no perder el progreso".

### Variables de entorno y secretos

JAMAS escribas secrets, tokens, o API keys en:
- Codigo fuente
- Archivos de configuracion publicos
- Logs o mensajes de error
- Commits

Usa variables de entorno o `.env` (que debe estar en `.gitignore`).

---

## Referencias cruzadas

- Para la estructura de delegacion que produce artefactos verificables: [guia-delegacion.md](guia-delegacion.md)
- Para cuando consultar al Oracle en vez de reintentar: [uso-oracle.md](uso-oracle.md)
- Para anti-patrones que violan los phase gates: [anti-patrones.md](anti-patrones.md)
