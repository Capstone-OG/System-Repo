# Nhật Ký Cập Nhật (Update Log) - System Repo

## [04/10/2026] - Triển Khai Hoàn Chỉnh Hệ Thống API & Trang Cấp Phát Tài Khoản Đa Vai Trò (IAM Provisioning), Smart RBAC & Seed Admin CSDL

- **Phát Triển API Cấp Phát Tài Khoản Nội Bộ Trực Tiếp (`V-Eval-Identity_Service`)**:
  - `POST /api/v1/users/provision`: Cấp phát tài khoản trực tiếp cho bất kỳ vai trò nào (`TEACHER`, `ACADEMIC_MANAGER`, `ACADEMIC_DIRECTOR`, `ADMINISTRATOR`, `PARENT`, `STUDENT`) với trạng thái kích hoạt ngay (`IsActive = true`) mà không cần qua OTP email.
  - `GET /api/v1/users`: Tra cứu, phân trang, lọc vai trò/cơ sở và tìm kiếm người dùng.
  - `PATCH /api/v1/users/{id}/toggle-status`: Khóa hoặc mở khóa trạng thái tài khoản.
  - Seed tài khoản Quản trị viên `admin` / `1234` (`admin@veval.edu.vn`) băm BCrypt, lưu trực tiếp trong PostgreSQL (`v_eval_identity`).
- **Phát Triển Trang Cấp Phát & Quản Lý Tài Khoản Đa Vai Trò (`V-Eval-Web_Client`)**:
  - Xây dựng giao diện `AccountProvisioningView.jsx` chuẩn executive: thống kê tài khoản theo thời gian thực, bảng người dùng phân quyền màu sắc, lọc theo vai trò, tìm kiếm thông minh và nút gạt bật/tắt trạng thái hoạt động tức thì.
  - Modal cấp tài khoản trực quan với 6 vai trò, chọn cơ sở đào tạo, bộ sinh mật khẩu ngẫu nhiên an toàn, và nút sao chép thông tin bàn giao một chạm.
  - Tích hợp dịch vụ `userService.js` kết nối qua Gateway YARP `:5212`.
  - Điều hướng hợp nhất: Nút tab "Cấp Tài Khoản (IAM)" trên thanh điều hướng đầu trang, menu tài khoản và bảng điều khiển quản lý cơ sở.
- **Kiểm Thử Vận Hành & Tuân Thủ Quy Chuẩn**:
  - `dotnet build` Identity Service thành công 100% (0 warning, 0 error).
  - `npm run build` Web Client thành công 100% trong 758ms (0 warning, 0 error).
  - Cú pháp [`docker-compose.yml`](./docker-compose.yml) đạt chuẩn 100% qua lệnh `docker compose config`.
  - Đã kiểm thử live: Tạo thành công giảng viên `thaynam.toan@veval.edu.vn` qua Gateway, tài khoản đăng nhập thành công nhận JWT token hợp lệ.
