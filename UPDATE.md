# Nhật Ký Cập Nhật (Update Log) - System Repo

## [03/10/2026] - Bổ Sung Tài Liệu Chuyên Sâu: Tổng Hợp Thuật Toán Toàn Hệ Thống (Flow 1 đến Flow 4)

- **Tài Liệu Kiến Trúc Toán Học & AI**:
  - Tạo mới tài liệu chuyên sâu [`docs/ai_architecture/tong_hop_thuat_toan_va_cong_thuc_toan.md`](./docs/ai_architecture/tong_hop_thuat_toan_va_cong_thuc_toan.md):
    1. Bản đồ tổng thể toàn bộ các thuật toán và mô hình từ Core Flow 1 đến Core Flow 4.
    2. Chi tiết công thức toán học và lý do bắt buộc phải sử dụng của từng giải thuật: IRT 2PL, MAP (Brent), Anti-Guessing Penalty, Sigmoid Mapping, Phân lớp năng lực, Cấu trúc DAG, Thuật toán Tarjan, Cắt tỉa Heuristic, Sắp xếp Tô-pô (Topological Sort), Mô hình BKT (Bayesian Knowledge Tracing), Semantic Embedding 3072 chiều, Cosine Similarity trên pgvector, Phương pháp Socrates và Sinh câu hỏi tương đương.
    3. Bảng tra cứu đối chiếu nhanh toàn diện phục vụ thuyết trình và phản biện Hội đồng.
  - Tạo mới tài liệu [`docs/ai_architecture/phan_biet_sigmoid_irt_va_bkt.md`](./docs/ai_architecture/phan_biet_sigmoid_irt_va_bkt.md):
    1. Phân định rõ ràng bản chất 2 lần xuất hiện của hàm Sigmoid trong Core Flow 1 (Cấp độ câu hỏi trong IRT 2PL vs Cấp độ học sinh quy đổi sang BKT Prior).
    2. Sơ đồ dòng chảy dữ liệu Mermaid chuẩn mực và kịch bản trả lời phản biện giảng viên.
