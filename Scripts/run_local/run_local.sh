#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
ALL_SERVICES_DIR="$ROOT_DIR/All Services"

echo "====================================================================="
echo "          V-Eval - Local Full Services Runner Tool (Linux)"
echo "====================================================================="
echo ""
echo "Project Root Directory: $ROOT_DIR"
echo ""

echo "Chon che do khoi dong:"
echo "  [1] Khoi dong FULL tat ca 7 Service [Gateway, Identity, Content, Practice, AI Engine, Python RAG, Web Client]"
echo "  [2] Khoi dong cac Microservices C# [.NET Core]"
echo "  [3] Khoi dong chi AI Subsystem [AI Engine .NET + Python FastAPI RAG]"
echo "  [4] Khoi dong chi Web Client [React 19 Vite - Port 5173]"
echo "  [5] Giai phong / Kill tat ca cac Port va Tien trinh dang chiem dung"
echo "  [6] Thoat"
echo ""

read -r -p "Nhap lua chon cua ban [Mac dinh: 1]: " CHOICE
CHOICE="${CHOICE:-1}"

if [ "$CHOICE" = "6" ]; then
    echo "Tam biet!"
    exit 0
fi

# Clean ports
PORTS_TO_CLEAN=(5212 5155 5156 5249 5250 5261 5104 8000 5000 5001 5002 5005 5006 5173 5174 8080 3000)

echo ""
echo "====================================================================="
echo "[BƯỚC 1] Giai phong cac cong Port tranh xung dot..."
echo "====================================================================="

for port in "${PORTS_TO_CLEAN[@]}"; do
    pid=$(lsof -ti :"$port" 2>/dev/null || fuser "$port/tcp" 2>/dev/null || true)
    if [ -n "$pid" ]; then
        echo "[KILL] Phat hien Tien trinh ID $pid chiem dung Port $port. Dang giai phong..."
        kill -9 $pid 2>/dev/null || true
    fi
done
echo "[DONE] Da giai phong hoan tat cac Port phat trien."
echo ""

if [ "$CHOICE" = "5" ]; then
    echo "[INFO] Da giai phong thanh cong tat ca cac cong."
    exit 0
fi

if [ -f "$ROOT_DIR/Scripts/sync_config/sync_config.sh" ]; then
    bash "$ROOT_DIR/Scripts/sync_config/sync_config.sh" --install-missing
fi

echo "====================================================================="
echo "[BƯỚC 2] Tien hanh khoi dong cac Service..."
echo "====================================================================="
echo ""

LOG_DIR="$ROOT_DIR/.local_logs"
mkdir -p "$LOG_DIR"

start_service() {
    local name="$1"
    local dir="$2"
    local cmd="$3"
    local log="$LOG_DIR/$name.log"

    echo "[START] Dang khoi dong $name..."
    (cd "$dir" && exec $cmd) > "$log" 2>&1 &
    local pid=$!
    echo "        PID: $pid | Log: $log"
    sleep 2
}

# 1. Identity Service
if [ "$CHOICE" = "1" ] || [ "$CHOICE" = "2" ]; then
    ID_DIR="$ALL_SERVICES_DIR/V-Eval-Identity_Service/V-Eval-Identity_Service.API"
    if [ -f "$ID_DIR/V-Eval-Identity_Service.API.csproj" ]; then
        start_service "Identity_Service" "$ID_DIR" "dotnet run"
    fi
fi

# 2. Content Service
if [ "$CHOICE" = "1" ] || [ "$CHOICE" = "2" ]; then
    CONTENT_DIR="$ALL_SERVICES_DIR/V-Eval-Content_Service/V-Eval-Content_Service.API"
    if [ -f "$CONTENT_DIR/V-Eval-Content_Service.API.csproj" ]; then
        start_service "Content_Service" "$CONTENT_DIR" "dotnet run"
    fi
fi

# 3. Practice Service
if [ "$CHOICE" = "1" ] || [ "$CHOICE" = "2" ]; then
    PRACTICE_DIR="$ALL_SERVICES_DIR/V-Eval-Practice_Service/V-Eval-Practice_Service.API"
    if [ -f "$PRACTICE_DIR/V-Eval-Practice_Service.API.csproj" ]; then
        start_service "Practice_Service" "$PRACTICE_DIR" "dotnet run"
    fi
fi

# 4. AI Engine .NET API
if [ "$CHOICE" = "1" ] || [ "$CHOICE" = "2" ] || [ "$CHOICE" = "3" ]; then
    AI_NET_DIR="$ALL_SERVICES_DIR/V-Eval-Ai_Engine/V-Eval-Ai_Engine.API"
    if [ -f "$AI_NET_DIR/V-Eval-Ai_Engine.API.csproj" ]; then
        start_service "Ai_Engine_API" "$AI_NET_DIR" "dotnet run"
    fi
fi

# 5. AI Engine Python FastAPI RAG
if [ "$CHOICE" = "1" ] || [ "$CHOICE" = "3" ]; then
    AI_PY_DIR="$ALL_SERVICES_DIR/V-Eval-Ai_Engine/rag-service"
    if [ -f "$AI_PY_DIR/main.py" ]; then
        PY_CMD="python3 -m uvicorn main:app --port 8000 --reload"
        if [ -f "$AI_PY_DIR/.venv/bin/python" ]; then
            PY_CMD="$AI_PY_DIR/.venv/bin/python -m uvicorn main:app --port 8000 --reload"
        fi
        start_service "Python_RAG" "$AI_PY_DIR" "$PY_CMD"
    fi
fi

# 6. API Gateway YARP
if [ "$CHOICE" = "1" ] || [ "$CHOICE" = "2" ]; then
    GATEWAY_DIR="$ALL_SERVICES_DIR/V-Eval-Gateway/V-Eval-Gateway.API"
    if [ -f "$GATEWAY_DIR/V-Eval-Gateway.API.csproj" ]; then
        start_service "Gateway_YARP" "$GATEWAY_DIR" "dotnet run"
    fi
fi

# 7. Web Client
if [ "$CHOICE" = "1" ] || [ "$CHOICE" = "4" ]; then
    WEB_DIR="$ALL_SERVICES_DIR/V-Eval-Web_Client"
    if [ -f "$WEB_DIR/package.json" ]; then
        start_service "Web_Client" "$WEB_DIR" "npm run dev"
    fi
fi

echo ""
echo "====================================================================="
echo "          DANH SACH CAC SERVICE VA PORT HOAT DONG"
echo "====================================================================="
echo "  * API Gateway YARP      : http://localhost:5212  [Entry Point]"
echo "  * Identity Service      : http://localhost:5155  [gRPC: 5156]"
echo "  * Content Service       : http://localhost:5249  [gRPC: 5250]"
echo "  * Practice Service      : http://localhost:5261  [UI Runner: :5261/view-diagnostic.html]"
echo "  * AI Engine .NET API    : http://localhost:5104  [OCR, Ingestion]"
echo "  * Python FastAPI RAG    : http://localhost:8000  [Swagger: :8000/docs]"
echo "  * Web Client React Vite : http://localhost:5173  [Frontend UI]"
echo "====================================================================="
echo "Logs duoc luu tai: $LOG_DIR"
echo "Chay option [5] de dung toan bo cac tien trinh khi hoan tat."
