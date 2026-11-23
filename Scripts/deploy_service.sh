#!/usr/bin/env bash
# ==============================================================================
# V-Eval System Central Continuous Deployment Script
# Target: Ubuntu Docker Server (veval.io.vn)
# Usage: ./Scripts/deploy_service.sh <target>
# Targets: web-client | gateway | identity | content | practice | ai-engine | system
# ==============================================================================

set -euo pipefail

TARGET="${1:-}"

if [ -z "$TARGET" ]; then
  echo "❌ Error: Missing deployment target!"
  echo "Usage: $0 <web-client|gateway|identity|content|practice|ai-engine|system>"
  exit 1
fi

# Detect Capstone Root Directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAPSTONE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Ensure flock lock to prevent concurrent deployments
LOCK_FILE="/tmp/veval-deploy.lock"
exec 200>"$LOCK_FILE"

echo "🔒 Acquiring deployment lock ($LOCK_FILE)..."
flock -x 200
echo "✅ Lock acquired. Starting deployment for target: '$TARGET' at $(date '+%Y-%m-%d %H:%M:%S')"

cleanup() {
  echo "🔓 Releasing deployment lock..."
  flock -u 200 || true
}
trap cleanup EXIT

cd "$CAPSTONE_ROOT"

case "$TARGET" in
  "web-client")
    SUB_DIR="All Services/V-Eval-Web_Client"
    COMPOSE_SERVICES="v-eval-web-client"
    ;;
  "gateway")
    SUB_DIR="All Services/V-Eval-Gateway"
    COMPOSE_SERVICES="v-eval-gateway"
    ;;
  "identity")
    SUB_DIR="All Services/V-Eval-Identity_Service"
    COMPOSE_SERVICES="v-eval-identity-service"
    ;;
  "content")
    SUB_DIR="All Services/V-Eval-Content_Service"
    COMPOSE_SERVICES="v-eval-content-service"
    ;;
  "practice")
    SUB_DIR="All Services/V-Eval-Practice_Service"
    COMPOSE_SERVICES="v-eval-practice-service"
    ;;
  "ai-engine")
    SUB_DIR="All Services/V-Eval-Ai_Engine"
    COMPOSE_SERVICES="v-eval-ai-engine v-eval-ai-rag"
    ;;
  "system")
    SUB_DIR="."
    COMPOSE_SERVICES="system-config"
    ;;
  *)
    echo "❌ Unknown target: '$TARGET'"
    echo "Allowed targets: web-client, gateway, identity, content, practice, ai-engine, system"
    exit 1
    ;;
esac

# 1. Update source code from GitHub
echo "🔄 Updating source repository for '$TARGET' in '$SUB_DIR'..."
if [ "$TARGET" = "system" ]; then
  git fetch origin main
  git checkout main
  git reset --hard origin/main
else
  pushd "$SUB_DIR" > /dev/null
  git fetch origin main
  git checkout main
  git reset --hard origin/main
  popd > /dev/null
fi

# 2. Deploy via Docker Compose
if [ "$TARGET" = "system" ]; then
  echo "🔍 Validating docker compose configuration..."
  docker compose config --quiet
  echo "✅ docker-compose.yml configuration is valid! System repo updated."
else
  echo "🚀 Building and restarting service(s): $COMPOSE_SERVICES..."
  # Selective rebuild: --no-deps ensures veval-tunnel and other running containers remain untouched
  docker compose up -d --build --no-deps $COMPOSE_SERVICES

  echo "⏳ Verifying container health..."
  sleep 3
  docker compose ps $COMPOSE_SERVICES
fi

# 3. Prune unused images to preserve disk space
echo "🧹 Pruning old dangling docker images..."
docker image prune -f

echo "🎉 Deployment completed successfully for '$TARGET' at $(date '+%Y-%m-%d %H:%M:%S')!"

