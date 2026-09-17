# Nhật Ký Cập Nhật (Update Log)

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
