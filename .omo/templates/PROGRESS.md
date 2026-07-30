# PROGRESS — [Nombre del Proyecto]

**Ultima sesion:** YYYY-MM-DD | **Sesion ID:** xxx
**Estado general:** 🟢 Saludable

> **Regla de oro:** Lo que no esta escrito en este archivo no existe. Actualizar SIEMPRE al cerrar sesion.

---

## Feature Actual

- **ID:** F01 — [Titulo del feature]
- **Estado:** active
- **Spec:** specs/nombre-spec.md (o `null` si no tiene)
- **Verificacion:** `curl -s http://localhost:3000/health | jq .status`
- **Bloqueantes:** Ninguno

---

## Log de Sesiones

| Fecha | Sesion | Feature | Que se hizo | Build | Tests | Notas |
|-------|--------|---------|-------------|-------|-------|-------|
| YYYY-MM-DD | ses_xxx | F01 | Inicializacion del harness | ✅ | ✅ | init.sh funcional, baseline verde |

---

## Problemas Conocidos

- [ ] [Descripcion del problema] — Plan: [que hacer] — Sesion: [donde se descubrio]

---

## Proxima Sesion

1. Leer este archivo (es lo primero que hace clock-in)
2. Leer `feature_list.json` para ver la cola de features
3. Ejecutar `./init.sh` para verificacion baseline
4. Si baseline falla → arreglar ANTES de tocar features
5. Seleccionar el feature no terminado de mayor prioridad
6. Trabajar SOLO en ese feature (WIP=1)

---

## Metricas

| Metrica | Valor | Tendencia |
|---------|-------|-----------|
| Features completados | 0/1 | — |
| Build pass rate | 100% | — |
| Test pass rate | 100% | — |
| Tiempo de inicio de sesion | ~1 min | — |
