# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [26/10/2026] - Chuẩn Hóa Cấu Trúc Tài Liệu docs, Tinh Gọn diagrams Trực Tiếp & Khắc Phục Kiến Trúc Review 2

- **Tinh Gọn & Chuẩn Hóa Thư Mục Sơ Đồ [`docs/diagrams/`](./docs/diagrams/)**:
  - Đưa trực tiếp toàn bộ 6 file mã nguồn Mermaid sơ đồ hoạt động (Activity Diagrams) chuẩn hóa theo từng Core Flow ra thẳng thư mục gốc `docs/diagrams/`:
    - `core1_activity.mmd`: Khảo thí chẩn đoán năng lực & Phân tầng xếp lớp cơ sở.
    - `core2_activity.mmd`: Cắt tỉa thời gian, kiểm định DAG (Tarjan SCC), Kahn Topo & Gom cụm vi mô K-Means.
    - `core3_activity.mmd`: Chu trình tự học thích ứng P-L-A-R (BR-01, BR-03, BR-08) & Phòng thi thử giám sát liêm chính (BR-20).
    - `core4_activity.mmd`: Gia sư Socratic AI, phòng vệ ảo giác GraphRAG & Thẩm định mẫu đề mới Exception Queue.
    - `core5_activity.mmd`: Dashboard phân tích học sinh, Streak, Ma trận 2D Heatmap lớp học & CTA Live Q&A.
    - `core6_activity.mmd`: Sổ tay lỗi sai & Lập lịch ôn tập lặp lại ngắt quãng SuperMemo-2 (SM-2).
  - Duy trì sơ đồ kiến trúc tổng quan hệ thống: `architecture.mmd`.
  - Dọn sạch các file `.mmd` cũ mang tính chất tượng trưng/phác thảo trước đây (`02_logical_erd.mmd`, `03_state_machine.mmd`, `04_activity_swimlane.mmd`).
  - Chuẩn hóa cú pháp node vòng tròn Mermaid: Chuyển đổi `(( "..." ))` sang cú pháp chuẩn `(("..."))` không chứa khoảng trắng cho toàn bộ các nút Start/End, khắc phục triệt để lỗi `Parse error Expecting 'DOUBLECIRCLEEND' got 'STR'` trên GitHub và MD Editor Plus.
  - Lưu giữ nguyên vẹn 2 thư mục chứa ảnh sơ đồ chuẩn: `activity_diagram/` và `ActivityDiagramCore236/`.

- **Tái Cấu Trúc Toàn Diện Thư Mục [`docs/`](./docs/)**:
  - Tại gốc `docs/` chỉ duy trì đúng 2 thư mục tài nguyên chính quy:
    1. [`docs/diagrams/`](./docs/diagrams/): Chứa các sơ đồ kiến trúc và activity diagrams chuẩn 6 Core Flows.
    2. [`docs/SQL/`](./docs/SQL/): Chứa file kịch bản CSDL chính thức `SQL.sql` và tài liệu nghiệm thu 74 quan hệ thực thể.
  - Toàn bộ các tài liệu đặc tả, kế hoạch triển khai chi tiết, báo cáo nội bộ và biên bản họp được dời độc lập sang thư mục nội bộ tại gốc repo: [`docs_noi_bo/`](./docs_noi_bo/).
  - Cập nhật mục lục điều hướng và cây thư mục dự án trong [`README.md`](./README.md) đồng bộ hoàn toàn với cấu trúc mới.

- **Khắc Phục Toàn Diện 7 Điểm Lệch Kiến Trúc Review 2**:
  1. Thống nhất duy nhất 1 chuẩn Mermaid (đã loại bỏ PlantUML lệch bản).
  2. Chốt hạ Vector Database trong mã nguồn là Supabase PostgreSQL `pgvector` (`v_eval_ai`).
  3. Khớp chính xác model ID Google Gemini: `gemini-3.6-flash`, `gemini-embedding-001`, `gemini-flash-lite-latest`.
  4. Chuẩn hóa luồng Gateway điều phối độc lập tới `AI Engine Core (.NET)` và `AI RAG Service (Python)`.
  5. Thống nhất số lượng Service: 1 Web Client, 1 API Gateway, 3 Core Microservices, 1 Phân hệ AI Subsystem và 1 CSDL Supabase PostgreSQL.
  6. Viết lại System at a Glance đạt chuẩn 148 từ.
  7. Hoàn thiện bảng khai báo công nghệ đủ 5 nhóm chuẩn Report 4 trong tài liệu kiến trúc.
