# Nhật Ký Cập Nhật (Update Log) - System Repo

## [06/10/2026] - Hợp Nhất Giao Diện Xác Thực (TNhan UI/UX) Với Tầng API IAM (ThinhTT), Cấp Quyền Đa Vai Trò & Tích Hợp Discord CI Tracker

- **Hợp Nhất Toàn Diện Hệ Thống Xác Thực Web Client (`V-Eval-Web_Client`)**:
  - Tích hợp thiết kế split-screen hiện đại, dynamic activity ticker, hình ảnh học sinh thực tế `vietnamese_student_real.jpg`, bộ form module hóa (`LoginForm.jsx`, `RegisterForm.jsx`, `ForgotPasswordModal.jsx`, `AuthModal.jsx`) từ nhánh `TNhan`.
  - Tích hợp Custom Rounded Select bo tròn cao cấp cho việc chọn Khối Lớp, Điểm mục tiêu ĐGNL và chọn Cơ sở đào tạo (`GET /api/v1/campuses`).
  - Đấu nối 100% logic API thật vào form: `authService.login()`, `authService.register()`, `authService.verifyOtp()`, `authService.forgotPassword()`, `authService.resetPassword()`.
  - Bắt mã lỗi tài khoản chưa kích hoạt (`Auth.AccountNotActivated`) chuyển sang xác thực mã OTP 6 số.
  - Bảo toàn 1-Click Demo Login 4 vai trò (Học sinh, Giáo viên, Quản lý, Phụ huynh).
- **Bảo Toàn 100% Các Thành Phần IAM & Dashboard Mới Của ThinhTT**:
  - Trang Quản trị Cấp phát Tài khoản IAM (`AccountProvisioningView.jsx`).
  - Dashboard Học thuật Cơ sở (`CampusManagerDashboardView.jsx`) và Dashboard Phụ huynh (`ParentDashboardView.jsx`).
  - Dịch vụ người dùng `userService.js` và dịch vụ xác thực `authService.js`.
  - Quản trị trạng thái và điều hướng phân quyền RBAC trong `App.jsx`.
- **Sửa Lỗi Thiếu Thông Báo Discord & Thiết Lập CI/CD GitHub Actions Cho Web Client**:
  - Bổ sung workflow `.github/workflows/discord-commit-tracker.yml` gửi webhook embed thông báo commit thời gian thực về kênh Discord hệ thống.
  - Bổ sung workflow `.github/workflows/ci.yml` tự động kiểm thử và biên dịch ứng dụng web trên Node.js 20.
- **Kiểm Thử Vận Hành & Build Verification**:
  - `npm run build` Web Client hoàn tất thành công trong 679ms (0 error, 0 warning).
