# NHẬT KÝ CẬP NHẬT HỆ THỐNG (SYSTEM-REPO UPDATE LOG)

## [07/11/2026] - Triển Khai Phân Hệ Quản Lý Tài Khoản Ngừng Hoạt Động (Soft Delete / Inactive) & Thùng Rác Lưu Trữ, Tái Thiết Kế Thanh Điều Hướng Segmented Control, Cổng Giám Đốc Học Thuật & Kiểm Tra Email Đa Tầng Cấp Phát IAM

- **Phân Hệ Quản Lý Tài Khoản Ngừng Hoạt Động (Soft Delete / Inactive) Toàn Diện (`V-Eval-Identity_Service` & `V-Eval-Web_Client`)**:
  - **Nguyên Tắc Bảo Toàn Dữ Liệu Sư Phạm Tuyệt Đối (No Hard Delete)**: Loại bỏ triệt để thao tác xóa cứng (`DELETE FROM "Users"`), bảo đảm 100% tính toàn vẹn liên kết khóa ngoại đối với lịch sử nộp bài thi chẩn đoán IRT (`ExamSubmissions`), lộ trình thích ứng (`PracticeSessions`), giao dịch học phí PayOS (`PaymentOrders`) và quan hệ Phụ huynh - Học sinh.
  - **Bộ Lọc Trạng Thái & Thống Kê Realtime (`V-Eval-Identity_Service`)**:
    - Nâng cấp `GetUsersQuery` và `GET /api/v1/users` hỗ trợ tham số `bool? isActive` lọc chính xác tài khoản đang hoạt động (`true`) hoặc đã ngừng hoạt động/ẩn (`false`).
    - Nâng cấp `PagedUsersResult` trả về đồng thời `ActiveCount` và `InactiveCount` theo thời gian thực từ PostgreSQL `v_eval_identity."Users"`.
    - Nâng cấp `ToggleUserStatusCommand` (`PATCH /api/v1/users/{id}/toggle-status`) hỗ trợ tham số `targetStatus` tùy chọn để đặt trạng thái kích hoạt hoặc ngừng hoạt động có kiểm soát.
  - **Giao Diện Dual-View & Modals Xác Nhận Chuyên Nghiệp (`V-Eval-Web_Client` - [`AccountProvisioningView.jsx`](./All%20Services/V-Eval-Web_Client/src/components/admin/AccountProvisioningView.jsx))**:
    - Tách biệt 2 tab rõ ràng: **"Tài Khoản Đang Hoạt Động"** (mặc định chỉ hiện active, tài khoản bị vô hiệu hóa sẽ **tự động bị ẩn (hidden)** khỏi danh sách) và **"Tài Khoản Đã Ngừng Hoạt Động (Ẩn)"** (kho lưu trữ tài khoản vô hiệu hóa với banner thông tin rõ ràng).
    - Thẻ thống kê 1 (*"Đang hoạt động"*) và Thẻ 4 (*"Đã ngừng hoạt động"*) hỗ trợ bấm trực tiếp để chuyển nhanh bộ lọc tương ứng.
    - Modal xác nhận Ngừng hoạt động (icon `UserX` đỏ) và Modal xác nhận Khôi phục hoạt động (icon `RotateCcw` xanh lá) kèm cảnh báo bảo toàn dữ liệu.

- **Tái Thiết Kế Giao Diện Thanh Điều Hướng Chuẩn Segmented Control & Nhận Diện Cổng Giám Đốc Học Thuật (`V-Eval-Web_Client`)**:
  - **Segmented Control Navigation Bar ([`App.jsx`](./All%20Services/V-Eval-Web_Client/src/App.jsx))**: Khắc phục triệt để lỗi rớt dòng 2 hàng gây vỡ giao diện trên Cổng Quản lý Học thuật bằng thanh điều hướng dạng Segmented Control nguyên khối (`bg-slate-100/90`, bo tròn `rounded-2xl`, hỗ trợ cuộn mượt `overflow-x-auto scrollbar-none`). Tab kích hoạt dạng card nổi bật (`bg-white text-blue-700 shadow-sm font-extrabold ring-1 ring-slate-200/80`). Tinh giản nhãn các tab trực quan: *"So sánh Cơ sở"*, *"Ma trận Lớp học"*, *"Khung Chương trình"*, *"Cấp phát Tài khoản"*, *"Báo cáo Chất lượng"*.
  - **Nhận diện Giám Đốc Học Thuật (`ACADEMIC_DIRECTOR`)**: Tự động chuyển đổi giao diện sang *"Cổng Giám Đốc Học Thuật Toàn Trường"* kèm biểu tượng vương miện hoàng gia `Crown` và huy hiệu `ACADEMIC DIRECTOR PORTAL`.

- **Tích Hợp Kiểm Tra Email Đa Tầng Vào Cấp Phát Tài Khoản & Khắc Phục Lỗi Null `CampusId` (`V-Eval-Identity_Service` & `V-Eval-Web_Client`)**:
  - **Kiểm Tra Email Đa Tầng Backend & Frontend**: Bổ sung `EmailValidationHelper.ValidateEmailComprehensiveAsync` vào lệnh cấp phát tài khoản trực tiếp `ProvisionUserCommand` và giao diện web `AccountProvisioningView.jsx`, phát hiện lỗi gõ nhầm `@mail.com`, từ chối tạo tài khoản ảo và gợi ý `@gmail.com` kèm nút sửa nhanh 1-Click.
  - **Khắc phục lỗi Null `CampusId`**: Chuyển trường `CampusId` trong thực thể `Student` sang dạng nullable (`Guid?`), sửa logic null-check trong gRPC, loại bỏ hoàn toàn ngoại lệ `InvalidCastException: Column 'campus_id' is null` gây lỗi HTTP 500 khi gọi `GET /api/v1/users`.

- **Kiểm Thử & Vận Hành Toàn Hệ Thống**:
  - `V-Eval-Identity_Service`: .NET 9 SDK build sạch 100% (0 Error, 0 Warning), 5/5 xUnit unit tests đạt Passed 100%.
  - `V-Eval-Web_Client`: `npm run build` hoàn thành sạch sẽ 100% (3008 modules transformed, 0 Error).
