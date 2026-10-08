#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

CONFIGS_DIR="$ROOT_DIR/Configs"
ALL_SERVICES_DIR="$ROOT_DIR/All Services"

ARG_MODE="$1"

sync_one_down() {
    local src="$1"
    local dst="$2"
    local label="$3"
    local svc_root="$4"

    if [ ! -f "$src" ]; then
        echo "[BO QUA] Khong tim thay file nguon Configs cho $label"
        return 0
    fi

    if [ -n "$svc_root" ] && [ ! -d "$svc_root" ]; then
        echo "[BO QUA] Service $label chua duoc clone tai local."
        return 0
    fi

    local dst_dir
    dst_dir="$(dirname "$dst")"
    mkdir -p "$dst_dir"

    if [ -f "$dst" ]; then
        cp -f "$dst" "${dst}.bak"
    fi

    cp -f "$src" "$dst"
    echo "[SUCCESS] Da cap nhat cau hinh cho: $label"
}

sync_one_up() {
    local src="$1"
    local dst="$2"
    local label="$3"

    if [ ! -f "$src" ]; then
        echo "[BO QUA] Service $label chua co file cau hinh tai local de gom."
        return 0
    fi

    local dst_dir
    dst_dir="$(dirname "$dst")"
    mkdir -p "$dst_dir"

    cp -f "$src" "$dst"
    echo "[SUCCESS] Da gom cau hinh cho: $label"
}

check_one() {
    local path="$1"
    local label="$2"

    if [ -f "$path" ]; then
        echo "  [SAN SANG] $label"
    else
        echo "  [CHUA CO ] $label - Can chay sync de bo sung"
    fi
}

install_if_missing() {
    local src="$1"
    local dst="$2"
    local label="$3"
    local svc_root="$4"

    if [ ! -f "$src" ]; then return 0; fi
    if [ -n "$svc_root" ] && [ ! -d "$svc_root" ]; then return 0; fi

    if [ ! -f "$dst" ]; then
        local dst_dir
        dst_dir="$(dirname "$dst")"
        mkdir -p "$dst_dir"
        cp -f "$src" "$dst"
        echo "[BO SUNG] Da tu dong tao file cau hinh con thieu cho: $label"
    fi
}

do_apply_all() {
    echo ""
    echo "====================================================================="
    echo "[SYNC DOWN] Dang nap cau hinh chuan vao cac Service..."
    echo "====================================================================="
    echo ""

    sync_one_down "$CONFIGS_DIR/V-Eval-Gateway/appsettings.json" "$ALL_SERVICES_DIR/V-Eval-Gateway/V-Eval-Gateway.API/appsettings.json" "V-Eval-Gateway" "$ALL_SERVICES_DIR/V-Eval-Gateway"
    sync_one_down "$CONFIGS_DIR/V-Eval-Identity_Service/appsettings.json" "$ALL_SERVICES_DIR/V-Eval-Identity_Service/V-Eval-Identity_Service.API/appsettings.json" "V-Eval-Identity_Service" "$ALL_SERVICES_DIR/V-Eval-Identity_Service"
    sync_one_down "$CONFIGS_DIR/V-Eval-Content_Service/appsettings.json" "$ALL_SERVICES_DIR/V-Eval-Content_Service/V-Eval-Content_Service.API/appsettings.json" "V-Eval-Content_Service" "$ALL_SERVICES_DIR/V-Eval-Content_Service"
    sync_one_down "$CONFIGS_DIR/V-Eval-Practice_Service/appsettings.json" "$ALL_SERVICES_DIR/V-Eval-Practice_Service/V-Eval-Practice_Service.API/appsettings.json" "V-Eval-Practice_Service" "$ALL_SERVICES_DIR/V-Eval-Practice_Service"
    sync_one_down "$CONFIGS_DIR/V-Eval-Ai_Engine/appsettings.json" "$ALL_SERVICES_DIR/V-Eval-Ai_Engine/V-Eval-Ai_Engine.API/appsettings.json" "V-Eval-Ai_Engine API" "$ALL_SERVICES_DIR/V-Eval-Ai_Engine"
    sync_one_down "$CONFIGS_DIR/V-Eval-Ai_Engine/rag-service/.env" "$ALL_SERVICES_DIR/V-Eval-Ai_Engine/rag-service/.env" "V-Eval-Ai_Engine Python RAG" "$ALL_SERVICES_DIR/V-Eval-Ai_Engine"
    sync_one_down "$CONFIGS_DIR/V-Eval-Web_Client/.env" "$ALL_SERVICES_DIR/V-Eval-Web_Client/.env" "V-Eval-Web_Client" "$ALL_SERVICES_DIR/V-Eval-Web_Client"

    echo ""
    echo "[HOAN TAT] Da dong bo toan bo cau hinh chuan vao cac Service!"
}

