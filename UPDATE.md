# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [27/10/2026] - Chuẩn Hóa Kiến Trúc, Đồng Bộ ERD.mmd, Triển Khai 10 Unit Tests & Gắn Tag review-2 Toàn Bộ Hệ Thống

- **Bổ Sung Đầy Đủ Các Kênh Giao Tiếp Server-to-Server Thực Tế**:
  - Bổ sung kết nối `Practice Service ==> Identity Service` qua `gRPC HTTP/2 (:5155)`: Phục vụ truy vấn thông tin định danh học sinh (`GetStudentProfileSummary`) và phân quyền phụ huynh - học sinh (`GetParentStudents`) trong luồng Diagnostic & Analytics Dashboard.
  - Bổ sung kết nối `Practice Service --> AI RAG Service (Python FastAPI)` qua `HTTP / SSE Stream (:8000)`: Khắc phục sự thiếu sót của sơ đồ cũ, thể hiện đúng kiến trúc thực tế khi Practice Service đóng vai trò ủy thác/điều phối luồng hội thoại với Gia sư Socratic AI Tutor (`AiTutorClient` gọi `/api/v1/socratic/ask-stream`).
  - Duy trì kết nối `Practice Service ==> Content Service` qua `gRPC HTTP/2 (:5250)`: Lấy dữ liệu Skill Tree DAG, Quiz đề thi, câu hỏi và đáp án.

- **Bổ Sung Tầng Người Dùng & Thiết Bị (Clients & Users Layer)**:
  - Thể hiện trực quan khối đối tượng người dùng (Students, Teachers, Parents, Admins) tương tác qua trình duyệt vào `V-Eval Web Client (React 19 SPA + JSXGraph & KaTeX)` và cổng kết nối dự kiến của `Mobile Client (PWA / Flutter)`.

- **Minh Bạch Hóa Các Port Dịch Vụ & Schema Cô Lập Trên Supabase**:
  - Ghi chú cổng chính xác trên từng box để tiện tra cứu và triển khai:
    - `API Gateway`: Cổng `5000` (Microsoft YARP Reverse Proxy).
    - `Identity Service`: Cổng `5155` (EF Core -> Schema `v_eval_identity`).
    - `Content Service`: Cổng `5249` (REST) & `5250` (gRPC) (EF Core -> Schema `v_eval_content` + Supabase Object Storage).
    - `Practice Service`: Cổng `5261` (EF Core -> Schema `v_eval_practice`).
    - `AI Engine Core (.NET 9)`: Cổng `5104` (EF Core / Npgsql -> Schema `v_eval_ai` + Supabase Object Storage).
    - `AI RAG Service (Python FastAPI)`: Cổng `8000` (HNSW Vector Search & KG -> Schema `v_eval_ai`).
  - Tầng dịch vụ bên ngoài: Thể hiện rõ `Google Gemini API` (LLM & Vision chính), `OpenAI API` (Fallback dự phòng) và `Google OAuth 2.0` (Social Login).

