# NHẬT KÝ CẬP NHẬT HỆ THỐNG (SYSTEM-REPO UPDATE LOG)

## [13/11/2026] - Hợp Nhất Develop Frontend & Khắc Phục Lỗi Lịch Sử Làm Bài Cùng Luyện Tập Thích Ứng ZPD

- **Đồng bộ nhánh `develop`**:
  - Hợp nhất thành công 3 commit mới nhất từ `origin/develop` (`852e484`, `c40cee0`, `29d2794`) tích hợp không gian làm việc bài học học sinh (`StudentCurriculumView.jsx`), cổng giáo viên (`TeacherPortalView.jsx`), tách trang lịch sử thi cử (`StudentHistoryPage.jsx`) và thanh điều hướng rút gọn (`AccountNavbar.jsx`).
- **Khắc phục lỗi Lịch sử làm bài & Bắt đầu bài thi chẩn đoán ([`practiceService.js`](./All%20Services/V-Eval-Web_Client/src/services/practiceService.js))**:
  - Sửa đường dẫn gọi API trong `getDiagnosticHistory` và `getDiagnosticResult` từ `/api/v1/practice/...` thành `/api/practice/...` (bỏ tiền tố thừa `v1`), khớp chính xác với `DiagnosticSubmissionsController` của Practice Service, loại bỏ triệt để lỗi HTTP 404 *"Không tìm thấy dữ liệu hoặc đường dẫn yêu cầu"*.
- **Khắc phục lỗi nạp câu hỏi Luyện tập thích ứng ZPD ([`AdaptiveQuizModal.jsx`](./All%20Services/V-Eval-Web_Client/src/components/modals/AdaptiveQuizModal.jsx))**:
  - Mở rộng cơ chế bóc tách câu hỏi từ đề thi của Content Service: gom câu hỏi từ cả `single_questions` lẫn câu hỏi phân bổ trong các bài đọc `passages.flatMap(p => p.questions || [])`, loại bỏ lỗi mảng câu hỏi rỗng và cảnh báo *"Chưa có câu hỏi ZPD từ Backend Content Service"*.
- **Kiểm thử & Biên dịch**:
  - Chạy `node --test tests/*.test.js src/**/*.test.js`: toàn bộ 28/28 tests vượt qua 100%, `npm run lint` đạt 0 errors, `npm run build` thành công.
