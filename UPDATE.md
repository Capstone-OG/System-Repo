# Nhật Ký Cập Nhật (Update Log) - System Repo

## [22/09/2026] - Triển Khai Toàn Diện Core Flow 1 (Chẩn Đoán Năng Lực Đầu Vào, Ước Lượng IRT & BKT Priors, Tự Động Xếp Lớp & Trực Quan Hóa Dữ Liệu)

Toàn bộ luồng nghiệp vụ **Core Flow 1 (Từ Đề thi Chẩn đoán 30 câu $\to$ Chấm điểm $\to$ AI Psychometrics $\to$ Xếp lớp Campus $\to$ DTO trực quan)** đã được phát triển, liên thông và kiểm thử thành công 100% qua 4 Microservices:

---

### 1. AI Engine (`All Services/V-Eval-Ai_Engine/rag-service`)
* **Toán học & Psychometrics (`rag-service/diagnostic_engine.py`) [MỚI]**:
  * **Thuật toán IRT 2PL (Item Response Theory 2-Parameter Logistic)**: Ước lượng năng lực học sinh $\theta_0$ qua phương pháp Maximum A Posteriori (MAP) kết hợp hàm phạt Gaussian Prior $N(0, 2.0^2)$ và thuật toán tối ưu hóa Brent (`scipy.optimize.minimize_scalar`).
  * **Cơ chế chống đoán mò (Anti-guessing penalty)**: Nếu thời gian làm câu hỏi $< 5\text{s}$, tự động giảm tham số phân biệt $a \to 0.1$ để triệt tiêu hiện tượng ăn may gây sai lệch năng lực.
  * **Xác suất thành thục ban đầu BKT Prior $P(L_0)$**: Áp dụng Logistic Sigmoid $P(L_0) = \frac{1}{1 + e^{-\theta}}$ với cơ chế kẹp an toàn $[0.05, 0.95]$.
  * **Suy diễn miền năng lực (Domain-level Inference)**: Các kỹ năng không có câu hỏi trong đề 30 câu tự động kế thừa $P(L_0)$ suy diễn từ năng lực miền cha $\theta_{\text{domain}}$, đảm bảo giải quyết trọn vẹn bài toán Cold-Start.
  * **Phân lớp học sinh 3 cấp**: `FOUNDATION` ($\theta < -0.5$), `ACCELERATION` ($-0.5 \le \theta \le 0.5$), `BREAKTHROUGH` ($\theta > 0.5$).
  * **Tọa độ Biểu đồ Radar đa trục**: Tính toán tỷ lệ % thực tế (`student_pct`) và điểm chuẩn chuẩn hóa (`benchmark_pct`) theo từng miền năng lực.
* **REST API & Tích Hợp Gemini LLM (`rag-service/routers/diagnostic.py`) [MỚI]**:
  * `POST /api/v1/diagnostic/analyze`: Nhận kết quả 30 câu trả lời, tính toán chỉ số psychometrics và gọi Google Gemini (`gemini-3.6-flash`, `temperature = 0.3`) tạo nhận xét sư phạm tích cực bằng Tiếng Việt.
  * Tích hợp cơ chế tự động Fallback nội bộ nếu kết nối LLM gặp sự cố (Zero-Downtime).
  * `GET /api/v1/diagnostic/config`: Trả về tham số cấu hình ngưỡng và thang đo.
* **Data Contracts Pydantic (`rag-service/schemas.py`) [CẬP NHẬT]**:
  * Định nghĩa trọn bộ DTO: `DiagnosticAnswerItem`, `DiagnosticDomainName`, `DiagnosticAnalyzeRequest`, `DiagnosticSkillPriorDto`, `DiagnosticDomainScoreDto`, `DiagnosticRadarAxisDto`, `DiagnosticAnalyzeResponse`.
* **Bộ Kiểm Thử Toàn Diện (`rag-service/tests/test_diagnostic.py`) [MỚI]**:
  * 12/12 unit và integration test cases đạt **100% PASS rate** (kiểm thử IRT, BKT, edge cases 100% đúng/sai, suy diễn untested skills, endpoint FastAPI).
