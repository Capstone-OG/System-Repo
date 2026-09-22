# Nhật Ký Cập Nhật (Update Log)

## [22/09/2026] - Hoàn Tất Toàn Diện Core Flow 1: Engine IRT & BKT Priors (AI Engine) và Tích Hợp Xếp Lớp Tự Động (Practice Service)
- **AI Engine (`rag-service`)**:
  - Triển khai `rag-service/diagnostic_engine.py`: Module toán học cốt lõi tính toán năng lực học sinh `theta_0` theo mô hình IRT 2-Parameter Logistic (2PL) với Maximum A Posteriori (MAP) Estimation, hàm phạt Gaussian Prior `N(0, 2.0^2)` và thuật toán tối ưu hóa Brent (`scipy.optimize.minimize_scalar`).
  - Tích hợp cơ chế triệt tiêu đoán mò thần tốc (< 5 giây): hạ tham số phân biệt `a -> 0.1` để ngăn chặn hiện tượng làm bừa nhưng ăn may làm sai lệch năng lực thực tế.
  - Tính toán xác suất thành thạo ban đầu BKT Prior `P(L0) = Sigmoid(theta)` cho từng kỹ năng với cơ chế kẹp an toàn `[0.05, 0.95]`.
  - Xử lý tình huống không hoàn hảo (unhappy case): các kỹ năng không có câu hỏi trong đề rút gọn 30 câu tự động kế thừa `P(L0)` suy diễn từ năng lực miền cha.
  - Phân loại xếp lớp chuẩn mực 3 cấp: `FOUNDATION` (`theta < -0.5`), `ACCELERATION` (`-0.5 <= theta <= 0.5`), `BREAKTHROUGH` (`theta > 0.5`).
  - Dựng tọa độ biểu đồ Radar so sánh năng lực học sinh theo từng miền với điểm chuẩn benchmark dựa trên mục tiêu điểm thi (V-ACT target score).
  - Triển khai `POST /api/v1/diagnostic/analyze` và `GET /api/v1/diagnostic/config` trong `rag-service/routers/diagnostic.py`, tích hợp lời nhận xét sư phạm tích cực từ Google Gemini (`gemini-3.5-flash`).
  - Hoàn thành bộ kiểm thử 10/10 test cases đơn vị và tích hợp endpoint với 100% PASS rate (`tests/test_diagnostic.py`).
- **Practice Service (`V-Eval-Practice_Service`)**:
  - Triển khai `IAiDiagnosticClient` & `AiDiagnosticClient`: HTTP Client kết nối API phân tích năng lực của AI Engine kèm cơ chế Resilient Local Fallback chống nghẽn dịch vụ (Zero-Blocking).
  - Mở rộng thực thể Domain & EF Core `PracticeDbContext`: Ánh xạ `ExamSubmission` (bổ sung `Theta0`, `PlacementClass`, `AiCommentary`, `EnrolledClassId`), `LearningProfile` (bảng `LearningProfiles`), `Class` (bảng `Classes`) và `ClassEnrollment` (bảng `ClassEnrollments`).
  - Triển khai `ILearningProfileRepository` & `LearningProfileRepository`: Lưu trữ ma trận xác suất làm chủ ban đầu $P(L_0)$ cho mô hình BKT.
  - Triển khai `IClassEnrollmentRepository` & `ClassEnrollmentRepository`: Tự động tìm kiếm/khởi tạo lớp học tại cơ sở (`CampusId`) theo phân lớp và tạo bản ghi ghi danh (`ENROLLED`).
  - Nâng cấp `SubmitDiagnosticCommandHandler`: Khép kín toàn bộ luồng 5 bước từ nộp bài, chấm điểm, chẩn đoán AI, lưu BKT Priors, xếp lớp Campus và trả về Biểu đồ Radar đa giác trong $< 2$ giây (Happy Case).
  - Di trú schema CSDL PostgreSQL: Bổ sung 4 cột mới vào `practice.exam_submissions` và tạo các bảng `LearningProfiles`, `Classes`, `ClassEnrollments`.
  - Trực quan hóa DTO dữ liệu trả về: Bổ sung tên kỹ năng (`SkillName`), tên môn học (`DomainName`), cơ sở đào tạo (`CampusName`), đối tượng kỹ năng yếu trực quan (`WeakSkills`) và phân tách đa trục Biểu đồ Radar đa giác.
  - Kiểm thử trực tiếp End-to-End thành công 100% qua Swagger UI: Trả về kết quả chẩn đoán, xếp lớp tự động `FOUNDATION`, tạo lớp tại cơ sở và lưu trữ 12 BKT Priors.
  - Biên dịch toàn bộ giải pháp .NET 9 sạch: 0 Warning(s), 0 Error(s).
- **Tài Liệu & Tiến Độ**:
  - Cập nhật đồng bộ `docs/daily.md`, `docs/process.md`, `docs/architecture_acceptance.md` và `UPDATE.md` của AI Engine, Practice Service và System Repo.

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
