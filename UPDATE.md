# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - V-EVAL CAPSTONE SYSTEM REPO

## [21/11/2026]
- **V-Eval-Web_Client**:
  - **Tối Giản & Tái Cấu Trúc Ma Trận Thời Khóa Biểu Tuần 8 Cột (Weekly Timetable Matrix Grid) (`TeacherScheduleView.jsx`)**:
    - *Tối giản giao diện & loại bỏ banner lệch tông*: Loại bỏ hoàn toàn banner hero xanh đen cồng kềnh giúp giao diện thời khóa biểu đồng điệu với phong cách sáng màu của hệ thống; chuyển nút làm mới lịch (`RefreshCw`) vào thanh công cụ của bảng tuần.
    - *Giao diện ma trận tuần 8 cột chuẩn học viện & đại học*: Thiết kế bảng ma trận gồm Cột 1 (Slot 1-6) và 7 cột Thứ trong tuần (Thứ 2 - Chủ nhật kèm ngày DD/MM). Tự động nhận diện và làm nổi bật ngày hiện tại ("Hôm nay") bằng viền và nền xanh ngọc dịu nhẹ; các ô trống hiển thị dấu gạch ngang `-` thanh lịch.
    - *Thẻ ca học chi tiết*: Hiển thị tên lớp, trạng thái chuyên cần (Có mặt / Chưa điểm danh), giờ học, phòng học, chế độ Offline, tên giảng viên, nhãn chuyên đề và sĩ số học sinh; tích hợp nút mở Modal điểm danh chuyên cần và nút xếp nhóm học tập vi mô 3–5 em.
    - *Điều hướng tuần & chuyển chế độ xem*: Hỗ trợ điều hướng tuần trước/tuần này/tuần sau; banner phát hiện thông minh chuyển nhanh đến tuần có ca dạy gần nhất; chuyển đổi linh hoạt giữa `Lưới tuần` (Matrix Grid) và `Danh sách` (Agenda Cards).
    - *Duy trì kết nối CSDL thời gian thực*: Tích hợp 100% dữ liệu động từ backend qua `practiceService` (lớp học, ca dạy, học sinh và lưu điểm danh trực tiếp).
  - **Kiểm Thử & Biên Dịch**: `npm run build` thành công 100% trong 1.71s (`3079 modules`, `0 Error`).
- **V-Eval-Practice_Service**:
  - **Duy Trì Vận Hành Ổn Định Các Phân Hệ Lịch Dạy & Điểm Danh**: `dotnet build` thành công toàn bộ solution (`0 Warning`, `0 Error`).
