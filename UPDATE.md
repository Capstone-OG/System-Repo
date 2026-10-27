# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [27/10/2026] - Rà Soát Toàn Diện & Chuẩn Hóa Sơ Đồ Kiến Trúc Hệ Thống (System Overview Architecture) & Đồng Bộ ERD.mmd

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

- **Tối Ưu Hóa Nhãn Súc Tích & Thuận Tiện Trực Quan Hóa Trên Miro**:
  - Tinh gọn văn bản trong từng node, loại bỏ các đoạn văn dài thừa thãi; giữ cấu trúc Title + Subtitle ngắn gọn 1-2 dòng giúp người dùng dễ dàng chuyển đổi thành các card/box trực quan trên Miro.
  - Đảm bảo 100% chuẩn Mermaid 11.15.0+ (bọc ngoặc kép node có ký tự đặc biệt, không liên kết gộp `A & B --> C`).
  - Đồng bộ đồng nhất trên toàn bộ hệ thống tài liệu:
    1. [`docs/diagrams/architecture.mmd`](./docs/diagrams/architecture.mmd)
    2. [`docs/diagrams/erd.mmd`](./docs/diagrams/erd.mmd)
    3. [`docs_noi_bo/V-Eval_Architecture_Plan.md`](./docs_noi_bo/V-Eval_Architecture_Plan.md)
    4. [`README.md`](./README.md)
