# Nhật Ký Cập Nhật (Update Log) - System Repo

## [30/09/2026] - Triển Khai Hoàn Thiện APIs 12, 13, 14, 15: Điểm Danh Chuyên Cần, Thời Khóa Biểu Giảng Dạy, Video Ghi Hình & Hủy Buổi Học Trực Tuyến

- **Triển Khai Hoàn Tất Giai Đoạn 3 (Phân Hệ Live Q&A, Điểm Danh, Lịch Dạy Giáo Viên & Hủy Buổi Học) Trong Practice Service**:
  - **API 12 (`POST /api/v1/practice/live-sessions/{sessionId}/attendance`)**: Giáo viên thực hiện điểm danh chuyên cần chính thức cho học sinh (`ATTENDED` hoặc `ABSENT`), bảo lưu thời điểm `JoinedAt` thực tế của học sinh. Chặn điểm danh buổi học đã bị hủy (`400 Bad Request`).
  - **API 13 (`GET /api/v1/practice/live-sessions/teacher-schedule`)**: Giáo viên tra cứu toàn bộ thời khóa biểu giảng dạy các buổi Live Q&A được phân công (`TeacherId`), kiểm tra giáo viên tồn tại (`404 Not Found` `TeacherNotFound`), thống kê sĩ số lớp học, số học sinh tham gia, số vắng mặt và link phòng họp.
  - **API 14 (`PUT /api/v1/practice/live-sessions/{sessionId}/recording`)**: Giáo viên cập nhật link video ghi hình buổi học trực tuyến (`RecordingUrl`), chặn cập nhật buổi học đã hủy (`400 Bad Request`), đánh dấu `IsRecorded = true` và chuyển trạng thái sang `COMPLETED`.
  - **API 15 (`PUT /api/v1/practice/live-sessions/{sessionId}/cancel`)**: Giáo viên / Giáo vụ hủy buổi học trực tuyến khi có việc đột xuất. Không xóa vật lý bản ghi trong CSDL (buổi học do Academic Manager tạo, bảo lưu lịch sử đào tạo), chuyển trạng thái sang `CANCELLED` kèm lý do hủy `reason`. Ngăn chặn toàn bộ thao tác Join phòng (API 11), điểm danh (API 12) và nộp video ghi hình (API 14) đối với buổi học đã hủy.
- **Cơ Sở Dữ Liệu & Tầng Lưu Trữ (Infrastructure & Persistence)**:
  - Bổ sung `GetSessionsForTeacherAsync`, `TeacherExistsAsync` và `GetEnrolledStudentCountByClassIdAsync` vào [`ILiveSessionRepository.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Application/Common/Interfaces/Repositories/ILiveSessionRepository.cs) và [`LiveSessionRepository.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Infrastructure/Persistence/Repositories/LiveSessionRepository.cs).
- **Kiểm Thử Toàn Hệ Thống & Vận Hành Thực Tế (Live End-to-End Test)**:
  - Solution `V-Eval-Practice_Service.sln` biên dịch sạch 100% (**0 Warning, 0 Error**).
  - Kiểm thử trực tiếp các kịch bản qua REST API & Swagger UI:
    1. **API 12 (Teacher Attendance)**: Giáo viên điểm danh 2 học sinh (`1111...` ATTENDED, `2222...` ABSENT) cho Session `2a196c82...` -> `200 OK`, `totalAttended: 1`, `totalAbsent: 1`. Điểm danh buổi học đã hủy -> `400 Bad Request`.
    2. **API 13 (Teacher Schedule)**: Giáo viên `99999999-9999-9999-9999-999999999999` tra cứu lịch dạy -> `200 OK`, trả về 5 buổi Live đầy đủ số liệu sĩ số lớp, số tham gia, số vắng mặt. Tra cứu giáo viên không tồn tại -> `404 Not Found` (`TeacherNotFound`).
    3. **API 14 (Update Recording)**: Cập nhật URL ghi hình -> `200 OK`, `isRecorded: true`, `status: "COMPLETED"`. Cập nhật buổi học đã hủy -> `400 Bad Request`.
    4. **API 15 (Cancel Session)**: Hủy buổi học `8ebfe3ee...` với lý do bận công tác -> `200 OK`, `status: "CANCELLED"`. Hủy lại -> `400 Bad Request`. Học sinh gọi API 11 Join phòng -> `400 Bad Request` ("Buổi học này đã bị hủy bỏ").
    5. **Xác thực dữ liệu thời gian thực (API 10)**: Học sinh tra cứu thời khóa biểu cá nhân thấy ngay trạng thái `ATTENDED`, link video recording và trạng thái `COMPLETED`.
- **Kế Hoạch & Phân Công Nhiệm Vụ Giai Đoạn 4 (Content Service)**:
  - Phân công nhân sự **ThinhTT** phụ trách 4 API Quản trị Ngân hàng câu hỏi gốc & Bộ đề Quiz củng cố chuyên đề: **API 16** (`POST /api/v1/content/questions`), **API 17** (`PUT /api/v1/content/questions/{id}`), **API 18** (`DELETE /api/v1/content/questions/{id}`), **API 19** (`POST /api/v1/content/exams/quiz`).
  - Đã cập nhật chi tiết bảng phân công và phạm vi nghiệp vụ trong `docs/core_flow_2_quy_hoach_lo_trinh_hoc_tap.md`, `Content Service/docs/daily.md` và `Content Service/docs/process.md`.
