# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [03/11/2026] - Nâng Cấp Master Database Schema V5.0 & Hoàn Thành Toàn Diện Phân Hệ Thanh Toán PayOS (VietQR) Cả Backend & Frontend Kèm Kích Hoạt Lộ Trình PLAR Nguyên Khối (ACID Transaction)

- **Cập Nhật Toàn Diện Master DDL (`docs/SQL/SQL.sql`)**:
  - Hợp nhất và chuẩn hóa 51 bảng dữ liệu trên 5 Bounded Context Schemas theo chuẩn kiến trúc Microservices Database-per-Service:
    1. `v_eval_identity` (12 bảng): Chuẩn hóa định danh, phân quyền RBAC và phân công môn giảng dạy (`TeacherSubjects`).
    2. `v_eval_content` (8 bảng): Khung năng lực, kỹ năng vi mô (`exam_weight_pct`), học liệu và ngân hàng đề thi.
    3. `v_eval_enrollment` (5 bảng): Quản lý khóa học, chuẩn đầu ra, ghi danh và hạ tầng thanh toán PayOS (VietQR) với `order_code`, `checkout_url` cùng bảng nhật ký giao dịch `PaymentTransactions`.
    4. `v_eval_practice` (19 bảng): Vận hành lớp học offline, nhóm vi mô 3–5 HS, liên kết đề thi chốt chặng `daily_exam_id` vào `RoadmapNodes`, phân tách riêng tiến trình chu trình 4 bước PLAR (`StageProgress`), mô hình BKT/SM-2 và bộ đếm chuyên cần streak (`StudentDailyActivities`).
    5. `v_eval_outcome` (7 bảng): Quản lý toàn diện nguyện vọng đại học, điểm thi ĐGNL thật, kết quả xét tuyển và báo cáo tăng điểm `CohortOutcomeSummaries`.
  - Thực thi triệt để nguyên tắc phân rã Microservices: Chỉ tạo ràng buộc khóa ngoại vật lý (Physical FK) trong nội bộ từng schema; toàn bộ liên kết xuyên schema được định nghĩa dưới dạng khóa ngoại logic (`FK*`).
  - Phủ kín 60+ chỉ mục Index tối ưu hóa truy vấn hiệu năng cao và bổ sung 15+ mệnh đề CHECK bảo vệ toàn vẹn miền dữ liệu tại tầng DB engine.

- **Kế Hoạch Kỹ Thuật Core Flow (`docs_noi_bo/core_flow/ke_hoach_trien_khai_payment_payos_va_kich_hoat_lo_trinh_plar.md`)**:
  - Thực thể hóa sơ đồ ERD tinh gọn 21 thực thể trung tâm xoay quanh `User`, phân định tường minh vai trò của `RoadmapNode`, `StageProgress` và `DailyActivity`.
  - Thiết kế quy trình thanh toán PayOS học tập từ dự án mẫu `F:\EXE101\ShootMatch` kết hợp mô hình ACID Transaction.

- **Hiện Thực Hóa Triệt Để Mã Nguồn Phân Hệ Backend Trong Practice Service (`V-Eval-Practice_Service`)**:
  - **Domain & Persistence**: Bổ sung các thực thể `Payment`, `PaymentTransaction`, `CourseRegistration`, `Course` thuộc schema `v_eval_enrollment`, cấu hình đầy đủ mapping EF Core trong `PracticeDbContext`.
  - **Application (CQRS)**:
    - Xây dựng giao diện trừu tượng `IExecutionTransaction` quản lý giao dịch CSDL nguyên khối.
    - `CreatePaymentLinkCommand`: Sinh `orderCode` an toàn, chuẩn hóa mô tả chuyển khoản <= 25 ký tự, tích hợp tạo link PayOS VietQR.
    - `ProcessPayOsWebhookCommand`: Xác thực chữ ký HMAC-SHA512, áp dụng Idempotency check, cập nhật thanh toán thành công, tự động kích hoạt đăng ký `CourseRegistration`, xếp lớp `ClassEnrollment`, tự động tạo `LearningRoadmap` chu trình 4 bước PLAR (chặng 1 mở khóa `IN_PROGRESS`), ghi vết kiểm toán `PaymentTransactions` - tất cả trong 1 Database Transaction duy nhất.
    - Truy vấn tra cứu trạng thái `GetPaymentStatusQuery` và lịch sử kiểm toán `GetPaymentTransactionsQuery`.
  - **Infrastructure & API**:
    - Hiện thực `PayOsPaymentService` dựa trên NuGet `payOS` 2.1.0 và `PaymentRepository`.
    - Tạo `PaymentsController` tại `/api/practice/payments` hỗ trợ tạo link, nhận webhook, tra cứu trạng thái và audit logs.
  - **Kiểm Thử Đơn Vị**:
    - Viết 8 Unit Tests chuyên sâu (`CreatePaymentLinkCommandHandlerTests`, `ProcessPayOsWebhookCommandHandlerTests`), đạt **12/12 tests PASS 100%**.

- **Hiện Thực Hóa Toàn Diện Giao Diện Frontend Trong Web Client (`V-Eval-Web_Client`)**:
  - **Dịch Vụ Tầng Web (`src/services/paymentService.js`)**: Kết nối YARP Gateway (`:5212`) gọi Practice Service (`:5261`), hỗ trợ tạo link PayOS VietQR, polling kiểm tra trạng thái và lịch sử kiểm toán kèm cơ chế fallback an toàn.
  - **Modal Thanh Toán PayOS VietQR (`src/components/modals/PayOsCheckoutModal.jsx`)**: Giao diện ngân hàng hiện đại, polling mỗi 3 giây, nút chuyển hướng cổng PayOS, nút giả lập Instant Verify và hiệu ứng pháo hoa mở khóa chặng 1 PLAR.
  - **Màn Hình Quản Lý Học Phí (`src/components/payment/TuitionPaymentView.jsx`)**: Giới thiệu 3 gói học thích ứng ĐGNL (Fast-Track Sprint, Standard Adaptive, Intensive Plus) và bảng đối soát lịch sử giao dịch.
  - **Tích Hợp Cổng Phụ Huynh & Sidebar**: Banner thanh toán học phí trên `ParentDashboardView.jsx`, tab điều hướng `Học phí & Gói học` trên `Sidebar.jsx` và cập nhật định tuyến trong `App.jsx`.
  - **Kiểm Thử & Đóng Gói**: Bổ sung `tests/paymentService.test.js` (**6/6 tests PASS 100%**), `npm run build` thành công trong 1.40s.

- **Đồng Bộ Cấu Hình PayOS Thực Tế & Khởi Chạy Dịch Vụ Định Danh Identity Service**:
  - Trích xuất và cấu hình thông tin PayOS thật (Client ID, API Key, Checksum Key) từ dự án tham khảo `F:\EXE101\ShootMatch` vào Practice Service, hoàn tất tạo mã VietQR thực trên `pay.payos.vn`.
  - Khắc phục lỗi đăng ký tài khoản (UC 01) trong Identity Service: Bổ sung trường `CampusId` vào `RegisterUserCommand`, xử lý gán cơ sở mặc định và kích hoạt profile phụ huynh `Parents`, sửa triệt để lỗi 502/500 qua Gateway.
