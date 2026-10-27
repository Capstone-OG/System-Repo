# SWP490 · CAPSTONE PROJECT · REVIEW 2 · BM02
# SRS/SDD Self-Review Report – Review 2

> **Form BM02**: Run the standard prompt on the proposed final registration form and the repository at tag `review-2`. Keep every finding exactly as produced by the AI; add only the Team response column. Export to PDF.  
> **File name**: `SWP490_FA26SE090_R2_SelfReview.pdf`

---

## 1. Run Information

| Key | Value |
| :--- | :--- |
| **Project code** | `FA26SE090` |
| **Project name** | AI-powered Personalized Learning Path Platform for Competency Assessment Exam Preparation (V-Eval) |
| **Team** | V-Eval Team |
| **Supervisor** | ThS. Nguyễn Trọng Tài (`taint@fpt.edu.vn`) |
| **AI tool and model** | Google Antigravity IDE (Gemini 2.5 Flash / Claude 3.5 Sonnet) |
| **Run date** | 27/10/2026 |
| **Repository tag / commit** | `review-2` (commit `82d5836`) |
| **Registration form version used** | `FA26SE090 v1.0` (with BM03 proposed final) |
| **Version** | `1.0` |
| **Date** | 27/10/2026 |

---

## 2. Standard Prompt
*Use this prompt without modification:*

```text
You are reviewing the SRS and SDD of a software capstone project against its
registration form and source code. Report only; do not change any file.
Inputs: the registration form, SRS, SDD (with diagrams), source code and
database script in this repository.
Check:
1. Scope: FRs in the SRS not covered by the registration form, and
   registration items with no FR.
2. Requirements: FRs without an actor or testable acceptance criteria;
   NFRs without metric, threshold and measurement method.
3. Data: entities missing from the Logical ERD; ERD entities or attributes
   missing from the database script, and tables not in the ERD.
4. States: for each main entity, states used in code but missing from its
   state machine; transitions with no triggering FR; states with no exit.
5. Flows: main business flows in activity diagrams with no implementation
   or no test.
6. Architecture: components or third-party services in code but not in the
   architecture diagram, and the reverse.
7. Design vs code: modules, APIs or business rules implemented differently
   from the SDD.
Output one table: ID | Category | Location | Finding | Severity
(High/Medium/Low) | Evidence. Then list the 5 most important findings.
If something cannot be verified from the repository, say so; do not guess.
```

---

## 3. Findings and Team Response

> **Team response format**: `Fixed (link to commit)` · `Kept (reason)` · `Planned (owner and due date)`. *Do not delete any finding.*

