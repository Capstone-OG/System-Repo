# Nhật Ký Cập Nhật (Update Log) - System Repo

## [09/10/2026] - Nâng Cấp Mô Hình Giảng Dạy Offline: Giới Hạn Sĩ Số Lớp 20 Người, Đánh Số Thứ Tự Tăng Dần & Phân Nhóm Học Tập Vi Mô (3 - 5 Học Sinh)

- **Giới Hạn Sĩ Số Lớp 20 Học Sinh & Tự Động Đánh Số Thứ Tự Lớp Tăng Dần (`Practice Service`)**:
  - Ràng buộc trần sĩ số tối đa `MaxClassCapacity = 20` trong `ClassEnrollmentRepository.EnrollStudentAsync`.
  - Tự động kiểm tra số lượng học sinh đang `ENROLLED` trong từng lớp active tại cơ sở. Khi các lớp hiện tại đã đủ 20 học sinh (hoặc chưa có lớp), hệ thống tự động sinh lớp mới với số thứ tự tăng dần chuẩn hóa (`01, 02...`, ví dụ: `"Lớp Nền tảng (Foundation) 01 - Cơ sở Quận 9"`, `"Lớp Nền tảng (Foundation) 02 - Cơ sở Quận 9"`).
- **Mô Hình Thực Thể & CSDL Nhóm Học Tập Vi Mô (Micro Study Groups: 3 - 5 Bạn)**:
  - Bổ sung thực thể Domain `ClassGroup.cs` và `ClassGroupMember.cs`, đăng ký `DbSet` trong `PracticeDbContext.cs`.
  - Bổ sung bootstrap DDL SQL trong `Program.cs` khởi tạo bảng `"ClassGroups"` và `"ClassGroupMembers"` trên Supabase PostgreSQL.
  - Xây dựng Repository `IClassGroupRepository` và `ClassGroupRepository`, đăng ký Scoped DI.
- **Động Cơ Phân Cụm Vi Mô Đồng Nhất (`ClassMicroClusterer.cs`)**:
  - Hiện thực thuật toán gom cụm đồng nhất (Homogeneous Capacitated Clustering) đảm bảo nghiêm ngặt sĩ số mỗi nhóm vi mô từ 3 đến 5 học sinh (`3 <= Size <= 5`).
  - Tự động phát hiện các kỹ năng yếu chung (`MasteryScore < 0.60`), xác định chủ đề trọng tâm `FocusArea`, sinh tên nhóm sư phạm và gợi ý phiếu bài tập vi mô thích ứng (`RecommendedWorksheetTitle`).
- **Bộ 3 REST APIs Nhóm Học Tập Vi Mô Trên `ClassesController.cs`**:
  - `POST /api/practice/classes/{classId}/micro-groups/auto-partition`: Tự động chia học sinh trong lớp thành các nhóm 3 - 5 bạn theo lỗ hổng kiến thức.
  - `GET /api/practice/classes/{classId}/micro-groups`: Lấy danh sách nhóm vi mô, thành viên từng nhóm và đề luyện tập đã phân phối.
  - `POST /api/practice/classes/{classId}/micro-groups/{groupId}/assign-worksheet`: Phân phối đề luyện tập / phiếu bài tập vi mô thích ứng trực tiếp cho nhóm.
- **Đồng Bộ Tầng Dịch Vụ Phía Frontend (`Web Client`)**:
  - Cập nhật `src/services/practiceService.js` bổ sung các hàm `autoClusterClasses`, `autoPartitionMicroGroups`, `getClassMicroGroups`, `assignGroupWorksheet`.
- **Kiểm Thử Toàn Diện & Trạng Thái Hệ Thống**:
  - Toàn bộ Solution `V-Eval-Practice_Service.sln` biên dịch sạch 100% (**0 Warning, 0 Error**).
  - Frontend `Web Client` build Vite thành công 100% (**0 Error, 0 Warning**).
  - Cấu hình `docker compose config` hợp lệ 100%.
