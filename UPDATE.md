# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [13/10/2026] - Thiết Kế GraphRAG Tri Thức Liên Môn & Triển Khai Hoàn Tất Bộ APIs 16 - 19 Content Service

- **Thiết Kế Kiến Trúc GraphRAG Tri Thức Liên Môn (Cross-Disciplinary Knowledge Graph)**:
  - Hoàn thiện tài liệu kiến trúc chuyên sâu `docs/ai_architecture/thiet_ke_graph_rag_tri_thuc_lien_mon.md` giải quyết bản chất liên môn kỳ thi ĐGNL ĐHQG-HCM (V-ACT).
  - Phân tích ưu thế vượt trội của GraphRAG so với Vector RAG: Vượt qua bẫy cô lập từ vựng đơn môn, liên kết các cạnh `[APPLIES_MODEL]` giữa Toán, Lý, Hóa, Sinh, Logic với cùng một mô hình toán học lõi (ví dụ Hệ PT 2 ẩn).
  - Thiết kế lược đồ CSDL PostgreSQL `v_eval_ai.cross_disciplinary_models` & `v_eval_ai.skill_model_cross_links`, thuật toán Graph Traversal và Prompt Socratic AI chẩn đoán lỗi gốc rễ.
- **Hoàn Tất Triển Khai Bộ APIs 16 - 19 Quản Trị Ngân Hàng Câu Hỏi & Sinh Đề Quiz (Content Service)**:
  - **API 16: `POST /api/content/questions`**: Thêm mới câu hỏi gốc với công thức LaTeX stem, 4 đáp án A-D, phương án đúng `CorrectOption`, độ khó Bloom 1-6 và lời giải chi tiết `Explanation`.
  - **API 17: `PUT /api/content/questions/{id}`**: Hiệu đính nội dung, đáp án, độ khó Bloom và giải thích chi tiết.
  - **API 18: `DELETE /api/content/questions/{id}`**: Xóa câu hỏi khỏi ngân hàng đề và giải phóng liên kết đề thi `exam_questions`.
  - **APIs Tra Cứu**: `GET /api/content/questions/{id}` và `GET /api/content/questions/by-skill/{skillId}` (lọc theo Bloom).
  - **API 19: `POST /api/content/exams/quiz`**: Đóng gói đề Quiz củng cố thích ứng 5-10 câu hỏi chuẩn Bloom từ `SkillIds` / `CommonWeakSkillIds` kết nối trực tiếp với bàn học của Practice Service.
- **Trạng Thái Kiểm Thử Toàn Hệ Thống**:
  - `V-Eval-Content_Service.sln` biên dịch sạch 100% (**0 Warning, 0 Error**).
  - Toàn bộ thay đổi nằm trên nhánh `ThinhTT/feature-question-bank-adaptive-quiz`.
