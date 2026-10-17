# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [18/10/2026] - Hoàn Tất Giai Đoạn 1 Core Flow 5: Thực Thể CSDL & Cấu Hình Fluent API Practice Service

- **Triển Khai 4 Thực Thể CSDL Mới Cho Core Flow 5 (`V-Eval-Practice_Service`)**:
  - `ClassSkillHeatmap`: Lưu trữ từng ô ma trận nhiệt $P(L_t)$ cho học sinh và kỹ năng.
  - `ClassHeatmapSummary`: Tổng hợp thống kê cột kỹ năng toàn lớp (Mean, StdDev, StrugglingRate, Bimodal Flag, AlertStatus).
  - `StudentDailyActivity`: Ghi nhận chuyên cần và thời gian học tập hằng ngày theo chuẩn Active Study Day (Streak & Streak Freeze).
  - `StudentReadinessMetric`: Chỉ số sẵn sàng thi tổng hợp $R_{\text{exam}}$ cho Cổng Phụ huynh & Học sinh.
- **Cấu Hình Tầng Dữ Liệu & Hạ Tầng (`PracticeDbContext.cs`)**:
  - Đăng ký 4 `DbSet` trong schema `v_eval_practice`.
  - Cấu hình Fluent API: Khóa chính, ràng buộc unique index (`uq_class_student_skill`, `uq_class_skill_summary`, `uq_student_activity_date`, `idx_readiness_student_id`) và quan hệ cascade delete với bảng `Classes`.
- **Tự Động Hóa DDL Khởi Tạo Database (`Program.cs` & `docs/SQL`)**:
  - Tích hợp câu lệnh `CREATE TABLE IF NOT EXISTS` và chỉ mục tự động khởi tạo khi service khởi động trong `Program.cs`.
  - Tạo script DDL độc lập `./docs/SQL/SQL_Migration_Flow5_Analytics.sql`.
- **Kiểm Thử & Biên Dịch**:
  - Biên dịch `dotnet build` toàn bộ solution `V-Eval-Practice_Service.sln` thành công 100% (**0 Warning, 0 Error**).
- **Tài Liệu Kỹ Thuật Hệ Thống**:
  - Cập nhật đồng bộ bộ 3 tài liệu chuẩn `docs/daily.md`, `docs/process.md` và `docs/architecture_acceptance.md` của `V-Eval-Practice_Service`.