do_collect_all() {
    echo ""
    echo "====================================================================="
    echo "[SYNC UP] Dang gom cau hinh tu cac Service vao System-Repo/Configs..."
    echo "====================================================================="
    echo ""

    sync_one_up "$ALL_SERVICES_DIR/V-Eval-Gateway/V-Eval-Gateway.API/appsettings.json" "$CONFIGS_DIR/V-Eval-Gateway/appsettings.json" "V-Eval-Gateway"
    sync_one_up "$ALL_SERVICES_DIR/V-Eval-Identity_Service/V-Eval-Identity_Service.API/appsettings.json" "$CONFIGS_DIR/V-Eval-Identity_Service/appsettings.json" "V-Eval-Identity_Service"
    sync_one_up "$ALL_SERVICES_DIR/V-Eval-Content_Service/V-Eval-Content_Service.API/appsettings.json" "$CONFIGS_DIR/V-Eval-Content_Service/appsettings.json" "V-Eval-Content_Service"
    sync_one_up "$ALL_SERVICES_DIR/V-Eval-Practice_Service/V-Eval-Practice_Service.API/appsettings.json" "$CONFIGS_DIR/V-Eval-Practice_Service/appsettings.json" "V-Eval-Practice_Service"
    sync_one_up "$ALL_SERVICES_DIR/V-Eval-Ai_Engine/V-Eval-Ai_Engine.API/appsettings.json" "$CONFIGS_DIR/V-Eval-Ai_Engine/appsettings.json" "V-Eval-Ai_Engine API"
    sync_one_up "$ALL_SERVICES_DIR/V-Eval-Ai_Engine/rag-service/.env" "$CONFIGS_DIR/V-Eval-Ai_Engine/rag-service/.env" "V-Eval-Ai_Engine Python RAG"
    sync_one_up "$ALL_SERVICES_DIR/V-Eval-Web_Client/.env" "$CONFIGS_DIR/V-Eval-Web_Client/.env" "V-Eval-Web_Client"

    echo ""
    echo "[HOAN TAT] Da gom cau hinh xong! Ban co the commit va push System-Repo de chia se cho ca team."
}

do_check_status() {
    echo ""
    echo "====================================================================="
    echo "[STATUS] Kiem tra trang thai file cau hinh tai tung Service..."
    echo "====================================================================="
    echo ""

    check_one "$ALL_SERVICES_DIR/V-Eval-Gateway/V-Eval-Gateway.API/appsettings.json" "V-Eval-Gateway [appsettings.json]"
    check_one "$ALL_SERVICES_DIR/V-Eval-Identity_Service/V-Eval-Identity_Service.API/appsettings.json" "V-Eval-Identity_Service [appsettings.json]"
    check_one "$ALL_SERVICES_DIR/V-Eval-Content_Service/V-Eval-Content_Service.API/appsettings.json" "V-Eval-Content_Service [appsettings.json]"
    check_one "$ALL_SERVICES_DIR/V-Eval-Practice_Service/V-Eval-Practice_Service.API/appsettings.json" "V-Eval-Practice_Service [appsettings.json]"
    check_one "$ALL_SERVICES_DIR/V-Eval-Ai_Engine/V-Eval-Ai_Engine.API/appsettings.json" "V-Eval-Ai_Engine API [appsettings.json]"
    check_one "$ALL_SERVICES_DIR/V-Eval-Ai_Engine/rag-service/.env" "V-Eval-Ai_Engine Python RAG [.env]"
    check_one "$ALL_SERVICES_DIR/V-Eval-Web_Client/.env" "V-Eval-Web_Client [.env]"
    echo ""
}

