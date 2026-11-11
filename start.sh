#!/usr/bin/env bash
# V-Eval Capstone - Shortcut to start_docker.sh
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$DIR/start_docker.sh" "$@"
