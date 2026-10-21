# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [19/10/2026] - Hoàn Tất Triển Khai Toàn Diện 9/9 APIs Core Flow 6 (Dự Báo Điểm SEM & Cảnh Báo Sớm BR-04)

- **Hoàn Tất Triển Khai Phân Hệ Cảnh Báo Sớm Cá Nhân & Can Thiệp Sư Phạm Mentor (Core Flow 6)**:
  - **API 5: `GET /api/practice/early-warnings/my-alerts`**: Học sinh tra cứu danh sách cảnh báo cá nhân theo 3 cấp độ (`YELLOW`, `RED`, `UNREALISTIC_GOAL`), hỗ trợ lọc `unreadOnly` và `alertType`, thống kê badge thông báo thời gian thực.
  - **API 6: `PATCH /api/practice/early-warnings/{alertId}/read`**: Đánh dấu đã đọc thông báo cảnh báo với cơ chế xác thực đa người dùng an toàn (tránh can thiệp chéo giữa các học sinh).
  - **API 7: `GET /api/practice/early-warnings/dashboard`**: Dashboard cảnh báo sớm học sinh dành cho Mentor, hỗ trợ lọc theo lớp `classId`, làm giàu dữ liệu tự động với điểm dự báo `PredictedScore`, mục tiêu `TargetScore` và thâm hụt điểm `DeficitScore`.
  - **API 8: `POST /api/practice/early-warnings/{alertId}/resolve`**: Mentor ghi chú giải quyết can thiệp sư phạm (`resolution_notes`), lưu vết `handled_by` và đóng ca cảnh báo `is_resolved = true`.
  - **API 9: `POST /api/practice/early-warnings/{alertId}/schedule-counseling`**: Mentor lên lịch hẹn tư vấn 3 bên (Phụ huynh - Học sinh - Mentor) đối với trường hợp cảnh báo mục tiêu không tưởng `UNREALISTIC_GOAL`, đề xuất mức điểm mục tiêu khả thi theo phân phối chuẩn ĐGNL và cập nhật giải quyết ca cảnh báo.
- **Tổng Kết Core Flow 6 (100% Hoàn Thành)**:
  - Cả 9 API thuộc Core Flow 6 đã hoàn tất 100%: Dải điểm SEM (API 1), Đề ôn tập biến thể vi mô (API 2), Nộp bài xóa nợ điểm thâm hụt (API 3), Thuật toán tối ưu Toa thuốc Knapsack ROI (API 4), Thông báo cá nhân (API 5), Đánh dấu đã đọc (API 6), Dashboard Mentor (API 7), Can thiệp sư phạm (API 8), và Lịch hẹn tư vấn 3 bên (API 9).
  - Solution `V-Eval-Practice_Service.sln` biên dịch sạch 100% (**0 Warning, 0 Error**).
  - Đã kiểm thử live đầy đủ các ca thành công (200 OK) và ca kiểm soát lỗi RFC 7807 (400, 401, 403, 404) trực tiếp lẫn thông qua API Gateway YARP.
