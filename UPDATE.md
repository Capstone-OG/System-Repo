# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [12/10/2026] - Hợp Nhất Hoàn Tất Toàn Diện Core Flow 3 (Module 3) & Core Flow 4 (GraphRAG Socratic AI Tutor)

- **Hoàn Tất Toàn Diện Core Flow 3 (Module 3 — Thi Thử Mô Phỏng & Giám Sát Liêm Chính)**:
  - `ExamSubmissions` & `ProctoringSnapshots`: Bổ sung 4 trường liêm chính (`TabDepartureCount`, `IntegrityStatus`, `MentorVerdict`, `MentorNotes`) và lưu vết webcam hậu kiểm.
  - Bộ 6 APIs Thi thử chuẩn hóa: `POST /mock-exams/{examId}/start` (khởi tạo đề thi 120 câu ĐGNL), `POST /{submissionId}/log-tab-departure` (cắm cờ rời tab > 3 lần), `POST /{submissionId}/upload-snapshot` (ảnh webcam), `POST /{submissionId}/submit` (chấm điểm 1200, nạp câu sai vào SM-2), `GET /{submissionId}` (visual audit trail), `PATCH /{submissionId}/mentor-review` (Mentor thẩm duyệt gian lận).
- **Hoàn Thành Giai Đoạn 6 (Human-in-the-Loop Feedback & Mentor Studio — `V-Eval-Ai_Engine`)**:
  - `rag-service/routers/socratic_tutor.py`: Bổ sung bộ 4 endpoint API hoàn thiện vòng lặp phản hồi:
    - `POST /api/v1/socratic/interactions/{id}/report`: Ghi nhận cờ báo cáo sai từ học sinh (`student_reported = TRUE`) và lưu lý do.
    - `GET /api/v1/socratic/interactions`: Truy vấn lịch sử tương tác đa chiều hỗ trợ lọc `reported_only`, kết nối dữ liệu Dạng bài chuẩn (`pattern_name`, `core_theory_latex`) và Bẫy nhận thức (`pattern_traps`).
    - `POST /api/v1/socratic/interactions/{id}/override-exemplar`: Mentor Hành động 1 — Lưu lời giải mẫu chuẩn do Mentor chỉnh sửa vào bảng `v_eval_ai.pattern_exemplars` và cập nhật trạng thái `OVERRIDDEN_EXEMPLAR_SAVED`.
    - `POST /api/v1/socratic/interactions/{id}/add-trap`: Mentor Hành động 2 — Bổ sung bẫy tư duy mới phát hiện vào bảng `v_eval_ai.pattern_traps` và cập nhật trạng thái `NEW_TRAP_ADDED`.
    - `GET /api/v1/socratic/view-mentor`: Phục vụ giao diện thẩm định Mentor Studio.
  - `V-Eval-Ai_Engine.API/wwwroot/view-tutor-mentor.html`: Xây dựng giao diện web Mentor Studio phong cách Glassmorphic Dark Mode hiện đại, tích hợp KaTeX kết xuất công thức toán học STEM, thanh tra Subgraph Context và form hành động nhanh lưu Lời giải mẫu / Bẫy tư duy vào đồ thị tri thức.
  - `V-Eval-Ai_Engine.API/Endpoints/ExamEndpoints.cs`: Ánh xạ route `GET /api/ai-engine/view-tutor-mentor` phục vụ trực tiếp qua .NET Engine.
  - Kiểm thử: Xây dựng bộ test `rag-service/tests/test_socratic_mentor.py` với 5/5 unit tests passed. Toàn bộ 37/37 unit tests của AI Engine đạt 100%.
- **Tích Hợp Dịch Vụ Thực Hành (`V-Eval-Practice_Service`)**:
  - `Application/Common/Interfaces/IAiTutorClient.cs`: Mở rộng giao thức `ReportInteractionAsync` và `GetInteractionsAsync`.
  - `Infrastructure/HttpClients/AiTutorClient.cs`: Hiện thực hóa HTTP client gọi dịch vụ AI Engine kèm cơ chế Resilient Fallback bảo đảm hệ thống vận hành liên tục.
  - `API/Controllers/AiTutorController.cs`: Cung cấp endpoint `POST /api/practice/ai-tutor/report` (giải mã `StudentId` từ `X-User-Id` header) và `GET /api/practice/ai-tutor/interactions`.
  - Biên dịch .NET 9: Toàn bộ solution `V-Eval-Practice_Service.sln` biên dịch sạch 100% (0 warning, 0 error).
- **Nghiệm Thu Kiến Trúc Hồ Sơ Năng Lực Học Sinh & Phân Cụm Vi Mô (Practice Service)**:
  - Làm rõ cơ chế kết hợp giữa Vector Đặc Trưng Miền Vĩ Mô (`double[4] DomainFeatures [Lang, Math, NatSci, SocSci]`) làm tọa độ gom cụm K-Means++ và Điểm Kỹ Năng Vi Mô (`SkillScores Dictionary`) để truy xuất điểm nghẽn kiến thức (`MasteryScore < 0.60`).
  - Xác nhận tính toàn vẹn của ràng buộc trần sĩ số lớp offline 20 học sinh và quy mô phân nhóm vi mô 3 - 5 học sinh/bàn (`ClassMicroClusterer`).
- **Nghiệm Thu Kiến Trúc Ngân Hàng Câu Hỏi & Đóng Gói Đề Quiz Thích Ứng (Content Service - APIs 16 - 19)**:
  - Hoàn tất đặc tả kỹ thuật và thiết kế kiến trúc Clean Architecture/CQRS cho bộ 4 REST APIs:
    - `POST /api/content/questions` (API 16 - Thêm câu hỏi LaTeX, Bloom 1-6, IRT difficulty).
    - `PUT /api/content/questions/{id}` (API 17 - Hiệu đính nội dung câu hỏi).
    - `DELETE /api/content/questions/{id}` (API 18 - Xóa mềm/vô hiệu hóa câu hỏi).
    - `POST /api/content/exams/quiz` (API 19 - Đóng gói đề Quiz củng cố 5-10 câu hỏi theo `CommonWeakSkillIds` kết nối trực tiếp với bàn học của Practice Service).
  - Khởi tạo và đẩy lên nhánh `ThinhTT/feature-content-questions-quiz-apis` trong Content Service sẵn sàng bước vào giai đoạn code.
- **Tài Liệu Kỹ Thuật & Cập Nhật Hệ Thống**:
  - Cập nhật nhật ký chi tiết tại `docs/daily.md`, `docs/process.md` và `docs/architecture_acceptance.md` của các service liên quan.
