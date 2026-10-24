# BẢN ĐẶC TẢ THIẾT KẾ MÔ HÌNH DỮ LIỆU KHÁI NIỆM & VẬT LÝ TOÀN DIỆN
# HỆ THỐNG ĐÁNH GIÁ & HỌC TẬP THÍCH ỨNG V-EVAL (V-ACT ĐHQG-HCM)

> **Tài liệu**: Bản đặc tả kiến trúc dữ liệu và mô hình thực thể quan hệ (ERD Specification)  
> **Phiên bản Schema**: Schema V4.1 (Đồng bộ 100% CSDL PostgreSQL/Supabase, 4 Microservices & [SQL.sql](./SQL.sql))  
> **Ngày ban hành**: 24/10/2026 — Phiên bản Chuẩn hóa Toàn diện  
> **Quy mô Hệ thống**: 47 Thực thể (`v_eval_identity`: 13, `v_eval_content`: 8, `v_eval_practice`: 19, `v_eval_ai`: 7) & 74 Mối quan hệ  
> **Sơ đồ đính kèm**: File [Capstone.drawio](./Capstone.drawio) gồm đầy đủ 3 Trang chuẩn (Trang-1: Bounded Context Clustered ERD, Trang-2: Conceptual Entity ERD, Trang-3: Flat Full-Detail Physical & Logical ERD)  
> **Tương thích Markdown**: Chuẩn hóa 100% cho MD Editor Plus (Relative links, Backtick LaTeX, Mermaid 11.15.0+).

---

## 📌 PHẦN 1: TỔNG QUAN KIẾN TRÚC & PHƯƠNG ÁN THIẾT KẾ HYBRID BEST-PRACTICE

### 1.1 Phương Án C: Kiến Trúc Thực Tiễn Tối Ưu Cho V-Eval (Hybrid Best-Practice)
Hệ thống V-Eval áp dụng mô hình phân tách Bounded Contexts theo Microservices kết hợp toàn vẹn dữ liệu đa tầng:
1. **Nội bộ trong cùng 1 Microservice**:
   - Bắt buộc sử dụng **Khóa ngoại vật lý cứng (Physical Foreign Key)** với ràng buộc toàn vẹn `REFERENCES` trực tiếp trong PostgreSQL (`ON DELETE CASCADE` / `ON DELETE SET NULL`).
   - Trên sơ đồ ERD: Sử dụng **Đường nét liền (Solid Line)**.
   - Thể hiện tính toàn vẹn cấp cơ sở dữ liệu ACID tuyệt đối giữa các thực thể phụ thuộc trong cùng một domain context (ví dụ `MockExams -> ExamQuestions`, `Classes -> ClassGroups -> ClassGroupMembers`, `LearningRoadmaps -> RoadmapNodes`).
2. **Xuyên giữa các Microservice (Cross-Service Boundary)**:
   - Các cột liên kết là kiểu dữ liệu `uuid` chuẩn chỉ và được đánh chỉ mục hiệu năng cao B-Tree (`CREATE INDEX idx_...`).
   - Tầng ứng dụng kiểm soát toàn vẹn bằng giao thức **gRPC trên nền HTTP/2** độ trễ cực thấp (`< 5ms`) qua các Client Interface (`IContentGrpcClient`, `IIdentityGrpcClient`).
   - Trên sơ đồ ERD: Sử dụng **Đường nét đứt (Dashed Line)**.
   - Giúp Hội đồng phản biện và Giảng viên nhận diện ngay lập tức ranh giới Microservices:
     - **Nét liền (Solid Line)** = Khóa ngoại vật lý nội bộ Service (Physical FK, tổng cộng **42 đường**).
     - **Nét đứt (Dashed Line)** = Tham chiếu logic giữa các Bounded Contexts qua gRPC / API (Logical Reference, tổng cộng **32 đường**).

