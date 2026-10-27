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

- **Khởi Tạo Độc Lập & Đồng Bộ 100% Sơ Đồ Thực Thể [`docs/diagrams/erd.mmd`](./docs/diagrams/erd.mmd)**:
  - Khởi tạo file độc lập `docs/diagrams/erd.mmd` khớp 100% với kịch bản CSDL chính thức [`docs/SQL/SQL.sql`](./docs/SQL/SQL.sql) (Schema V4.1) và báo cáo nghiệm thu 74 mối quan hệ [`docs/SQL/Tong_Quan_Chi_Tiet_Moi_Quan_He_Entities.md`](./docs/SQL/Tong_Quan_Chi_Tiet_Moi_Quan_He_Entities.md).
  - Phân vùng chính xác 47 thực thể trên 4 Bounded Contexts (`v_eval_identity`: 13, `v_eval_content`: 8, `v_eval_practice`: 19, `v_eval_ai`: 7) và 74 mối quan hệ (42 Khóa ngoại vật lý nội bộ + 32 Tham chiếu logic liên service).
  - Cập nhật khối `erDiagram` trong [`docs_noi_bo/V-Eval_Architecture_Plan.md`](./docs_noi_bo/V-Eval_Architecture_Plan.md) (mục 2.2), loại bỏ hoàn toàn các thực thể giả định cũ lỗi thời.

- **Triển Khai Bộ 10 xUnit Tests Chuẩn Mực & Cập Nhật CI Pipeline**:
  - Khởi tạo project `V-Eval-Practice_Service.Tests` với 10 unit test cases bao phủ toàn diện 3 thuật toán cốt lõi:
    1. `BktEngineTests`: Kiểm thử xác suất Bayesian Knowledge Tracing khi làm đúng, làm sai, phạt đoán mò theo quy tắc BR-08 và kẹp biên an toàn.
    2. `SpacedRepetitionCalculatorTests`: Kiểm thử thuật toán lặp lại ngắt quãng SuperMemo-2 (SM-2), chuỗi làm đúng 3 lần liên tiếp đạt chuẩn thành thạo và cơ chế reset interval khi làm sai.
    3. `ZpdQuestionSelectorTests`: Kiểm thử mô hình trắc lượng IRT 2PL, chuyển đổi logit năng lực $\theta$ và thuật toán chọn câu hỏi rơi vào vùng phát triển gần nhất (ZPD: $P \in [0.60, 0.75]$).
  - Thêm bước chạy test tự động (`dotnet test`) vào file CI workflow `.github/workflows/ci.yml` của Practice Service.

- **Gắn Tag Git `review-2` Đồng Loạt 100% Toàn Bộ Organization `Capstone-OG`**:
  - Gắn và đẩy tag `review-2` thành công lên `System-Repo` và toàn bộ 6 repo dịch vụ con (`v-eval-ai-engine`, `v-eval-content-service`, `v-eval-gateway`, `v-eval-identity-service`, `v-eval-practice-service`, `v-eval-web-client`).

- **Hoàn Thiện Hồ Sơ BM02 (Self-Review Report)**:
  - Chạy đầy đủ Prompt chuẩn của môn học đối chiếu toàn diện 7 hạng mục (Scope, Requirements, Data, States, Flows, Architecture, Design vs code).
  - Xuất 10 phát hiện thực tế kèm phân loại `Team response` minh bạch: 3 Fixed, 1 Kept, 6 Planned.
  - Điền trực tiếp dữ liệu chuẩn hóa vào file [`docs_noi_bo/SWP490_R2_BM02_Self_Review_Report_1.docx`](./docs_noi_bo/SWP490_R2_BM02_Self_Review_Report_1.docx) và khởi tạo bản xem trước [`docs_noi_bo/SWP490_R2_BM02_Self_Review_Report.md`](./docs_noi_bo/SWP490_R2_BM02_Self_Review_Report.md).
