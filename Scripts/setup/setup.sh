#!/usr/bin/env bash
set -e

echo "====================================================================="
echo "               V-Eval - Project Setup Script (Linux/macOS)"
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

echo "=== [1/2] Dong bo Repository he thong (System-Repo) ==="
cd "$ROOT_DIR"

if [ ! -d ".git" ]; then
    echo "[INFO] Dang khoi tao Git cho System-Repo..."
    git init
    git remote add origin https://github.com/Capstone-OG/System-Repo.git
else
    echo "[INFO] Git da duoc khoi tao o System-Repo. Cap nhat origin..."
    git remote remove origin 2>/dev/null || true
    git remote add origin https://github.com/Capstone-OG/System-Repo.git
fi

if ! git rev-parse --verify HEAD &>/dev/null; then
    echo "[INFO] Chua co commit nao. Dang tao commit lam moc..."
    git add -A
    git commit -m "Initial commit from setup" 2>/dev/null || true
fi

echo "Dang dong bo code goc tu remote..."
git fetch origin || true

DEFAULT_BRANCH="main"
if git rev-parse --verify origin/develop &>/dev/null; then
    DEFAULT_BRANCH="develop"
fi

git checkout "$DEFAULT_BRANCH" 2>/dev/null || git checkout -b "$DEFAULT_BRANCH" "origin/$DEFAULT_BRANCH" 2>/dev/null || true
git pull origin "$DEFAULT_BRANCH" || true
echo "[SUCCESS] Dong bo he thong goc hoan tat."
echo ""

echo "=== [2/2] Khoi tao va Clone cac Service con ==="
CONFIG_FILE="$ROOT_DIR/git_config.txt"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "[ERROR] Khong tim thay file $CONFIG_FILE! Vui long tao file nay truoc."
    exit 1
fi

ALL_SERVICES_DIR="$ROOT_DIR/All Services"
mkdir -p "$ALL_SERVICES_DIR"

while IFS='=' read -r SERVICE_NAME CONFIG_VAL || [ -n "$SERVICE_NAME" ]; do
    # Skip empty lines or comments
    [[ "$SERVICE_NAME" =~ ^[[:space:]]*# ]] && continue
    [[ -z "$SERVICE_NAME" ]] && continue
    SERVICE_NAME="$(echo "$SERVICE_NAME" | tr -d '\r' | xargs)"
    CONFIG_VAL="$(echo "$CONFIG_VAL" | tr -d '\r' | xargs)"
    [[ -z "$CONFIG_VAL" ]] && continue

    REPO_URL="${CONFIG_VAL%%|*}"
    BRANCH="${CONFIG_VAL##*|}"

    echo ""
    echo "-------------------------------------------------------------"
    echo "Service: $SERVICE_NAME"
    echo "Nhanh:   $BRANCH"
    echo "Remote:  $REPO_URL"
    echo "-------------------------------------------------------------"

    TARGET_PATH="$ALL_SERVICES_DIR/$SERVICE_NAME"

    if [ -d "$TARGET_PATH/.git" ]; then
        echo "Folder \"$TARGET_PATH\" exists. Fetching and pulling..."
        cd "$TARGET_PATH"
        git fetch origin || true
        git checkout "$BRANCH" || true
        git pull origin "$BRANCH" || true
        cd "$ROOT_DIR"
        echo "[SUCCESS] Updated $SERVICE_NAME."
    else
        if [ -d "$TARGET_PATH" ]; then
            echo "[INFO] Phat hien thu muc \"$TARGET_PATH\" chua phai Git repo hop le. Dang don dep de clone lai..."
            rm -rf "$TARGET_PATH"
        fi
        echo "Folder \"$TARGET_PATH\" does not exist. Cloning repository..."
        if ! git clone -b "$BRANCH" "$REPO_URL" "$TARGET_PATH"; then
            echo "[WARNING] Lan dau clone that bai. Dang thu retry..."
            sleep 2
            git clone -b "$BRANCH" "$REPO_URL" "$TARGET_PATH"
        fi
        echo "[SUCCESS] Cloned $SERVICE_NAME from GitHub."
    fi

    # Build dependencies
    if [ -d "$TARGET_PATH" ]; then
        cd "$TARGET_PATH"
        if [ -f "package.json" ]; then
            echo "Cai dat dependencies va build cho $SERVICE_NAME..."
            if command -v npm &>/dev/null; then
                npm install
                npm run build
            fi
        else
            IS_DOTNET=0
            if compgen -G "*.sln" > /dev/null || compgen -G "*/*.csproj" > /dev/null || compgen -G "*/*/*.csproj" > /dev/null; then
                IS_DOTNET=1
            fi
            if [ "$IS_DOTNET" -eq 1 ] && command -v dotnet &>/dev/null; then
                echo "Dang phuc hoi NuGet va build $SERVICE_NAME..."
                dotnet restore
                dotnet build
            fi
        fi
        cd "$ROOT_DIR"
    fi
done < "$CONFIG_FILE"

# Sync configuration
echo ""
echo "====================================================================="
echo "Nap cau hinh chuan tu Configs cho tat ca cac Service..."
echo "====================================================================="
if [ -f "$ROOT_DIR/Scripts/sync_config/sync_config.sh" ]; then
    bash "$ROOT_DIR/Scripts/sync_config/sync_config.sh" --force
    bash "$ROOT_DIR/Scripts/sync_config/sync_config.sh" --check
fi

echo ""
echo "====================================================================="
echo "               V-Eval Setup Completed!"
echo "====================================================================="
echo ""
