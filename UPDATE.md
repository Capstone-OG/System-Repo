# NHẬT KÝ CẬP NHẬT HỆ THỐNG (SYSTEM-REPO UPDATE LOG)

## [13/11/2026] - Tối Giản Bố Cục Trang Tổng Quan Hài Hòa, Nâng Cấp Ảnh Học Sinh & Khắc Phục Lỗi Lịch Sử Làm Bài

- **Tái cấu trúc bố cục trang Tổng quan theo thứ tự thị giác chuẩn mực ([`App.jsx`](./All%20Services/V-Eval-Web_Client/src/App.jsx))**:
  - Đưa `HeroBanner` lên vị trí đầu trang làm điểm nhấn chào đón học viên và truyền cảm hứng chủ đạo.
  - Đặt `MetricsGrid` 4 chỉ số KPI ngay phía dưới banner, giúp học sinh nắm bắt toàn diện dữ liệu học tập (Điểm dự báo 1200, Streak chuyên cần, Tiến độ lộ trình, Trọng tâm cần ôn tập).
  - Bố trí khối hành động kép (`DiagnosticOnboardingCard` 70% + `StudentParentLinkCard` 30%) ở phía chân trang, tạo điểm kết cân đối, hài hòa trước footer, loại bỏ tình trạng trang bị cụt đột ngột.
- **Nâng cấp thẻ ảnh học sinh & Bỏ khối chặng học giả lập ([`HeroBanner.jsx`](./All%20Services/V-Eval-Web_Client/src/components/dashboard/HeroBanner.jsx), [`App.jsx`](./All%20Services/V-Eval-Web_Client/src/App.jsx))**:
  - Gỡ bỏ hoàn toàn khối `MilestoneCard` và `LiveQnACard` giả lập không có thực.
  - Chuyển đổi ảnh học sinh sang chân dung học sinh THPT Việt Nam thực tế (`vietnamese_student_real.jpg`) bọc trong khung thẻ kính mờ bán trong suốt sang trọng.
  - Thay thế toàn bộ thuật ngữ kỹ thuật khó hiểu ("ZPD", "DAG", "Flow 5", "IRT 2PL") bằng thông điệp sư phạm trực quan, thân thiện.
- **Khắc phục lỗi Crash 500 nạp lịch sử làm bài thi chẩn đoán (Practice Service & Web Client)**:
  - **Backend Practice Service ([`ContentGrpcClient.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Infrastructure/GrpcClients/ContentGrpcClient.cs), [`GetDiagnosticSubmissionById.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Application/Features/DiagnosticSubmissions/Queries/GetDiagnosticSubmissionById/GetDiagnosticSubmissionById.cs))**:
    - Bắt ngoại lệ `RpcException(StatusCode.NotFound)` khi truy vấn đáp án cho mã đề thi cũ/không còn lưu câu hỏi trong Content Service, trả về fallback rỗng an toàn thay vì để văng lỗi `500 Internal Server Error`.
    - Mở rộng `DiagnosticSubmissionSummaryDto` bổ sung `Theta0` và `PlacementClass` từ CSDL, giúp lấy ngay chỉ số năng lực IRT mà không cần gọi API chi tiết lặp lại.
  - **Frontend Web Client ([`DiagnosticAssessmentPage.jsx`](./All%20Services/V-Eval-Web_Client/src/components/diagnostic/DiagnosticAssessmentPage.jsx))**:
    - Bọc từng lời gọi chi tiết bài thi trong `Promise.all` với `try/catch` độc lập, tự động fallback lấy `theta0` từ summary DTO nếu bài cũ gặp lỗi, đảm bảo 100% hiển thị lịch sử thông suốt.
- **Phân tách 2 chế độ Lộ trình học tập & Ràng buộc học phí ([`StudentCurriculumView.jsx`](./All%20Services/V-Eval-Web_Client/src/components/curriculum/StudentCurriculumView.jsx), [`TuitionRequiredModal.jsx`](./All%20Services/V-Eval-Web_Client/src/components/modals/TuitionRequiredModal.jsx))**:
  - Hỗ trợ chuyển đổi linh hoạt giữa *🏫 Lớp Học Chung* và *🎯 Lộ Trình Cá Nhân Riêng* 3 chặng thích ứng.
  - Học sinh sau khi thi chỉ được xem cấu trúc tổng quát của lộ trình; chặn mở bài học chi tiết và luyện tập củng cố khi chưa hoàn tất học phí qua PayOS VietQR.
- **Kiểm thử & Biên dịch**:
  - Toàn bộ 14/14 tests xUnit Practice Service pass 100%; build .NET sạch 0 Warning 0 Error.
  - Toàn bộ 31/31 unit tests Web Client pass 100%; `npm run lint` đạt 0 lỗi, `npm run build` thành công trong 1.05s.
