# Nhật Ký Cập Nhật (Update Log) - System Repo

## [24/09/2026] - Bổ Sung Route Aliases Content Service (`/api/content/exams`) & Tối Ưu Hóa Multi-Schemas Supabase

- **Bổ Sung Route Aliases Cho Content Service (`V-Eval-Content_Service`)**:
  - Đã thêm Route Alias `[Route("api/content/exams")]` và `[Route("api/content")]` song song với `/v1/` trong `MockExamsController` và `DiagnosticController`.
  - Khắc phục triệt để lỗi HTTP `404 (Not Found)` khi Web Viewer gọi direct endpoint `GET http://localhost:5249/api/content/exams`.
  - Tối ưu `app.UseHttpsRedirection()` trong `Program.cs` hỗ trợ HTTP port 5249 và gRPC port 5250 ở môi trường Development.
- **Cấu Hình Chuỗi Kết Nối PostgreSQL Supabase Cho AI Engine & Microservices**:
  - Đã bổ sung `ConnectionStrings:DefaultConnection` vào `appsettings.json` của `V-Eval-Ai_Engine.API` kết nối tới Supabase Cloud.
  - Đã khởi tạo file `rag-service/.env` & `.env.example` cấu hình `DATABASE_URL` cho Python RAG Service (`postgresql+psycopg`) kết nối trực tiếp đến Supabase PostgreSQL.
- **Tái Cấu Trúc Schema CSDL Độc Lập Cho 5 Microservices**:
  - `v_eval_identity`: Quản lý Auth, Users, Roles & Profiles.
  - `v_eval_content`: Quản lý Ngân hàng Đề thi, Passage, Questions, Competency Domains & Skills.
  - `v_eval_practice`: Quản lý Lớp học, Exam Submissions, Submissions Answers & Ability Groups.
  - `v_eval_ai`: Quản lý Vector Store `KnowledgeVectorChunks` (`pgvector`), AI Tutor Sessions & Token Logs.
  - `v_eval_system`: Quản lý System Alerts & Configurations.
