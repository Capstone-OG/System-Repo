# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - V-EVAL CAPSTONE SYSTEM REPO

## [21/11/2026]
- **V-Eval-Web_Client**:
  - **Loại Bỏ 2 Nút Thu Gọn Sidebar Trùng Lặp Ở Mép Brand Header & Navbar (`Sidebar.jsx`, `AccountNavbar.jsx`)**:
    - Triệt tiêu 2 nút thu gọn/mở rộng sidebar (`PanelLeftClose`/`PanelLeftOpen`) nằm kề nhau gây rối mắt giữa Sidebar và Top Navbar.
    - Giữ nguyên nút menu điều hướng responsive mobile (`Menu`), làm phẳng và thoáng đãng thanh tiêu đề desktop.
  - **Tối Giản Cảnh Báo Sư Phạm Thành Nút Bấm Popup (Pedagogical Alerts Modal) (`TeacherDashboardView.jsx`)**:
    - Gom danh sách thẻ cảnh báo trải dài thô xuống màn hình thành 1 dải mỏng nhẹ và 1 nút bấm: `Xem danh sách chuyên đề ({count})`.
    - Khi bấm, hiển thị Modal danh sách chuyên đề cuộn mượt (`max-h-[85vh]`), hiển thị chi tiết tỷ lệ hiểu bài, số học sinh chưa đạt và nút mở nhanh tạo nhóm bồi dưỡng vi mô 3–5 em.
  - **Tối Giản & Tái Cấu Trúc Ma Trận Thời Khóa Biểu Tuần 8 Cột (Weekly Timetable Matrix Grid) (`TeacherScheduleView.jsx`)**:
    - Loại bỏ khối banner hero xanh đen cồng kềnh giúp giao diện phẳng đồng điệu; đưa nút làm mới (`RefreshCw`) vào thanh công cụ.
    - Xây dựng bảng ma trận 8 cột (Slot 1-6 + Thứ 2 đến Chủ nhật), làm nổi bật ngày hiện tại, ô trống hiển thị `-`, thẻ ca học đầy đủ thông tin sư phạm kèm modal điểm danh trực tiếp tại lớp.
  - **Kiểm Thử & Biên Dịch**: `npm run build` thành công 100% trong 1.32s (`3079 modules`, `0 Error`).
- **V-Eval-Practice_Service**:
  - **Đồng Bộ Danh Tính Họ Tên Học Sinh Thực Tế Cho Ma Trận Nhiệt Lớp Học (`GetClassHeatmapQueryHandler.cs`, `IIdentityGrpcClient.cs`)**:
    - Tiêm `IIdentityGrpcClient` vào `GetClassHeatmapQueryHandler`, gọi gRPC `GetStudentNamesAsync` sang Identity Service để truy vấn họ tên người dùng từ bảng `v_eval_identity."Users"`.
    - Thay thế hoàn toàn mã định danh giả lập `Học sinh #...` bằng danh tính thực tế: `Nguyễn Hoàng An`, `Trần Ngọc Mai`, `Phạm Tấn Lộc`, `Mai Thành Nhân`, `Trần Thái Thịnh`, `Lê Hoàng Long`.
    - Tự động bỏ qua bộ đệm cache khi phát hiện dữ liệu cũ và tái đồng bộ vào MemoryCache.
    - `dotnet build`: Hoàn thành 100%, 0 lỗi, 0 cảnh báo; `dotnet test`: 20/20 unit tests Passed.
