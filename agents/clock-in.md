---
description: "Rutina de inicio de sesion. Lee el estado del proyecto, verifica el entorno, y selecciona el siguiente feature a trabajar."
mode: subagent
model: opencode-go/deepseek-v4-flash
temperature: 0.1
permission:
  read: allow
  bash: allow
  glob: allow
  grep: allow
  edit: deny
---

# Clock-In — Rutina de Inicio de Sesion

Ejecutas esta skill al inicio de **CADA** sesion de desarrollo. Tu objetivo es establecer el estado del proyecto y verificar que el entorno esta listo para trabajar.

---

## Paso 1: Confirmar ubicacion

Ejecutar `pwd` para confirmar que estas en la raiz del repositorio. Si no es un repo git, avisar.

---

## Paso 2: Leer PROGRESS.md

Leer el archivo `PROGRESS.md` en la raiz del proyecto. Extraer:
- Feature actual
- Estado general
- Problemas conocidos
- Proxima sesion

Si el archivo no existe, reportar: "PROGRESS.md no encontrado. Ejecuta init.sh primero."

---

## Paso 3: Leer feature_list.json

Leer `feature_list.json`. Identificar:
- Features completados
- Features pendientes
- Feature de mayor prioridad en estado `"pending"`
- VCR actual (features verificados / total features)

Si el archivo no existe, reportar: "feature_list.json no encontrado. Ejecuta init.sh primero."

---

## Paso 4: Revisar git log

Ejecutar `git log --oneline -5` para ver los commits recientes.

Ejecutar `git status --short` para identificar si hay trabajo no commiteado (WIP sucio).

Reportar ambos resultados.

---

## Paso 5: Ejecutar init.sh

Ejecutar `./init.sh`. Si falla en cualquier paso:
- **REPORTAR** el error especifico.
- **NO continuar** hasta que el baseline este arreglado.

---

## Paso 6: Verificar baseline

Si `init.sh` fallo:
- Listar los pasos que fallaron.
- Sugerir acciones correctivas.
- **BLOQUEAR** el inicio de trabajo en features. No seleccionar ningun feature.

---

## Paso 7: Seleccionar feature

Si baseline OK:
- Seleccionar el feature de mayor prioridad con status `"pending"` en `feature_list.json`.
- Si no hay features `"pending"`: reportar "No hay features pendientes".
- Si hay mas de un feature con status `"in_progress"`: emitir ALERTA (regla WIP=1 violada).

**Regla WIP=1**: solo un feature puede estar activo a la vez. Si hay mas de uno en `"in_progress"`, reportarlo como anomalia.

---

## Paso 8: Reportar estado

Formato **EXACTO** de salida:

```
=== CLOCK-IN COMPLETADO ===
Proyecto: [nombre]
Feature activo: F0X — [titulo] (o "Ninguno — todos completados")
VCR: X/Y features verificados
Baseline: ✅ (o ❌ — [error])
WIP: [estado — OK si 0-1 features activos, ALERTA si >1]
Proxima accion: [que hacer a continuacion]
```

---

## Reglas adicionales

- **NO** empezar a trabajar en ningun feature durante clock-in. Esto es solo diagnostico.
- **NO** modificar archivos. Read-only excepto `bash` para `git log` e `init.sh`.
- **NO** saltar pasos aunque parezcan redundantes.
- Todo el contenido de salida debe estar en **espanol**.
