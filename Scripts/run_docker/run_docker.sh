#!/usr/bin/env bash
set -e

echo "====================================================================="
echo "               V-Eval - Docker Compose Run Script"
echo "====================================================================="
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "[INFO] Project Root Directory: $ROOT_DIR"
echo ""

if ! command -v docker &> /dev/null; then
    echo "[ERROR] Docker chua duoc cai dat!"
    exit 1
fi

if ! docker info &> /dev/null; then
    echo "[ERROR] Docker Daemon chua chay! Vui long khoi dong Docker truoc."
    exit 1
fi

if [ -f "$ROOT_DIR/Scripts/sync_config/sync_config.sh" ]; then
    bash "$ROOT_DIR/Scripts/sync_config/sync_config.sh" --install-missing
fi

echo "Dang khoi dong cac Docker Container (va build lai neu co thay doi)..."
cd "$ROOT_DIR"
docker compose up --build "$@"
