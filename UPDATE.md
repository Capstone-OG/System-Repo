# CẬP NHẬT TIẾN ĐỘ HỆ THỐNG - V-EVAL CAPSTONE SYSTEM REPO

## [28/11/2026] - Hoàn Thiện Kéo-Thả Câu Hỏi Vào Gia Sư AI Trên Toàn Bộ Màn Hình Học Sinh

- **V-Eval-Web_Client**: Tạo helper dùng chung `src/utils/aiQuestionDrag.js`, bổ sung kéo-thả câu hỏi sang Gia sư AI trên toàn bộ màn hình học tập, luyện tập, sổ tay SM-2 và xem lại bài làm của học sinh (giữ khóa phòng thi đang làm bài), hỗ trợ thả trực tiếp vào nút nổi **Hỏi Gia sư AI** và sửa lỗi nhấp nháy `onDragLeave`. `node --test tests/*.test.js` pass 100%, `npm run build` đạt 0 lỗi (`3.19s`).