* **Tài Liệu Đặc Tả Toán Học (`docs/ai_architecture/cong_thuc_psychometrics_irt_bkt.md`) [MỚI]**:
  * Ban hành tài liệu toán học chuyên sâu trình bày chi tiết toàn bộ các công thức toán học IRT 2PL, MAP Brent, SEM, BKT Sigmoid, Domain Inference, Radar Benchmark và lý giải bài toán thực tế.

---

### 2. Practice Service (`All Services/V-Eval-Practice_Service`)
* **Tích Hợp AI Subsystem Client (`V-Eval-Practice_Service.Infrastructure/HttpClients/AiDiagnosticClient.cs`) [MỚI]**:
  * Triển khai `IAiDiagnosticClient` kết nối `POST /api/v1/diagnostic/analyze` với timeout 15s.
  * Cơ chế Resilient Fallback: Tự động tính toán $\theta_0$ xấp xỉ nội bộ nếu AI Engine tạm ngắt kết nối.
* **Mở Rộng Domain Entities & CSDL PostgreSQL (`V-Eval-Practice_Service.Domain/Entities`) [CẬP NHẬT & MỚI]**:
  * `ExamSubmission`: Bổ sung 4 cột `Theta0`, `PlacementClass`, `AiCommentary`, `EnrolledClassId`.
  * `LearningProfile` [MỚI]: Thực thể lưu ma trận xác suất làm chủ ban đầu $P(L_0)$ cho từng kỹ năng vào bảng `practice.learning_profiles`.
  * `Class` & `ClassEnrollment` [MỚI]: Thực thể quản lý lớp học tại cơ sở (`CampusId`) và ghi nhận trạng thái ghi danh (`ENROLLED`).
* **Mở Rộng EF Core Persistence (`PracticeDbContext.cs`) [CẬP NHẬT]**:
  * Đăng ký `DbSet<LearningProfile>`, `DbSet<Class>`, `DbSet<ClassEnrollment>`.
  * Thêm logic tự động di trú DDL trên startup (`Program.cs`): `ALTER TABLE practice.exam_submissions ADD COLUMN IF NOT EXISTS ...` và tạo các bảng thiếu.
* **Triển Khai Repositories Nghiệp Vụ [MỚI]**:
  * `ILearningProfileRepository` / `LearningProfileRepository`: Lưu trữ ma trận $P(L_0)$.
  * `IClassEnrollmentRepository` / `ClassEnrollmentRepository`: Tìm kiếm/tự động tạo lớp học tại Campus theo phân lớp (`FOUNDATION` / `ACCELERATION` / `BREAKTHROUGH`) và tạo bản ghi ghi danh `ClassEnrollment`.
* **Khép Kín Luồng Xử Lý Nghiệp Vụ (`SubmitDiagnosticCommandHandler.cs`) [CẬP NHẬT]**:
  1. Gọi gRPC Identity Service: Xác thực học sinh, lấy `CampusId` và `CampusName`.
  2. Gọi gRPC Content Service: Lấy bảng đáp án bí mật kèm `SkillName`, `DomainId`, `DomainName`.
  3. Chấm điểm 30 câu hỏi: Tính tổng điểm, tỷ lệ chính xác, phân nhóm kỹ năng, lọc kỹ năng yếu (`< 60%`), phân nhóm độ khó.
  4. Gửi dữ liệu sang AI Engine: Nhận về $\theta_0$, phân lớp, AI commentary, tọa độ Radar Chart, BKT Priors.
  5. Cập nhật bài nộp, lưu $P(L_0)$ vào `LearningProfiles`, tự động tạo/ghi danh lớp tại Campus, trả về DTO trực quan.
* **Trực Quan Hóa DTO Dữ Liệu Phản Hồi [CẬP NHẬT]**:
  * Bổ sung `SkillName`, `DomainId`, `DomainName` vào `QuestionResultDto` và `SkillDiagnosticDto`.
  * Bổ sung object `WeakSkills` trực quan (`skillId`, `skillName`, `domainName`, `accuracyPercentage`).
  * Bổ sung `CampusName`, `ClassName`, `ClassId`, `EnrollmentId`, `RadarChart`, `SkillPriors` vào `SubmitDiagnosticResponseDto`.

---

