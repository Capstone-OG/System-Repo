# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - V-EVAL CAPSTONE SYSTEM REPO

## [11/11/2026] - Chuyển Toàn Bộ Nhánh Làm Việc Sang Main & Triển Khai Toàn Diện Hệ Thống Microservices Lên Docker Qua Tên Miền pickic.io.vn

- **Đồng Bộ Nhánh Làm Việc Toàn Hệ Thống Sang `main`**:
  - Đã chuyển nhánh và fast-forward/merge đồng bộ 100% tất cả 7 kho lưu trữ (Root System-Repo cùng 6 Microservices: `V-Eval-Ai_Engine`, `V-Eval-Content_Service`, `V-Eval-Gateway`, `V-Eval-Identity_Service`, `V-Eval-Practice_Service`, `V-Eval-Web_Client`) lên nhánh chuẩn `main`.

- **Triển Khai Hoàn Chỉnh Toàn Bộ Microservices Lên Docker Compose**:
  - Khởi tạo và liên kết mạng bridge nội bộ `capstone_veval_network` điều phối toàn bộ 7 container dịch vụ:
    - `v_eval_gateway` (Port `5212:5212`): YARP API Gateway làm cổng giao tiếp duy nhất (Single Entry Point), định tuyến động tới các cluster backend.
    - `v_eval_ai_engine` (Port `5104:5104`): Bộ máy AI phân tích đề thi, OCR Gemini, trích xuất cấu trúc SGK và Socratic AI Tutor.
    - `v_eval_content_service` (Port `5249:5249`, `5250:5250`): Ngân hàng câu hỏi, ma trận đề, dàn kiến thức và gRPC server.
    - `v_eval_identity_service` (Port `5155:5155`, `5156:5156`): Phân hệ xác thực tập trung IAM, JWT Token, quản trị người dùng và gRPC server.
    - `v_eval_practice_service` (Port `5002:5002`): Thi trực tuyến, tính toán dải điểm SEM, thuật toán gợi ý Knapsack ROI và cảnh báo sớm.
    - `v_eval_web_client` (Port `5173:80`): Giao diện Single Page App (React 19 + Vite + TailwindCSS) vận hành trên nền Nginx Alpine tối ưu hóa Gzip và proxy `/api/`.
    - `pickic-tunnel`: Cloudflare Tunnel kết nối 4 Edge data centers toàn cầu, ánh xạ các domain công khai bảo mật SSL/TLS.

- **Định Tuyến Tên Miền Công Khai (Cloudflare Tunnel Routing)**:
  - Cập nhật cấu hình Cloudflare Tunnel `/home/thai-thinh/.cloudflared/config.yml`:
    - `https://pickic.io.vn` ➔ `http://127.0.0.1:5173` (Web Client SPA).
    - `https://app.pickic.io.vn` ➔ `http://127.0.0.1:5173` (Web Client SPA).
    - `https://api.pickic.io.vn` ➔ `http://127.0.0.1:5212` (V-Eval YARP API Gateway).
  - Web Client tự động chuyển đổi URL API Gateway sang `https://api.pickic.io.vn` khi chạy trên domain `pickic.io.vn`, giữ nguyên `http://localhost:5212` khi chạy local.

- **Bộ Script 1-Click Khởi Động Hệ Thống Chuẩn Hóa**:
  - `start_docker.sh` (cùng shortcut `start.sh` & `Scripts/run_docker/run_docker.sh`): Tự động kiểm tra Docker daemon, giải phóng port xung đột, đồng bộ cấu hình, đóng gói Web Client dist và khởi chạy toàn bộ 7 container dịch vụ trong nền (-d) chỉ với 1 cú click.
  - `start_local.sh`: Khởi chạy chế độ phát triển Local 1-click, tự động mở 7 cửa sổ terminal độc lập (Gnome Terminal / GUI Terminal) cho 7 dịch vụ (Gateway, Identity, Content, Practice, AI Engine .NET, Python RAG, Web Client) kèm health-check giám sát trực tiếp.

- **Hoạch Định Kiến Trúc Dự Phòng API Gateway (High Availability & SPOF Mitigation Strategy)**:
  - Phân tích rủi ro Điểm Tắc Nghẽn Đơn Lẻ (Single Point of Failure - SPOF) khi Gateway là Single Entry Point; đánh giá đặc tính 100% Stateless của YARP Kestrel .NET 9 (xác thực token không trạng thái, không lưu cache nghiệp vụ) cho phép mở rộng theo chiều ngang (Horizontal Scaling) vô hạn mà không lo nghẽn bộ nhớ hay conflict session.
  - Xây dựng mô hình cân bằng tải đa tầng: Tầng Docker / Staging (Cloudflare Ingress / Nginx Upstream Round-robin kèm Liveness Healthcheck `/healthz` và Docker self-healing `restart: always`); Tầng Production (Kubernetes Deployment replicas >= 2, Horizontal Pod Autoscaler HPA tự động co giãn theo tải CPU/RAM). Chuẩn bị sẵn sàng bộ luận điểm kiến trúc bảo vệ đồ án trước Hội đồng phản biện Capstone.
