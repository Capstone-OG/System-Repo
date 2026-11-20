# NHẬT KÝ CẬP NHẬT TIẾN ĐỘ HẰNG NGÀY (DAILY UPDATE LOG)

### [20/11/2026]
- **Nhiệm vụ trọng tâm**:
  - **Chuẩn Hóa Vai Trò Cổng Giám Đốc Học Thuật Liên Cơ Sở (`ACADEMIC_DIRECTOR`) Trên `V-Eval-Web_Client`**:
    - Bảo toàn 100% 4 phân hệ chuyên môn cốt lõi của Director (`Kiểm duyệt Gia sư AI`, `Quản lý Khung Chương trình`, `Sách giáo khoa (SGK)`, `Đề thi & AI Bloom`).
    - Dọn sạch Menu Sidebar (`Sidebar.jsx`): đổi tên nhóm sang **"Quản Trị Học Thuật Liên Cơ Sở"**, mục trang chủ **"Tổng quan Các Cơ sở"**, gỡ 3 mục trỏ nhầm/lấn sân (`Giám sát Ma trận Lớp học`, `Báo cáo Chất lượng Đào tạo`, `Cấp phát Tài khoản IAM`) và bỏ badge `Flow 4` gây cắt chữ.
    - Nâng cấp chế độ `isDirectorMode` ngay trong `CampusManagerDashboardView.jsx` (không tạo file dư thừa): xóa hardcode `, Nguyễn Duy Khôi!` và `67%`, mặc định hiển thị **Tất cả các cơ sở (`ALL`)** kèm **Bảng Đối Sánh Chất Lượng Giữa Các Cơ Sở**, nạp KPI thật từ `contentService` / `userService` / `practiceService`, bổ sung 4 thẻ lối tắt chuyên môn, chuyển bản đồ nhiệt sang chế độ **Giám sát (Chỉ đọc)**.
    - Cập nhật routing an toàn trong `App.jsx` để Director không bị rơi nhầm sang màn hình Student hoặc Teacher.
  - **Khắc Phục Triệt Để Lỗi Logout Vẫn Dính Tài Khoản Cũ Trên Trang Chủ (`App.jsx`, `apiClient.js`, `authService.js`, `PublicHeader.jsx`)**:
    - Chặn Race Condition của `/api/v1/users/me` qua `sessionVersion`, chặn lưu hồ sơ "bóng ma" khi không có `accessToken`, chuyển sang Optimistic Logout tức thì và kiểm tra `authService.isAuthenticated()` trên `PublicHeader.jsx`.
  - **Đồng Bộ 100% Đợt Học & Khóa Học Sang Cổng Học Phí Student/Parent + Bổ Sung Sửa/Xóa Khóa Học (`V-Eval-Practice_Service` & `V-Eval-Web_Client`)**:
    - **Backend (`CoursesController.cs`, `ScheduleService.cs`, `IScheduleService.cs`, `ScheduleDtos.cs`)**: Bổ sung `PUT /api/v1/courses/{courseId}` (chỉnh sửa khóa học, kiểm tra trùng mã) và `DELETE /api/v1/courses/{courseId}` (tự động Soft-Archive `IsActive = false` nếu đã gắn lớp học hoặc học sinh đăng ký/đóng tiền, xóa cứng nếu chưa có ràng buộc).
    - **Frontend (`TuitionPaymentView.jsx`, `AcademicManagerDashboardView.jsx`, `practiceService.js`)**: Gỡ bỏ hoàn toàn 3 gói học hardcode, tải trực tiếp `AcademicTerms` (`ACTIVE`) và `Courses` (`isActive: true`) theo `campusId` kèm Banner Đợt học đang tuyển sinh; bổ sung nút Sửa (✏️) và Xóa (🗑️) khóa học trên cổng Academic Manager.
- **Trạng thái**: Hoàn thành 100%, `dotnet build` sạch `0 Warning / 0 Error`, `dotnet test` đạt **20/20 Passed**, và `npm run build` (`vite build`) đạt `✓ built in 1.39s` (`0 lỗi`).
