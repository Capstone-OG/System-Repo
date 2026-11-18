# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - V-EVAL CAPSTONE SYSTEM REPO

## [19/11/2026] - Triệt Tiêu Hoàn Toàn Giả Lập Giáo Viên Cổng Phụ Huynh: Hiển Thị Đúng Trạng Thái Chưa Phân Công Từ CSDL

- **Loại Bỏ Hoàn Toàn Dữ Liệu Fallback Giả Lập ([`GetParentDashboardQueryHandler.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Application/Features/Analytics/Queries/GetParentDashboard/GetParentDashboardQueryHandler.cs), [`IdentityGrpcService.cs`](./All%20Services/V-Eval-Identity_Service/V-Eval-Identity_Service.API/Services/IdentityGrpcService.cs))**:
  - Xóa bỏ 100% dữ liệu cứng `"ThS. Nguyễn Minh Triết"` và `"0908 246 357"`.
  - Phản ánh trung thực trạng thái CSDL: Khi lớp học chưa gán `TeacherId` (hoặc giáo viên không tồn tại trong CSDL), hệ thống trả về `"Chưa có giáo viên phụ trách"` và số điện thoại `"Chưa có"`.
  - `IdentityGrpcService.GetTeacherProfile` trả về `Exists = false` khi không tìm thấy giáo viên trong CSDL thay vì sinh dữ liệu mẫu.
- **Tối Ưu Trải Nghiệm Giao Diện Phụ Huynh ([`ParentDashboardView.jsx`](./All%20Services/V-Eval-Web_Client/src/components/dashboard/ParentDashboardView.jsx))**:
  - Hiển thị rõ ràng trạng thái chưa có giáo viên hoặc chưa có số liên hệ.
  - Nút đăng ký trao đổi 1-1 hiển thị thông báo hướng dẫn phụ huynh khi lớp con đang chờ điều phối giáo viên.
- **Kiểm Thử & Nghiệm Thu**:
  - `V-Eval-Practice_Service.Tests`: 20/20 unit tests Passed 100%.
  - `V-Eval-Identity_Service.Tests`: 5/5 unit tests Passed 100%.
  - `V-Eval-Web_Client`: `npm run build` thành công 100%.
