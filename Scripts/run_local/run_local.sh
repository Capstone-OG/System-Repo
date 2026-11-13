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

# Auto-load environment variables from .env files
load_env_file() {
    local env_file="$1"
    if [ -f "$env_file" ]; then
        echo "[ENV] Nap bien moi truong tu: $env_file"
        while IFS= read -r line || [ -n "$line" ]; do
            line=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
            [[ -z "$line" || "$line" =~ ^# ]] && continue
            if [[ "$line" =~ ^([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]]; then
                local key="${BASH_REMATCH[1]}"
                local val="${BASH_REMATCH[2]}"
                val=$(echo "$val" | sed -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//")
                # Bo qua cac placeholder mau
                if [[ "$val" =~ ^(YOUR_|your-|PLACEHOLDER|<) ]]; then
                    continue
                fi
                if [ -n "$val" ] && [ -z "${!key}" ]; then
                    export "$key"="$val"
                fi
            fi
        done < "$env_file"
    fi
}

load_env_file "$ROOT_DIR/.env"
load_env_file "$ROOT_DIR/Configs/.env"
load_env_file "$ALL_SERVICES_DIR/V-Eval-Ai_Engine/rag-service/.env"

# Neu chua co trong .env, quet tim trong appsettings.json cua AI Engine
if [ -z "$GEMINI_API_KEY" ] || [[ "$GEMINI_API_KEY" =~ ^(YOUR_|your-) ]]; then
    for app_json in "$ROOT_DIR/Configs/V-Eval-Ai_Engine/appsettings.json" "$ALL_SERVICES_DIR/V-Eval-Ai_Engine/V-Eval-Ai_Engine.API/appsettings.json"; do
        if [ -f "$app_json" ]; then
            extracted_key=$(grep -o '"GeminiApiKey"[[:space:]]*:[[:space:]]*"[^"]*"' "$app_json" 2>/dev/null | head -n 1 | sed -E 's/.*"GeminiApiKey"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/' || true)
            if [ -n "$extracted_key" ] && [[ ! "$extracted_key" =~ ^(YOUR_|your-) ]]; then
                export GEMINI_API_KEY="$extracted_key"
                export GOOGLE_API_KEY="$extracted_key"
                break
            fi
        fi
    done
fi

if [ -z "$OPENAI_API_KEY" ] || [[ "$OPENAI_API_KEY" =~ ^(YOUR_|your-) ]]; then
    for app_json in "$ROOT_DIR/Configs/V-Eval-Ai_Engine/appsettings.json" "$ALL_SERVICES_DIR/V-Eval-Ai_Engine/V-Eval-Ai_Engine.API/appsettings.json"; do
        if [ -f "$app_json" ]; then
            extracted_oai=$(grep -o '"ApiKey"[[:space:]]*:[[:space:]]*"[^"]*"' "$app_json" 2>/dev/null | head -n 1 | sed -E 's/.*"ApiKey"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/' || true)
            if [ -n "$extracted_oai" ] && [[ ! "$extracted_oai" =~ ^(YOUR_|your-) ]]; then
                export OPENAI_API_KEY="$extracted_oai"
                break
            fi
        fi
    done
fi

# Dong bo alias GOOGLE_API_KEY <-> GEMINI_API_KEY
if [ -n "$GEMINI_API_KEY" ] && [ -z "$GOOGLE_API_KEY" ]; then
    export GOOGLE_API_KEY="$GEMINI_API_KEY"
fi
if [ -n "$GOOGLE_API_KEY" ] && [ -z "$GEMINI_API_KEY" ]; then
    export GEMINI_API_KEY="$GOOGLE_API_KEY"
fi

if [ -n "$GEMINI_API_KEY" ] && [[ ! "$GEMINI_API_KEY" =~ ^(YOUR_|your-) ]]; then
    echo "[INFO] Da nhan dien GEMINI_API_KEY (${GEMINI_API_KEY:0:8}***)"
else
    unset GEMINI_API_KEY
    unset GOOGLE_API_KEY
    echo "[CANH BAO] GEMINI_API_KEY chua duoc cau hinh (hoac dang la placeholder)."
    echo "           Vui long khai bao GEMINI_API_KEY trong file /data/Capstone/.env hoac Configs/V-Eval-Ai_Engine/appsettings.json"
fi
echo ""

# Detect available Linux GUI terminal emulator
TERMINAL_APP=""
if [ -n "$WAYLAND_DISPLAY" ] || [ -n "$DISPLAY" ]; then
    if command -v gnome-terminal >/dev/null 2>&1; then
        TERMINAL_APP="gnome-terminal"
    elif command -v x-terminal-emulator >/dev/null 2>&1; then
        TERMINAL_APP="x-terminal-emulator"
    elif command -v konsole >/dev/null 2>&1; then
        TERMINAL_APP="konsole"
    elif command -v xfce4-terminal >/dev/null 2>&1; then
        TERMINAL_APP="xfce4-terminal"
    elif command -v terminator >/dev/null 2>&1; then
        TERMINAL_APP="terminator"
    elif command -v alacritty >/dev/null 2>&1; then
        TERMINAL_APP="alacritty"
    elif command -v kitty >/dev/null 2>&1; then
        TERMINAL_APP="kitty"
    elif command -v xterm >/dev/null 2>&1; then
        TERMINAL_APP="xterm"
    fi
fi

if [ -n "$TERMINAL_APP" ]; then
    echo "[TERMINAL] Phat hien trinh gia lap terminal: $TERMINAL_APP. Moi service se duoc mo trong mot cua so terminal rieng biet."
else
    echo "[INFO] Khong tim thay giao dien GUI (DISPLAY/WAYLAND). Cac service se chay duoi nen (Headless) va ghi log vao .local_logs."
fi
echo ""

echo "Chon che do khoi dong:"
echo "  [1] Khoi dong FULL tat ca 7 Service [Gateway, Identity, Content, Practice, AI Engine, Python RAG, Web Client]"
echo "  [2] Khoi dong cac Microservices C# [.NET Core]"
echo "  [3] Khoi dong chi AI Subsystem [AI Engine .NET + Python FastAPI RAG]"
echo "  [4] Khoi dong chi Web Client [React 19 Vite - Port 5173]"
echo "  [5] Giai phong / Kill tat ca cac Port va Tien trinh dang chiem dung"
echo "  [6] Thoat"
echo ""

CHOICE="${1:-}"
if [ -z "$CHOICE" ]; then
    read -r -p "Nhap lua chon cua ban [Mac dinh: 1]: " CHOICE
fi
CHOICE="${CHOICE:-1}"

if [ "$CHOICE" = "6" ]; then
    echo "Tam biet!"
    exit 0
fi

# Clean ports & processes
PORTS_TO_CLEAN=(5212 5155 5156 5249 5250 5261 5104 8000 5000 5001 5002 5005 5006 5173 5174 8080 3000)

echo ""
echo "====================================================================="
echo "[BƯỚC 1] Giai phong cac cong Port va tien trinh ton dong..."
echo "====================================================================="

# 1. Kill cac tien trinh cu cua V-Eval (Dotnet & Python RAG) tranh zombie socket
pkill -9 -f "V-Eval-Identity_Service" 2>/dev/null || true
pkill -9 -f "V-Eval-Content_Service" 2>/dev/null || true
pkill -9 -f "V-Eval-Practice_Service" 2>/dev/null || true
pkill -9 -f "V-Eval-Ai_Engine" 2>/dev/null || true
pkill -9 -f "V-Eval-Gateway" 2>/dev/null || true
pkill -9 -f "uvicorn main:app" 2>/dev/null || true

# 2. Dung fuser -k de giai phong truc tiep tren tung Port
for port in "${PORTS_TO_CLEAN[@]}"; do
    fuser -k -9 "${port}/tcp" >/dev/null 2>&1 || true
done

# 3. Kiem tra lai bang lsof neu con sot
for port in "${PORTS_TO_CLEAN[@]}"; do
    pids=$(lsof -ti :"$port" 2>/dev/null || true)
    if [ -n "$pids" ]; then
        for p in $pids; do
            kill -9 "$p" 2>/dev/null || true
        done
    fi
done

# 4. Kiem tra va dung cac container Docker v_eval neu dang chiem port
if command -v docker >/dev/null 2>&1; then
    running_dockers=$(docker ps -q --filter "name=v_eval_" 2>/dev/null || true)
    if [ -n "$running_dockers" ]; then
        echo "[DOCKER] Phat hien container Docker V-Eval dang chay lam chiem cong. Dang dung..."
        docker stop $running_dockers >/dev/null 2>&1 || true
    fi
fi

sleep 1
echo "[DONE] Da giai phong hoan tat toan bo cac Port phat trien."
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
    local label="${4:-$name}"
    local title="V-Eval - $label"
    local log="$LOG_DIR/$name.log"

    echo "[START] Dang khoi dong $label..."

    if [ -n "$TERMINAL_APP" ]; then
        local runner="$LOG_DIR/run_${name}.sh"
        cat <<EOF > "$runner"
#!/usr/bin/env bash
printf '\033]0;%s\007' "$title"
echo "====================================================================="
echo "  $title"
echo "  Thu muc: $dir"
echo "  Lenh:    $cmd"
echo "====================================================================="
echo ""
export ASPNETCORE_ENVIRONMENT=Development
EOF
        if [ -n "$GEMINI_API_KEY" ]; then
            echo "export GEMINI_API_KEY=\"$GEMINI_API_KEY\"" >> "$runner"
            echo "export GOOGLE_API_KEY=\"$GOOGLE_API_KEY\"" >> "$runner"
        fi
        if [ -n "$OPENAI_API_KEY" ]; then
            echo "export OPENAI_API_KEY=\"$OPENAI_API_KEY\"" >> "$runner"
        fi
        cat <<EOF >> "$runner"
cd "$dir" || { echo "[ERROR] Khong the truy cap $dir"; read -r; exit 1; }
$cmd 2>&1 | tee -a "$log"
EXIT_CODE=\${PIPESTATUS[0]}
echo ""
echo "====================================================================="
echo "[INFO] Tien trinh $label da dung lai (Exit code: \$EXIT_CODE)."
echo "Nhan phim [Enter] de dong cua so terminal nay..."
echo "====================================================================="
read -r
EOF
        chmod +x "$runner"

        case "$TERMINAL_APP" in
            gnome-terminal)
                gnome-terminal --title="$title" -- bash "$runner" &
                ;;
            x-terminal-emulator)
                x-terminal-emulator -T "$title" -e bash "$runner" &
                ;;
            konsole)
                konsole --new-tab -p tabtitle="$title" -e bash "$runner" &
                ;;
            xfce4-terminal)
                xfce4-terminal --title="$title" -e "bash $runner" &
                ;;
            terminator)
                terminator -T "$title" -x bash "$runner" &
                ;;
            alacritty)
                alacritty --title "$title" -e bash "$runner" &
                ;;
            kitty)
                kitty --title "$title" bash "$runner" &
                ;;
            xterm)
                xterm -title "$title" -e bash "$runner" &
                ;;
            *)
                (cd "$dir" && exec $cmd) > "$log" 2>&1 &
                ;;
        esac
        echo "        -> Cua so: $TERMINAL_APP [$title]"
    else
        (cd "$dir" && exec $cmd) > "$log" 2>&1 &
        local pid=$!
        echo "        PID: $pid | Log: $log"
    fi
    sleep 2
}