### 1.2 Quy Tắc Đi Dây Hình Sấm Sét Bậc Thang (Stepped Orthogonal / Manhattan Routing)
Để đảm bảo sơ đồ ERD trực quan, không rối mắt và đạt chuẩn công nghiệp:
- **Định hướng đường nối**: Mỗi đường nối chỉ bao gồm các đoạn thẳng song song 100% với trục Ox hoặc Oy (`curved=0; rounded=0; edgeStyle=orthogonalEdgeStyle`).
- **Góc bẻ hướng**: Chuẩn góc vuông `90°` ziczac dạng hình sấm sét bậc thang, đi qua các khoảng trống hành lang 2–3 ô lưới (100–160px) giữa các bảng.
- **Điểm neo (Anchor Points)**: Dây nối xuất phát và kết thúc vuông góc tại các điểm mép ngoài bảng (`exitX/Y` và `entryX/Y` tại `0.0, 0.5, 1.0`), có cơ chế dãn cách (staggering) tránh đè dây khi nhiều quan hệ cùng kết nối vào một mặt bảng.
- **Cầu nhảy giao cắt (Arc Jump Bridges)**: Khi 2 dây trực giao cắt nhau, hệ thống tự động sinh cầu vòm cung `jumpStyle=arc; jumpSize=6` để phân định dây rõ ràng.
- **Không chồng lấn (Zero Collision)**: Tuyệt đối 100% không có dây nào đè lên tiêu đề bảng hoặc thân bất kỳ bảng nào (`0 collisions` trên cả 3 trang). Toàn bộ dây đi độc quyền qua các hành lang xa lộ (highways).