- **Khởi Tạo Độc Lập & Cập Nhật Đầy Đủ Thuộc Tính Sơ Đồ Thực Thể [`docs/diagrams/erd.mmd`](./docs/diagrams/erd.mmd) & Đồng Bộ CSDL**:
  - **Khai báo thuộc tính chi tiết (Attribute Definitions)**: Khai báo đầy đủ 100% thuộc tính/cột (`column_type`, `column_name`, `PK`, `FK`, `UK` và chú thích nghiệp vụ) cho toàn bộ 50 thực thể trong `docs/diagrams/erd.mmd` và tài liệu kiến trúc [`docs_noi_bo/V-Eval_Architecture_Plan.md`](./docs_noi_bo/V-Eval_Architecture_Plan.md).
  - **Bổ sung thực thể `LearningProfiles`**: Bổ sung đầy đủ entity block và quan hệ cho `LearningProfiles` (lưu tiên nghiệm BKT $P(L_0)$) trong `erd.mmd` khớp 100% với code `PracticeDbContext.cs` và `SQL.sql`.
  - **Bổ sung vòng đời trạng thái Sổ tay lỗi sai (`MistakeNotebooks`)**: Bổ sung cột `status` và lớp hằng số `MistakeLifecycleState` (`NEW_MISTAKE`, `DUE_FOR_REVIEW`, `REVIEWING`, `RETAINED`, `RELAPSED`, `MASTERED`) trong code [`MistakeNotebook.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Domain/Entities/MistakeNotebook.cs), CSDL `SQL.sql` và `erd.mmd`.
  - **Chuẩn hóa Vector Embedding 768 Chiều & HNSW Indexing**: Thống nhất toàn hệ thống chiều vector embedding về 768 chiều (Google Gemini `text-embedding-004`) cho cả `KnowledgeVectorChunks` và `archetype_patterns`, khắc phục triệt để giới hạn 2000 chiều của pgvector và kích hoạt chỉ mục HNSW `idx_archetype_patterns_hnsw`.
  - **Đồng bộ kịch bản DDL Python RAG**: Đồng bộ trọn vẹn 9 bảng của schema `v_eval_ai` vào `graph_schema.sql` và `apply_graph_schema.py`.
  - Quy mô hệ thống hoàn thiện: **50 Thực thể** (Identity: 13, Content: 8, Practice: 20, AI: 9) và **81 Mối quan hệ** liên kết logic & vật lý.

- **Chuẩn Hóa Bộ Unit Tests Tinh Gọn (2-4 Tests/Service) Phủ Đầy Đủ 100% Các Service & Tích Hợp CI Pipelines**:
  - Triển khai đồng bộ bộ Unit Test tinh gọn, đúng định mức 2–4 test cases cho toàn bộ 6 repositories có code trong hệ thống V-Eval:
    1. `V-Eval-Practice_Service` (4 tests): Kiểm thử công thức cập nhật xác suất thành thạo BKT (khi đúng/sai), thuật toán lặp lại ngắt quãng SM-2 và bộ chọn câu hỏi thích ứng ZPD.
    2. `V-Eval-Content_Service` (3 tests): Kiểm thử trình xác thực FluentValidation cho lệnh tạo đề thi `CreateQuizExamCommandValidatorTests` (hợp lệ, thiếu title, sai thời lượng).
    3. `V-Eval-Identity_Service` (3 tests): Kiểm thử kiến trúc Common Result Pattern (`Result.Success`, `Result.Failure`, `Result<T>.Success`).
    4. `V-Eval-Gateway` (3 tests): Kiểm thử pipeline middleware `CorrelationIdMiddlewareTests` (tự động sinh GUID khi thiếu header, bảo tồn header khi có sẵn, đảm bảo next pipeline).
    5. `V-Eval-Ai_Engine` (3 tests): Kiểm thử thực thể Socratic Tutor Session Domain `TutorSessionTests` (khởi tạo, validate dữ liệu rỗng, ghi nhận hội thoại & kết thúc phiên).
    6. `V-Eval-Web_Client` (3 tests): Kiểm thử module quản lý token & phiên đăng nhập `tokenStorage.test.js` bằng Node.js Native Test Runner (set/get tokens, parse user profile, clear storage).
  - Tích hợp bước chạy test tự động (`dotnet test` / `npm test`) vào toàn bộ file `.github/workflows/ci.yml` của các repositories tương ứng.

- **Gắn Tag Git `review-2` Đồng Loạt 100% Toàn Bộ Organization `Capstone-OG`**:
  - Gắn và đẩy tag `review-2` thành công lên `System-Repo` và toàn bộ 6 repo dịch vụ con (`v-eval-ai-engine`, `v-eval-content-service`, `v-eval-gateway`, `v-eval-identity-service`, `v-eval-practice-service`, `v-eval-web-client`).

- **Chuẩn Hóa Hồ Sơ Biểu Mẫu BM02 (Self-Review Report)**:
  - Khởi tạo và làm sạch biểu mẫu BM02 chuẩn [`docs/docs/SWP490_R2_BM02_Self_Review_Report_1.docx`](./docs/docs/SWP490_R2_BM02_Self_Review_Report_1.docx) sẵn sàng phục vụ báo cáo đối soát và đánh giá nghiệm thu đợt Review 2.
