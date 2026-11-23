# UPDATE - SYSTEM REPO

## [23/11/2026]
- **V-Eval-Web_Client**:
  - **Tối Ưu Hóa Giao Diện & Đồng Bộ 100% Dữ Liệu Học Sinh Thực Tế Cho Buổi Học Offline (TCH-02) (`TeacherScheduleView.jsx`, `OfflineSessionPreparationModal.jsx`, `offlineSessionStore.js`, `tests/offlineSessionStore.test.js`)**:
    + *Tái thiết kế Modal Chuẩn bị Buổi học*: Loại bỏ toàn bộ các khối chữ giải thích quy tắc mang tính giáo điều và thuật ngữ kỹ thuật nội bộ (như `Mô hình lớp học đảo ngược`, `Giảng viên tự quyết 100% không cần Director duyệt`, `ZPD`, `Vi mô`, `Heatmap`, `WS-ZPD-ENG-01`).
    + Giao diện phân tách 2 tab gọn gàng, tự nhiên: `1. Chữa bài chung cả lớp` (gợi ý kỹ năng làm sai nhiều + câu hỏi mẫu) và `2. Nhóm học tập tại bàn` (Bàn 1, Bàn 2 kèm học sinh và phiếu bài tập).
    + *Đồng bộ trực tiếp 100% danh sách học sinh thật từ CSDL*: Kết nối API `practiceService.getClassHeatmap(session.classId)` và `practiceService.getSessionAttendances(session.sessionId)` để tải danh sách học sinh thực tế (`Trần Thái Thịnh`, `Trần Ngọc Mai`, `Mai Thành Nhân`, `Lê Hoàng Long`, `Nguyễn Hoàng An`, `Phạm Tấn Lộc`), tự động chia bàn học cân đối; tự động phát hiện và thanh lọc cache cũ lỗi thời.
    + *Tinh giản thẻ ca học Thời khóa biểu*: Rút gọn thành 2 mục trực quan `1. Chữa bài chung` và `2. Nhóm tại bàn`; nút hành động đổi thành `Chuẩn bị buổi học` thân thiện với người dùng.
  - **Chuẩn Hóa Phân Quyền Maker - Checker Cho Role Teacher (`TextbookIngestView.jsx`, `TextbookStudioView.jsx`, `CurriculumStudioEditor.jsx`, `ExamWorkspaceHeader.jsx`, `App.jsx`)**:
    + *Nạp tài liệu SGK*: Áp dụng cơ chế **Chỉ xem (Read-only)** cho Giảng viên, ẩn form upload PDF và bóc tách AI cấp hệ thống.
    + *Studio Biên soạn SGK & Đề thi*: Hiển thị banner `Chế độ Soạn thảo (Maker) — Gửi duyệt lên Giám đốc Học thuật`, chuyển đổi nút lưu thành `Lưu bản nháp` và `Gửi duyệt (PENDING_REVIEW)`, ẩn quyền tự xuất bản và xóa học liệu cấp hệ thống.
  - **Kiểm Thử & Biên Dịch**: `npm run build` hoàn thành 100% trong 1.15s (`3083 modules`, `0 Error`); toàn bộ **30/30 unit tests passed 100%** (`tests/*.test.js` 22/22, `examStateBridge.test.js` 6/6, `offlineSessionStore.test.js` 2/2).
