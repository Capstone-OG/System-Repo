#!/usr/bin/env bash
# =====================================================================
#   🚀 V-EVAL CAPSTONE - KHỞI ĐỘNG LOCAL DEVELOPMENT (7 TERMINALS)
# =====================================================================
# Script 1-click khởi chạy toàn bộ 7 Microservices & Web Client
# Mở trực tiếp 7 cửa sổ terminal độc lập (Gnome Terminal / GUI Emulator)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR"

# Chuyển tiếp trực tiếp sang Scripts/run_local/run_local.sh với lựa chọn 1 (Full 7 Services)
exec bash "$ROOT_DIR/Scripts/run_local/run_local.sh" 1 "$@"

