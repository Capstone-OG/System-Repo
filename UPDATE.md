# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - V-EVAL CAPSTONE SYSTEM REPO

## [19/11/2026] - Chuẩn Hóa Cổng Phụ Huynh 4 Phân Hệ & Tối Ưu Quản Lý Học Thuật Cơ Sở

- **Chuẩn Hóa Cổng Phụ Huynh 4 Phân Hệ & Bố Cục Dashboard 3 Tầng ([`ParentDashboardView.jsx`](./All%20Services/V-Eval-Web_Client/src/components/dashboard/ParentDashboardView.jsx), [`ParentChildResultsView.jsx`](./All%20Services/V-Eval-Web_Client/src/components/dashboard/ParentChildResultsView.jsx), [`ParentEarlyWarningsAndTeacherView.jsx`](./All%20Services/V-Eval-Web_Client/src/components/dashboard/ParentEarlyWarningsAndTeacherView.jsx))**:
  - Di chuyển toàn bộ các Hook `useEffect` lên đầu component trước các câu lệnh `if (...) return`, triệt tiêu hoàn toàn ngoại lệ `Rendered more hooks than during the previous render`.
  - Nâng state `parentActiveChildId` lên `App.jsx`, giải quyết triệt để lỗi lệch ngữ cảnh con khi chuyển tab; đồng bộ tự động cho toàn bộ Dashboard, Tiến độ & Kết quả, Cảnh báo sớm và Học phí.
  - Tái thiết kế Sidebar 4 mục chuẩn: *1. Tổng quan đồng hành*, *2. Tiến độ & Kết quả của con*, *3. Cảnh báo & Trao đổi Giáo viên*, *4. Học phí & Lịch sử giao dịch*.
  - Bổ sung bộ chọn dropdown con ngay trên thanh điều hướng đầu trang `AccountNavbar` khi phụ huynh liên kết $\ge 2$ con, cho phép chuyển đổi học sinh tức thì từ mọi trang.
  - Đồng bộ hóa sự kiện click chọn thẻ con trong `TuitionPaymentView` với `onSelectChildId`, cập nhật trạng thái `activeChildId` toàn cục ngay lập tức.
  - Loại bỏ hoàn toàn các từ viết tắt nội bộ: IRT Theta, BKT, ZPD, PLAR, Core Flow 5, Live Identity + Practice gRPC, giá thử nghiệm 5.000 ₫; thay bằng ngôn ngữ tiếng Việt đời thường, dễ hiểu cho gia đình.
- **Nâng Cấp Xếp Lớp Đầu Vào Theo Ma Trận 4 Miền × 3 Cấp Bậc (12 Lớp Chuẩn)**:
  - Cấu hình ngưỡng Cơ bản (`< 50%`) và Nâng cao (`>= 75%`) trực quan; hỗ trợ checkbox *Chỉ xếp học sinh mới chưa có lớp (Bảo toàn 100% lớp của HS cũ)*.
  - Hiển thị ma trận 4 hàng (4 Miền kiến thức) × 3 cột (Cơ bản / Tăng tốc / Nâng cao) kèm sĩ số `X/20 HS`, nhãn trạng thái và nút Gán Giáo Viên phụ trách trực tiếp.
- **Đồng Bộ Dữ Liệu Học Sinh & Khắc Phục Xung Đột Phòng Học 409**:
  - Triển khai phương thức gRPC `GetStudentsByIds` trong `IdentityGrpcService.cs` và `GetStudentNamesAsync` trong `IdentityGrpcClient.cs`, truy vấn động họ tên học sinh thực tế từ CSDL.
  - Cập nhật cơ chế đổi ca học thời khóa biểu (Edit Slot thay vì Append), kiểm soát xung đột phòng học và giảng viên 2 tầng ở cả Backend (`ScheduleService.cs`) và Frontend (`scheduleSlotConflict`).
- **Kiểm Thử & Nghiệm Thu**:
  - `npm run build`: Thành công 100% trong 1.11s, 0 lỗi biên dịch.
  - `node --test tests/*.test.js`: Toàn bộ **22/22 unit tests Passed**.
  - `dotnet test`: Toàn bộ tests của Practice Service và Identity Service đều Passed.
