# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [18/10/2026] - Hoàn Tất Giai Đoạn 1 & 2 Core Flow 5: CSDL & Động Cơ Hybrid Aggregation Engine

- **Giai Đoạn 1: Triển Khai 4 Thực Thể CSDL Mới Cho Core Flow 5 (`V-Eval-Practice_Service`)**:
  - `ClassSkillHeatmap`: Lưu trữ từng ô ma trận nhiệt $P(L_t)$ cho học sinh và kỹ năng.
  - `ClassHeatmapSummary`: Tổng hợp thống kê cột kỹ năng toàn lớp (Mean, StdDev, StrugglingRate, Bimodal Flag, AlertStatus).
  - `StudentDailyActivity`: Ghi nhận chuyên cần và thời gian học tập hằng ngày theo chuẩn Active Study Day (Streak & Streak Freeze).
  - `StudentReadinessMetric`: Chỉ số sẵn sàng thi tổng hợp $R_{\text{exam}}$ cho Cổng Phụ huynh & Học sinh.
  - Cấu hình Fluent API trong `PracticeDbContext`, tự động hóa DDL khởi tạo trong `Program.cs` và file di trú `docs/SQL/SQL_Migration_Flow5_Analytics.sql`.
- **Giai Đoạn 2: Xây Dựng Động Cơ Hybrid Aggregation Engine & Background Worker 15 Phút**:
  - Xây dựng 2 repositories mới `ClassHeatmapRepository` và `StudentActivityRepository` xử lý truy vấn ma trận nhiệt và chuỗi chuyên cần (Streak).
  - Xây dựng `ClassHeatmapCacheService` đệm bộ nhớ `IMemoryCache` (< 300ms) kèm cơ chế dọn cache cục bộ theo lớp `InvalidateClassHeatmapAsync`.
  - Xây dựng `ClassHeatmapAggregatorService` tính toán khảo thí chuẩn hóa (Mean, StdDev, StrugglingRate, Bimodal Flag) và chỉ số sẵn sàng thi $R_{\text{exam}} = 0.50 S_\theta + 0.35 C_{\text{BKT}} + 0.15 F_{\text{consistency}}$.
  - Xây dựng `ClassHeatmapAggregationWorker : BackgroundService` chạy định kỳ 15 phút quét toàn bộ các lớp `ACTIVE`.
  - Tích hợp Write-Through O(1) và ghi nhận chuyên cần trực tiếp vào `SubmitAnswerCommandHandler`, `SubmitMockExamCommandHandler`, và `TrackVideoCommandHandler`.
- **Kiểm Thử & Biên Dịch**:
  - Biên dịch `dotnet build` toàn bộ solution `V-Eval-Practice_Service.sln` thành công 100% (**0 Warning, 0 Error**).
- **Tài Liệu Kỹ Thuật Hệ Thống**:
  - Cập nhật đồng bộ bộ 3 tài liệu chuẩn `docs/daily.md`, `docs/process.md` và `docs/architecture_acceptance.md` của `V-Eval-Practice_Service`.
