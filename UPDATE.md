# Nhật Ký Cập Nhật (Update Log) - System Repo

## [28/09/2026] - Hoàn Tất Giai Đoạn 1 Core Flow 2 (Path Planning): Schema CSDL, EF Core 9, Seeding Đồ Thị DAG 12 Kỹ Năng & RPC GetSkillsTree

- **Khởi Tạo CSDL & Di Trú Supabase PostgreSQL (5 Bảng Cốt Lõi)**:
  - Khởi tạo bảng `v_eval_content."SkillPrerequisites"` lưu trữ đồ thị có hướng (DAG) giữa các kỹ năng khảo thí.
  - Khởi tạo bảng `v_eval_practice."LearningRoadmaps"` quản lý lộ trình học tập cá nhân hóa gắn liền với kết quả chẩn đoán Flow 1.
  - Khởi tạo bảng `v_eval_practice."RoadmapNodes"` quản lý từng chặng học (Milestones) tích hợp 3 thành phần (Video lý thuyết, Quiz củng cố, Lịch Live Q&A).
  - Khởi tạo và cập nhật bảng `v_eval_practice."LiveSessions"` (bổ sung `recording_url`, `is_recorded` cho Unhappy Case 3) và `v_eval_practice."LiveSessionAttendance"` (bổ sung `makeup_quiz_id`, `is_makeup_quiz_passed`).
- **Nâng Cấp V-Eval Content Service**:
  - Bổ sung entity [`SkillPrerequisite.cs`](./All%20Services/V-Eval-Content_Service/V-Eval-Content_Service.Domain/Entities/SkillPrerequisite.cs) với khóa chính phức hợp `(skill_id, prerequisite_id)`.
  - Bổ sung navigation properties `Prerequisites` và `DependentSkills` trong [`Skill.cs`](./All%20Services/V-Eval-Content_Service/V-Eval-Content_Service.Domain/Entities/Skill.cs).
  - Đăng ký `DbSet<SkillPrerequisite>` và cấu hình Fluent API trong [`ContentDbContext.cs`](./All%20Services/V-Eval-Content_Service/V-Eval-Content_Service.Infrastructure/Persistence/ContentDbContext.cs) và [`IContentDbContext.cs`](./All%20Services/V-Eval-Content_Service/V-Eval-Content_Service.Application/Common/Interfaces/IContentDbContext.cs).
  - Khởi tạo seeder [`SkillPrerequisiteSeeder.cs`](./All%20Services/V-Eval-Content_Service/V-Eval-Content_Service.Infrastructure/Persistence/Seeds/SkillPrerequisiteSeeder.cs): tự động nạp 4 Miền Năng Lực, 12 Kỹ Năng Chuẩn ĐGNL ĐHQG-HCM kèm trọng số và 9 cung quan hệ tiên quyết không chu trình.
  - Hiện thực phương thức RPC `GetSkillsTree` trong [`ContentGrpcService.cs`](./All%20Services/V-Eval-Content_Service/V-Eval-Content_Service.API/Services/ContentGrpcService.cs) theo hợp đồng `content.proto`.
- **Nâng Cấp V-Eval Practice Service**:
  - Tạo 4 thực thể Domain mới: [`LearningRoadmap.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Domain/Entities/LearningRoadmap.cs), [`RoadmapNode.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Domain/Entities/RoadmapNode.cs), [`LiveSession.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Domain/Entities/LiveSession.cs), [`LiveSessionAttendance.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Domain/Entities/LiveSessionAttendance.cs).
  - Đăng ký 4 `DbSet` và cấu hình Fluent API đầy đủ quan hệ Cascade/Restrict theo schema `v_eval_practice` trong [`PracticeDbContext.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Infrastructure/Persistence/PracticeDbContext.cs).
- **Kiểm Thử Biên Dịch & Vận Hành Toàn Diện**:
  - Cả hai solution `V-Eval-Content_Service.sln` và `V-Eval-Practice_Service.sln` biên dịch sạch 100% (**0 Warning, 0 Error**).
  - Dữ liệu 12 kỹ năng chuẩn và 9 cung DAG được đồng bộ và xác nhận trực tiếp trên Supabase PostgreSQL.
