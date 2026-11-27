# CẬP NHẬT TIẾN ĐỘ HỆ THỐNG - V-EVAL CAPSTONE SYSTEM REPO

## [27/11/2026] - Nâng Cấp Giao Diện Phòng Thi, Kết Quả Đánh Giá, Khung Chat Gia Sư AI & Phát Đề Đầu Vào Ngẫu Nhiên

- **V-Eval-Web_Client**: Tinh gọn giao diện phòng thi (`ExamRoom.jsx`, `DiagnosticAssessmentPage.jsx`), thêm dropdown `Bảng số liệu` tự động cho Markdown table, tăng cường `MathText.jsx`; sửa lỗi tràn lưới & tương thích MUI v9 tại `DiagnosticSkillOverviewCard.jsx`; chuẩn hóa khung chat Gia sư AI (`AISocraticTutorModal.jsx`) cố định `34vw` + lịch sử trượt mượt 2 chiều `16vw` (tổng `50vw`). `node --test tests/*.test.js` pass 100%, `npm run build` đạt 0 lỗi (`1.94s`).
- **V-Eval-Content_Service**: Cập nhật `GetDiagnosticTestQuery.cs` lọc đề `DIAGNOSTIC` đã xuất bản (`IsPublished`) và phát ngẫu nhiên trong tập đề chưa làm.
- **Supabase `v_eval_content`**: Chuẩn hóa phân loại 91 kỹ năng Ngôn ngữ, dựng lại 3 đề đầu vào `DIAGNOSTIC` (90 câu hỏi chuẩn) và chuyển đổi 19/19 câu hỏi bảng số liệu sang Markdown Table.