# 1. Identity Service
if [ "$CHOICE" = "1" ] || [ "$CHOICE" = "2" ]; then
    ID_DIR="$ALL_SERVICES_DIR/V-Eval-Identity_Service/V-Eval-Identity_Service.API"
    if [ -f "$ID_DIR/V-Eval-Identity_Service.API.csproj" ]; then
        start_service "Identity_Service" "$ID_DIR" "dotnet run" "Identity Service [HTTP: 5155 | gRPC: 5156]"
    fi
fi

# 2. Content Service
if [ "$CHOICE" = "1" ] || [ "$CHOICE" = "2" ]; then
    CONTENT_DIR="$ALL_SERVICES_DIR/V-Eval-Content_Service/V-Eval-Content_Service.API"
    if [ -f "$CONTENT_DIR/V-Eval-Content_Service.API.csproj" ]; then
        start_service "Content_Service" "$CONTENT_DIR" "dotnet run" "Content Service [HTTP: 5249 | gRPC: 5250]"
    fi
fi

# 3. Practice Service
if [ "$CHOICE" = "1" ] || [ "$CHOICE" = "2" ]; then
    PRACTICE_DIR="$ALL_SERVICES_DIR/V-Eval-Practice_Service/V-Eval-Practice_Service.API"
    if [ -f "$PRACTICE_DIR/V-Eval-Practice_Service.API.csproj" ]; then
        start_service "Practice_Service" "$PRACTICE_DIR" "dotnet run" "Practice Service [HTTP: 5261]"
    fi
