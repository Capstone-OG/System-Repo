# Nhật Ký Cập Nhật (Update Log) - System Repo

## [08/10/2026] - Triển Khai Giai Đoạn 1 Core Flow 4 GraphRAG AI Tutor: CSDL Knowledge Graph & Archetype Seeder

- **Hoàn Thành Triển Khai Giai Đoạn 1 (Database DDL & Archetype Knowledge Graph Seeding)**:
  - Khởi tạo thành công 5 bảng trong schema `v_eval_ai` trên Supabase PostgreSQL (`archetype_patterns`, `pattern_exemplars`, `pattern_traps`, `novel_pattern_proposals`, `ai_tutor_interaction_logs`).
  - Viết và chạy script seeding dữ liệu thực tế `seed_archetypes.py`: tích hợp Google Gemini Embedding (`models/gemini-embedding-001`) sinh vector 3072 chiều, nạp dạng bài chuẩn Toán học `MATH_ASYMPTOTE_PARAM_01`, 1 câu hỏi mẫu chuẩn và 2 bẫy tư duy thường gặp.
  - Cập nhật toàn bộ tài liệu kiểm thử và nghiệm thu kiến trúc tại `docs/daily.md`, `docs/process.md`, và `docs/architecture_acceptance.md`.
- **Tài Liệu Kỹ Thuật & Triển Khai Thực Chiến**:
  - Tạo mới tài liệu hướng dẫn kỹ thuật chi tiết [`docs/ai_architecture/quy_trinh_trien_khai_chi_tiet_flow_4_graph_rag.md`](./docs/ai_architecture/quy_trinh_trien_khai_chi_tiet_flow_4_graph_rag.md):
    1. **Tái sử dụng 100% Pipeline Vision OCR & LaTeX sẵn có**: Tích hợp trực tiếp với dịch vụ `GeminiExamParserService.cs` (.NET 9) và kiến trúc `docs/ai_data_ingestion.md` (PDFtoImage SkiaSharp 150 DPI render trong 1.5s, Gemini Vision Multimodal `temperature = 0.0`, trích xuất 100% LaTeX chuẩn `$ ... $`, Zero-Spoiler Rule chống lộ đáp án).
    2. **Cấu trúc thư mục mã nguồn**: Thiết kế phân tách module giữa `V-Eval-Ai_Engine` (.NET 9 Vision Ingestion), `rag-service` (Python/FastAPI GraphRAG) và `Practice_Service` (.NET 9 Socratic Proxy).
    3. **Giai đoạn 1 (Database DDL)**: Thiết kế toàn bộ schema bảng PostgreSQL + pgvector (`archetype_patterns`, `pattern_exemplars`, `pattern_traps`, `novel_pattern_proposals`, `ai_tutor_interaction_logs`).
    4. **Giai đoạn 2 (Novelty Detector)**: Kết nối DTO câu hỏi LaTeX từ `GeminiExamParserService` sang module `NoveltyDetector` (ngưỡng Cosine $< 0.75$) để tự động gắn cờ dạng bài mới cho Academic thẩm định.
    5. **Giai đoạn 3 (Hybrid GraphRAG Retriever)**: Code Python truy vết 2 bước trên đồ thị kết hợp pgvector để trích xuất Subgraph Context (Định lý cốt lõi, Lời giải mẫu, Bẫy gắn liền với phương án sai).
    6. **Giai đoạn 4 (Socratic Engine & LLM-as-a-Judge)**: Code điều phối Gemini 2.0 Flash qua SSE stream và bộ thẩm định độc lập kiểm tra vi phạm giải thay hoặc ảo giác (tự động Fallback về CSDL).
    7. **Giai đoạn 5 (Tích hợp Backend .NET 9)**: Controller `AiTutorController.cs` quản lý JWT, Rate Limiting (10 req/phút) và proxy stream `text/event-stream`.
    8. **Giai đoạn 6 (Human-in-the-Loop Feedback)**: Quy trình học sinh báo cáo sai sót và Dashboard để Mentor thẩm định, ghi đè lời giải vào Knowledge Graph.
    9. **Bảng tiêu chí nghiệm thu (Acceptance Criteria)** cho 7 kịch bản kiểm thử toàn diện.
  - Cập nhật tài liệu kiến trúc [`docs/ai_architecture/core_flow_4_ai_tutor_graph_rag.md`](./docs/ai_architecture/core_flow_4_ai_tutor_graph_rag.md) bổ sung đầy đủ các bước vận hành tuần tự (Luồng A & Luồng B) và kịch bản văn nói thuyết trình bảo vệ đồ án.
