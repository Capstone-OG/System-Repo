# V-Eval System-Repo — Cập Nhật Tiến Độ

## [23/11/2026] - Công Cụ Bổ Sung Ngân Hàng Câu Hỏi Tự Động & Đồng Bộ Tiến Độ Phiên Làm Việc

- **Script Bổ Sung Ngân Hàng Câu Hỏi Theo Từng Dạng Bài (`Scripts/seed_questions_batch.py`)**:
  - Viết script Python chuẩn không cần thư viện ngoài (chỉ dùng stdlib Python 3.11), tự nạp toàn bộ cây kỹ năng GDPT 2018 từ `V-Eval-Content_Service` (`GET /api/content/curriculum`), kiểm tra số câu hiện có của từng dạng bài và dùng Gemini API (tự động fallback `gemini-3.5-flash-lite` -> `gemini-3.6-flash` -> `gemini-3.8-flash`) sinh bổ sung các câu hỏi còn thiếu (Bloom L1-L4, lọc trùng nội dung, hỗ trợ resume) rồi lưu trực tiếp qua `POST /api/content/questions`.
  - Đã kiểm thử & chèn thành công hơn 2,188 câu hỏi mới vào CSDL PostgreSQL.
- **Đồng Bộ Phiên Bản Các Service Liên Quan**:
  - `V-Eval-Practice_Service`: Cố định `StepOrder` bất biến khi đọc lộ trình & triển khai luồng phê duyệt lộ trình 2 cấp (`DRAFT_PENDING_TEACHER` -> `PENDING_DIRECTOR_APPROVAL` -> `ACTIVE`).
  - `V-Eval-Content_Service`: Xáo trộn ngẫu nhiên & chống trùng lặp theo nội dung (`ContentLatex`) trong gRPC `GetMilestoneQuiz`.
  - `V-Eval-Web_Client`: Nút `Nháp Toán`, sửa hiển thị `MathText.jsx`, tối ưu thanh lọc lộ trình, thiết kế lại thẻ Pha Reflect & Hoàn thành chặng, ẩn dấu nháy caret trên text thường và bổ sung trang `RoadmapApprovalStudioView.jsx` cho Giảng viên & Director.
