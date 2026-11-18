# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - V-EVAL CAPSTONE SYSTEM REPO

## [18/11/2026] - Triệt Tiêu Hardcode Cổng Phụ Huynh (Nối CSDL Thật Trường Lớp & gRPC Danh Tính Giáo Viên) & Hoàn Thiện Trải Nghiệm Lịch Sử Bài Thi Đa Con

- **Triệt Tiêu Toàn Diện Dữ Liệu Hardcode Trong Parent Dashboard ([`GetParentDashboardQueryHandler.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Application/Features/Analytics/Queries/GetParentDashboard/GetParentDashboardQueryHandler.cs))**:
  - Xóa bỏ 100% dữ liệu mock/giả lập: *"Học viên V-Eval"*, *"Hệ thống Khảo thí V-Eval"*, *"Đại học"*, *"Cố vấn Học tập"*, *"1900 8889"*.
  - Truy vấn lớp học thật của con từ `v_eval_practice.ClassEnrollments` qua `IClassEnrollmentRepository` để lấy tên lớp (`enrolledClass.Name`, ví dụ: `"Lớp Bứt Phá Điểm 10 - Offline Quận 1"`).
  - Lấy trường THPT thật từ `student.SchoolName` (ví dụ: `"THPT Chuyên Lê Hồng Phong - TP.HCM"`).
  - Tự động suy luận ngành mục tiêu nguyện vọng 1 bám sát điểm số `TargetScore` thật của học sinh (ví dụ: `>= 900` điểm trỏ đến Khoa học Máy tính - ĐH Bách Khoa).
- **Liên Thông gRPC Danh Tính & Thông Tin Liên Hệ Giáo Viên Thật ([`identity.proto`](./grpc/identity.proto), [`IdentityGrpcService.cs`](./All%20Services/V-Eval-Identity_Service/V-Eval-Identity_Service.API/Services/IdentityGrpcService.cs), [`IdentityGrpcClient.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Infrastructure/GrpcClients/IdentityGrpcClient.cs))**:
  - Bổ sung RPC `GetTeacherProfile` vào `identity.proto` tiếp nhận `teacher_id`, trả về họ tên, số điện thoại, email và chuyên môn.
  - Hiện thực phương thức `GetTeacherProfile` trên Identity Service gRPC server (cổng 5156).
  - Practice Service từ `TeacherId` của lớp gọi sang Identity Service để lấy họ tên và số điện thoại thật của giáo viên phụ trách hiển thị trực tiếp lên Cổng Phụ huynh.
  - Mở rộng `GetParentStudents` đồng bộ `school_name` và `target_score` qua gRPC.
- **Gắn Bối Cảnh `studentId` Vào Lịch Sử Bài Thi Của Con & Hỗ Trợ Chuyển Đổi Đa Con ([`SubmissionHistoryView.jsx`](./All%20Services/V-Eval-Web_Client/src/components/diagnostic/SubmissionHistoryView.jsx), [`App.jsx`](./All%20Services/V-Eval-Web_Client/src/App.jsx))**:
  - Truyền `studentId`, `studentName`, `childrenList` và cờ `isParent` vào `SubmissionHistoryView`.
  - Tích hợp thanh chip chuyển đổi nhanh giữa các con, tự động làm mới lịch sử và biểu đồ năng lực theo từng con.
  - Tùy biến trải nghiệm phụ huynh: đổi tiêu đề, chuyển nhãn phương án trắc nghiệm thành *"Con đã chọn"*, phân lập lưu trữ và xóa bài thi an toàn.
- **Kiểm Thử & Nghiệm Thu Hệ Thống**:
  - `V-Eval-Practice_Service`: 20/20 unit tests Passed 100%.
  - `V-Eval-Identity_Service`: 5/5 unit tests Passed 100%.
  - `V-Eval-Web_Client`: `npm run build` thành công, 22/22 tests passed.
  - `grpc/identity.proto`: Đồng bộ 100% hợp đồng nhị phân giữa các service.