fi

# 4. AI Engine .NET API
if [ "$CHOICE" = "1" ] || [ "$CHOICE" = "2" ] || [ "$CHOICE" = "3" ]; then
    AI_NET_DIR="$ALL_SERVICES_DIR/V-Eval-Ai_Engine/V-Eval-Ai_Engine.API"
    if [ -f "$AI_NET_DIR/V-Eval-Ai_Engine.API.csproj" ]; then
        start_service "Ai_Engine_API" "$AI_NET_DIR" "dotnet run" "AI Engine .NET API [HTTP: 5104]"
    fi
fi

# 5. AI Engine Python FastAPI RAG
if [ "$CHOICE" = "1" ] || [ "$CHOICE" = "3" ]; then
    AI_PY_DIR="$ALL_SERVICES_DIR/V-Eval-Ai_Engine/rag-service"
    if [ -f "$AI_PY_DIR/main.py" ]; then
        PY_CMD="python3 -m uvicorn main:app --port 8000 --reload"
        if [ -f "$AI_PY_DIR/.venv/bin/python" ]; then
            PY_CMD="./.venv/bin/python -m uvicorn main:app --port 8000 --reload"
        fi
        start_service "Python_RAG" "$AI_PY_DIR" "$PY_CMD" "AI Engine Python FastAPI RAG [HTTP: 8000]"
    fi
