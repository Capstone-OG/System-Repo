# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [03/11/2026] - Nâng Cấp Master Database Schema V5.0 & Bản Kế Hoạch Kỹ Thuật Core Flow Thanh Toán PayOS - PLAR

- **Cập Nhật Toàn Diện Master DDL (`docs/SQL/SQL.sql`)**:
  - Hợp nhất và chuẩn hóa 51 bảng dữ liệu trên 5 Bounded Context Schemas theo chuẩn kiến trúc Microservices Database-per-Service:
    1. `v_eval_identity` (12 bảng): Chuẩn hóa định danh, phân quyền RBAC và phân công môn giảng dạy (`TeacherSubjects`).
    2. `v_eval_content` (8 bảng): Khung năng lực, kỹ năng vi mô (`exam_weight_pct`), học liệu và ngân hàng đề thi.
    3. `v_eval_enrollment` (5 bảng): Quản lý khóa học, chuẩn đầu ra, ghi danh và hạ tầng thanh toán PayOS (VietQR) với `order_code`, `checkout_url` cùng bảng nhật ký giao dịch `PaymentTransactions`.
    4. `v_eval_practice` (19 bảng): Vận hành lớp học offline, nhóm vi mô 3–5 HS, liên kết đề thi chốt chặng `daily_exam_id` vào `RoadmapNodes`, phân tách riêng tiến trình chu trình 4 bước PLAR (`StageProgress`), mô hình BKT/SM-2 và bộ đếm chuyên cần streak (`StudentDailyActivities`).
    5. `v_eval_outcome` (7 bảng): Quản lý toàn diện nguyện vọng đại học, điểm thi ĐGNL thật, kết quả xét tuyển và báo cáo tăng điểm `CohortOutcomeSummaries`.
  - Thực thi triệt để nguyên tắc phân rã Microservices: Chỉ tạo ràng buộc khóa ngoại vật lý (Physical FK) trong nội bộ từng schema; toàn bộ liên kết xuyên schema được định nghĩa dưới dạng khóa ngoại logic (`FK*`).
  - Phủ kín 60+ chỉ mục Index tối ưu hóa truy vấn hiệu năng cao và bổ sung 15+ mệnh đề CHECK bảo vệ toàn vẹn miền dữ liệu tại tầng DB engine.
- **Hoàn Thiện Bản Kế Hoạch Kỹ Thuật Core Flow Nội Bộ (`docs_noi_bo/core_flow/ke_hoach_trien_khai_payment_payos_va_kich_hoat_lo_trinh_plar.md`)**:
  - Thực thể hóa sơ đồ ERD tinh gọn 21 thực thể trung tâm xoay quanh `User`, phân định tường minh vai trò của `RoadmapNode`, `StageProgress` và `DailyActivity`.
  - Đặc tả chi tiết luồng thanh toán PayOS học tập từ dự án mẫu `F:\EXE101\ShootMatch`: cấu hình `appsettings.json`, sinh `orderCode` an toàn, kiểm soát `description <= 25 ký tự`.
  - Thiết kế khối Database Transaction nguyên khối (ACID) cho Webhook IPN: xác thực chữ ký HMAC ➔ Idempotency Guard ➔ Kích hoạt đơn đăng ký ➔ Tự động sinh `LearningRoadmaps` và mở khóa chặng 1 `RoadmapNodes`.
  - Đặc tả 4 bài kiểm thử trọng tâm (Happy Path, Idempotency, Rollback Safety, Tampered Signature) với bộ thư viện chuẩn `xUnit 2.9.2`, `Moq 4.20.72` và `FluentAssertions 7.2.0`.
