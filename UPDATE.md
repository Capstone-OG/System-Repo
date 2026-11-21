# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - V-EVAL CAPSTONE SYSTEM REPO

## [21/11/2026]
- **V-Eval-Practice_Service**:
  - **Đồng Bộ Danh Tính Họ Tên Học Sinh Thực Tế Cho Ma Trận Nhiệt Lớp Học (`GetClassHeatmapQueryHandler.cs`, `IIdentityGrpcClient.cs`)**:
    - Tiêm `IIdentityGrpcClient` vào `GetClassHeatmapQueryHandler`, gọi gRPC `GetStudentNamesAsync` sang Identity Service để truy vấn họ tên người dùng từ bảng `v_eval_identity."Users"`.
    - Thay thế hoàn toàn mã định danh giả lập `Học sinh #...` bằng danh tính thực tế: `Nguyễn Hoàng An`, `Trần Ngọc Mai`, `Phạm Tấn Lộc`, `Mai Thành Nhân`, `Trần Thái Thịnh`, `Lê Hoàng Long`.
    - Tự động bỏ qua bộ đệm cache khi phát hiện dữ liệu cũ và tái đồng bộ vào MemoryCache.
    - `dotnet build`: Hoàn thành 100%, 0 lỗi, 0 cảnh báo; `dotnet test`: 20/20 unit tests Passed.
- **V-Eval-Web_Client**:
  - **Tối Giản & Tái Cấu Trúc Ma Trận Thời Khóa Biểu Tuần 8 Cột (Weekly Timetable Matrix Grid) (`TeacherScheduleView.jsx`)**:
    - Loại bỏ hoàn toàn khối banner hero xanh đen cồng kềnh giúp giao diện thời khóa biểu đồng điệu với phong cách phẳng sáng màu; chuyển nút làm mới lịch (`RefreshCw`) vào thanh công cụ của bảng tuần.
    - Thiết kế bảng ma trận gồm Cột 1 (Slot 1-6) và 7 cột Thứ trong tuần (Thứ 2 - Chủ nhật kèm ngày DD/MM). Tự động nhận diện và làm nổi bật ngày hiện tại ("Hôm nay") bằng viền và nền xanh ngọc dịu nhẹ; các ô trống hiển thị dấu gạch ngang `-` thanh lịch.
    - Thẻ ca học hiển thị đầy đủ thông tin: tên lớp, chuyên cần, giờ học, phòng học, chế độ Offline, tên giảng viên, chuyên đề bài học và sĩ số; tích hợp modal điểm danh chuyên cần tại lớp.
    - `npm run build`: Biên dịch thành công 100% trong 1.23s (`3079 modules`, `0 Error`).
