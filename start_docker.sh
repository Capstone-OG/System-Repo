#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR"

echo "====================================================================="
echo "   🚀 V-EVAL CAPSTONE - KHỞI ĐỘNG HỆ THỐNG QUA DOCKER COMPOSE"
echo "====================================================================="
echo ""

# 1. Kiểm tra Docker Daemon
if ! command -v docker &> /dev/null; then
    echo "❌ [ERROR] Docker chưa được cài đặt trên máy tính này!"
    exit 1
fi

if ! docker info &> /dev/null; then
    echo "❌ [ERROR] Docker Daemon chưa chạy! Vui lòng bật Docker Desktop hoặc khởi động dockerd."
    exit 1
fi

# 2. Giải phóng các port nếu đang bị chiếm dụng bởi tiến trình local
echo "🔍 [1/4] Kiểm tra và giải phóng các port nếu bị chiếm dụng bởi tiến trình local..."
if command -v fuser &> /dev/null; then
    fuser -k 5212/tcp 5104/tcp 5249/tcp 5250/tcp 5155/tcp 5156/tcp 5002/tcp 5173/tcp 8000/tcp 2>/dev/null || true
fi

# 3. Đồng bộ chiều Configs -> Services (Configs là nguồn chuẩn, ghi đè file cục bộ)
echo "⚙️  [2/4] Kiểm tra và đồng bộ file cấu hình (.env, appsettings.json)..."
if [ -f "$ROOT_DIR/Scripts/sync_config/sync_config.sh" ]; then
    bash "$ROOT_DIR/Scripts/sync_config/sync_config.sh" --force
fi

# 4. Kiểm tra và đóng gói dist của Web Client
echo "📦 [3/4] Kiểm tra và đóng gói Web Client dist..."
if [ -d "$ROOT_DIR/All Services/V-Eval-Web_Client" ]; then
    if [ ! -d "$ROOT_DIR/All Services/V-Eval-Web_Client/dist" ] || [ -n "$(find "$ROOT_DIR/All Services/V-Eval-Web_Client/src" -newer "$ROOT_DIR/All Services/V-Eval-Web_Client/dist" 2>/dev/null)" ]; then
        echo "   -> Phát hiện thay đổi trong mã nguồn Web Client. Đang đóng gói lại dist..."
        (cd "$ROOT_DIR/All Services/V-Eval-Web_Client" && npm run build)
    else
        echo "   -> Thư mục dist đã sẵn sàng, bỏ qua bước build lại để tối ưu tốc độ."
    fi
fi

# 5. Khởi động các container Docker
echo "🐳 [4/4] Đang khởi chạy các Docker Container ở chế độ nền (-d)..."
cd "$ROOT_DIR"
docker compose up -d "$@"

echo ""
echo "====================================================================="
echo "✅  TOÀN BỘ HỆ THỐNG V-EVAL ĐÃ KHỞI CHẠY THÀNH CÔNG TRÊN DOCKER!"
echo "====================================================================="
echo "  * 🌐 Web Client SPA     : http://localhost:5173 | https://pickic.io.vn | https://app.pickic.io.vn"
echo "  * 🟢 YARP API Gateway   : http://localhost:5212 | https://api.pickic.io.vn"
echo "  * 🔐 Identity Service   : http://localhost:5155 | gRPC: 5156"
echo "  * 📚 Content Service    : http://localhost:5249 | gRPC: 5250"
echo "  * 🎯 Practice Service   : http://localhost:5002"
echo "  * 🧠 AI Engine API      : http://localhost:5104"
echo "  * 🤖 AI Python RAG      : http://localhost:8000"
echo "  * ☁️  Cloudflare Tunnel  : pickic.io.vn (Đã kết nối 4 Edge Server Cloudflare)"
echo "====================================================================="
echo ""
docker compose ps
echo ""
echo "👉 Xem log thời gian thực: docker compose logs -f"
echo "👉 Dừng toàn bộ hệ thống:  docker compose down"
echo ""

if [ "$1" = "-f" ] || [ "$1" = "--logs" ]; then
    docker compose logs -f
fi

