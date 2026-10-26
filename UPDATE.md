# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [26/10/2026] - Khắc Phục Toàn Diện 7 Điểm Lệch Kiến Trúc Review 2, Chuẩn Hóa 100% Mermaid & Bổ Sung Trọn Bộ 4 Sơ Đồ Bắt Buộc

- **Khắc Phục Toàn Diện 7 Điểm Lệch Kiến Trúc (Theo Kết Quả Audit Review 2)**:
  1. **Thống nhất duy nhất 1 chuẩn Mermaid**: Xóa bỏ file `architecture.puml` để tránh lệch hai bản, đảm bảo tất cả sơ đồ kiến trúc đều hiển thị trực quan tự động trên GitHub và MD Editor Plus.
  2. **Chốt hạ Vector Database**: Xác định chính xác 100% trong code là **`Supabase PostgreSQL (pgvector)`** (extension `vector`, schema `v_eval_ai`), loại bỏ hoàn toàn tên Qdrant khỏi sơ đồ và tài liệu.
  3. **Chốt chính xác model Google Gemini**: Khớp cấu hình code với model ID cụ thể: `gemini-3.6-flash` (RAG LLM), `gemini-embedding-001` (3072-dim Embeddings) và `gemini-flash-lite-latest` (C# Vision OCR).
  4. **Đối chiếu khớp 1:1 hộp và luồng dữ liệu**:
     - Định danh `Mobile Client` dạng `[Kế hoạch pha 2 / Planned]` kết nối nét đứt, tập trung nghiệm thu Web Client (React 19 Responsive SPA).
     - Bổ sung `OpenAI API (GPT-4o-mini)` làm Secondary Fallback LLM khi Gemini chạm rate-limit.
     - Điều chỉnh luồng Gateway điều phối độc lập tới cả `AI Engine Core (.NET)` và `AI RAG Service (Python)`.
     - Loại bỏ mũi tên gọi ảo `PracticeSvc -> AiCoreNet`.
  5. **Thống nhất số lượng Service**: Xác định rõ cấu trúc hệ thống gồm: 1 Web Client, 1 API Gateway, 3 Core Microservices, 1 Phân hệ AI Subsystem và 1 Hệ lưu trữ Supabase PostgreSQL (Multi-Schema & pgvector).
  6. **Viết lại "System at a Glance"**: Đạt chuẩn **148 từ** (≤150 từ), tập trung đúng 3 trọng tâm: Vấn đề giải quyết, Đối tượng thụ hưởng và Giải pháp công nghệ cốt lõi.
  7. **Rút gọn nhãn sơ đồ**: Loại bỏ toàn bộ port và endpoint chi tiết khỏi các hộp sơ đồ Mermaid để tránh nặng hình, chuyển toàn bộ thông số kỹ thuật sang bảng ma trận trong Report 4.

- **Bổ Sung Trọn Bộ 4 Sơ Đồ Mermaid Bắt Buộc Tại [`docs/diagrams/`](./docs/diagrams/)**:
  - [Sơ đồ 1: Kiến trúc tổng quan hệ thống](./docs/diagrams/architecture.mmd) (`flowchart TB`).
  - [Sơ đồ 2: Sơ đồ thực thể logic - Logical ERD](./docs/diagrams/02_logical_erd.mmd) (`erDiagram`).
  - [Sơ đồ 3: Máy trạng thái phiên thi thích ứng](./docs/diagrams/03_state_machine.mmd) (`stateDiagram-v2`).
  - [Sơ đồ 4: Sơ đồ hoạt động phân làn Swimlane](./docs/diagrams/04_activity_swimlane.mmd) (`flowchart TD`).

- **Hoàn Thiện Bảng Khai Báo Công Nghệ Đủ 5 Nhóm Trong [`docs/V-Eval_Architecture_Plan.md`](./docs/V-Eval_Architecture_Plan.md)**:
  - Bổ sung nhóm Dịch vụ bên thứ ba & Dữ liệu gửi đi (cam kết bảo vệ PII học sinh).
  - Bổ sung môi trường Staging (Ubuntu VPS Demo 1.1), quy trình CI/CD và chiến lược Rollback container tag dưới 30 giây.
  - Bổ sung quy tắc phân nhánh Gitflow và công cụ AI hỗ trợ phát triển.
