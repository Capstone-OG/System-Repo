# NHẬT KÝ CẬP NHẬT HỆ THỐNG (SYSTEM-REPO UPDATE LOG)

## [07/11/2026] - Triển Khai Toàn Diện Core Flow 6 Lên Web Client: Dự Báo Điểm SEM 95%, Toa Thuốc Bù Điểm Knapsack ROI, Cảnh Báo Sớm 3 Tầng BR-04 & Sổ Tay Lỗi Sai SM-2

- **Web Client (`V-Eval-Web_Client`)**:
  - **Tầng Dịch Vụ Core Flow 6 (`apiClient.js`, `practiceService.js`, `tests/practiceService.flow6.test.js`)**:
    - Bổ sung phương thức `apiClient.patch` và giải mã lỗi chi tiết từ cấu trúc `Result<T>` của ASP.NET Core.
    - Đấu nối trọn bộ **13 API Core Flow 6** qua cổng YARP Gateway (`:5212`), chuẩn hóa song ngữ `snake_case` / `camelCase`, tự động kích hoạt `recalculatePrediction` khi học sinh chưa có bản ghi dự báo (`404`), lưu trữ bền vững trạng thái fallback ngoại tuyến và phát sự kiện đồng bộ `veval:flow6-updated` (`8/8 unit tests pass`).
  - **Dự Báo Điểm SEM 95% & Toa Thuốc Bù Điểm Knapsack ROI (`ScorePredictionPanel.jsx`, `PrescriptionPracticeModal.jsx`, `LearningAnalyticsView.jsx`, `App.jsx`)**:
    - Hiển thị trực quan thang 1200 điểm ĐGNL kèm khoảng tin cậy 95% (`Predicted ± 1.96 × SEM`), bảng cân đối thiếu hụt mục tiêu (`ON_TRACK`, `AT_RISK`, `CRITICAL`), nút tái tính toán dự báo SEM và xếp hạng dạng bài tối ưu `ROI = ΔScore / Số giờ ôn`.
    - Xây dựng modal làm 3-5 câu hỏi biến thể đồng cấu (render công thức KaTeX qua `MathText`), tự động cập nhật xác suất làm chủ BKT `P(L_t)`, gạch nợ điểm thiếu hụt khi đạt độ chính xác `>= 67%` và đối chiếu cùng Gia sư AI Socratic sau khi nộp bài.
  - **Cảnh Báo Sớm 3 Tầng BR-04 & Trung Tâm Can Thiệp Sư Phạm Đa Vai Trò (`NotificationBellPopover.jsx`, `StudentEarlyWarningsCard.jsx`, `EarlyWarningsMentorPanel.jsx`)**:
    - Thay thế chuông thông báo tĩnh trên `Navbar.jsx` bằng trung tâm thông báo thời gian thực theo vai trò (Học sinh/Phụ huynh vs Giáo viên/Quản lý cơ sở).
    - Tích hợp hộp thư cảnh báo cá nhân trên Cổng Học sinh & Phụ huynh, cùng bảng điều phối 6 KPI trên Cổng Giáo viên & Quản lý cơ sở kèm **Modal Ghi nhận Can thiệp (`resolve`)** và **Modal Đặt lịch Tư vấn Mục tiêu 3 bên (`schedule-counseling`)**.
  - **Sổ Tay Lỗi Sai Phản Tư & Lặp Lại Ngắt Quãng SuperMemo-2 (`MistakeNotebookSM2View.jsx`, `Sidebar.jsx`)**:
    - Triển khai phân hệ Sổ tay lỗi sai hỗ trợ lọc & gắn nhãn siêu nhận thức (`MISSING_CONCEPT`, `CARELESS`, `MISREAD_QUESTION`), chạy phiên ôn tập câu hỏi đồng cấu đến hạn hôm nay theo thuật toán SM-2 (`EF >= 1.3`, `3 lần đúng liên tiếp -> Thành thạo`) và kết nối trực tiếp trên thanh điều hướng `Sidebar.jsx`.
  - **Kiểm Thử & Đóng Gói**:
    - `npm test` đạt `8/8 tests pass` (`3 suites`), `vite build` hoàn thành sạch sẽ 100% (`0 errors`).
