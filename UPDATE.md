# Nhật Ký Cập Nhật (Update Log)

## [15/09/2026] - Dockerize Toàn Hệ Thống 5 Microservices & Chuẩn Hóa Orchestration Docker Compose
- **Khởi Tạo Dockerfile Multi-Stage .NET 9 Tinh Gọn Cho 5 Microservices**:
  - `All Services/V-Eval-Gateway/Dockerfile`: Cổng `5212` (Gateway YARP Proxy).
  - `All Services/V-Eval-Ai_Engine/Dockerfile`: Cổng `5104` (AI Exam Ingestion & Chatbot).
  - `All Services/V-Eval-Content_Service/Dockerfile`: Cổng `5249` (Ngân hàng câu hỏi & Đề thi).
  - `All Services/V-Eval-Identity_Service/Dockerfile`: Cổng `5001` (Quản lý Người dùng & JWT Auth).
  - `All Services/V-Eval-Practice_Service/Dockerfile`: Cổng `5002` (Thi trực tuyến & Chấm điểm).
- **Chuẩn Hóa Docker Compose Orchestration (`docker-compose.yml`)**:
  - Điều phối 5 container microservice kết nối qua mạng nội bộ bridge `veval_network`.
  - Cấu hình port mapping, biến môi trường `ASPNETCORE_ENVIRONMENT=Development` và chính sách tự động khởi động lại `restart: unless-stopped`.
  - Kiểm thử cú pháp `docker compose config` đạt **100% thành công (Exit Code 0)**.
- **Cập Nhật Script Chạy Tự Động (`Scripts/run_docker/run_docker.bat`)**:
  - Script tự động phát hiện root project, kiểm tra Docker Daemon và thực thi `docker-compose up --build`.
- **Cập Nhật Hệ Thống Tài Liệu & README**:
  - Cập nhật bảng ma trận Port và tài liệu Daily Check Log cho cả 5 phân hệ dịch vụ.

## [14/09/2026] - Chuyển Đổi V-Eval Gateway sang Modular Architecture, Security Claims Transformer & Chuẩn Hóa Cấu Hình Production
- **Tái Cấu Trúc V-Eval Gateway sang Modular Architecture**:
  - Gỡ bỏ 3 tầng dự án Clean Architecture rỗng (`Domain`, `Application`, `Infrastructure`).
  - Chuyển `V-Eval-Gateway.API` về mô hình **Feature Folders / Modular Architecture** với 6 mô-đun chức năng: `Middlewares/`, `Security/`, `Transforms/`, `RateLimiting/`, `Health/`, `Extensions/`.
- **Mô-Đun Bảo Mật & Response Token Warning (`ClaimsHeaderTransform.cs`)**:
  - Triển khai `Anti-Header-Spoofing`: Tự động xóa các header `X-User-*` giả mạo từ client.
  - Bóc tách JWT Claims (`UserId`, `Role`, `Email`) tiêm vào Proxy Request Header.
  - Cấu hình tự động gửi Response Header `X-Token-Refresh-Required: true` khi Token sắp hết hạn (dưới ngưỡng `RefreshThresholdMinutes`, mặc định 5 phút).
- **Mô-Đun Chống Spam API (`RateLimiterExtensions.cs`)**:
  - Tích hợp Fixed Window (100 req/min) & Sliding Window (60 req/min) trả về HTTP 429 khi quá tải.
- **Chuẩn Hóa Production Config & Git Security trên Toàn Hệ Thống (5 Microservices)**:
  - Khởi tạo file mẫu `appsettings.example.json` cho cả 5 microservices.
  - Cập nhật quy tắc `.gitignore` bảo vệ tuyệt toàn bộ các file `appsettings.json` cá nhân.
  - Hoàn thiện bộ tài liệu triển khai và nghiệm thu kiến trúc tại `V-Eval-Gateway/docs/`.
