# UPDATE - V-EVAL SYSTEM REPO

## [25/11/2026] - Hoàn Thiện Studio Soạn Thảo & MathLab 2D/3D, Tối Ưu Supabase Egress (>95%) & Nhúng Vector 768 Chiều pgvector HNSW

- **Hoàn Thiện Studio Soạn Thảo & Phòng Dựng Hình 2D/3D (`V-Eval-Web_Client`)**:
  - Thiết kế lại toàn diện `InteractiveMathWorkbenchModal` (render 100% KaTeX, MUI `Select`, tùy biến kích thước/góc xoay/tọa độ, sửa trực tiếp nhãn điểm phụ, công cụ 1-click hạ đường vuông góc 3D kèm ký hiệu góc vuông).
  - Tối ưu `CurriculumStudioEditor`, `WordStyleFormulaCanvas`, `VisualMathField`, `HierarchicalMathPalette` (Bàn phím soạn thảo chèn tại con trỏ, trạng thái active cho `B/I/U/S`, phân trang số gọn có nhập trang & nút cuộn nhanh, dọn gọn bảng STEM & Bảng biến thiên).
- **Khắc Phục Triệt Để Supabase Egress (`V-Eval-Content_Service`, `V-Eval-Practice_Service`, `V-Eval-Web_Client`)**:
  - Đã deploy lên `main` và đồng bộ `develop` (Cache gRPC + `SplitQuery` + DTO projections + FE deduplication).
- **Nhúng Vector 768 Chiều & Backfill pgvector HNSW (`V-Eval-Ai_Engine`)**:
  - Triển khai `GeminiEmbeddingService` (`gemini-embedding-001`, 768 chiều L2-normalized) + `PgVectorDbService` (HNSW + mở rộng ngữ cảnh lân cận) và backfill hoàn tất **708/708** chunks SGK trên Supabase (`missing = 0`).
