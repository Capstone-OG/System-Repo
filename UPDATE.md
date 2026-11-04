# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [04/11/2026] - Bổ Sung API Xác Thực OTP Quên Mật Khẩu (UC 05b), Chặn Triệt Để OTP Sai & Nâng Cấp Giao Diện Fintech

- **Bổ Sung API Xác Thực Mã OTP Quên Mật Khẩu (UC 05b - `POST /api/auth/verify-reset-otp`)**:
  - Triển khai `VerifyResetOtpCommand` (Application) và đăng ký endpoint tại `AuthController.cs`.
  - Khắc phục triệt để vấn đề nhập sai OTP nhưng vẫn chuyển qua bước đặt lại mật khẩu: Hệ thống đối soát trực tiếp mã OTP loại `RESET_PASSWORD` với CSDL ngay tại Bước 2; nếu sai hoặc hết hạn sẽ chặn đứng lập tức (HTTP 400 `Auth.InvalidOtp: "Mã xác thực OTP không chính xác hoặc đã hết hạn."`), buộc người dùng ở lại Bước 2 và hiển thị banner cảnh báo đỏ.
  - Phía Web Client: Tích hợp `authService.verifyResetOtp(email, otpCode)` trong `WebLoginPage.jsx` trước khi cho phép mở Bước 3.

- **Tích Hợp Dịch Vụ Gửi Email Brevo SMTP Relay Thực Tế Cho Identity Service**:
  - Đấu nối thành công cấu hình Brevo SMTP Relay (`smtp-relay.brevo.com:587`, STARTTLS) với tài khoản `c17a0c001@smtp-brevo.com` và khóa API bảo mật chính thức.
  - Chuẩn hóa thông tin người gửi mang nhận diện hệ thống: `V_Eval System <veval.system@gmail.com>`.
  - Triển khai `IEmailService` (Application) và `BrevoSmtpEmailService` (Infrastructure) sử dụng `MailKit` & `MimeKit` v4.17.0.
  - Thiết kế khuôn mẫu HTML email phản hồi nhanh, chuẩn nhận diện ĐHQG-HCM, hiển thị mã OTP 6 số cùng hướng dẫn bảo mật thời hạn 10 phút.

- **Nâng Cấp Giao Diện Nhập Mã OTP Chuẩn Fintech & Hoàn Thiện Luồng Quên Mật Khẩu (Frontend)**:
  - **Lưới 6 ô vuông nhập số độc lập (6-Digit PIN Grid)**: Thay thế ô nhập đơn điệu bằng 6 ô vuông bo tròn hiện đại (`w-12 h-14`), chữ số lớn `text-2xl font-black`, tự động nhảy ô, hỗ trợ Backspace và dán toàn bộ 6 số (`Ctrl + V`).
  - **Đồng hồ đếm ngược 60 giây & Nút gửi lại mã**: Tự động đếm ngược với nút `Gửi lại mã OTP` tích hợp icon xoay tròn `RefreshCw`.
  - **Thanh tiến trình 3 bước (Step Indicator)**: Hiển thị trạng thái hoàn thành: `[1. Email] ── [2. Mã OTP] ── [3. Mật khẩu mới]`.
  - **Bảo mật mật khẩu mới (Bước 3)**: Bổ sung nút ẩn/hiện mật khẩu (`Eye` / `EyeOff`), bảng kiểm tra độ mạnh mật khẩu thời gian thực (8+ ký tự, in hoa, thường, số) và kiểm tra khớp mật khẩu.

- **Kiểm Thử Toàn Diện & Đảm Bảo Chất Lượng (Build & Unit Tests)**:
  - Identity Service Unit Tests: **5/5 tests PASS 100%**.
  - Web Client Tests: **6/6 tests PASS 100%** (`npm test` & `npm run build` thành công trong 1.18s).
  - Toàn bộ các project C# biên dịch sạch sẽ: **0 Warning(s), 0 Error(s)**.
  - Dịch vụ Identity Service (:5155) và Gateway YARP (:5212) định tuyến thông suốt và chặn đúng mã OTP không hợp lệ.
