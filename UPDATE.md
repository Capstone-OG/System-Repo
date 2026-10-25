# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [25/10/2026] - Chuyển Đổi Mô Hình Offline Cohort: Dọn Sạch LiveSessions, Đồng Bộ CSDL Supabase 47 Bảng & Chuẩn Hóa ERD 3 Trang Phương Án C (Hybrid Best-Practice)

- **Dọn Sạch Hoàn Toàn Tàn Dư LiveSessions Khỏi Mọi Thành Phần**:
  - Gỡ bỏ triệt để cột `FK live_session_id : uuid` khỏi thực thể `RoadmapNodes` trên cả Trang 1 và Trang 3.
  - Làm sạch 100% khối mã nguồn PlantUML nội tại (`plantUmlData`) của `puml_root_wrapper`: gỡ bỏ các định nghĩa thực thể cũ `LiveSessions`, `LiveSessionAttendance` và 5 quan hệ phụ thuộc.
  - Đổi tên Package 5 từ `5. Lớp học, Live & Nhóm vi mô` thành `5. Lớp học & Nhóm vi mô (Classes & Cohorts)`.

- **Đồng Bộ Kiến Trúc & CSDL Supabase PostgreSQL Sang Mô Hình Offline Cohort (47 Thực Thể)**:
  - Phân vùng 4 schemas sạch sẽ, loại bỏ hoàn toàn các bảng streaming trực tuyến cũ (`LiveSessions` & `LiveSessionAttendance`):
    1. `v_eval_identity` (13 bảng): `Campuses`, `Roles`, `Users`, `UserRoles`, `RefreshTokens`, `OtpVerifications`, `Students`, `Parents`, `ParentStudentRelations`, `Teachers`, `AcademicManagers`, `AcademicDirectors`, `Administrators`.
    2. `v_eval_content` (8 bảng): `CompetencyDomains`, `Skills`, `SkillPrerequisites`, `Materials`, `Passages`, `Questions`, `MockExams`, `ExamQuestions`.
    3. `v_eval_practice` (19 bảng): `Classes`, `ClassEnrollments`, `ClassGroups`, `ClassGroupMembers`, `ExamSubmissions`, `SubmissionAnswers`, `ProctoringSnapshots`, `LearningProfiles`, `LearningRoadmaps`, `RoadmapNodes`, `StageProgress`, `AdaptiveQuizAttempts`, `MistakeNotebooks`, `ScorePredictions`, `SystemAlerts`, `ClassSkillHeatmaps`, `ClassHeatmapSummaries`, `StudentDailyActivities`, `StudentReadinessMetrics`.
    4. `v_eval_ai` (7 bảng): `KnowledgeSources`, `KnowledgeVectorChunks`, `archetype_patterns`, `pattern_exemplars`, `pattern_traps`, `novel_pattern_proposals`, `ai_tutor_interaction_logs`.
  - Cập nhật [`docs/SQL/SQL.sql`](./docs/SQL/SQL.sql) khớp 100% với CSDL Supabase live (di chuyển `ClassGroups` và `ClassGroupMembers` vào schema `v_eval_practice`, bổ sung chỉ mục B-Tree hiệu năng cao `idx_class_groups_class`, `idx_class_group_members_group`, `idx_class_group_members_student`).

- **Dọn Sạch Codebase C# Microservice (`V-Eval-Practice_Service`)**:
  - Gỡ bỏ hoàn toàn các entity, repository, query/command handlers liên quan đến `LiveSessions` và `TriggerHeatmapLiveSession`.
  - Đóng gói chặng học `RoadmapNodes` theo mô hình 2 thành phần tinh gọn (Lý thuyết + Quiz củng cố).
  - Biên dịch thành công toàn bộ solution `V-Eval-Practice_Service.sln` (**0 Error, 0 Warning**).

