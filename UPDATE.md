# Nhật Ký Cập Nhật (Update Log) - System Repo

## [08/10/2026] - Khởi Động Triển Khai Core Flow 3: Luyện Tập Thích Ứng P-L-A-R (Bước 0 & API 1: StartStage)

- **Biên Soạn Bản Kế Hoạch Kỹ Thuật Toàn Diện Core Flow 3 [`docs/ke_hoach_trien_khai_core_flow_3_adaptive_practice.md`](./docs/ke_hoach_trien_khai_core_flow_3_adaptive_practice.md)**:
  - Phân định rõ phạm vi trách nhiệm: Độc lập với Core 1 và Core 2 (phân cụm xếp lớp do đồng đội phụ trách); tập trung 100% vào Chu trình tự học thích ứng P-L-A-R, Sổ tay lỗi sai & Lặp lại ngắt quãng, Gói bài phân hóa trên lớp, và Phòng thi thử mô phỏng Proctored.
  - Thiết kế lược đồ CSDL PostgreSQL schema `practice` cho 5 bảng: `stage_progress`, `adaptive_quiz_attempts`, `mistake_notebook`, `mock_exam_submissions`, `proctoring_snapshots`.
- **Triển Khai Mã Nguồn Practice Service (Bước 0 & API 1)**:
  - Mở rộng Domain Entities: [`StageProgress.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Domain/Entities/StageProgress.cs) và [`AdaptiveQuizAttempt.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Domain/Entities/AdaptiveQuizAttempt.cs).
  - Cấu hình EF Core Fluent API trong `PracticeDbContext`, đăng ký `IStageProgressRepository` & `StageProgressRepository`.
  - Hiện thực API 1: `POST /api/practice/stages/{roadmapNodeId}/start` (khởi tạo tiến trình `StageProgress` tại bước `PREVIEW` và cấp 3 câu Quick Check khởi động).
  - Xây dựng Controller [`StagesController.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.API/Controllers/StagesController.cs) với route chuẩn không có `v1`: `[Route("api/practice/stages")]`.
  - Biên dịch toàn bộ Solution `V-Eval-Practice_Service.sln` sạch 100% (**0 Warning, 0 Error**).
