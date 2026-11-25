# UPDATE - V-EVAL SYSTEM REPO

## [25/11/2026] - Tối Ưu Supabase Egress (>95%), Nhúng Vector 768 Chiều pgvector HNSW & Hoàn Thiện UX Kho Đề MUI

- **Khắc Phục Triệt Để Lỗi Egress 29.57 GB Trên Supabase (`V-Eval-Content_Service`, `V-Eval-Practice_Service`, `V-Eval-Web_Client`)**:
  - **Content Service**: Cache `IMemoryCache` + `SemaphoreSlim` cho `GetSkillsTree` (30 phút), `GetExamAnswerKey` (15 phút), `GetSkillsLookupAsync` (30 phút, chỉ chiếu 3 cột thay vì `SELECT *`); tách 3 truy vấn độc lập trong `GetCurriculumTreeQuery` (chỉ lấy tối đa 1 câu hỏi mẫu/kỹ năng thay vì toàn bảng `Questions`); nâng TTL `CurriculumController` lên 30 phút và tự động vô hiệu hóa cache khi ghi.
  - **Practice Service**: Kích hoạt `QuerySplittingBehavior.SplitQuery` toàn cục trên `PracticeDbContext`; cache phía client trong `ContentGrpcClient` (`GetSkillsTreeAsync` 30 phút, `GetExamAnswerKeysAsync` 15 phút); bổ sung `GetSummariesByStudentIdAsync` dùng `.AsNoTracking().Select(...)` loại bỏ `SubmissionAnswers` & `AiCommentary` trên luồng Dashboard.
  - **Web Client**: Bổ sung TTL cache + in-flight Promise deduplication cho `contentService.getCurriculum()` (15 phút) và `practiceService.getMyRoadmap()` / `getStudentDashboard()` (30 giây).
- **Nhúng Vector 768 Chiều & Backfill pgvector HNSW (`V-Eval-Ai_Engine`)**:
  - Triển khai `GeminiEmbeddingService` (`gemini-embedding-001`, 768 chiều L2-normalized) + `PgVectorDbService` (HNSW `<=>` + mở rộng ngữ cảnh lân cận) và backfill hoàn tất **708/708** chunks SGK trên Supabase (`missing = 0`).
- **Hoàn Thiện UX Kho Đề / Xem Đề MUI (`V-Eval-Web_Client`)**:
  - Tách thẻ tiêu đề, phân trang 5 câu/trang, nút AI tạo lời giải, chuyển toàn bộ dropdown và popup đổi đề sang MUI (`npm run build` pass 0 lỗi).