### 1.3 Cấu Trúc 3 Trang Sơ Đồ Tại Capstone.drawio
- **Trang 1: Bounded Context Clustered ERD**: Gom nhóm 9 phân vùng nghiệp vụ theo màu sắc nhận diện Bounded Context, hiển thị chi tiết mọi cột thuộc tính (PK, FK, kiểu dữ liệu), áp dụng đường nét liền (42 FK nội bộ) và nét đứt (32 liên kết liên dịch vụ), toàn bộ 74 đường nối đi qua hành lang an toàn không đè lên bất kỳ bảng nào (`0 collisions`).
- **Trang 2: Conceptual Entity ERD**: Dạng nút thực thể gọn gàng, tập trung vào bản chất mối quan hệ ngữ nghĩa giữa 47 thực thể, toàn bộ 74 đường nối đi dây Manhattan sấm sét với chuẩn hóa ký hiệu chân quạ (Crow's Foot) và cầu nhảy giao cắt vòng cung `jumpStyle=arc; jumpSize=6`, neo mép chuẩn và đạt `0 collisions`.
- **Trang 3: Flat Full-Detail Physical & Logical ERD**: Mô hình trải phẳng toàn diện unclustered gồm 47 bảng đầy đủ thuộc tính chi tiết, bố trí theo 12 cột rãnh chuyên biệt, toàn bộ 74 đường nối đi qua hệ thống kênh phân làn (Channels), xa lộ đỉnh (North Skyway) và xa lộ đáy (South Highway), tuyệt đối `0 collisions` và phân định minh bạch Physical FK (nét liền) vs Logical Ref (nét đứt).

---

## 📊 PHẦN 2: DANH MỤC 47 THỰC THỂ HỆ THỐNG THEO 4 BOUNDED CONTEXTS

| Phân hệ (Schema) | STT | Tên Bảng (Entity) | Ý Nghĩa Nghiệp Vụ Cốt Lõi |
|---|---|---|---|
| **`v_eval_identity`** (13 bảng) | 1 | `Campuses` | Cơ sở đào tạo offline (địa chỉ, hotline, trạng thái vận hành) |
| | 2 | `Roles` | Danh mục vai trò phân quyền RBAC (`STUDENT`, `TEACHER`, `ADMIN`...) |
| | 3 | `Users` | Tài khoản định danh trung tâm (email, mật khẩu băm Argon2, avatar) |
| | 4 | `UserRoles` | Bảng liên kết nhiều-nhiều Người dùng - Vai trò (mỗi user ≥ 1 role) |
| | 5 | `Administrators` | Hồ sơ Quản trị viên hệ thống (System Administrator) |
| | 6 | `AcademicManagers` | Hồ sơ Trưởng bộ phận chuyên môn cơ sở |
| | 7 | `AcademicDirectors` | Hồ sơ Chuyên viên kiểm duyệt học thuật nội dung |
| | 8 | `Teachers` | Hồ sơ Giáo viên phụ trách lớp học offline tại cơ sở |
| | 9 | `Parents` | Hồ sơ Phụ huynh học sinh |
| | 10 | `Students` | Hồ sơ Học sinh luyện thi ĐGNL (trường THPT, điểm mục tiêu, campus) |
| | 11 | `ParentStudentRelations` | Quan hệ liên kết giám sát Phụ huynh - Con cái (phụ huynh ≥ 1 con) |
| | 12 | `RefreshTokens` | Quản lý phiên đăng nhập mở rộng (JWT Refresh Token, chống replay) |
| | 13 | `OtpVerifications` | Mã OTP xác thực email khi đăng ký / đặt lại mật khẩu |
| **`v_eval_content`** (8 bảng) | 14 | `CompetencyDomains` | Miền năng lực 3 phần thi ĐGNL (Ngôn ngữ, Toán - Logic, Giải quyết VĐ) |
| | 15 | `Skills` | Cây kỹ năng vi mô 3 cấp độ (Domain -> Chuyên đề -> Kỹ năng chi tiết) |
| | 16 | `SkillPrerequisites` | Đồ thị có hướng DAG biểu diễn quan hệ tiên quyết giữa các kỹ năng |
| | 17 | `Materials` | Học liệu lý thuyết video và tài liệu bổ trợ theo kỹ năng |
| | 18 | `Questions` | Ngân hàng câu hỏi trắc nghiệm chuẩn hóa (LaTeX, 4 đáp án A-D, Bloom) |
| | 19 | `Passages` | Đoạn văn / ngữ liệu đọc hiểu dùng chung cho chùm câu hỏi ĐGNL |
| | 20 | `MockExams` | Đề thi chuẩn hóa (Chẩn đoán 30 câu, Thi thử 120 câu, Quiz củng cố) |
| | 21 | `ExamQuestions` | Bảng liên kết thứ tự câu hỏi và điểm số trong đề thi |
| **`v_eval_practice`** (19 bảng) | 22 | `Classes` | Lớp học offline tại cơ sở (sĩ số tối đa 20 học sinh, phòng học) |
| | 23 | `ClassEnrollments` | Danh sách học sinh ghi danh chính thức vào lớp học offline |
| | 24 | `ClassGroups` | Nhóm học tập vi mô 3–5 học sinh phân hóa theo vùng trũng kiến thức |
| | 25 | `ClassGroupMembers` | Thành viên học sinh trong nhóm vi mô |
| | 26 | `ExamSubmissions` | Phiên làm bài thi thử / thi chẩn đoán (thời gian làm, tổng điểm) |
| | 27 | `SubmissionAnswers` | Chi tiết câu trả lời từng câu hỏi trong bài thi nộp |
| | 28 | `ProctoringSnapshots` | Ảnh chụp webcam và giám sát liêm chính thi cử (đếm rời tab) |
| | 29 | `LearningProfiles` | Hồ sơ năng lực BKT `P(L_t)` và xác suất ban đầu `P(L_0)` theo kỹ năng |
| | 30 | `LearningRoadmaps` | Lộ trình cá nhân hóa tự động cắt tỉa mục tiêu theo điểm chẩn đoán |
| | 31 | `RoadmapNodes` | Chặng học 2 thành phần tích hợp (Video lý thuyết + Quiz củng cố) |
| | 32 | `StageProgress` | Tiến trình chặng học chu trình 4 bước P-L-A-R tích hợp State Machine |
| | 33 | `AdaptiveQuizAttempts` | Log trả lời trắc nghiệm thích ứng từng câu (BKT & IRT ZPD engine) |
| | 34 | `MistakeNotebooks` | Sổ tay lỗi sai & thuật toán lặp lại ngắt quãng SuperMemo-2 (SM-2) |
| | 35 | `ScorePredictions` | Dự báo khoảng điểm SEM 95% và toa thuốc bù điểm Knapsack ROI |
| | 36 | `SystemAlerts` | Hệ thống cảnh báo sớm 3 cấp độ BR-04 (`SAFE`, `AMBER`, `RED`) |
| | 37 | `ClassSkillHeatmaps` | Ma trận nhiệt năng lực kỹ năng của từng học sinh trong lớp học |
| | 38 | `ClassHeatmapSummaries` | Tổng hợp cột kỹ năng lớp học (Mean `P(L_t)`, StdDev, cờ phân hóa 2 cực) |
| | 39 | `StudentDailyActivities` | Nhật ký chuyên cần, thời gian học và chuỗi ngày liên tục (streak) |
| | 40 | `StudentReadinessMetrics` | Chỉ số sẵn sàng thi ĐGNL tổng hợp và phân tầng năng lực học sinh |
| **`v_eval_ai`** (7 bảng) | 41 | `KnowledgeSources` | Nguồn tài liệu SGK, sách chuyên đề và sách giáo viên số hóa |
| | 42 | `KnowledgeVectorChunks` | Vector Embeddings 768 chiều (`pgvector`) kèm chỉ mục Cosine HNSW |
| | 43 | `archetype_patterns` | Đồ thị tri thức dạng bài chuẩn hóa (Archetype Knowledge Graph) |
| | 44 | `pattern_exemplars` | Câu hỏi mẫu điển hình kèm lời giải chuẩn mực (Golden Solution) |
| | 45 | `pattern_traps` | Các bẫy nhận thức, ngộ nhận thường gặp và gợi ý gợi mở Socratic |
| | 46 | `novel_pattern_proposals` | Đề xuất dạng bài mới trích xuất từ đề thi thực tế chờ phê duyệt |
| | 47 | `ai_tutor_interaction_logs` | Nhật ký tương tác Trợ giảng AI Socratic và lưu vết kiểm duyệt |

---

## 🔗 PHẦN 3: BẢNG ĐỐI CHIẾU 74 MỐI QUAN HỆ & BẢN SỐ (CARDINALITY MATRIX)

### 3.1 Khóa Ngoại Vật Lý Nội Bộ (Solid Line - Physical FK: 42 quan hệ)
Mọi quan hệ này được bảo đảm bằng `REFERENCES` trong PostgreSQL:

| STT | Bảng Cha (Source) | Bảng Con (Target) | Bản Số (Cardinality) | Ký hiệu ERD | Cột Khóa Ngoại |
|---|---|---|---|---|---|
| 1 | `Users` | `UserRoles` | `1 : 1..N` | `||` — `|<` | `user_id` NOT NULL |
| 2 | `Roles` | `UserRoles` | `1 : 0..N` | `||` — `o<` | `role_id` NOT NULL |
| 3 | `Users` | `RefreshTokens` | `1 : 0..N` | `||` — `o<` | `user_id` NOT NULL |
| 4 | `Users` | `Students` | `1 : 0..1` | `||` — `o|` | `student_id` = PK |
| 5 | `Users` | `Parents` | `1 : 0..1` | `||` — `o|` | `parent_id` = PK |
| 6 | `Users` | `Teachers` | `1 : 0..1` | `||` — `o|` | `teacher_id` = PK |
| 7 | `Users` | `AcademicManagers` | `1 : 0..1` | `||` — `o|` | `manager_id` = PK |
| 8 | `Users` | `AcademicDirectors` | `1 : 0..1` | `||` — `o|` | `director_id` = PK |
| 9 | `Users` | `Administrators` | `1 : 0..1` | `||` — `o|` | `admin_id` = PK |
| 10 | `Campuses` | `Students` | `0..1 : 0..N` | `o|` — `o<` | `campus_id` NULLable |
| 11 | `Campuses` | `Teachers` | `1 : 0..N` | `||` — `o<` | `campus_id` NOT NULL |
| 12 | `Campuses` | `AcademicManagers` | `1 : 0..N` | `||` — `o<` | `campus_id` NOT NULL |
| 13 | `Parents` | `ParentStudentRelations` | `1 : 1..N` | `||` — `|<` | `parent_id` NOT NULL |
| 14 | `Students` | `ParentStudentRelations` | `1 : 0..N` | `||` — `o<` | `student_id` NOT NULL |
| 15 | `CompetencyDomains` | `Skills` | `1 : 0..N` | `||` — `o<` | `domain_id` NOT NULL |
| 16 | `Skills` | `Skills` | `0..1 : 0..N` | `o|` — `o<` | `parent_id` NULLable |
| 17 | `Skills` | `SkillPrerequisites` | `1 : 0..N` | `||` — `o<` | `skill_id` NOT NULL |
| 18 | `Skills` | `SkillPrerequisites` | `1 : 0..N` | `||` — `o<` | `prerequisite_id` NOT NULL |
| 19 | `Skills` | `Materials` | `1 : 0..N` | `||` — `o<` | `skill_id` NOT NULL |
| 20 | `Skills` | `Questions` | `1 : 0..N` | `||` — `o<` | `skill_id` NOT NULL |
| 21 | `Passages` | `Questions` | `0..1 : 0..N` | `o|` — `o<` | `passage_id` NULLable |
| 22 | `MockExams` | `ExamQuestions` | `1 : 0..N` | `||` — `o<` | `exam_id` NOT NULL |
| 23 | `Questions` | `ExamQuestions` | `1 : 0..N` | `||` — `o<` | `question_id` NOT NULL |
| 24 | `Classes` | `ClassEnrollments` | `1 : 0..N` | `||` — `o<` | `class_id` NOT NULL |
| 25 | `Classes` | `ClassGroups` | `1 : 0..N` | `||` — `o<` | `class_id` NOT NULL |
| 26 | `ClassGroups` | `ClassGroupMembers` | `1 : 0..N` | `||` — `o<` | `group_id` NOT NULL |
| 27 | `Classes` | `ExamSubmissions` | `0..1 : 0..N` | `o|` — `o<` | `enrolled_class_id` NULLable |
| 28 | `ExamSubmissions` | `SubmissionAnswers` | `1 : 0..N` | `||` — `o<` | `submission_id` NOT NULL |
| 29 | `ExamSubmissions` | `ProctoringSnapshots` | `1 : 0..N` | `||` — `o<` | `submission_id` NOT NULL |
| 30 | `ExamSubmissions` | `ClassEnrollments` | `0..1 : 0..N` | `o|` — `o<` | `diagnostic_submission_id` |
| 31 | `ExamSubmissions` | `LearningRoadmaps` | `0..1 : 0..N` | `o|` — `o<` | `diagnostic_submission_id` |
| 32 | `LearningRoadmaps` | `RoadmapNodes` | `1 : 0..N` | `||` — `o<` | `roadmap_id` NOT NULL |
| 33 | `RoadmapNodes` | `StageProgress` | `1 : 0..N` | `||` — `o<` | `roadmap_node_id` NOT NULL |
| 34 | `StageProgress` | `AdaptiveQuizAttempts` | `1 : 0..N` | `||` — `o<` | `stage_progress_id` NOT NULL |
| 35 | `Classes` | `ClassSkillHeatmaps` | `1 : 0..N` | `||` — `o<` | `class_id` NOT NULL |
| 36 | `Classes` | `ClassHeatmapSummaries` | `1 : 0..N` | `||` — `o<` | `class_id` NOT NULL |
| 37 | `KnowledgeSources` | `KnowledgeVectorChunks` | `1 : 0..N` | `||` — `o<` | `source_id` NOT NULL |
| 38 | `archetype_patterns` | `pattern_exemplars` | `1 : 0..N` | `||` — `o<` | `archetype_pattern_id` |
| 39 | `archetype_patterns` | `pattern_traps` | `1 : 0..N` | `||` — `o<` | `archetype_pattern_id` |
| 40 | `archetype_patterns` | `novel_pattern_proposals` | `0..1 : 0..N` | `o|` — `o<` | `nearest_archetype_id` |
| 41 | `archetype_patterns` | `ai_tutor_interaction_logs`| `0..1 : 0..N` | `o|` — `o<` | `archetype_pattern_id` |
| 42 | `pattern_traps` | `ai_tutor_interaction_logs`| `0..1 : 0..N` | `o|` — `o<` | `matched_trap_id` |

### 3.2 Tham Chiếu Logic Liên Dịch Vụ (Dashed Line - Logical Reference via gRPC: 32 quan hệ)
Mọi quan hệ này được bảo đảm bằng cột `uuid` có chỉ mục B-Tree và kiểm soát bằng gRPC/Application:

| STT | Bảng Gốc (Source) | Bảng Đích (Target) | Bản Số (Cardinality) | Ký hiệu ERD | Cơ chế đồng bộ qua gRPC |
|---|---|---|---|---|---|
| 43 | `Users` | `OtpVerifications` | `0..1 : 0..N` | `o|` ╌╌ `o<` | Khớp logic qua trường `email` |
| 44 | `Campuses` | `Classes` | `1 : 0..N` | `||` ╌╌ `o<` | gRPC Identity Client `GetCampusById` |
| 45 | `Teachers` | `Classes` | `0..1 : 0..N` | `o|` ╌╌ `o<` | gRPC Identity Client `ValidateTeacher` |
| 46 | `AcademicManagers` | `Classes` | `0..1 : 0..N` | `o|` ╌╌ `o<` | gRPC Identity Client `ValidateManager` |
| 47 | `Students` | `ClassEnrollments` | `1 : 0..N` | `||` ╌╌ `o<` | gRPC Identity Client `ValidateStudent` |
| 48 | `Students` | `ClassGroupMembers` | `1 : 0..N` | `||` ╌╌ `o<` | gRPC Identity Client `ValidateStudent` |
| 49 | `Students` | `ExamSubmissions` | `1 : 0..N` | `||` ╌╌ `o<` | gRPC Identity Client `ValidateStudent` |
| 50 | `MockExams` | `ExamSubmissions` | `1 : 0..N` | `||` ╌╌ `o<` | gRPC Content Client `GetMockExamById` |
| 51 | `Questions` | `SubmissionAnswers` | `1 : 0..N` | `||` ╌╌ `o<` | gRPC Content Client `GetQuestionById` |
| 52 | `Students` | `LearningRoadmaps` | `1 : 0..N` | `||` ╌╌ `o<` | gRPC Identity Client `ValidateStudent` |
| 53 | `Skills` | `RoadmapNodes` | `1 : 0..N` | `||` ╌╌ `o<` | gRPC Content Client `GetSkillsTree` |
| 54 | `Materials` | `RoadmapNodes` | `0..1 : 0..N` | `o|` ╌╌ `o<` | gRPC Content Client `GetMaterialById` |
| 55 | `MockExams` | `RoadmapNodes` | `0..1 : 0..N` | `o|` ╌╌ `o<` | gRPC Content Client `GetQuizExamById` |
| 56 | `Students` | `StageProgress` | `1 : 0..N` | `||` ╌╌ `o<` | gRPC Identity Client `ValidateStudent` |
| 57 | `Students` | `LearningProfiles` | `1 : 0..N` | `||` ╌╌ `o<` | gRPC Identity Client `ValidateStudent` |
| 58 | `Skills` | `LearningProfiles` | `1 : 0..N` | `||` ╌╌ `o<` | gRPC Content Client `GetSkillById` |
| 59 | `Students` | `AdaptiveQuizAttempts` | `1 : 0..N` | `||` ╌╌ `o<` | gRPC Identity Client `ValidateStudent` |
| 60 | `Questions` | `AdaptiveQuizAttempts` | `1 : 0..N` | `||` ╌╌ `o<` | gRPC Content Client `GetQuestionById` |
| 61 | `Students` | `MistakeNotebooks` | `1 : 0..N` | `||` ╌╌ `o<` | gRPC Identity Client `ValidateStudent` |
| 62 | `Questions` | `MistakeNotebooks` | `1 : 0..N` | `||` ╌╌ `o<` | gRPC Content Client `GetQuestionById` |
| 63 | `Skills` | `MistakeNotebooks` | `1 : 0..N` | `||` ╌╌ `o<` | gRPC Content Client `GetSkillById` |
| 64 | `Students` | `ScorePredictions` | `1 : 0..N` | `||` ╌╌ `o<` | gRPC Identity Client `ValidateStudent` |
| 65 | `Students` | `SystemAlerts` | `1 : 0..N` | `||` ╌╌ `o<` | gRPC Identity Client `ValidateStudent` |
| 66 | `Users` | `SystemAlerts` | `0..1 : 0..N` | `o|` ╌╌ `o<` | gRPC Identity Client `GetUserById` |
| 67 | `Students` | `ClassSkillHeatmaps` | `1 : 0..N` | `||` ╌╌ `o<` | gRPC Identity Client `ValidateStudent` |
| 68 | `Skills` | `ClassSkillHeatmaps` | `1 : 0..N` | `||` ╌╌ `o<` | gRPC Content Client `GetSkillById` |
| 69 | `Skills` | `ClassHeatmapSummaries` | `1 : 0..N` | `||` ╌╌ `o<` | gRPC Content Client `GetSkillById` |
| 70 | `Students` | `StudentDailyActivities` | `1 : 0..N` | `||` ╌╌ `o<` | gRPC Identity Client `ValidateStudent` |
| 71 | `Students` | `StudentReadinessMetrics` | `1 : 0..1` | `||` ╌╌ `o|` | gRPC Identity Client `ValidateStudent` |
| 72 | `Skills` | `archetype_patterns` | `1 : 0..N` | `||` ╌╌ `o<` | gRPC Content Client `GetSkillById` |
| 73 | `Students` | `ai_tutor_interaction_logs` | `1 : 0..N` | `||` ╌╌ `o<` | gRPC Identity Client `ValidateStudent` |
| 74 | `Questions` | `ai_tutor_interaction_logs` | `1 : 0..N` | `||` ╌╌ `o<` | gRPC Content Client `GetQuestionById` |

---

## 🎯 PHẦN 4: HƯỚNG DẪN KIỂM THỬ & SỬ DỤNG SƠ ĐỒ
1. **Mở sơ đồ trên VS Code / Web**:
   - Cài đặt extension **Draw.io Integration** trên VS Code hoặc truy cập trang web [app.diagrams.net](https://app.diagrams.net).
   - Mở file [Capstone.drawio](./Capstone.drawio):
     - **Trang 1 (`Trang-1`)**: Trực quan hóa kiến trúc theo Bounded Contexts.
     - **Trang 2 (`Trang-2`)**: Trực quan hóa mức khái niệm tập trung vào quan hệ thực thể.
     - **Trang 3 (`Trang-3`)**: Trực quan hóa trải phẳng toàn diện (Flat Detail) với 47 bảng và 74 đường nối sấm sét Manhattan.
2. **Kiểm tra tính toàn vẹn CSDL**:
   - Chạy script kiểm thử đối chiếu giữa [SQL.sql](./SQL.sql) và CSDL Supabase PostgreSQL:
     - Đảm bảo 47 bảng tồn tại đúng schema (`v_eval_identity`: 13, `v_eval_content`: 8, `v_eval_practice`: 19, `v_eval_ai`: 7).
     - Đảm bảo 100% mã nguồn C# Solution `V-Eval-Practice_Service.sln` biên dịch sạch `0 Error, 0 Warning`.
