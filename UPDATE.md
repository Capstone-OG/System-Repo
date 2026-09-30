# Nhật Ký Cập Nhật (Update Log) - System Repo

## [30/09/2026] - Triển Khai Hoàn Thiện APIs 12, 13, 14: Điểm Danh Chuyên Cần, Thời Khóa Biểu Giảng Dạy & Cập Nhật Video Ghi Hình Buổi Live

- **Triển Khai Hoàn Tất Giai Đoạn 3 (Phân Hệ Live Q&A, Điểm Danh & Lịch Dạy Giáo Viên) Trong Practice Service**:
  - **API 12 (`POST /api/v1/practice/live-sessions/{sessionId}/attendance`)**: Giáo viên thực hiện điểm danh chuyên cần chính thức cho học sinh (`ATTENDED` hoặc `ABSENT`), lưu vết thời điểm và cập nhật bản ghi `LiveSessionAttendance`.
  - **API 13 (`GET /api/v1/practice/live-sessions/teacher-schedule`)**: Giáo viên tra cứu toàn bộ thời khóa biểu giảng dạy các buổi Live Q&A được phân công (`TeacherId`), thống kê sĩ số lớp học, số học sinh tham gia, số vắng mặt và link phòng họp.
  - **API 14 (`PUT /api/v1/practice/live-sessions/{sessionId}/recording`)**: Giáo viên cập nhật link video ghi hình buổi học trực tuyến (`RecordingUrl`), đánh dấu `IsRecorded = true` và chuyển trạng thái sang `COMPLETED`.
- **Cơ Sở Dữ Liệu & Tầng Lưu Trữ (Infrastructure & Persistence)**:
  - Bổ sung `GetSessionsForTeacherAsync` và `GetEnrolledStudentCountByClassIdAsync` vào [`ILiveSessionRepository.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Application/Common/Interfaces/Repositories/ILiveSessionRepository.cs) và [`LiveSessionRepository.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Infrastructure/Persistence/Repositories/LiveSessionRepository.cs).
- **Kiểm Thử Toàn Hệ Thống & Vận Hành Thực Tế (Live End-to-End Test)**:
  - Solution `V-Eval-Practice_Service.sln` biên dịch sạch 100% (**0 Warning, 0 Error**).
  - Kiểm thử trực tiếp 4 kịch bản qua REST API:
    1. **API 12 (Teacher Attendance)**: Giáo viên điểm danh 2 học sinh (`1111...` ATTENDED, `2222...` ABSENT) cho Session `2a196c82...` -> `200 OK`, `totalAttended: 1`, `totalAbsent: 1`.
    2. **API 13 (Teacher Schedule)**: Giáo viên `99999999-9999-9999-9999-999999999999` tra cứu lịch dạy -> `200 OK`, trả về 5 buổi Live đầy đủ số liệu sĩ số lớp, số tham gia, số vắng mặt.
    3. **API 14 (Update Recording)**: Cập nhật URL ghi hình -> `200 OK`, `isRecorded: true`, `status: "COMPLETED"`.
    4. **Xác thực dữ liệu thời gian thực (API 10)**: Học sinh tra cứu thời khóa biểu cá nhân thấy ngay trạng thái `ATTENDED`, link video recording và trạng thái `COMPLETED`.
