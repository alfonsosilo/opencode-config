# Spec Template — Ejemplo canónico

Esta es la spec de referencia que `spec-writer` usa como modelo. Toda spec generada debe seguir esta estructura y nivel de detalle.

---

# Spec: Autenticación JWT

**Status:** draft | **Author:** @alfonsoserrano | **Date:** 2026-07-08

## Resumen
Añadir autenticación stateless con JWT a la API Express existente. Los usuarios se registran con email/password, hacen login y reciben un token JWT que deben enviar en el header `Authorization` para acceder a rutas protegidas. No incluye refresh tokens ni OAuth en esta iteración.

## Endpoints / Interfaces

### POST /auth/register
- **Input:** `{ email: string, password: string }`
- **Validación:** email formato RFC 5322, password mínimo 8 caracteres, sin espacios al inicio/fin
- **Output (éxito, 201):** `{ user: { id: string, email: string }, token: string }`
- **Errores:**
  - `409` Email ya registrado → `{ error: "EMAIL_EXISTS" }`
  - `422` Validación fallida → `{ error: "VALIDATION", fields: { email?: string, password?: string } }`
- **Side effects:** Hash bcrypt (12 rounds), INSERT en tabla `users`, generar JWT
- **Edge cases:** Email con mayúsculas → normalizar a minúsculas antes de guardar; password con espacios → recortar; email duplicado aunque difiera en mayúsculas → 409

### POST /auth/login
- **Input:** `{ email: string, password: string }`
- **Output (éxito, 200):** `{ user: { id: string, email: string }, token: string }`
- **Errores:**
  - `401` Credenciales inválidas → `{ error: "INVALID_CREDENTIALS" }`
  - `429` Rate limit excedido → `{ error: "RATE_LIMIT", retryAfter: number }`
- **Side effects:** Ninguno (read-only + generación de token)
- **Edge cases:** Usuario no existe vs contraseña incorrecta → misma respuesta 401 (no filtrar si el email existe); 5 intentos/minuto por IP

### GET /auth/me
- **Input:** Header `Authorization: Bearer <token>`
- **Output (éxito, 200):** `{ user: { id: string, email: string, createdAt: string } }`
- **Errores:**
  - `401` Token ausente → `{ error: "UNAUTHORIZED" }`
  - `401` Token inválido (firma incorrecta) → `{ error: "UNAUTHORIZED" }`
  - `401` Token expirado → `{ error: "TOKEN_EXPIRED" }`
- **Side effects:** Ninguno
- **Edge cases:** Token malformado (no es JWT) → 401; header `Authorization` con esquema incorrecto (`Basic`, `Digest`) → 401

### Middleware `requireAuth`
- **Ubicación:** `src/middleware/auth.ts`
- **Input:** Request con header `Authorization: Bearer <token>`
- **Output (éxito):** `req.user = { id: string, email: string }` (tipado, extiende `Request`)
- **Output (fallo):** Responde directamente con error 401 (ver formatos arriba)
- **Side effects:** Ninguno (no modifica DB, no cachea)
- **Edge cases:** Aplicar solo en rutas protegidas, NO como middleware global

## Modelos de datos

```typescript
// src/types/auth.ts

interface RegisterInput {
  email: string;
  password: string;
}

interface LoginInput {
  email: string;
  password: string;
}

interface AuthResponse {
  user: UserPublic;
  token: string;
}

interface UserPublic {
  id: string;
  email: string;
  createdAt?: string; // solo en /auth/me
}

interface AuthError {
  error: string;
  fields?: Record<string, string>;
  retryAfter?: number;
}

// Extensión de Request
declare global {
  namespace Express {
    interface Request {
      user?: { id: string; email: string };
    }
  }
}
```

## Reglas de negocio
- Un email solo puede registrarse una vez (case-insensitive)
- Las contraseñas NUNCA se almacenan en texto plano (bcrypt, 12 rounds)
- El token JWT expira en 24h (configurable vía `JWT_EXPIRES_IN`)
- El rate limit de login es por IP, no por usuario (evita DoS sin filtrar emails)
- Si `JWT_SECRET` no está definido al arrancar, la app hace `process.exit(1)` con mensaje claro
- Las contraseñas no se devuelven NUNCA en ninguna respuesta

## Convenciones
- Seguir patrones existentes en `src/middleware/` (ver `src/middleware/errorHandler.ts`)
- Seguir patrones de rutas en `src/routes/` (ver `src/routes/health.ts`)
- Tests con vitest, misma configuración que el resto del proyecto
- Tipos en `src/types/auth.ts`
- No usar `any`, `@ts-ignore`, ni `as` casts inseguros

## Criterios de aceptación
- [ ] POST /auth/register con email nuevo y password válido → 201 + token JWT
- [ ] POST /auth/register con email ya registrado → 409 EMAIL_EXISTS
- [ ] POST /auth/register con email inválido → 422 VALIDATION con fields.email
- [ ] POST /auth/register con password < 8 chars → 422 VALIDATION con fields.password
- [ ] POST /auth/register con email en mayúsculas → normaliza, registra, 201
- [ ] POST /auth/login con credenciales correctas → 200 + token JWT válido
- [ ] POST /auth/login con contraseña incorrecta → 401 INVALID_CREDENTIALS
- [ ] POST /auth/login con email no registrado → 401 INVALID_CREDENTIALS (misma respuesta)
- [ ] POST /auth/login con 6 intentos en 1 minuto → 429 RATE_LIMIT
- [ ] GET /auth/me con token válido → 200 + datos del usuario
- [ ] GET /auth/me sin token → 401 UNAUTHORIZED
- [ ] GET /auth/me con token expirado → 401 TOKEN_EXPIRED
- [ ] GET /auth/me con token malformado → 401 UNAUTHORIZED
- [ ] Ruta sin `requireAuth` no pide autenticación (middleware no es global)
- [ ] Password se almacena hasheada (verificable: el hash no es reversible)
- [ ] `JWT_SECRET` viene de `process.env`, no está hardcodeado
- [ ] `process.exit(1)` si `JWT_SECRET` no existe al arrancar

## Fuera de scope
- Refresh tokens (se añadirán en spec separada: `specs/refresh-tokens.md`)
- Verificación de email (email verification flow)
- Reset de password (forgot password flow)
- Roles y permisos (RBAC)
- OAuth / social login (Google, GitHub, etc.)
- Blacklist / invalidación de tokens
- 2FA / MFA

## Dependencias
- `bcrypt` (ya instalado en el proyecto)
- `jsonwebtoken` (ya instalado en el proyecto)
- `express-rate-limit` (nueva dependencia, añadir al package.json)
- `src/types/auth.ts` (nuevo archivo de tipos)
- `src/middleware/auth.ts` (nuevo middleware)
- `src/routes/auth.ts` (nuevas rutas)
- Variable de entorno: `JWT_SECRET` (añadir a `.env.example`)
- Variable de entorno: `JWT_EXPIRES_IN` (default: `24h`)
