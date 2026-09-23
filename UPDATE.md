# Nhật Ký Cập Nhật (Update Log) - System Repo

## [23/09/2026] - Tái Cấu Trúc CSDL SQL Schema V2 Phân Chia 5 Microservice Schemas (`v_eval_*`) & Migration An Toàn Supabase
- **Tái Cấu Trúc Toàn Bộ CSDL PostgreSQL Schema ([SQL.sql](./docs/SQL/SQL.sql))**:
  - **Phân chia 5 Schemas chuyên biệt với tiền tố chuẩn `v_eval_*`**:
    1. `v_eval_identity`: Quản lý RBAC, Auth, User & Actor Profiles (`Campuses`, `Roles`, `Users`, `UserRoles`, `Students`, `Parents`, `Teachers`, `AcademicManagers`, `AcademicDirectors`, `Administrators`, `RefreshTokens`, `OtpVerifications`).
    2. `v_eval_content`: Quản lý Ngân hàng Đề thi & Khung Năng lực (`CompetencyDomains`, `Skills`, `Materials`, `Passages`, `Questions`, `MockExams`, `ExamQuestions`).
    3. `v_eval_practice`: Quản lý Thi thử, Kết quả Luyện tập, Lớp học & Ability Groups (`Classes`, `ClassEnrollments`, `LiveSessions`, `LiveSessionAttendance`, `TeacherFeedback`, `LearningProfiles`, `LearningRoadmaps`, `RoadmapNodes`, `AttemptLogs`, `ExamSubmissions`, `SubmissionAnswers`, `AbilityGroups`, `StudentGroupMemberships`).
    4. `v_eval_ai`: Quản lý RAG Tri thức, AI Tutor & Vector Database (`KnowledgeSources`, `KnowledgeVectorChunks`, `AITutorSessions`, `AITutorMessages`, `ScorePredictions`, `TokenUsageLogs`).
    5. `v_eval_system`: Quản lý Cảnh báo hệ thống & Cấu hình Vận hành (`SystemAlerts`, `SystemConfigs`).
  - **Cơ chế Idempotent & Non-Destructive Migration**:
    - Đảm bảo an toàn 100% khi thực thi trên CSDL đã có dữ liệu (Supabase Cloud hoặc Docker Postgres local), **tuyệt đối KHÔNG XÓA hay drop bảng/dữ liệu cũ**.
  - **Khởi Tạo Trọn Bộ EF Core Code-First Migrations**:
    - Đã tạo và áp dụng EF Core Migrations cho tất cả 3 Microservices C# (`v_eval_content`, `v_eval_identity`, `v_eval_practice`) biên dịch thành công 100% (0 Errors, 0 Warnings).
