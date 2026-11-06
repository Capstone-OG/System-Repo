# NHẬT KÝ CẬP NHẬT HỆ THỐNG (SYSTEM-REPO UPDATE LOG)

## [06/11/2026] - Phân Chia Cổng Giao Diện 5 Vai Trò, Đồng Bộ Template Màu Sắc Chuẩn Trang Chủ (`#FDFBF7`), Kiểm Tra Đa Tầng Email Đăng Ký (DNS MX), Liên Kết Phụ Huynh - Học Sinh 3 Phương Thức & Đấu Nối 100% Dữ Liệu Thực Từ Backend API

- **Hệ Thống Liên Kết Phụ Huynh - Học Sinh 3 Phương Thức Trực Tiếp Trên CSDL (`V-Eval-Identity_Service` & `V-Eval-Web_Client` - UC 41)**:
  - **Phương thức 1 (Mã Tài Khoản Học Sinh `VE-XXXXXX` & Mã PIN 6 Số)**: Cấp mã định danh cố định `VE-XXXXXX` cùng mã PIN 6 số động hạn 30 phút (`PARENT_LINK_CODE`) trên Cổng Học Viên (`StudentParentLinkCard.jsx`); Phụ huynh nhập mã tại `ParentDashboardView.jsx` (`POST /api/v1/users/parent-link/connect`) để liên kết tức thì vào bảng `v_eval_identity.ParentStudentRelations`.
  - **Phương thức 2 (Đường Liên Kết Mời 1-Click & Mã QR)**: Tạo đường dẫn mời `?parentLinkCode=...` và hiển thị Mã QR trên Cổng Học Viên; khi Phụ huynh mở link hoặc quét QR, hệ thống tự động kết nối và tải ngay báo cáo học tập của con.
  - **Phương thức 3 (Tìm Theo Email/SĐT Học Sinh & Xác Nhận 2 Chiều Trên Web)**: Phụ huynh gửi yêu cầu theo Email/SĐT của con (`POST /api/v1/users/parent-link/request`); Học sinh thấy ngay thông báo trên Cổng Học Viên và bấm **`✓ Chấp Nhận Liên Kết`** (`POST /api/v1/users/me/parent-link-requests/{id}/respond`) mà không phụ thuộc máy chủ gửi thư SMTP.

- **Loại Bỏ Triệt Để Dữ Liệu Học Sinh Mẫu Giả Định (Phạm Minh Hoàng) Trong Backend & Frontend (`V-Eval-Practice_Service` & `V-Eval-Web_Client`)**:
  - Xóa bỏ hoàn toàn khối lệnh tiêm học sinh mẫu `"Phạm Minh Hoàng"` (`3fa85f64-5717-4562-b3fc-2c963f66afa6`) trong [`GetParentDashboardQueryHandler.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Application/Features/Analytics/Queries/GetParentDashboard/GetParentDashboardQueryHandler.cs); khi phụ huynh chưa liên kết với học sinh, backend trả về danh sách rỗng 100% thực tế (`children: []`), kích hoạt màn hình chờ liên kết sạch sẽ trên Web.
  - Chuẩn hóa các chỉ số tự học và tính kỷ luật về `0.0` khi chưa có bài làm thực tế thay cho các con số giả định (`82.4`, `14.5` giờ, `12` ngày streak).

- **Kiểm Tra Tính Hợp Lệ Đa Tầng Cho Email Đăng Ký (`V-Eval-Identity_Service` & `V-Eval-Web_Client` - UC 01a)**:
  - Triển khai `EmailValidationHelper.cs`, `ValidateEmailQuery.cs` (`GET /api/auth/validate-email`) và `emailValidator.js` kiểm tra cú pháp RFC 5322, quy tắc tài khoản Gmail (6–30 ký tự), phát hiện sai chính tả tên miền kèm nút sửa 1-Click, chặn dịch vụ email ảo 10 phút, chặn chuỗi ký tự lặp bất thường (`22222`) và đối soát bản ghi máy chủ nhận thư DNS `MX`.

- **Web Client (`V-Eval-Web_Client` - Nhánh `ThinhTT/feature-role-portals-and-home-theme-sync`)**:
  - Loại bỏ 100% Demo / Hardcode / Mock Fallback & thư mục `tests/`; phân chia độc lập 5 cổng vai trò (`student`, `parent`, `teacher`, `manager`, `admin`) trên nền kem sáng học thuật `#FDFBF7` chuẩn Trang chủ; `npm run build` hoàn thành sạch sẽ (`3008 modules transformed`, **0 Error**).
