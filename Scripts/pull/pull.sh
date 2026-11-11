#!/usr/bin/env bash
set -e

echo "====================================================================="
echo "               V-Eval - Global Pull and History Sync Tool"
echo "====================================================================="
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "[INFO] Project Root Directory: $ROOT_DIR"
echo ""

if ! command -v git &> /dev/null; then
    echo "[ERROR] Git chua duoc cai dat hoac chua them vao PATH!"
    exit 1
fi

ALL_SERVICES_DIR="$ROOT_DIR/All Services"
CONFIG_FILE="$ROOT_DIR/git_config.txt"

process_pull() {
    local repo_path="$1"
    local repo_name="$2"
    local cur_branch="$3"

    cd "$repo_path"
    git checkout "$cur_branch" 2>/dev/null || true
    git fetch origin 2>/dev/null || true

    if [ -n "$(git status --porcelain)" ]; then
        echo "[CANH BAO] Repo $repo_name co thay doi chua commit o local:"
        git status -s
        echo "Tien hanh stash va pull..."
        git stash
        git pull origin "$cur_branch" || true
        git stash pop 2>/dev/null || true
    else
        echo "[INFO] Dang pull repo $repo_name..."
        git pull origin "$cur_branch" || true
    fi
    cd "$ROOT_DIR"
}

# --- BƯỚC 1: Pull System-Repo gốc ---
echo "============================================================="
echo "Dang kiem tra va dong bo System-Repo (Root)"
echo "============================================================="
ROOT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
process_pull "$ROOT_DIR" "System-Repo" "$ROOT_BRANCH"
echo ""

# --- BƯỚC 2: Duyệt qua các Service con để Pull ---
if [ ! -f "$CONFIG_FILE" ]; then
    echo "[WARNING] Khong tim thay file git_config.txt. Bo qua cac service con."
    exit 0
fi

while IFS='=' read -r SERVICE_NAME CONFIG_VAL || [ -n "$SERVICE_NAME" ]; do
    [[ "$SERVICE_NAME" =~ ^[[:space:]]*# ]] && continue
    [[ -z "$SERVICE_NAME" ]] && continue
    SERVICE_NAME="$(echo "$SERVICE_NAME" | tr -d '\r' | xargs)"
    CONFIG_VAL="$(echo "$CONFIG_VAL" | tr -d '\r' | xargs)"
    [[ -z "$CONFIG_VAL" ]] && continue

    BRANCH="${CONFIG_VAL##*|}"
    TARGET_PATH="$ALL_SERVICES_DIR/$SERVICE_NAME"

    echo "============================================================="
    echo "Dang kiem tra va dong bo Service: $SERVICE_NAME [$BRANCH]"
    echo "============================================================="

    if [ -d "$TARGET_PATH/.git" ]; then
        process_pull "$TARGET_PATH" "$SERVICE_NAME" "$BRANCH"
    else
        echo "[WARNING] Thu muc \"$TARGET_PATH\" chua duoc khoi tao Git."
        echo "[INFO] Vui long chay Scripts/setup/setup.sh de khoi tao."
    fi
    echo ""
done < "$CONFIG_FILE"

# --- BƯỚC 3: Kiem tra va bo sung cau hinh ---
if [ -f "$ROOT_DIR/Scripts/sync_config/sync_config.sh" ]; then
    echo "============================================================="
    echo "Kiem tra va bo sung cau hinh sau khi pull..."
    echo "============================================================="
    bash "$ROOT_DIR/Scripts/sync_config/sync_config.sh" --install-missing
fi

echo "====================================================================="
echo "               Dong bo hoan tat"
echo "====================================================================="
