# NHẬT KÝ CẬP NHẬT HỆ THỐNG (SYSTEM-REPO UPDATE LOG)

## [13/11/2026] - Tối Giản Màn Hình Tổng Quan Học Tập, Khắc Phục Lỗi Lịch Sử Làm Bài & Kích Hoạt Học Phí PayOS

- **Tối giản hóa màn hình Tổng quan học tập & Bỏ khối chặng học giả lập ([`App.jsx`](./All%20Services/V-Eval-Web_Client/src/App.jsx))**:
  - Gỡ bỏ hoàn toàn khối `MilestoneCard` và `LiveQnACard` tại trang tổng quan (chặng học giả lập, phòng phụ đạo mock), tập trung hoàn toàn vào các nội dung thiết thực cho học sinh.
  - Tinh chỉnh `HeroBanner.jsx` và `MetricsGrid.jsx`: thay thế các từ ngữ kỹ thuật nội bộ ("ZPD", "DAG", "Flow 5", "IRT 2PL") bằng thông tin trực quan: Điểm năng lực ước tính, Chuỗi chuyên cần, Tiến độ lộ trình, và Trọng tâm cần cải thiện.
- **Khắc phục lỗi Crash 500 nạp lịch sử làm bài thi chẩn đoán (Practice Service & Web Client)**:
  - **Backend Practice Service ([`ContentGrpcClient.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Infrastructure/GrpcClients/ContentGrpcClient.cs), [`GetDiagnosticSubmissionById.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Application/Features/DiagnosticSubmissions/Queries/GetDiagnosticSubmissionById/GetDiagnosticSubmissionById.cs))**:
    - Bắt ngoại lệ `RpcException(StatusCode.NotFound)` khi truy vấn đáp án cho mã đề thi cũ/không còn lưu câu hỏi trong Content Service, trả về fallback rỗng an toàn thay vì để văng lỗi `500 Internal Server Error`.
    - Mở rộng `DiagnosticSubmissionSummaryDto` bổ sung `Theta0` và `PlacementClass` từ CSDL, giúp lấy ngay chỉ số năng lực IRT mà không cần gọi API chi tiết lặp lại.
  - **Frontend Web Client ([`DiagnosticAssessmentPage.jsx`](./All%20Services/V-Eval-Web_Client/src/components/diagnostic/DiagnosticAssessmentPage.jsx))**:
    - Bọc từng lời gọi chi tiết bài thi trong `Promise.all` với `try/catch` độc lập, tự động fallback lấy `theta0` từ summary DTO nếu bài cũ gặp lỗi, đảm bảo 100% hiển thị lịch sử thông suốt.
- **Phân tách 2 chế độ Lộ trình học tập ([`StudentCurriculumView.jsx`](./All%20Services/V-Eval-Web_Client/src/components/curriculum/StudentCurriculumView.jsx), [`curriculumAccess.js`](./All%20Services/V-Eval-Web_Client/src/components/curriculum/curriculumAccess.js))**:
  - Hỗ trợ chuyển đổi linh hoạt giữa *🏫 Lớp Học Chung* và *🎯 Lộ Trình Cá Nhân Riêng* 3 chặng thích ứng.
- **Thiết lập ràng buộc học phí & Chế độ xem tổng quát ([`TuitionRequiredModal.jsx`](./All%20Services/V-Eval-Web_Client/src/components/modals/TuitionRequiredModal.jsx))**:
  - Học sinh sau khi thi chỉ được xem cấu trúc tổng quát của lộ trình.
  - Chặn mở bài học chi tiết, video bài giảng, phương pháp giải và luyện tập củng cố khi chưa hoàn tất học phí (`!isPaid`), tự động mở modal điều hướng đến trang thanh toán VietQR PayOS.
- **Kiểm thử & Biên dịch**:
  - Toàn bộ 14/14 tests xUnit Practice Service pass 100%; build .NET sạch 0 Warning 0 Error.
  - Toàn bộ 31/31 unit tests Web Client pass 100%; `npm run lint` đạt 0 lỗi, `npm run build` thành công trong 1.17s.
