# Nhật Ký Cập Nhật (Update Log) - System Repo

## [29/09/2026] - Triển Khai Hoàn Thiện Giai Đoạn 3: Quản Lý Buổi Học Live Q&A, Phân Công Giáo Viên, Thời Khóa Biểu & Điểm Danh Trực Tuyến (APIs 8, 9, 10, 11)

- **Triển Khai Hoàn Tất Giai Đoạn 3 (Phân Hệ Live Q&A, Phân Công Lớp & Điểm Danh) Trong Practice Service**:
  - **API 8 (`POST /api/v1/practice/live-sessions`)**: Quản trị viên/Điều phối cơ sở tạo lịch buổi học Live Q&A giải đáp thắc mắc, tự động phân công giáo viên theo lớp học (`Classes`) và tạo link phòng học trực tuyến chuẩn hóa.
  - **API 9 (`PUT /api/v1/practice/classes/{classId}/assign-teacher`)**: Quản trị viên cơ sở phân công hoặc điều chuyển giáo viên phụ trách lớp học cơ sở (`TeacherId`, `AssignedBy`, `AssignedAt`).
  - **API 10 (`GET /api/v1/practice/live-sessions/my-schedule`)**: Học sinh tra cứu toàn bộ thời khóa biểu các buổi Live Q&A của lớp học cơ sở được phân bổ (`EnrolledClassId`), nhận diện trạng thái điểm danh cá nhân (`ATTENDED`, `ABSENT`, `NOT_ATTENDED`), link video ghi hình xem lại và cờ trạng thái bài Quiz bù.
  - **API 11 (`POST /api/v1/practice/live-sessions/{sessionId}/join`)**: Học sinh tham gia phòng học trực tuyến, hệ thống cung cấp link phòng họp (`MeetingUrl`) và ghi nhận thời điểm vào lớp `JoinedAt = UtcNow`. Quyền hạn điểm danh chuyên cần (`ATTENDED` hoặc `ABSENT`) được bảo lưu trọn vẹn cho Giảng viên tại API 12.
- **Cơ Sở Dữ Liệu & Tầng Lưu Trữ (Infrastructure & Persistence)**:
  - Khởi tạo Repository [`ILiveSessionRepository.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Application/Common/Interfaces/Repositories/ILiveSessionRepository.cs) và [`LiveSessionRepository.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Infrastructure/Persistence/Repositories/LiveSessionRepository.cs) quản lý thực thể `LiveSessions` và `LiveSessionAttendance` trên schema `v_eval_practice`.
  - Đăng ký DI Scoped trong `DependencyInjection.cs`.
- **Kiểm Thử Toàn Hệ Thống & Vận Hành Thực Tế (Live End-to-End Test)**:
  - Solution `V-Eval-Practice_Service.sln` biên dịch sạch 100% (**0 Warning, 0 Error**).
  - Kiểm thử trực tiếp 5 kịch bản qua REST API & gRPC:
    1. **API 9 (Assign Teacher)**: Phân công giáo viên `99999999-9999-9999-9999-999999999999` cho lớp cơ sở `33333333-3333-3333-3333-333333333333` -> `200 OK`.
    2. **API 8 (Create Live Session)**: Tạo lịch buổi học Live Q&A -> `201 Created`, kế thừa thông tin giáo viên phụ trách chuẩn xác.
    3. **API 10 (Get My Live Schedule)**: Học sinh `11111111-1111-1111-1111-111111111111` tra cứu lịch học -> `200 OK`, hiển thị 4 buổi Live kèm trạng thái điểm danh riêng biệt (`ABSENT`, `ATTENDED`, `NOT_ATTENDED`).
    4. **API 11 (Join Live Session)**: Học sinh tham gia buổi Live -> `200 OK`, nhận URL phòng học, ghi nhận thời điểm vào lớp `JoinedAt`, bảo lưu trạng thái chờ Giảng viên đánh giá chuyên cần tại API 12.
    5. **Xác thực dữ liệu thời gian thực**: Tra cứu lại API 10 chứng minh dữ liệu đồng bộ và chính xác.
