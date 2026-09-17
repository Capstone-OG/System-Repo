# Nhật Ký Cập Nhật (Update Log)

## [18/09/2026] - Phát Hành Bộ Script Push Độc Lập Cho Từng Microservice & Thiết Lập AI Rules Hướng Đối Tượng Tài Liệu
- **Khởi Tạo Bộ Quy Tắc Hệ Thống Cho AI Assistant (`AGENTS.md` & `.agents/rules/documentation_workflow.md`)**:
  - Thiết lập quy tắc bắt buộc **Documentation First**: AI **BẮT BUỘC** phải cập nhật đầy đủ file `UPDATE.md`, `daily_check_log.md` và tài liệu kiến trúc của từng service trước khi đề xuất hoặc thực hiện các lệnh Git Add / Commit / Push.
  - Quy định quy trình 3 bước nghiêm ngặt: (1) Code & Test, (2) Cập nhật docs & `UPDATE.md` của ngày hôm đó ở đầu file, (3) Mới được hỏi/thực hiện Commit & Push.
- **Phát Hành Công Cụ Push Độc Lập Cho Từng Service (`Scripts/push.bat`)**:
  - Đóng gói file script [`Scripts/push.bat`](file:///e:/CapStone/All%20Services/V-Eval-Gateway/Scripts/push.bat) độc lập tại từng microservice (`V-Eval-Gateway`, `V-Eval-Identity_Service`, `V-Eval-Content_Service`, `V-Eval-Practice_Service`, `V-Eval-Ai_Engine`).
  - **3 Chế độ Push thông minh**:
    1. *Push nhánh hiện tại*: Đẩy code trực tiếp lên nhánh làm việc hiện tại (`develop`, `main`, ...).
    2. *Chọn nhánh đã có*: Hiển thị danh sách các nhánh local hiện có dưới dạng **Menu đánh số trực quan** (không cần nhập thủ công tên nhánh).
    3. *Tạo nhánh mới*: Tạo và checkout sang nhánh feature mới tự động.
  - **Cơ chế Kiểm tra & Cảnh báo Đỏ (Red Warning) Lịch sử Git**:
    - Tự động chạy `git fetch origin` và kiểm tra sai lệch SHA giữa Local & Remote trước khi push.
    - Tự động `git pull` nếu code local bị chậm (behind).
    - **Cảnh báo Đỏ nổi bật** và ngắt quy trình Push ngay lập tức nếu phát hiện xung đột (Conflict / Divergence) để yêu cầu Developer xử lý thủ công an toàn.
- **Sửa Lỗi Dứt Điểm Bộ Script Hệ Thống (`Scripts/`)**:
  - Khắc phục các lỗi cú pháp Windows CMD Batch trên [`pull.bat`](file:///e:/CapStone/Scripts/pull/pull.bat), [`push.bat`](file:///e:/CapStone/Scripts/push/push.bat), [`setup.bat`](file:///e:/CapStone/Scripts/setup/setup.bat), [`run_docker.bat`](file:///e:/CapStone/Scripts/run_docker/run_docker.bat), [`run_local.bat`](file:///e:/CapStone/Scripts/run_local/run_local.bat).
  - Khắc phục triệt để lỗi escape quote `\"` tại lệnh `pushd`, lỗi ngoặc đơn `()` trong câu lệnh `echo` và scope nhãn `:PROCESS_PULL`.

## [16/09/2026 - 17/09/2026] - Đồng Bộ Cấu Trúc CSDL V2 ERD (PlantUML) & Chuẩn Hóa JWT Claims X-Headers Tại Gateway
- **Đồng Bộ 100% CSDL PostgreSQL Schema V2 (`docs/SQL/SQL.sql`)**:
  - Cập nhật DDL PostgreSQL khớp 100% với sơ đồ PlantUML `VACT_SCHEMA_V2_ERD`:
    - Bổ sung Cụm 1 & 2 (RBAC & Actor Profiles): `Campuses`, `Students`, `Teachers`, `Parents`, `AcademicManagers`, `AcademicDirectors`, `Administrators`.
    - Bổ sung Cụm 5 (Lớp học & Live): `Classes`, `ClassEnrollments`, `LiveSessions`, `LiveSessionAttendance`, `TeacherFeedback`.
    - Bổ sung Cụm 7, 8, 9 (AI RAG & Vận hành): `KnowledgeSources`, `TokenUsageLogs`, `SystemConfigs`.
- **Đồng Bộ JWT Claims & Nâng Cấp Gateway Claims Transformer**:
  - Nâng cấp [`ClaimsHeaderTransform.cs`](file:///e:/CapStone/All%20Services/V-Eval-Gateway/V-Eval-Gateway.API/Security/ClaimsHeaderTransform.cs): Bóc tách claim `campus_id` đính kèm vào Header **`X-Campus-Id`** cho các microservice nội bộ.
  - Hoàn thiện trọn bộ X-Headers: `X-User-Id`, `X-User-Role`, `X-User-Email`, `X-Campus-Id`, `X-Token-Expires-At`, `X-Token-Remaining-Seconds`, và `X-Token-Refresh-Required`.
- **Cập Nhật Hệ Thống Tài Liệu**:
  - Cập nhật nhật ký [`docs/daily_check_log.md`](file:///e:/CapStone/All%20Services/V-Eval-Gateway/docs/daily_check_log.md) và báo cáo nghiệm thu [`docs/nghiem_thu_va_thau_hieu_kien_truc.md`](file:///e:/CapStone/All%20Services/V-Eval-Gateway/docs/nghiem_thu_va_thau_hieu_kien_truc.md).

## [15/09/2026] - Dockerize Toàn Hệ Thống 5 Microservices & Chuẩn Hóa Orchestration Docker Compose
- **Khởi Tạo Dockerfile Multi-Stage .NET 9 Tinh Gọn Cho 5 Microservices**:
  - `All Services/V-Eval-Gateway/Dockerfile`: Cổng `5212` (Gateway YARP Proxy).
  - `All Services/V-Eval-Ai_Engine/Dockerfile`: Cổng `5104` (AI Exam Ingestion & Chatbot).
  - `All Services/V-Eval-Content_Service/Dockerfile`: Cổng `5249` (Ngân hàng câu hỏi & Đề thi).
  - `All Services/V-Eval-Identity_Service/Dockerfile`: Cổng `5001` (Quản lý Người dùng & JWT Auth).
  - `All Services/V-Eval-Practice_Service/Dockerfile`: Cổng `5002` (Thi trực tuyến & Chấm điểm).
- **Chuẩn Hóa Docker Compose Orchestration (`docker-compose.yml`)**:
  - Điều phối 5 container microservice kết nối qua mạng nội bộ bridge `veval_network`.
