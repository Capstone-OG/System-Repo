# NHẬT KÝ CẬP NHẬT HỆ THỐNG (SYSTEM-REPO UPDATE LOG)

## [08/11/2026] - Chuẩn Hóa Cấu Trúc Báo Cáo Nghiệm Thu Cá Nhân ThinhTT (Cặp Nhãn Checkbox & Clean Toggle), Hoàn Thiện Kiến Trúc Ingestion Textbook AI & Đồng Bộ Toàn Bộ Commit Phát Triển Vào Danh Mục Kiểm Duyệt

- **Chuẩn Hóa Cấu Trúc Báo Cáo Nghiệm Thu Mã Nguồn Cá Nhân ([`ThinhTT_aceptance.md`](./docs_noi_bo/personal/ThinhTT_aceptance.md))**:
  - **Gỡ Bỏ Bảng Ma Trận Section 0**: Loại bỏ hoàn toàn bảng tóm tắt rườm rà ở đầu tài liệu, tối ưu hóa bố cục tài liệu tập trung trực tiếp vào các phân hệ cốt lõi.
  - **Thiết Kế Cặp Nhãn Checkbox & Clean Toggle 100% Tương Thích MD Editor Plus**:
    - Chuẩn hóa toàn bộ 34 file thành định dạng cặp: Nhãn trạng thái kiểm duyệt (`- [x] **Đã duyệt**` hoặc `- [ ] **Chưa duyệt**`) đặt độc lập ở dòng ngay phía trên thẻ `<details>`.
    - Trả thẻ `<summary>` về tên file thuần túy (loại bỏ hoàn toàn icon, text trạng thái bên trong `<summary>`), ngăn ngừa lỗi vỡ giao diện trên các trình duyệt Markdown và CSS tùy biến.
    - Duyệt hoàn tất 5 file hạt nhân Phân hệ 1 AI Engine: [`CurriculumAiService.cs`](./All%20Services/V-Eval-Ai_Engine/V-Eval-Ai_Engine.Infrastructure/Services/CurriculumAiService.cs), [`GeminiExamParserService.cs`](./All%20Services/V-Eval-Ai_Engine/V-Eval-Ai_Engine.Infrastructure/Services/GeminiExamParserService.cs), [`TextbookRepository.cs`](./All%20Services/V-Eval-Ai_Engine/V-Eval-Ai_Engine.Infrastructure/Repositories/TextbookRepository.cs), [`CurriculumEndpoints.cs`](./All%20Services/V-Eval-Ai_Engine/V-Eval-Ai_Engine.API/Endpoints/CurriculumEndpoints.cs) và [`TextbookEndpoints.cs`](./All%20Services/V-Eval-Ai_Engine/V-Eval-Ai_Engine.API/Endpoints/TextbookEndpoints.cs).
    - 29 file cốt lõi còn lại (Content, Practice, Gateway, IAM, Web Client, DevOps) được đặt ở trạng thái chờ `- [ ] **Chưa duyệt**`.

- **Hoàn Thiện Giải Trình Kiến Trúc Chuyên Sâu Cho `TextbookEndpoints.cs` ([`ThinhTT_aceptance.md`](./docs_noi_bo/personal/ThinhTT_aceptance.md))**:
  - Làm rõ cơ chế điều phối Job chạy ngầm bất đồng bộ qua `Task.Run` kết hợp `IServiceScopeFactory`, giải phóng HTTP request ngay lập tức với mã HTTP 202 Accepted (`{ JobId, Status: "Processing" }`).
  - Trình bày chi tiết cơ chế Single-Pass SHA-256 CryptoStream chống bóc tách trùng lặp tài liệu, Dual-OCR pipeline kết hợp `PdfPig` và `VietOCR`, cơ chế checkpointing phục hồi trạng thái và trích xuất vector 768 chiều vào PostgreSQL `pgvector`.

- **Đồng Bộ Toàn Bộ Commit Mã Nguồn Chưa Kiểm Duyệt Vào Mục 9 ([`ThinhTT_aceptance.md`](./docs_noi_bo/personal/ThinhTT_aceptance.md))**:
  - Ghi nhận đầy đủ mã commit, ngày tháng, trạng thái thay đổi (`A`/`M`) và mô tả kỹ thuật chi tiết của tất cả các file do ThinhTT commit trực tiếp trên nhánh `ThinhTT/feature-role-portals-and-home-theme-sync` và `develop`:
    - **9.1. Identity Service**: Soft delete toggle status (`84a97dd`), Email validation DNS MX & Student nullable `campus_id` (`6a039ce`), Liên kết Phụ huynh - Học sinh 2 chiều (`1be554b`), Brevo SMTP Relay gửi OTP thực tế (`352b06a`).
    - **9.2. Practice Service**: `EarlyWarningSweepWorker` quét tự động 6h sáng và `NotificationDispatcher` đa kênh (`322d73d`), Dashboard phụ huynh DB thật (`6ad262c`).
    - **9.3. Content, Gateway & AI Engine**: Bộ test suites `xUnit`, `Moq`, `FluentAssertions`, Result Pattern, `CorrelationIdMiddleware`.
    - **9.4. Web Client**: Không gian làm việc `w-full` sát Sidebar & bảng IAM 1 dòng (`815c1f6`), tab quản lý tài khoản ngừng hoạt động Soft delete (`d4d023e`), thanh điều hướng Segmented Control & Cổng Giám đốc Học thuật (`444b73c`), thẻ liên kết 3-trong-1 & 5 cổng vai trò (`1da817d`), modal OTP 6 ô Fintech (`dc30a70`) và cổng thanh toán học phí VietQR PayOS (`389d856`).

- **Bổ Sung Cấu Hình SMTP Brevo Vào Bộ Cấu Hình Tập Trung ([`Configs/V-Eval-Identity_Service/appsettings.json`](./Configs/V-Eval-Identity_Service/appsettings.json))**:
  - Tích hợp schema cấu hình `Email` chuẩn vào bộ nạp tập trung (`Configs/`) phục vụ công cụ `sync_config.bat` / `sync_config.sh`.
  - Thiết lập giá trị mật khẩu dạng placeholder an toàn (`YOUR_BREVO_SMTP_KEY_OR_ENV_VAR`) ngăn chặn triệt để cơ chế quét mã bí mật (Secret Scanning) của GitHub, hỗ trợ lập trình viên chủ động điền key thực tế khi chạy môi trường cục bộ.
