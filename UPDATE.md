# Nhật Ký Cập Nhật (Update Log) - System Repo

## [09/10/2026] - Triển Khai Giai Đoạn 3 Core Flow 4 GraphRAG AI Tutor: Hybrid GraphRAG Retriever (Vector + Graph Traversal)

- **Hoàn Thành Giai Đoạn 3 (Hybrid GraphRAG Retriever — `V-Eval-Ai_Engine/rag-service`)**:
  - `graph/hybrid_retriever.py`: Truy vết đồ thị 2 bước (Hop 1: Neo vector cosine kết hợp phân vùng kỹ năng & fallback toàn cục; Hop 2: Mở rộng sang câu hỏi mẫu chuẩn và danh mục bẫy nhận thức).
  - Cơ chế **Fail-Closed Grounding**: Chặn đứng nguy cơ ảo giác tri thức bằng cách khóa trả về định lý khi độ tương đồng cosine $< 0.75$ (`LOW_CONFIDENCE`).
  - Cơ chế **Safe Trap Alignment**: Phân biệt câu hỏi mẫu gốc (ánh xạ trực tiếp theo phương án A/B/C/D) và câu hỏi biến thể xáo trộn (trả về danh sách bẫy ứng viên cho LLM đối sánh ngữ nghĩa ở Giai đoạn 4).
  - Tái cấu trúc `seed_archetypes.py` data-driven, sửa liên kết Kỹ năng Toán học và bổ sung dạng bài chuẩn Vật lý Dao động điều hòa `PHYS_SHM_MAX_SPEED_01`.
  - `routers/academic_graph.py`: Bổ sung endpoint nội bộ `POST /api/v1/academic-graph/subgraph/preview` cho phép xem trước toàn bộ Subgraph Context.
  - Kiểm thử: 15/15 unit tests passed, 5 kịch bản live trên Supabase Cloud đạt chuẩn, biên dịch .NET 9 thành công 100% (0 error).
- **Tài Liệu Kỹ Thuật & Cập Nhật Hệ Thống**:
  - Cập nhật chi tiết tiến độ tại `docs/daily.md`, `docs/process.md` (mục 24), và `docs/architecture_acceptance.md`.