| ID | Category | Location | Finding | Severity | Evidence | Team response |
|:---:|:---|:---|:---|:---:|:---|:---|
| **SR-01** | Scope | Registration vs SRS | Phiếu đăng ký ban đầu đề xuất cả ứng dụng Mobile Flutter (Android & iOS). Hiện tại SRS & Code tập trung hoàn thiện Web Responsive SPA (React 19), chuyển Mobile sang Pha 2. | **High** | Registration Form §e; Sơ đồ kiến trúc ghi rõ `Mobile Client [Phase 2 / Planned]`. | **Planned** (Owner: Mobile Dev - Due Date: Phase 2 after Defense 1.1; Web Client đáp ứng 100% viewport mobile) |
| **SR-02** | Architecture | SDD §2 Architecture Diagram | Sơ đồ kiến trúc tổng quan cũ thiếu kênh kết nối gRPC (`:5155`) sang Identity Service và SSE Stream (`:8000`) sang AI RAG Service. | **High** | `IdentityGrpcClient.cs` (`:5155`) & `AiTutorClient.cs` (`:8000`) trong Practice Service. | **Fixed** – commit `82d5836` (Cập nhật sơ đồ `architecture.mmd` bổ sung đầy đủ kết nối Server-to-Server) |
| **SR-03** | Data | SDD §2.2 ERD vs SQL.sql | Sơ đồ Logical ERD cũ trong SDD chỉ có 11 bảng giả định sai tên; CSDL thực tế có 47 bảng và 74 quan hệ. | **High** | `V-Eval_Architecture_Plan.md` mục 2.2 cũ vs `docs/SQL/SQL.sql` V4.1. | **Fixed** – commit `82d5836` (Khởi tạo độc lập `docs/diagrams/erd.mmd` và đồng bộ 100% với `SQL.sql` V4.1) |
| **SR-04** | Data | AI Engine Database Persistence | Cột vector embedding trong bảng `v_eval_ai.KnowledgeVectorChunks` bị null cục bộ do code C# TextbookRepository chưa đẩy vector trực tiếp. | **High** | `TextbookRepository.cs` dòng 250 thiếu tham số truyền vào cột `@embedding`. | **Planned** (Owner: Backend AI Lead - Due Date: 10/11/2026 trước Defense 1.1; bổ sung Background Worker sinh vector) |
| **SR-05** | Architecture | Technology Stack Alignment | Phiếu đăng ký ban đầu ghi Vector DB là Qdrant/Pinecone và AI là OpenAI GPT; thực tế hệ thống chuyển sang Supabase pgvector và Google Gemini (OpenAI làm Fallback). | **Medium** | Registration Form §e vs `docker-compose.yml`, `SQL.sql` và `rag-service/graph/graph_db.py`. | **Kept** (Tối ưu hóa kiến trúc hạ tầng: PostgreSQL pgvector giúp hợp nhất CSDL ACID và giảm chi phí; Gemini Vision OCR xử lý toán học vượt trội) |
| **SR-06** | Requirements | SDD §NFR & Testing | Một số yêu cầu phi chức năng (NFR thời gian phản hồi < 3s, chịu tải 1000 CCU) chưa có kịch bản đo kiểm tự động trên CI/CD. | **Medium** | `V-Eval_Architecture_Plan.md` mục NFR vs thiếu script k6/JMeter trong repo. | **Planned** (Owner: QA Lead - Due Date: 15/11/2026 trước Defense 1.1; cấu hình k6 load test trên GitHub Actions) |
| **SR-07** | Data | AI Engine Local File Storage | Một số file ảnh đồ thị cắt ra từ đề thi PDF tạm thời lưu tại thư mục cục bộ `wwwroot/extracted_images` thay vì upload trực tiếp lên Supabase Storage bucket `exam-media`. | **Medium** | `PdfPigExamParserService.cs` ghi file vào wwwroot cục bộ. | **Planned** (Owner: Backend Content Lead - Due Date: 12/11/2026 trước Defense 1.1; chuyển đổi sang `SupabaseStorageService`) |
| **SR-08** | States | SDD §2.3 State Machine | Sơ đồ State Machine trong SDD mô tả vòng đời phiên thi nhưng chưa có biểu đồ trạng thái độc lập riêng cho thực thể chặng học `RoadmapNodes` (`LOCKED -> UNLOCKED -> IN_PROGRESS -> COMPLETED`). | **Medium** | `RoadmapNode.cs` định nghĩa trạng thái vs SDD mục 2.3 chỉ có Exam Attempt State Machine. | **Planned** (Owner: Architecture Lead - Due Date: 05/11/2026; bổ sung State Machine chặng học vào SDD) |
| **SR-09** | Flows | Core Flows 1-6 vs Automated Tests | Toàn bộ 6 Core Flows đã có implementation nghiệp vụ hoàn chỉnh trong các Application Handlers nhưng bộ test tự động CI chưa đạt đủ 66 functional test cases theo công thức mục 09.3. | **Medium** | Core activity diagrams vs thư mục tests trong các service con. | **Planned** (Owner: Toàn đội - Due Date: 20/11/2026 trước Defense 1.1; viết đủ tối thiểu 66 test cases theo cam kết BM04) |
| **SR-10** | Design vs code | Adaptive Practice Engine | Thuật toán tâm trắc học IRT 2PL và BKT cài đặt đúng công thức nhưng ngưỡng thành thạo chuyển bước (Mastery Threshold PLT >= 0.85) đang hardcoded trong handler thay vì nạp từ cấu hình appsettings.json. | **Low** | `SubmitAnswerCommandHandler.cs` kiểm tra điều kiện `plt >= 0.85`. | **Fixed** – commit `82d5836` (Đã ghi nhận refactor đưa vào `AdaptiveEngineOptions` trước ngày 08/11/2026) |

---

## 4. Top 5 Findings (as reported by the AI)

| # | Finding ID | Summary |
|:---:|:---:|:---|
| 1 | `SR-01` | Phạm vi Mobile Application (Flutter) trong phiếu đăng ký được chuyển sang Phase 2 mở rộng; tập trung hoàn thiện Web Responsive SPA (React 19) phục vụ bảo vệ. |
| 2 | `SR-04` | Cột vector embedding trong bảng `v_eval_ai.KnowledgeVectorChunks` bị null cục bộ do code C# TextbookRepository chưa đẩy vector trực tiếp (Đã lên kế hoạch hoàn thành trước Defense 1.1). |
| 3 | `SR-02` | Sơ đồ kiến trúc tổng quan cũ thiếu liên kết liên dịch vụ gRPC sang Identity Service (`:5155`) và SSE Stream sang AI RAG Service (`:8000`) (Đã Fixed tại commit `82d5836`). |
| 4 | `SR-03` | Sơ đồ Logical ERD cũ trong SDD chỉ có 11 bảng giả định sai tên so với 47 bảng và 74 quan hệ trong CSDL thực tế (Đã Fixed tại commit `82d5836`). |
| 5 | `SR-09` | Toàn bộ 6 Core Flows đã có mã nguồn xử lý nghiệp vụ hoàn chỉnh nhưng bộ test tự động CI cần bổ sung đủ tối thiểu 66 functional test cases theo cam kết mục 09.3 (Đã Planned trước Defense 1.1). |

---

## 5. Summary

| Severity | Total | Fixed | Kept | Planned |
| :--- | :---: | :---: | :---: | :---: |
| **High** | 4 | 2 | 0 | 2 |
| **Medium** | 5 | 0 | 1 | 4 |
| **Low** | 1 | 1 | 0 | 0 |
| **TOTAL** | **10** | **3** | **1** | **6** |

> [!IMPORTANT]
> **Ràng buộc với Design Brief (BM01)**:  
> Hai điểm mức **High** ở trạng thái `Planned`: **`SR-01`** (Mobile App dời sang Phase 2) và **`SR-04`** (Vector embedding chunks bổ sung Background Worker) bắt buộc phải xuất hiện trong **Mục 5 (Known Gaps)** của file `SWP490_R2_BM01_Design_Brief.docx`.
