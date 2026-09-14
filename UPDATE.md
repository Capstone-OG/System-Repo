# Nhật Ký Cập Nhật (Update Log)

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
  - Khởi tạo file mẫu `appsettings.example.json` cho cả 5 microservices (`Gateway`, `Ai_Engine`, `Content_Service`, `Identity_Service`, `Practice_Service`).
  - Cập nhật quy tắc `.gitignore` bảo vệ tuyệt toàn bộ các file `appsettings.json` cá nhân chứa password / API Key thật khỏi bị lỡ tay đẩy lên Git.
  - Hoàn thiện bộ tài liệu triển khai và nghiệm thu kiến trúc tại `V-Eval-Gateway/docs/`.

## [12/09/2026] - Hoàn Thiện API Gateway Health Checks & Kiểm Thử Xây Dựng Hệ Thống
- **Xây Dựng Health Check Endpoint (`/healthz`)**:
  - Cung cấp REST Endpoint kiểm tra trạng thái hoạt động của Gateway (`/healthz`) trả về trạng thái HTTP 200 OK kèm dấu thời gian UTC.
- **Xác Minh Build & Đồng Bộ Hệ Thống**:
  - Biên dịch và kiểm thử thành công toàn bộ giải pháp `V-Eval-Gateway` (0 lỗi, 0 cảnh báo).

## [11/09/2026] - Thiết Kế Ma Trận Định Tuyến Microservices & Middleware V-Eval Gateway
- **Cấu Hình Routing & Cluster Matrix (`appsettings.json`)**:
  - Thiết lập bảng định tuyến YARP cho 4 phân hệ chính: AI Engine (`:5104`), Content Service (`:5249`), Identity Service (`:5001`), Practice Service (`:5002`).
  - Định tuyến các URL `/api/ai-engine/*`, `/view-exam`, `/extracted_images/*`, `/api/content/*` về đúng service xử lý.
- **Tích Hợp Middleware & Distributed Tracing**:
  - Bổ sung middleware tự động sinh và chuyển tiếp `X-Correlation-ID` header cho distributed tracing giữa các microservice.
  - Thiết lập chính sách CORS cho phép tất cả các nguồn truy cập từ Frontend/SPA.
