# NHẬT KÝ CẬP NHẬT HỆ THỐNG (SYSTEM-REPO UPDATE LOG)

## [07/11/2026] - Hợp Nhất Nhánh `develop` Toàn Hệ Thống & Hoàn Tất Chuẩn Hóa 40 Sơ Đồ Chi Tiết (Figure 18 - Figure 57) Phần IV SDD

- **Hợp Nhất Toàn Diện Nhánh `develop` Với Phân Hệ Curriculum Studio, PayOS & Xác Thực OTP**:
  - Hợp nhất thành công các tính năng từ nhánh `ThinhTT/feature-curriculum-studio-formula-editor`:
    - **Curriculum Studio & Formula Editor**: Soạn thảo công thức dạng Word (JSXGraph 2D/3D, Bảng Biến Thiên Vector `2N-1`, AI sinh câu hỏi).
    - **Thanh toán học phí trực tuyến PayOS VietQR**: Tích hợp `PaymentsController.cs`, `PayOsService.cs`, `TuitionPaymentView.jsx`, `PayOsCheckoutModal.jsx`, webhook kích hoạt lộ trình PLAR tự động.
    - **Xác thực OTP 6 chữ số chuẩn Fintech**: Gửi email thật qua Brevo SMTP (`SmtpEmailService.cs`), xác thực OTP khôi phục mật khẩu (`VerifyResetOtpCommandHandler.cs`, `ForgotPasswordModal.jsx`).
    - **Socratic Dual-Track AI Engine**: Triển khai phân tách 2 luồng (Track 1 Task Grounding triệt tiêu ô nhiễm vector; Track 2 Dynamic Intent Router 5 tình huống kết hợp tâm trạng).
    - **Bảo vệ luồng SSE**: Dùng kênh bất đồng bộ `System.Threading.Channels` chống rớt token và tối ưu trải nghiệm giao diện.
  - Kiểm thử toàn diện sau hợp nhất: Cả 5 Backend Solutions (`V-Eval-Identity_Service`, `V-Eval-Content_Service`, `V-Eval-Practice_Service`, `V-Eval-Gateway`) build đạt **0 Error(s)**; Frontend `V-Eval-Web_Client` test pass 9/9, build thành công; Docker Compose hợp lệ 100%.

- **Chuẩn Hóa Toàn Bộ Mục `IV.3 Detailed Design` Trong [`docs/report_tong_chuan_hoa.md`](./docs/report_tong_chuan_hoa.md) Khớp 100% Đồ Án Mẫu FPTU (`GFA67`)**:
  - Tách 7 Phân hệ quản lý (`3.1 -> 3.7`) thành **20 chức năng cốt lõi độc lập = 40 sơ đồ (`20 Class Diagrams` số lẻ + `20 Sequence Diagrams` số chẵn từ `Figure 18` đến `Figure 57`)**, bóc tách chi tiết từng hộp/thuộc tính/phương thức từ code C# thực tế.
  - **Rà soát & đối chiếu toàn bộ Phân hệ 3.7 (Multi-Campus Cohort, Heatmap & Early Warning Management)**:
    - `3.7.1 & 3.7.2` (Figure 52 & 53): Tự động phân lớp theo cụm năng lực đầu vào (`StudentKMeansClusterer` - Constrained K-Means phân tầng `FOUNDATIONAL`, `STANDARD`, `INTENSIVE`).
    - `3.7.3 & 3.7.4` (Figure 54 & 55): Khảo sát ma trận nhiệt năng lực lớp học theo mô hình Cache-Aside (`IClassHeatmapCacheService` với `IMemoryCache` nội bộ và chuẩn phân tán Redis 7).
    - `3.7.5 & 3.7.6` (Figure 56 & 57): Hệ thống cảnh báo sớm 3 cấp độ (`TIER_1 / 2 / 3`), phân định rõ luồng chạy ngầm của Worker định kỳ (`EarlyWarningSweepWorker`) và API giao diện của Mentor (`EarlyWarningsController`).
  - **Đối chiếu mã nguồn toàn hệ thống & hoàn thiện Checklist 7 hạng mục hoàn thiện code** ở cuối Phần IV, bảo toàn 100% văn bản Tiếng Anh chuẩn SDD sẵn sàng nộp.