### 3. Content Service (`All Services/V-Eval-Content_Service`)
* **Nâng Cấp Hợp Đồng gRPC (`V-Eval-Content_Service.Infrastructure/Protos/content.proto`) [CẬP NHẬT]**:
  * Mở rộng `AnswerKeyItem`: Bổ sung 3 trường `string skill_name = 5;`, `string domain_id = 6;`, `string domain_name = 7;`.
* **Nâng Cấp gRPC Server (`ContentGrpcService.cs`) [CẬP NHẬT]**:
  * Cải tiến truy vấn EF Core trong `GetExamAnswerKey`:
    `.Include(eq => eq.Question).ThenInclude(q => q.Skill).ThenInclude(s => s.Domain)`
    giúp truyền dữ liệu tên kỹ năng và môn học sang `Practice_Service`.
* **Đồng Bộ Hóa Proto**:
  * Copy trực tiếp file `content.proto` sang thư mục `Protos/` của `Practice_Service` để bảo đảm tính tương thích.

---

### 4. Identity Service (`All Services/V-Eval-Identity_Service`)
* **Nâng Cấp Hợp Đồng gRPC (`V-Eval-Identity_Service.Infrastructure/Protos/identity.proto`) [CẬP NHẬT]**:
  * Mở rộng thông điệp `GetStudentSummaryResponse`: Bổ sung trường `string campus_name = 8;`.
* **Nâng Cấp gRPC Server (`IdentityGrpcService.cs`) [CẬP NHẬT]**:
  * Nạp thông tin quan hệ `Student -> Campus` để trả về tên cơ sở đào tạo chính xác cho Practice Service.
* **Đồng Bộ Hóa Proto**:
  * Copy trực tiếp file `identity.proto` sang `Protos/` của `Practice_Service`.

---

### 5. Scripts Vận Hành & Kiểm Thử Tự Động (`Scripts/`)
* **`Scripts/run_local/run_core_flow1_services.bat` [MỚI]**: Khởi chạy đồng thời cả 4 dịch vụ (AI Engine port 8000, Identity Service 5155/5156, Content Service 5249/5250, Practice Service 5261).
* **`Scripts/test_core_flow1.ps1` [MỚI]**: Kịch bản PowerShell kiểm thử tích hợp tự động toàn bộ luồng nộp bài thi 30 câu hỏi và kiểm tra tính toàn vẹn của dữ liệu trong CSDL.

## [21/09/2026] - Cập Nhật ERD CSDL PostgreSQL Bổ Sung Luồng Duyệt Đề Thi AI 30 Câu & Nuốt Tài Liệu RAG Theo Môn / Skill
- **Cập Nhật CSDL Schema SQL ([SQL.sql](./docs/SQL/SQL.sql))**:
  - **Bổ sung quy trình Duyệt Đề Thi do AI Tạo vào bảng `MockExams`**:
    - Thêm `domain_id` (FK `CompetencyDomains`): Xác định môn học / miền năng lực của đề thi.
    - Thêm `is_ai_generated` (boolean, default false): Đánh dấu đề do AI tự động tổng hợp hay tạo thủ công.
    - Thêm `approval_status` (varchar, default `'APPROVED'`): Quản lý vòng đời kiểm duyệt (`'DRAFT'`, `'PENDING_APPROVAL'`, `'APPROVED'`, `'REJECTED'`).
    - Thêm `approved_by` (FK `Users`), `approved_at` (timestamp), và `rejection_reason` (text): Phục vụ thao tác duyệt/từ chối của Giám đốc môn học / Giáo viên.
  - **Bổ sung phân loại Môn & Skill vào bảng `KnowledgeSources` (Tài liệu RAG)**:
    - Thêm `domain_id` (FK `CompetencyDomains`) và `skill_id` (FK `Skills`): Cho phép nuốt và trích xuất tài liệu tri thức (SGK, bài giảng, tài liệu mở rộng) phân loại chuẩn xác theo từng môn học và kỹ năng.
    - Thêm `document_type` (varchar, default `'GENERAL_KNOWLEDGE'`): Phân biệt nguồn tài liệu (`'TEXTBOOK'`, `'CURRICULUM'`, `'GENERAL_KNOWLEDGE'`, `'PAST_EXAM'`).
    - Thêm `description` (text): Mô tả nội dung tài liệu.
  - **Thêm Chỉ Mục (Indexes)**:
    - `idx_mock_exams_approval` hỗ trợ tra cứu đề thi chờ duyệt theo môn học (`approval_status`, `domain_id`).
    - `idx_knowledge_sources_domain_skill` hỗ trợ RAG vector retriever lọc nhanh tài liệu tri thức theo môn & skill (`domain_id`, `skill_id`).