- **Triển Khai Phương Án C (Hybrid Best-Practice) & Đi Dây Manhattan Tối Ưu Cho [Capstone.drawio](./docs/SQL/Capstone.drawio)**:
  - **Phân định trực quan 2 loại đường nối**:
    - **Nét liền (Solid Line, 42 quan hệ)**: Đại diện cho Khóa ngoại vật lý nội bộ Service (Physical FK) có ràng buộc `REFERENCES` trong PostgreSQL (`strokeColor=#181818; strokeWidth=1.4`).
    - **Nét đứt (Dashed Line, 32 quan hệ)**: Đại diện cho Tham chiếu logic giữa các Bounded Contexts qua gRPC / API (Logical Reference), kiểm soát toàn vẹn ở tầng ứng dụng (`dashed=1; dashPattern=8 5; strokeColor=#4B5563; strokeWidth=1.4`).
  - **Khắc phục triệt để hiện tượng dây đè lên bảng & cắt dây rối mắt (Zero Collision Guarantee)**:
    - **100% Không dây đè lên bảng (0 Collisions trên cả 3 trang)**: Kiểm thử hình học tự động (`seg_intersects_rect`) chứng minh 0/74 đường nối chạm vào bất kỳ thân hoặc tiêu đề của 47 bảng trên toàn bộ 3 trang (`Trang-1`: 0 va chạm, `Trang-2`: 0 va chạm, `Trang-3`: 0 va chạm). Mọi dây nối xuất phát/kết thúc tại mép bảng (`exitX/Y`, `entryX/Y`) và di chuyển độc quyền qua các hành lang kênh xa lộ (highways/channels).
    - **Tối thiểu hóa giao cắt dây (Minimal Crossings & Arc Jump Bridges)**: Mọi điểm giao cắt trực giao vuông góc đều trang bị cầu nhảy vòng cung `jumpStyle=arc; jumpSize=6` rõ ràng, mạch lạc, phân định minh bạch Physical FK (nét liền) vs Logical Ref (nét đứt).
    - **100% Trực giao song song trục Ox/Oy**: Góc bẻ vuông chuẩn xác `90°` dạng sấm sét bậc thang (Stepped Orthogonal / Manhattan Routing), loại bỏ hoàn toàn các đường chéo.
  - **Khôi phục & Hoàn thiện cấu trúc đầy đủ 3 trang sơ đồ chuẩn**:
    - **Trang 1 (`Trang-1`)**: Bounded Context Clustered ERD gom 9 phân vùng Bounded Contexts, hiển thị chi tiết mọi cột thuộc tính (PK, FK, kiểu dữ liệu), đi dây hành lang ngoại vi an toàn tuyệt đối (0 va chạm).
    - **Trang 2 (`Trang-2`)**: Sơ đồ khái niệm tinh gọn (Conceptual Entity ERD), neo mép viền chuẩn xác (`0.0, 1.0`), loại bỏ triệt để lỗi dây xuyên tâm bảng, đi dây hành lang thông thoáng (0 va chạm).
    - **Trang 3 (`Trang-3`)**: Mô hình trải phẳng toàn diện (Flat Full-Detail Physical & Logical ERD) gồm 47 bảng đầy đủ thuộc tính chi tiết, bố trí 12 cột rãnh thông thoáng, hệ thống xa lộ đỉnh (North Skyway) và xa lộ đáy (South Highway) tối ưu (0 va chạm).

- **Chuẩn Hóa Ràng Buộc Cơ Sở & Hoàn Thiện Báo Cáo Kiểm Duyệt 75 Mối Quan Hệ**:
  - Cập nhật [`docs/SQL/SQL.sql`](./docs/SQL/SQL.sql) & Codebase C# `V-Eval-Identity_Service`: Chuyển `Students.campus_id` thành `NOT NULL REFERENCES Campuses(campus_id) ON DELETE RESTRICT`; bổ sung `AcademicDirectors.campus_id` (`NOT NULL REFERENCES Campuses(campus_id) ON DELETE RESTRICT`) gắn Giám đốc đào tạo trực tiếp phụ trách cơ sở.
  - Biên dịch thành công 100% cả `V-Eval-Identity_Service.sln` và `V-Eval-Practice_Service.sln` (**0 Error, 0 Warning**).
  - Biên soạn và nâng cấp tài liệu kiểm duyệt chuyên sâu [`docs/SQL/Tong_Quan_Chi_Tiet_Moi_Quan_He_Entities.md`](./docs/SQL/Tong_Quan_Chi_Tiet_Moi_Quan_He_Entities.md): Tổng hợp toàn diện **75 mối quan hệ** (43 Physical FKs + 32 Logical Refs), chuẩn hóa bản số bắt buộc `1..N` cho phụ huynh liên kết con em trong `ParentStudentRelations`, phân tích sâu tương quan hai chiều và ý nghĩa nghiệp vụ sư phạm kèm Ma trận Kiểm duyệt (Audit Checklist STT 1–75).
  - Cập nhật [`docs/SQL/Mo_Ta_Thiet_Ke_ERD_Concept.md`](./docs/SQL/Mo_Ta_Thiet_Ke_ERD_Concept.md) phản ánh chuẩn Schema V4.1 và cấu trúc đầy đủ 3 trang.