fi

# 6. API Gateway YARP
if [ "$CHOICE" = "1" ] || [ "$CHOICE" = "2" ]; then
    GATEWAY_DIR="$ALL_SERVICES_DIR/V-Eval-Gateway/V-Eval-Gateway.API"
    if [ -f "$GATEWAY_DIR/V-Eval-Gateway.API.csproj" ]; then
        start_service "Gateway_YARP" "$GATEWAY_DIR" "dotnet run" "API Gateway YARP [HTTP: 5212]"
    fi
fi

# 7. Web Client
if [ "$CHOICE" = "1" ] || [ "$CHOICE" = "4" ]; then
    WEB_DIR="$ALL_SERVICES_DIR/V-Eval-Web_Client"
    if [ -f "$WEB_DIR/package.json" ]; then
        start_service "Web_Client" "$WEB_DIR" "npm run dev" "Web Client React Vite [HTTP: 5173]"
    fi
fi

echo ""
echo "====================================================================="
echo "[BƯỚC 3] Kiem tra trang thai khoi dong cac Service (Health Check)..."
echo "====================================================================="

wait_for_port() {
    local port="$1"
    local name="$2"
    local max_wait="${3:-25}"
    local count=0
    printf "  %-32s : " "Dang cho $name [:$port]"
    while [ $count -lt $max_wait ]; do
        if (echo > "/dev/tcp/127.0.0.1/$port") >/dev/null 2>&1; then
            echo "[SAN SANG trong ${count}s]"
            return 0
        fi
        sleep 1
        count=$((count + 1))
    done
    echo "[DANG KHOI DONG NGAM - $count s]"
    return 1
}

if [ "$CHOICE" = "1" ] || [ "$CHOICE" = "2" ]; then
    wait_for_port 5155 "Identity Service" 25
    wait_for_port 5249 "Content Service" 20
    wait_for_port 5212 "Gateway YARP" 15
fi
if [ "$CHOICE" = "1" ] || [ "$CHOICE" = "4" ]; then
    wait_for_port 5173 "Web Client React" 15
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
if [ -n "$TERMINAL_APP" ]; then
    echo "Cac service da duoc khoi dong trong cac cua so terminal rieng biet."
    echo "Dong cua so terminal cua service tuong ung de tat service do."
else
    echo "Logs duoc luu tai: $LOG_DIR"
fi
echo "Chay option [5] de dung tat ca cac port khi hoan tat."