- **Thiết Thiết Kế Kế Hoạch Triển Khai Kiến Trúc (Implementation Plan)**:
  - Xây dựng luồng API sinh đề 30 câu bất đồng bộ (`POST /api/v1/content/exams/generate-ai`), lưu DB ở trạng thái `PENDING_APPROVAL` và phản hồi HTTP `200 OK` ngay lập tức mà không làm treo ứng dụng.

## [19/09/2026] - Phân Tích Kiểm Kê Schema SQL, Thuật Toán Gom Nhóm Năng Lực (AbilityGroups) & Đánh Giá Rủi Ro Clustering
- **Tạo Tài Liệu Phân Tích Gom Nhóm Tránh Nổ Tổ Hợp & Đánh Giá Rủi Ro ([Phan_Tich_Gom_Nhom_AbilityGroups.md](./docs/SQL/Phan_Tich_Gom_Nhom_AbilityGroups.md))**:
  - Đã kiểm kê luồng schema SQL hiện tại ([SQL.sql](./docs/SQL/SQL.sql)) bao gồm các thực thể `CompetencyDomains`, `Skills`, `LearningProfiles`, `MockExams`, `AttemptLogs`, `SubmissionAnswers`.
  - Phân tích chi tiết nguy cơ **nổ tổ hợp (combinatorial explosion)** khi gom nhóm trên vector $M=60$ skills toàn hệ thống ($3^{60}$ tổ hợp), dẫn tới lời nguyền số chiều và mất tác dụng tiết kiệm chi phí AI.
  - Đề xuất trọn bộ **3 giải pháp giảm chiều dữ liệu thực tế**:
    1. *Domain-level Clustering*: Phân tách thành 5 bài toán gom nhóm độc lập theo từng `domain_id` (Toán, Ngôn ngữ, KHTN, KHXH, Anh văn).
    2. *Fixed Cluster Count*: Cố định $K = 5$ cụm/domain $\Rightarrow$ Giới hạn tổng cộng **25 Ability Groups toàn hệ thống**.
    3. *Weakness Focus Filtering*: Lọc ra Top-K skill yếu nhất để loại bỏ nhiễu từ các skill khá giỏi.
  - Đã đồng bộ 100% CSDL Nhóm 10 trong `SQL.sql`: `AbilityGroups` và `StudentGroupMemberships`.
  - **Bổ sung Phân tích 8 Rủi ro chính của Thuật toán Clustering**:
    1. *Chọn sai K*, 2. *Dữ liệu thưa*, 3. *Chưa chuẩn hóa Scaling*, 4. *Outlier kéo lệch tâm cụm*, 5. *Giả định cụm hình cầu*, 6. *Cluster Drift theo thời gian*, 7. *Cold Start học sinh mới*, 8. *Nhãn không ổn định (Label Instability)*.
    - Xác định **Top 3 rủi ro đáng ưu tiên xử lý nhất cho V-ACT**: Dữ liệu thưa (7.2), Cold Start (7.7) và Chọn sai K (7.1).
- **Khắc Phục Lỗi Cú Pháp Mermaid Diagram & Chuẩn Hóa Markdown (`docs/luong_phan_tich_va_hien_thi_de_thi.md`)**:
  - Đã chuẩn hóa toàn bộ các sơ đồ `sequenceDiagram` và `flowchart TD` để tương thích 100% với trình biên dịch **Mermaid 11.15.0** trên **MD Editor Plus**:
    - Bọc ngoặc kép tất cả tên nhãn chứa ký tự đặc biệt, dấu ngoặc `()`, hai chấm `:`.
    - Loại bỏ hoàn toàn ngoặc vuông `[]`, ngoặc nhọn `{}` và dấu nháy kép lồng trong nội dung mũi tên/subgraph.
