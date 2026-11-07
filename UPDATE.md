# NHẬT KÝ CẬP NHẬT HỆ THỐNG (SYSTEM-REPO UPDATE LOG)

## [07/11/2026] - Tái Thiết Kế Thanh Điều Hướng Dạng Segmented Control, Nhận Diện Cổng Giám Đốc Học Thuật (Academic Director), Tích Hợp Kiểm Tra Email Đa Tầng (DNS MX & Chống Typo mail.com) Vào Cấp Phát Tài Khoản (IAM Provisioning) & Xử Lý Triệt Để Lỗi Null CampusId

- **Tái Thiết Kế Giao Diện Thanh Điều Hướng Chuẩn Segmented Control & Nhận Diện Cổng Giám Đốc Học Thuật (`V-Eval-Web_Client`)**:
  - **Segmented Control Navigation Bar ([`App.jsx`](./All%20Services/V-Eval-Web_Client/src/App.jsx))**: Khắc phục triệt để lỗi rớt dòng 2 hàng gây vỡ giao diện trên Cổng Quản lý Học thuật bằng thanh điều hướng dạng Segmented Control nguyên khối (`bg-slate-100/90`, bo tròn `rounded-2xl`, hỗ trợ cuộn mượt `overflow-x-auto scrollbar-none`). Tab kích hoạt dạng card nổi bật (`bg-white text-blue-700 shadow-sm font-extrabold ring-1 ring-slate-200/80`). Tinh giản nhãn các tab trực quan: *"So sánh Cơ sở"*, *"Ma trận Lớp học"*, *"Khung Chương trình"*, *"Cấp phát Tài khoản"*, *"Báo cáo Chất lượng"*.
  - **Nhận diện Giám Đốc Học Thuật (`ACADEMIC_DIRECTOR`)**: Tự động chuyển đổi giao diện sang *"Cổng Giám Đốc Học Thuật Toàn Trường"* kèm biểu tượng vương miện hoàng gia `Crown` và huy hiệu `ACADEMIC DIRECTOR PORTAL`.
  - **Kiểm tra Email Đa Tầng Tại Giao Diện ([`AccountProvisioningView.jsx`](./All%20Services/V-Eval-Web_Client/src/components/admin/AccountProvisioningView.jsx), [`emailValidator.js`](./All%20Services/V-Eval-Web_Client/src/utils/emailValidator.js))**: Tích hợp kiểm tra cú pháp RFC 5322, chặn email rác/ảo 10 phút, tra cứu bản ghi DNS MX, và cơ chế phát hiện lỗi gõ nhầm tên miền (`mail.com` thành `gmail.com`) với nút 1-Click sửa nhanh.

- **Tích Hợp Kiểm Tra Email Đa Tầng Vào Cấp Phát Tài Khoản & Khắc Phục Lỗi Null `CampusId` (`V-Eval-Identity_Service`)**:
  - **Kiểm Tra Email Đa Tầng Backend ([`ProvisionUserCommand.cs`](./All%20Services/V-Eval-Identity_Service/V-Eval-Identity_Service.Application/Features/Users/Commands/ProvisionUser/ProvisionUserCommand.cs), [`EmailValidationHelper.cs`](./All%20Services/V-Eval-Identity_Service/V-Eval-Identity_Service.Application/Common/Validators/EmailValidationHelper.cs))**: Bổ sung `EmailValidationHelper.ValidateEmailComprehensiveAsync` vào lệnh cấp phát tài khoản trực tiếp `ProvisionUserCommand`, phát hiện lỗi gõ nhầm `@mail.com`, từ chối tạo tài khoản ảo và hướng dẫn người dùng chính xác.
  - **Khắc phục lỗi Null `CampusId` ([`Student.cs`](./All%20Services/V-Eval-Identity_Service/V-Eval-Identity_Service.Domain/Entities/Profiles/Student.cs), [`IdentityGrpcService.cs`](./All%20Services/V-Eval-Identity_Service/V-Eval-Identity_Service.API/Services/IdentityGrpcService.cs))**: Chuyển trường `CampusId` trong thực thể `Student` sang dạng nullable (`Guid?`), sửa logic null-check trong gRPC, loại bỏ hoàn toàn ngoại lệ `InvalidCastException: Column 'campus_id' is null` gây lỗi HTTP 500 khi gọi `GET /api/v1/users`. Cập nhật các bản ghi thiếu cơ sở về cơ sở mặc định.

- **Kiểm Thử & Vận Hành Toàn Hệ Thống**:
  - `V-Eval-Identity_Service`: .NET 9 SDK build sạch 100% (0 Error, 0 Warning), 5/5 xUnit unit tests đạt Passed 100%.
  - `V-Eval-Web_Client`: `npm run build` hoàn thành sạch sẽ 100% (3008 modules transformed, 0 Error).
  - Đã kích hoạt và đồng bộ hóa thành công tài khoản Giám Đốc Học Thuật `congloc313@gmail.com` với mật khẩu `Thaithinh99@` trên CSDL PostgreSQL.
