# Nhật Ký Cập Nhật (Update Log) - System Repo

## [01/10/2026] - Tích Hợp Toàn Diện Web Client Vào Kiến Trúc Microservices Hệ Thống & Chuẩn Hóa Cấu Hình YARP Gateway

- **Đồng Bộ Kiến Trúc Giao Tiếp Web Client (`V-Eval-Web_Client`)**:
  - Hoàn thiện tầng giao tiếp trung tâm `src/services/` (`apiClient.js`, `authService.js`, `contentService.js`, `practiceService.js`, `aiService.js`) kết nối trực tiếp đến YARP API Gateway (`http://localhost:5212`).
  - Thiết lập cơ chế tự động đính kèm Bearer token và silent refresh qua response header `X-Token-Refresh-Required` của Gateway.
- **Hạ Tầng Docker & Runner Hệ Thống**:
  - Container hóa Web Client qua Dockerfile đa tầng (Node 22 + Nginx Alpine SPA routing) và tích hợp vào [`docker-compose.yml`](./docker-compose.yml) tại cổng `5173:80`.
  - Cập nhật [`Scripts/run_local/run_local.bat`](./Scripts/run_local/run_local.bat) và [`Scripts/setup/setup.bat`](./Scripts/setup/setup.bat) đồng bộ vận hành 7 dịch vụ hệ sinh thái V-Eval.
- **Kiểm Thử Vận Hành & Tuân Thủ Quy Chuẩn**:
  - `npm run build` cho Web Client hoàn thành trong 619ms với 0 cảnh báo/lỗi cú pháp.
  - Cú pháp [`docker-compose.yml`](./docker-compose.yml) đạt chuẩn 100% qua `docker compose config` và vượt qua kiểm tra định dạng `yamllint`.
