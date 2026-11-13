# NHẬT KÝ CẬP NHẬT HỆ THỐNG (SYSTEM-REPO UPDATE LOG)

## [13/11/2026] - Khắc Phục Lỗi Lịch Sử Làm Bài (Practice Service & Web Client), Triển Khai Ràng Buộc Xem Lộ Trình Sau Thi & Học Phí PayOS

- **Khắc phục lỗi Crash 500 nạp lịch sử làm bài thi chẩn đoán (Practice Service & Web Client)**:
  - **Backend Practice Service ([`ContentGrpcClient.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Infrastructure/GrpcClients/ContentGrpcClient.cs), [`GetDiagnosticSubmissionById.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Application/Features/DiagnosticSubmissions/Queries/GetDiagnosticSubmissionById/GetDiagnosticSubmissionById.cs))**:
    - Bắt ngoại lệ `RpcException(StatusCode.NotFound)` khi truy vấn đáp án cho mã đề thi cũ/không còn lưu câu hỏi trong Content Service, trả về fallback rỗng an toàn thay vì để văng lỗi `500 Internal Server Error`.
    - Mở rộng `DiagnosticSubmissionSummaryDto` bổ sung `Theta0` và `PlacementClass` từ CSDL, giúp lấy ngay chỉ số năng lực IRT mà không cần gọi API chi tiết lặp lại.
  - **Frontend Web Client ([`DiagnosticAssessmentPage.jsx`](./All%20Services/V-Eval-Web_Client/src/components/diagnostic/DiagnosticAssessmentPage.jsx))**:
    - Bọc từng lời gọi chi tiết bài thi trong `Promise.all` với `try/catch` độc lập, tự động fallback lấy `theta0` từ summary DTO nếu bài cũ gặp lỗi, đảm bảo 100% hiển thị lịch sử thông suốt.
- **Phân tách 2 chế độ Lộ trình học tập ([`StudentCurriculumView.jsx`](./All%20Services/V-Eval-Web_Client/src/components/curriculum/StudentCurriculumView.jsx), [`curriculumAccess.js`](./All%20Services/V-Eval-Web_Client/src/components/curriculum/curriculumAccess.js))**:
  - Hỗ trợ chuyển đổi linh hoạt giữa:
    - *🏫 Lớp Học Chung*: Toàn bộ cây tri thức chuẩn hóa 5 miền ĐGNL V-ACT theo cấu trúc Chương -> Bài học -> Dạng bài.
    - *🎯 Lộ Trình Cá Nhân Riêng*: Tự động phân cụm 3 chặng học thích ứng dựa trên kết quả thi chẩn đoán (Chặng 1: Bù lỗ hổng ZPD `+75 - +110đ`, Chặng 2: Nâng cao vận dụng `+50 - +70đ`, Chặng 3: Thực chiến 900+ `+35 - +50đ`).
- **Thiết lập ràng buộc học phí & Chế độ xem tổng quát ([`TuitionRequiredModal.jsx`](./All%20Services/V-Eval-Web_Client/src/components/modals/TuitionRequiredModal.jsx))**:
  - Học sinh sau khi thi chỉ được xem cấu trúc tổng quát của lộ trình.
  - Chặn mở bài học chi tiết, video bài giảng, phương pháp giải và luyện tập củng cố khi chưa hoàn tất học phí (`!isPaid`), tự động mở modal điều hướng đến trang thanh toán VietQR PayOS.
- **Đồng bộ hóa luồng sau thi & Học phí ([`DiagnosticAssessmentPage.jsx`](./All%20Services/V-Eval-Web_Client/src/components/diagnostic/DiagnosticAssessmentPage.jsx), [`TuitionPaymentView.jsx`](./All%20Services/V-Eval-Web_Client/src/components/payment/TuitionPaymentView.jsx), [`App.jsx`](./All%20Services/V-Eval-Web_Client/src/App.jsx))**:
  - Bổ sung banner thông báo và nút chuyển tiếp trực tiếp sang Lộ trình và Học phí ngay tại màn hình kết quả sau thi.
  - Tích hợp lưu vết trạng thái đóng tiền (`veval_tuition_paid_${studentId}`) và nút kích hoạt nhanh phục vụ kiểm thử nghiệm thu.
- **Kiểm thử & Biên dịch**:
  - Toàn bộ 14/14 tests xUnit Practice Service pass 100%; build .NET sạch 0 Warning 0 Error.
  - Toàn bộ 31/31 unit tests Web Client pass 100%; `npm run lint` đạt 0 lỗi, `npm run build` thành công.
