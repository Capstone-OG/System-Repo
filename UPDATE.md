# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [23/10/2026] - Hợp Nhất Master SQL.sql, Xử Lý Dây Đè Bảng Trang 1, Tinh Gọn Trang 2 & Thiết Kế Bản Vẽ Kiến Trúc Chuẩn (System_Architecture_Diagram.md)

- **Hợp Nhất Tập Trung CSDL 4 Schema Vào 1 File Duy Nhất (`docs/SQL/SQL.sql`)**:
  - Hợp nhất toàn bộ 49 bảng thực thể chuẩn hóa PostgreSQL 15+ / Supabase Cloud, xóa bỏ triệt để các file SQL phân mảnh cũ (`SQL_Migration_Flow5_Analytics.sql`, `V_EVAL_AI_SCHEMA.sql`, `V_EVAL_SCHEMA_V3.sql`).
  - Phân bổ tường minh theo 4 namespace schema:
    1. `v_eval_identity` (13 bảng): `Campuses`, `Roles`, `Users`, `UserRoles`, `RefreshTokens`, `OtpVerifications`, `Students`, `Parents`, `ParentStudentRelations`, `Teachers`, `AcademicManagers`, `AcademicDirectors`, `Administrators`.
    2. `v_eval_content` (8 bảng): `CompetencyDomains`, `Skills`, `SkillPrerequisites` (DAG), `Materials`, `Passages`, `Questions`, `MockExams`, `ExamQuestions`.
    3. `v_eval_practice` (21 bảng): `Classes`, `ExamSubmissions`, `SubmissionAnswers`, `ProctoringSnapshots`, `ClassEnrollments`, `ClassGroups`, `ClassGroupMembers`, `LiveSessions`, `LiveSessionAttendance`, `LearningProfiles`, `LearningRoadmaps`, `RoadmapNodes`, `StageProgress` (P-L-A-R), `AdaptiveQuizAttempts` (BKT/IRT), `MistakeNotebooks` (SM-2), `ScorePredictions` (SEM Knapsack), `SystemAlerts` (BR-04), `ClassSkillHeatmaps`, `ClassHeatmapSummaries`, `StudentDailyActivities`, `StudentReadinessMetrics`.
    4. `v_eval_ai` (7 bảng): `KnowledgeSources`, `KnowledgeVectorChunks` (768 chiều), `archetype_patterns` (Taxonomy Level 4 Knowledge Graph), `pattern_exemplars`, `pattern_traps`, `novel_pattern_proposals`, `ai_tutor_interaction_logs`.
  - Thiết lập đầy đủ ràng buộc khóa chính (PK), khóa ngoại (FK với Cascade/Restrict/SetNull chuẩn xác), chỉ mục hiệu năng cao (HNSW Vector Cosine index, Composite B-Tree indexes).

- **Xử Lý Triệt Để Hiện Tượng Dây Đè Lên Bảng Ở Trang 1 (`Trang-1` Physical ERD)**:
  - Khắc phục hoàn toàn lỗi đường nối đè qua nội dung văn bản các bảng bằng cơ chế **Highway Corridor Routing**: Các đường liên kết giữa các package được định tuyến ra các hành lang ngoại vi (`x = 1120..1160`, `x = 2220..2260`, `y = 25..35`, `y = 3200..3220`) trước khi cắm vào bảng đích.
  - Thiết lập tiếp điểm vào/ra tường minh (`exitX, exitY, entryX, entryY`) trên từng cạnh bảng và kích hoạt tính năng cầu nối nhảy dây `jumpStyle=arc;jumpSize=6;` giúp sơ đồ mạch lạc, chuyên nghiệp 100%. Bảo toàn nguyên vẹn 635 phần tử (556 UserObjects + 79 mxCells).

- **Tinh Gọn Bố Cục & Tối Ưu Đồ Thị Phẳng Tuyệt Đối Cho Trang 2 (`Trang-2` Zero-Crossings Planar ERD)**:
  - **Thu gọn kích thước tổng thể vừa vặn, mạch lạc (~3130px × ~1560px)**:
    - Thu hẹp lưới tọa độ ma trận 8 cột × 8 hàng từ bước 580px xuống bước 400px (`COLS = [80, 480, 880, 1280, 1680, 2080, 2480, 2880]`) và bước hàng từ 350px xuống 200px (`ROWS = [80, 280, 480, 680, 880, 1080, 1280, 1480]`).
    - Giảm ~30% chiều rộng canvas và ~41% chiều cao canvas so với phiên bản cũ, giúp sơ đồ nằm gọn trong tầm mắt.
  - **Duy trì tuyệt đối các chỉ số vàng đồ thị phẳng**: 0 giao cắt dây, 0 dây cắt đè bảng, 0 đường chéo, căn thẳng trực diện 23 quan hệ liền kề.

- **Thiết Kế Bản Vẽ Kiến Trúc Hệ Thống Chuẩn Phục Vụ Vẽ Tay (`docs/System_Architecture_Diagram.md`)**:
  - Chuẩn hóa vị trí thư viện: Đưa MathLab (`JSXGraph` 2D/3D & `KaTeX` Live Math) về đúng bản chất là các **thư viện tích hợp nội bộ** nằm trực tiếp bên trong `V-Eval Web Client (React 19 + Vite)`, không tách thành khối Client độc lập.
  - Xây dựng 2 định dạng bản vẽ thuần túy (Chỉ sơ đồ trực quan):
    1. **Sơ đồ tương tác Mermaid 11.15.0+**: Phân tầng 5 lớp (Client -> YARP Gateway -> Core Microservices .NET 9 -> AI Subsystem -> Supabase Data Persistence).
    2. **Bản vẽ hình hộp ASCII Blueprint**: Đo đạc tỷ lệ chuẩn xác từng khối hộp, cổng port và giao thức (`gRPC HTTP/2`, `HTTPS/REST`, `Npgsql EF Core`) để người dùng nhìn và tự vẽ tay bằng bút lên giấy A4/A3.
