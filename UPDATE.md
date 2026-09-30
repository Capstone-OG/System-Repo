# Nhật Ký Cập Nhật (Update Log) - System Repo

## [01/10/2026] - Nâng Cấp Core Flow 2 (Bước 1): Mở Rộng Mô Hình Thực Thể Class & Di Trú CSDL Phục Vụ Lớp Học Chuyên Đề (Thematic Cohort)

- **Triển Khai Bước 1 Kế Hoạch Nâng Cấp Core Flow 2 (Lớp Chuyên Đề K-Means) Trong Practice Service**:
  - **Mở Rộng Mô Hình Thực Thể [`Class.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Domain/Entities/Class.cs)**: Bổ sung 4 trường dữ liệu mới:
    - `ClassType` (`int`): `0` = Lớp hành chính theo năng lực tổng thể $\theta_0$, `1` = Lớp chuyên đề theo cụm lỗ hổng K-Means.
    - `DomainId` (`Guid?`): Khóa ngoại định danh miền kiến thức chuyên đề.
    - `DomainCode` (`string?`): Mã định danh chuẩn (`DOM_LANG`, `DOM_MATH`, `DOM_NAT_SCI`, `DOM_SOC_SCI`).
    - `ClusterIndex` (`int?`): Chỉ số cụm K-Means tương ứng tạo ra lớp chuyên đề này.
  - **Ánh Xạ Fluent API Trong [`PracticeDbContext.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Infrastructure/Persistence/PracticeDbContext.cs)**: Cấu hình ánh xạ cột `class_type`, `domain_id`, `domain_code`, `cluster_index` vào bảng `Classes` thuộc schema `v_eval_practice`.
  - **Di Trú Database Migration & Xác Thực Schema PostgreSQL**:
    - Áp dụng migration `20260930184119_AddThematicCohortFields` vào CSDL Supabase PostgreSQL.
    - Đã xác thực trực tiếp schema bảng `v_eval_practice.Classes` có đầy đủ 4 cột mới: `class_type (integer)`, `cluster_index (integer)`, `domain_code (character varying)`, `domain_id (uuid)`.
- **Kiểm Thử Toàn Diện & Biên Dịch Solution**:
  - Solution `V-Eval-Practice_Service.sln` biên dịch sạch 100% (**0 Warning, 0 Error**).
  - Duy trì tính toàn vẹn 100% cho toàn bộ 15 API của Core Flow 1 và Core Flow 2 hiện hữu.