- **Bổ Sung Quy Tắc Hệ Thống Cho Agent (`AGENTS.md` & `.agents/rules/markdown_formatting_rules.md`)**:
  - Đã ghi nhận quy tắc **MD Editor Plus Compatible Rule** vào bộ quy tắc của Agent:
    1. Không dùng URL `file:///` tuyệt đối trong tài liệu repo (dùng tương đối `./`).
    2. Bọc công thức KaTeX/LaTeX và escape sequence trong inline backticks `` `...` `` thay vì dùng `$` thô gây lỗi đỏ text.
    3. Tuân thủ nghiêm ngặt chuẩn sơ đồ Mermaid 11.15.0+ (bọc ngoặc nhãn có ký tự đặc biệt, cấm lồng `loop` trong `par` hay `loop` trong `loop`).


## [20/09/2026] - Triển Khai Thực Thể Campus, 6 Actor Profiles, API Cơ Sở & Server gRPC Identity
- **Hoàn Thiện Thực Thể Identity & 6 Actor Profiles (Schema `iam` & `profile`)**:
  - Bổ sung thực thể [`Campus.cs`](file:///d:/Capstone/All%20Services/V-Eval-Identity_Service/V-Eval-Identity_Service.Domain/Entities/Iam/Campus.cs) vào schema `iam.campuses` và 6 hồ sơ Actor: `Students`, `Parents`, `ParentStudentRelations`, `Teachers`, `AcademicManagers`, `AcademicDirectors`, `Administrators` vào schema `profile`.
  - Khóa ngoại 1-1 với `iam.users` (Cascade Delete), khóa ngoại cơ sở `iam.campuses`.
  - Cấu hình Fluent API EF Core, Seed 6 vai trò chuẩn và 2 cơ sở mẫu (CS Thủ Đức, CS Quận 10).
- **Phát Hành API Quản Lý & Lựa Chọn Cơ Sở (UC 10 & UC 40)**:
  - Triển khai `ICampusRepository` và [`CampusesController.cs`](file:///d:/Capstone/All%20Services/V-Eval-Identity_Service/V-Eval-Identity_Service.API/Controllers/CampusesController.cs) cung cấp endpoint `GET /api/v1/campuses`.
- **Chuẩn Hóa Hồ Sơ Học Sinh & Thang Điểm Chuẩn 1200 (UC 04)**:
  - Cập nhật [`UpdateProfileCommand.cs`](file:///d:/Capstone/All%20Services/V-Eval-Identity_Service/V-Eval-Identity_Service.Application/Features/Users/Commands/UpdateProfile/UpdateProfileCommand.cs) kiểm tra `TargetScore` theo thang điểm 1200 của bài thi ĐGNL ĐHQG-HCM V-ACT; tự động khởi tạo bản ghi `profile.students` nếu tài khoản chưa có.
  - Hỗ trợ routing kép `PUT /api/v1/students/me/profile` và `PUT /api/v1/users/me/profile`.
- **Hạ Tầng Liên Dịch Vụ gRPC**:
  - Hợp nhất toàn bộ hợp đồng liên dịch vụ vào file chuẩn duy nhất [`grpc/identity.proto`](file:///d:/Capstone/grpc/identity.proto) (gồm `ValidateUserPermission`, `GetStudentProfileSummary`, và chuẩn bị các RPC `LinkParentStudent`, `GetParentStudents` cho phân hệ Parent).
  - Triển khai [`IdentityGrpcService.cs`](file:///d:/Capstone/All%20Services/V-Eval-Identity_Service/V-Eval-Identity_Service.API/Services/IdentityGrpcService.cs) trên cổng `5155`.
- **Chuẩn Hóa Kiến Trúc Chuyên Nghiệp & Phân Hệ Khảo Thí (`V-Eval-Content_Service`)**:
  - Triển khai **Result Pattern** (`Result<T>`, `Error`, `ErrorType`) và `ApiControllerBase` đồng bộ 100% với kiến trúc chuyên nghiệp của Identity Service.
  - Tích hợp **FluentValidation** qua `ValidationBehavior` trong MediatR pipeline và `GlobalExceptionHandlerMiddleware` bắt ngoại lệ 500 toàn cục.
  - Chuyển đổi toàn bộ Minimal APIs sang Controllers chuẩn RESTful (`DiagnosticController`, `MockExamsController`).
  - **Core Flow 1 (Bước 2)**: Cung cấp API `GET /api/v1/content/diagnostic-test` trả về bộ đề thi chẩn đoán 30 câu hỏi chuẩn V-ACT, bảo mật chống gian lận 100% (ẩn `CorrectOption` và `Explanation`).
  - Tự động Seeding đề chẩn đoán 30 câu vào Supabase schema `content` khi ứng dụng khởi động (`DiagnosticExamSeeder`).
  - Cung cấp **Swagger UI** tại `http://localhost:5249/swagger` và bổ sung server gRPC `GetExamAnswerKey` phục vụ Practice Service chấm điểm bài thi.
- **Triển Khai Hoàn Thiện Clean Architecture & Phân Hệ Thi Trực Tuyến (`V-Eval-Practice_Service`)**:
  - Triển khai **Clean Architecture 4 tầng** (`Domain`, `Application`, `Infrastructure`, `API`) đồng bộ 100% với Identity và Content Services.
  - Triển khai các thực thể `ExamSubmission`, `SubmissionAnswer` và ánh xạ bảng `practice.exam_submissions`, `practice.submission_answers` trên Supabase PostgreSQL.
  - Thiết lập kiến trúc cổng kép Kestrel (REST HTTP/1 và gRPC HTTP/2) cho toàn bộ microservices liên lạc trơn tru không lỗi giao thức: Identity Service (5155/5156), Content Service (5249/5250), Practice Service (5261).
  - **Core Flow 1 (Bước 3: Chấm Điểm Tự Động & Chẩn Đoán Năng Lực Đầu Vào)**:
    + Cung cấp endpoint `POST /api/v1/practice/diagnostic-submissions` tiếp nhận bài nộp 30 câu hỏi.
    + Tự động gọi gRPC sang Identity Service xác thực học sinh và bắt buộc chọn cơ sở (`CampusId`).
    + Tự động gọi gRPC sang Content Service lấy bảng đáp án bảo mật, độ khó câu hỏi và mã kỹ năng.
    + Chấm điểm thô chính xác (thang điểm 0–30), ghi nhận vi mô thời gian phản hồi (`time_spent_seconds`) từng câu.
    + Phân tích chẩn đoán năng lực: phân tách `SkillBreakdown`, nhận diện kỹ năng yếu `WeakSkillIds` (tỷ lệ đúng < 60%), và thống kê 4 mức độ khó (Dễ, Trung bình, Khó, Rất khó) sẵn sàng làm dữ liệu đầu vào cho AI Subsystem phân lớp.
    + Cung cấp API tra cứu: `GET /api/v1/practice/diagnostic-submissions/{id}` (xem chi tiết toàn diện 30 câu hỏi, đúng/sai, đáp án, độ khó, kỹ năng) và `GET /api/v1/practice/diagnostic-submissions/student/{studentId}` (danh sách tóm tắt lịch sử bài làm tinh gọn: điểm số, % chính xác, thời gian làm bài).
    + Cung cấp **Swagger UI** tại `http://localhost:5261/swagger`.
- **Kiểm Thử Toàn Diện (End-to-End Test)**:
  - `dotnet build` trên cả 3 services: **Thành công 100% (0 Error(s), 0 Warning(s))**.
  - Kiểm thử liên thông trọn vẹn Core Flow 1 từ Bước 1 (Đăng ký, Đăng nhập, Chọn cơ sở) -> Bước 2 (Lấy đề thi 30 câu) -> Bước 3 (Nộp bài, chấm điểm, thống kê kỹ năng yếu, lưu CSDL): **Thành công 100%**.

## [18/09/2026] - Bổ Sung Trọn Bộ 3 API Bảo Mật Cho Identity Service: Quên Mật Khẩu, Đặt Lại Mật Khẩu & Đăng Xuất
- **Nâng Cấp Nghiệp Vụ IAM & Bảo Mật Phiên**:
  - Triển khai thành công 3 Use Cases mở rộng chuẩn CQRS (MediatR) tại `V-Eval-Identity_Service`:
    + **UC 05: Quên Mật Khẩu (`POST /api/Auth/forgot-password`)**: Sinh OTP 6 số lưu bảng `iam.otp_verifications` (`Type = "RESET_PASSWORD"`).
    + **UC 06: Đặt Lại Mật Khẩu (`POST /api/Auth/reset-password`)**: Xác thực OTP, cập nhật mật khẩu băm BCrypt, tự động thu hồi (revoke) toàn bộ Refresh Token cũ trên mọi thiết bị qua `RevokeAllByUserIdAsync`.
    + **UC 07: Đăng Xuất (`POST /api/Auth/logout`)**: Thu hồi Refresh Token (`is_revoked = true`) vô hiệu hóa phiên làm việc hiện tại.
  - Đồng bộ và hoàn thiện toàn diện bộ tài liệu chuẩn (`daily.md`, `process.md`, `architecture_acceptance.md`).
  - Giải pháp biên dịch sạch 100% không cảnh báo hay lỗi cú pháp (`dotnet build`).

## [18/09/2026] - Chuẩn Hóa Tên Bộ Tài Liệu Docs Toàn Bộ Microservices & Cấu Hình AI Rules
- **Chuẩn Hóa Bộ File Tài Liệu `docs/` Cho Tất Cả 5 Microservices**:
  - Đổi tên & đồng bộ toàn bộ tài liệu tiến độ của tất cả các service về 3 file chuẩn duy nhất:
    1. **`docs/daily.md`**: Nhật ký kiểm tra tiến độ hằng ngày.
    2. **`docs/process.md`**: Lộ trình và quy trình phát triển dịch vụ.
    3. **`docs/architecture_acceptance.md`**: Báo cáo nghiệm thu & thấu hiểu kiến trúc (Đã chuyển sang tiếng Anh).
  - Giữ nguyên tất cả các file tài liệu nghiệp vụ đặc thù khác trong thư mục `docs/`.
- **Khởi Tạo Bộ Quy Tắc Hệ Thống Cho AI Assistant (`AGENTS.md` & `.agents/rules/documentation_workflow.md`)**:
  - Thiết lập quy tắc bắt buộc **Documentation First**: AI **BẮT BUỘC** phải cập nhật đầy đủ file `UPDATE.md`, `daily_check_log.md` và tài liệu kiến trúc của từng service trước khi đề xuất hoặc thực hiện các lệnh Git Add / Commit / Push.
  - Quy định quy trình 3 bước nghiêm ngặt: (1) Code & Test, (2) Cập nhật docs & `UPDATE.md` của ngày hôm đó ở đầu file, (3) Mới được hỏi/thực hiện Commit & Push.
- **Phát Hành Công Cụ Push Độc Lập Cho Từng Service (`Scripts/push.bat`)**:
  - Đóng gói file script [`Scripts/push.bat`](file:///e:/CapStone/All%20Services/V-Eval-Gateway/Scripts/push.bat) độc lập tại từng microservice (`V-Eval-Gateway`, `V-Eval-Identity_Service`, `V-Eval-Content_Service`, `V-Eval-Practice_Service`, `V-Eval-Ai_Engine`).
  - **3 Chế độ Push thông minh**:
    1. *Push nhánh hiện tại*: Đẩy code trực tiếp lên nhánh làm việc hiện tại (`develop`, `main`, ...).
    2. *Chọn nhánh đã có*: Hiển thị danh sách các nhánh local hiện có dưới dạng **Menu đánh số trực quan** (không cần nhập thủ công tên nhánh).
    3. *Tạo nhánh mới*: Tạo và checkout sang nhánh feature mới tự động.
  - **Cơ chế Kiểm tra & Cảnh báo Đỏ (Red Warning) Lịch sử Git**:
    - Tự động chạy `git fetch origin` và kiểm tra sai lệch SHA giữa Local & Remote trước khi push.
    - Tự động `git pull` nếu code local bị chậm (behind).
    - **Cảnh báo Đỏ nổi bật** và ngắt quy trình Push ngay lập tức nếu phát hiện xung đột (Conflict / Divergence) để yêu cầu Developer xử lý thủ công an toàn.
- **Sửa Lỗi Dứt Điểm Bộ Script Hệ Thống (`Scripts/`)**:
  - Khắc phục các lỗi cú pháp Windows CMD Batch trên [`pull.bat`](file:///e:/CapStone/Scripts/pull/pull.bat), [`push.bat`](file:///e:/CapStone/Scripts/push/push.bat), [`setup.bat`](file:///e:/CapStone/Scripts/setup/setup.bat), [`run_docker.bat`](file:///e:/CapStone/Scripts/run_docker/run_docker.bat), [`run_local.bat`](file:///e:/CapStone/Scripts/run_local/run_local.bat).
  - Khắc phục triệt để lỗi escape quote `\"` tại lệnh `pushd`, lỗi ngoặc đơn `()` trong câu lệnh `echo` và scope nhãn `:PROCESS_PULL`.

## [16/09/2026 - 17/09/2026] - Đồng Bộ Cấu Trúc CSDL V2 ERD (PlantUML) & Chuẩn Hóa JWT Claims X-Headers Tại Gateway
- **Đồng Bộ 100% CSDL PostgreSQL Schema V2 (`docs/SQL/SQL.sql`)**:
  - Cập nhật DDL PostgreSQL khớp 100% với sơ đồ PlantUML `VACT_SCHEMA_V2_ERD`:
    - Bổ sung Cụm 1 & 2 (RBAC & Actor Profiles): `Campuses`, `Students`, `Teachers`, `Parents`, `AcademicManagers`, `AcademicDirectors`, `Administrators`.
    - Bổ sung Cụm 5 (Lớp học & Live): `Classes`, `ClassEnrollments`, `LiveSessions`, `LiveSessionAttendance`, `TeacherFeedback`.
    - Bổ sung Cụm 7, 8, 9 (AI RAG & Vận hành): `KnowledgeSources`, `TokenUsageLogs`, `SystemConfigs`.
- **Đồng Bộ JWT Claims & Nâng Cấp Gateway Claims Transformer**:
  - Nâng cấp [`ClaimsHeaderTransform.cs`](file:///e:/CapStone/All%20Services/V-Eval-Gateway/V-Eval-Gateway.API/Security/ClaimsHeaderTransform.cs): Bóc tách claim `campus_id` đính kèm vào Header **`X-Campus-Id`** cho các microservice nội bộ.
  - Hoàn thiện trọn bộ X-Headers: `X-User-Id`, `X-User-Role`, `X-User-Email`, `X-Campus-Id`, `X-Token-Expires-At`, `X-Token-Remaining-Seconds`, và `X-Token-Refresh-Required`.
- **Cập Nhật Hệ Thống Tài Liệu**:
  - Cập nhật nhật ký [`docs/daily_check_log.md`](file:///e:/CapStone/All%20Services/V-Eval-Gateway/docs/daily_check_log.md) và báo cáo nghiệm thu [`docs/nghiem_thu_va_thau_hieu_kien_truc.md`](file:///e:/CapStone/All%20Services/V-Eval-Gateway/docs/nghiem_thu_va_thau_hieu_kien_truc.md).

## [15/09/2026] - Dockerize Toàn Hệ Thống 5 Microservices & Chuẩn Hóa Orchestration Docker Compose
- **Khởi Tạo Dockerfile Multi-Stage .NET 9 Tinh Gọn Cho 5 Microservices**:
  - `All Services/V-Eval-Gateway/Dockerfile`: Cổng `5212` (Gateway YARP Proxy).
  - `All Services/V-Eval-Ai_Engine/Dockerfile`: Cổng `5104` (AI Exam Ingestion & Chatbot).
  - `All Services/V-Eval-Content_Service/Dockerfile`: Cổng `5249` (Ngân hàng câu hỏi & Đề thi).
  - `All Services/V-Eval-Identity_Service/Dockerfile`: Cổng `5001` (Quản lý Người dùng & JWT Auth).
  - `All Services/V-Eval-Practice_Service/Dockerfile`: Cổng `5002` (Thi trực tuyến & Chấm điểm).
- **Chuẩn Hóa Docker Compose Orchestration (`docker-compose.yml`)**:
  - Điều phối 5 container microservice kết nối qua mạng nội bộ bridge `veval_network`.
