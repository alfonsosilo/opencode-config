# Guia de Testing End-to-End (E2E)

## Por que E2E

Los tests unitarios son sistematicamente ciegos a defectos en fronteras de componentes.
Su diseno de aislamiento es precisamente lo que les impide detectar:

- Desajustes de interfaz entre componentes
- Errores de propagacion de estado
- Problemas de ciclo de vida de recursos
- Dependencias de entorno no documentadas

El testing E2E no solo detecta estos defectos: cambia como los agentes escriben codigo.
Cuando saben que hay tests E2E, los agentes consideran interacciones entre componentes,
respetan fronteras arquitectonicas, y manejan paths de error correctamente.

## Cuando usar E2E vs Unit Tests

| Situacion | Usar |
|-----------|------|
| Nueva feature con API + DB + frontend | E2E + unit |
| Cambio en logica de negocio interna | Unit |
| Integracion con API externa | E2E (con mock del externo) |
| Refactor sin cambio de comportamiento | Unit + E2E smoke |
| Bug fix | Unit (regresion) + E2E si afecta flujo de usuario |
| Cambio de config / texto | Ni uno ni otro |

## Pipeline de Verificacion (3 capas)

```
Capa 1 — Sintaxis/Estatica: lint, typecheck, lsp_diagnostics
         ↓ (no pasar si falla)
Capa 2 — Runtime/Unit: tests unitarios, tests de integracion
         ↓ (no pasar si falla)
Capa 3 — Sistema/E2E: tests end-to-end, smoke tests, verificacion Oracle
```

Regla: NO proceder a la capa N+1 si la capa N falla. Sin atajos.

## Herramientas

### Para APIs (REST/GraphQL)
- `curl` + `jq` para verificaciones simples
- Ejemplo minimo:
  ```bash
  curl -s -X POST http://localhost:3000/api/login \
    -H "Content-Type: application/json" \
    -d '{"email":"test@test.com","password":"12345678"}' \
    | jq -e '.token != null'
  ```

### Para frontend
- Playwright (skill ya disponible via `/playwright`)
- Ejemplo minimo: navegar a pagina, rellenar formulario, verificar resultado
- Se puede ejecutar como: `/playwright "Abre localhost:3000, haz login con test@test.com/12345678, verifica que ves 'Bienvenido'"`

### Para ambos (full-stack)
- Iniciar app en background
- Ejecutar tests E2E
- Parar app
- Verificar codigos de salida

```bash
# Ejemplo de script E2E auto-contenido
#!/bin/bash
set -e

# Setup
npm run dev &
PID=$!
sleep 3

# Test
curl -s http://localhost:3000/api/health | jq -e '.status == "ok"'

# Teardown
kill $PID
```

## Integracion en el flujo SDD

1. La spec define criterios de aceptacion
2. Cada criterio de aceptacion DEBE tener un comando de verificacion asociado
3. Los comandos de verificacion pueden ser unit o E2E segun el tipo de criterio
4. Oracle verifica que todos los criterios tienen comando y que pasan

Ejemplo de criterio con comando E2E:

- **Criterio**: "POST /auth/login con credenciales correctas devuelve 200 y token JWT valido"
- **Comando**:
  ```bash
  curl -s -X POST localhost:3000/auth/login \
    -H "Content-Type: application/json" \
    -d '{"email":"a@b.com","password":"12345678"}' \
    | jq -e '.token | test("^eyJ")'
  ```

## E2E Smoke Tests (minimo viable)

Para cada feature, crear al menos UN smoke test E2E que verifique el happy path completo.
Este smoke test se ejecuta en clock-out y en CI.

Los smoke tests deben ser:

- **Rapidos** (<10 segundos cada uno)
- **Deterministas** (sin depender de orden de ejecucion)
- **Autocontenidos** (setup y teardown en el mismo script)

## Anti-patrones comunes

- **Test que depende de orden de ejecucion**: "El test B asume que el test A creo el usuario."
  Solucion: cada test crea y limpia sus propios datos.
- **Test que no hace teardown**: deja basura en la DB y el siguiente test falla.
  Solucion: `trap "cleanup" EXIT` en bash, `afterAll` en Jest/Vitest.
- **Test que espera estado externo**: asume que cierto usuario existe en la DB.
  Solucion: el test crea su propio fixture en setup.
- **Test que solo verifica status code**: devuelve 200 pero el body esta vacio.
  Solucion: validar al menos UNA propiedad del body con `jq`.

## Referencias

- `/playwright` — skill de automatizacion de navegador
- `.omo/spec-template.md` — plantilla que incluye criterios de aceptacion con comandos de verificacion
- `docs/phase-gates.md` — puertas de verificacion donde se integra E2E como capa 3