do_install_missing() {
    echo "[INFO] Kiem tra va tu dong bo sung cau hinh neu con thieu..."
    install_if_missing "$CONFIGS_DIR/V-Eval-Gateway/appsettings.json" "$ALL_SERVICES_DIR/V-Eval-Gateway/V-Eval-Gateway.API/appsettings.json" "V-Eval-Gateway" "$ALL_SERVICES_DIR/V-Eval-Gateway"
    install_if_missing "$CONFIGS_DIR/V-Eval-Identity_Service/appsettings.json" "$ALL_SERVICES_DIR/V-Eval-Identity_Service/V-Eval-Identity_Service.API/appsettings.json" "V-Eval-Identity_Service" "$ALL_SERVICES_DIR/V-Eval-Identity_Service"
    install_if_missing "$CONFIGS_DIR/V-Eval-Content_Service/appsettings.json" "$ALL_SERVICES_DIR/V-Eval-Content_Service/V-Eval-Content_Service.API/appsettings.json" "V-Eval-Content_Service" "$ALL_SERVICES_DIR/V-Eval-Content_Service"
    install_if_missing "$CONFIGS_DIR/V-Eval-Practice_Service/appsettings.json" "$ALL_SERVICES_DIR/V-Eval-Practice_Service/V-Eval-Practice_Service.API/appsettings.json" "V-Eval-Practice_Service" "$ALL_SERVICES_DIR/V-Eval-Practice_Service"
    install_if_missing "$CONFIGS_DIR/V-Eval-Ai_Engine/appsettings.json" "$ALL_SERVICES_DIR/V-Eval-Ai_Engine/V-Eval-Ai_Engine.API/appsettings.json" "V-Eval-Ai_Engine API" "$ALL_SERVICES_DIR/V-Eval-Ai_Engine"
    install_if_missing "$CONFIGS_DIR/V-Eval-Ai_Engine/rag-service/.env" "$ALL_SERVICES_DIR/V-Eval-Ai_Engine/rag-service/.env" "V-Eval-Ai_Engine Python RAG" "$ALL_SERVICES_DIR/V-Eval-Ai_Engine"
    install_if_missing "$CONFIGS_DIR/V-Eval-Web_Client/.env" "$ALL_SERVICES_DIR/V-Eval-Web_Client/.env" "V-Eval-Web_Client" "$ALL_SERVICES_DIR/V-Eval-Web_Client"
}

if [ "$ARG_MODE" = "--install-missing" ]; then
    do_install_missing
    exit 0
elif [ "$ARG_MODE" = "--force" ]; then
    do_apply_all
    exit 0
elif [ "$ARG_MODE" = "--check" ]; then
    do_check_status
    exit 0
fi

echo "====================================================================="
echo "          V-Eval - Centralized Configuration Sync Tool"
echo "====================================================================="
echo ""
echo "Thu muc goc: $ROOT_DIR"
echo ""
echo "Chon tac vu dong bo cau hinh:"
echo "  [1] Nap cau hinh chuan vao tat ca Service [Configs -> Services]"
echo "  [2] Gom cau hinh tu may local vao thu muc Configs [Services -> Configs]"
echo "  [3] Kiem tra trang thai cau hinh cua cac Service"
echo "  [4] Thoat"
echo ""
read -r -p "Nhap lua chon cua ban [1, 2, 3, 4 - Mac dinh: 1]: " CHOICE
CHOICE="${CHOICE:-1}"

case "$CHOICE" in
    1) do_apply_all ;;
    2) do_collect_all ;;
    3) do_check_status ;;
    4) exit 0 ;;
    *) echo "Lua chon khong hop le."; exit 1 ;;
esac
