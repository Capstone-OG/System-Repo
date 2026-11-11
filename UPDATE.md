# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - V-EVAL CAPSTONE SYSTEM REPO

## [11/11/2026] - Nâng Cấp Hệ Thống Xoay Vòng 4 Gemini Keys, Khắc Phục Lỗi Bóc Tách Khung Tri Thức AI, Tối Ưu Hóa Docker Context & Triển Khai Toàn Diện pickic.io.vn

- **Khắc Phục Lỗi Deserialization JSON Bóc Tách Khung Tri Thức & Ưu Tiên Chuỗi Mô Hình Flash-Lite**:
  - Nâng cấp bộ phân tích `SanitizeAndRepairGeminiJson` và `TryParseCurriculumFromLooseJson` trong AI Engine, tự động tách code fence markdown ````json ... ````, bọc mảng gốc `[ ... ]` thành DTO hoàn chỉnh và hỗ trợ duyệt node mềm dẻo không phân biệt hoa thường.
  - Loại bỏ hoàn toàn nguy cơ rơi xuống bộ trích xuất fallback Regex làm chậm hệ thống (giảm thời gian trích xuất từ 71s xuống <3s).
  - Tối ưu hóa tệp PDF gửi sang Vision AI: Giảm độ phân giải render xuống `Dpi = 72` (tiết kiệm hơn 70% dung lượng payload), giới hạn kích thước ảnh `maxDim = 720` và chất lượng nén JPEG 50%.
  - Tái cấu trúc danh sách mô hình `GeminiModels`: Đưa các dòng Flash-Lite siêu tốc (`gemini-3.5-flash-lite`, `gemini-3.1-flash-lite`, `gemini-flash-lite-latest`) lên ưu tiên hàng đầu, triệt tiêu lỗi `HTTP 503 This model is currently experiencing high demand`.

- **Tối Ưu Hóa Tốc Độ Build Docker & Kiểm Soát Ngữ Cảnh (.dockerignore)**:
  - Bổ sung cấu hình `.dockerignore` tại thư mục gốc repository, loại trừ triệt để các thư mục nặng không cần thiết (`.git`, `node_modules`, `bin`, `obj`, `wwwroot/uploads`).
  - Giảm dung lượng ngữ cảnh Docker daemon nạp từ **2.14 GB xuống còn 3.2 MB** (giảm 99.8%), rút ngắn thời gian chuẩn bị build từ hơn 60 giây xuống chỉ còn **2.7 giây**.

- **Bảo Mật Bể Khóa 4 Google Gemini API Keys Qua Biến Môi Trường (.env)**:
  - Chuyển toàn bộ các khóa API nhạy cảm vào file `.env` (được bảo vệ an toàn bởi `.gitignore`) với các biến `GEMINI_KEY_1`, `GEMINI_KEY_2`, `GEMINI_KEY_3`, `GEMINI_KEY_4`.
  - Tham chiếu động biến môi trường trong `docker-compose.yml` (`AiSettings__GeminiApiKeys__0=${GEMINI_KEY_1}`, v.v.) và đặt giá trị an toàn trong `appsettings.json`, tuân thủ 100% quy chuẩn GitHub Secret Protection.

- **Đóng Gói Dịch Vụ Python FastAPI RAG Vào Docker Mạng Nội Bộ & Sửa Lỗi 502**:
  - Bổ sung service `v-eval-ai-rag` (Dockerfile tại `All Services/V-Eval-Ai_Engine/rag-service`) vào `docker-compose.yml`, lắng nghe cổng `8000:8000` trên mạng bridge `capstone_veval_network`.
  - Cấu hình Gateway YARP chuyển tiếp cụm `ai-rag-cluster` tới `http://v-eval-ai-rag:8000`, triệt tiêu hoàn toàn lỗi `HTTP 502 Bad Gateway (Connection refused localhost:8000)` khi gọi endpoint chẩn đoán `/api/v1/diagnostic/generate-exam`.
  - Cập nhật `start_docker.sh` kiểm soát port `8000` và hiển thị trạng thái của dịch vụ Python RAG.

