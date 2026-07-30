#!/usr/bin/env bash
# ============================================================
# init.sh — Inicializacion del entorno de desarrollo
#
# Este script configura el entorno y ejecuta verificacion baseline.
# Si falla, el agente NO debe tocar features hasta arreglarlo.
#
# Uso: ./init.sh
# ============================================================
set -euo pipefail

echo "=== Init: $(date) ==="
echo ""

# --- 1. Verificar dependencias del sistema ------------------
echo "[1/5] Verificando dependencias del sistema..."
# Descomenta y ajusta segun tu proyecto:
# command -v node >/dev/null 2>&1  || { echo "ERROR: node no encontrado. Instalar desde https://nodejs.org"; exit 1; }
# command -v python3 >/dev/null 2>&1 || { echo "ERROR: python3 no encontrado"; exit 1; }
# command -v go >/dev/null 2>&1      || { echo "ERROR: go no encontrado"; exit 1; }
echo "  ✅ Dependencias OK"
echo ""

# --- 2. Instalar dependencias del proyecto ------------------
echo "[2/5] Instalando dependencias del proyecto..."
# Descomenta y ajusta segun tu proyecto:
# npm ci
# pip install -r requirements.txt
# go mod download
echo "  ✅ Dependencias instaladas"
echo ""

# --- 3. Configurar entorno ----------------------------------
echo "[3/5] Configurando entorno..."
# Descomenta y ajusta segun tu proyecto:
# if [ ! -f .env ]; then
#   cp .env.example .env
#   echo "  📄 .env creado desde .env.example — revisa los valores"
# else
#   echo "  ✅ .env ya existe"
# fi
echo "  ✅ Entorno configurado"
echo ""

# --- 4. Setup (migraciones, generacion, etc.) ---------------
echo "[4/5] Ejecutando setup..."
# Descomenta y ajusta segun tu proyecto:
# npx prisma migrate dev
# python manage.py migrate
echo "  ✅ Setup completado"
echo ""

# --- 5. Verificacion baseline -------------------------------
echo "[5/5] Ejecutando verificacion baseline..."
# Descomenta y ajusta segun tu proyecto:
# npm test
# pytest
# go test ./...
echo "  ✅ Verificacion baseline"
echo ""

echo "=== Init completado exitosamente ==="
echo "Proyecto listo para desarrollo."
