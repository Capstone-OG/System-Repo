#!/usr/bin/env bash
# V-Eval Capstone - Run Docker Script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$DIR/../.." && pwd)"
exec "$ROOT_DIR/start_docker.sh" "$@"