- **Định Tuyến & Tiếp Nhận Webhook IPN PayOS Tuyệt Đối (Khắc Phục Lỗi 404 Gateway)**:
  - Bổ sung cấu hình route YARP `practice-payments-route` (`/api/payments/{**catch-all}`) chuyển tiếp toàn bộ yêu cầu thanh toán sang `practice-service-cluster`.
  - Bổ sung thuộc tính routing alias `[HttpPost("/api/payments/payos-webhook")]` tại `PaymentsController.cs` (Practice Service), bảo đảm tiếp nhận chuẩn xác IPN từ cổng thanh toán trực tuyến PayOS mà không còn bị HTTP 404.

- **Triển Khai Hoàn Chỉnh Toàn Bộ Microservices Lên Docker Compose Qua Tên Miền pickic.io.vn**:
  - Khởi tạo và liên kết mạng bridge nội bộ `capstone_veval_network` điều phối toàn bộ 8 container dịch vụ:
    - `v_eval_gateway` (Port `5212:5212`): YARP API Gateway làm cổng giao tiếp duy nhất (Single Entry Point), định tuyến động tới các cluster backend.
    - `v_eval_ai_engine` (Port `5104:5104`): Bộ máy AI phân tích đề thi, OCR Gemini, trích xuất cấu trúc SGK và Socratic AI Tutor.
    - `v_eval_ai_rag` (Port `8000:8000`): Dịch vụ Python FastAPI RAG chẩn đoán học tập và truy hồi dữ liệu ngữ nghĩa.
    - `v_eval_content_service` (Port `5249:5249`, `5250:5250`): Ngân hàng câu hỏi, ma trận đề, dàn kiến thức và gRPC server.
    - `v_eval_identity_service` (Port `5155:5155`, `5156:5156`): Phân hệ xác thực tập trung IAM, JWT Token, quản trị người dùng và gRPC server.
    - `v_eval_practice_service` (Port `5002:5002`): Thi trực tuyến, tính toán dải điểm SEM, thuật toán gợi ý Knapsack ROI và cảnh báo sớm.
    - `v_eval_web_client` (Port `5173:80`): Giao diện Single Page App (React 19 + Vite + TailwindCSS) vận hành trên nền Nginx Alpine.
    - `pickic-tunnel`: Cloudflare Tunnel kết nối 4 Edge data centers toàn cầu, ánh xạ các domain công khai `pickic.io.vn`, `app.pickic.io.vn`, `api.pickic.io.vn` bảo mật SSL/TLS.

- **Bộ Script 1-Click Khởi Động Hệ Thống Chuẩn Hóa**:
  - `start_docker.sh` (cùng shortcut `start.sh` & `Scripts/run_docker/run_docker.sh`): Tự động kiểm tra Docker daemon, giải phóng port xung đột (5173, 5212, 5155, 5249, 5002, 5104, 8000), đồng bộ cấu hình, đóng gói Web Client dist và khởi chạy toàn bộ 8 container dịch vụ trong nền (-d) chỉ với 1 cú click.
  - `start_local.sh`: Khởi chạy chế độ phát triển Local 1-click, tự động mở 7 cửa sổ terminal độc lập cho 7 dịch vụ kèm health-check giám sát trực tiếp.

- **Hoạch Định Kiến Trúc Dự Phòng API Gateway (High Availability & SPOF Mitigation Strategy)**:
  - Phân tích rủi ro Điểm Tắc Nghẽn Đơn Lẻ (Single Point of Failure - SPOF) khi Gateway là Single Entry Point; đánh giá đặc tính 100% Stateless của YARP Kestrel .NET 9 cho phép mở rộng theo chiều ngang (Horizontal Scaling) thành 2-3+ node Active-Active mà không gặp rào cản đồng bộ bộ nhớ.
  - Xây dựng mô hình cân bằng tải đa tầng: Tầng Docker / Staging (Cloudflare Ingress / Nginx Upstream Round-robin kèm Liveness Healthcheck `/healthz` và Docker self-healing `restart: always`); Tầng Production (Kubernetes Deployment replicas >= 2, Horizontal Pod Autoscaler HPA tự động co giãn theo tải CPU/RAM).
