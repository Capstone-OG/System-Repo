# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [14/10/2026] - Chuyển Đổi Dàn Kiến Thức Thành Dữ Liệu Động Từ Database & Liên Thông API 19

- **Gỡ Bỏ Hoàn Toàn Hardcode Dàn Kiến Thức Trên Frontend (Web Client)**:
  - Xóa bỏ toàn bộ dữ liệu tĩnh `DOMAINS_DATA` trên Frontend.
  - Tích hợp `contentService.getCurriculum()` gọi API Gateway `GET /api/content/curriculum` để nạp trực tiếp toàn bộ 4 miền năng lực và 12 kỹ năng chuẩn từ cơ sở dữ liệu.
- **Triển Khai REST API Dàn Kiến Thức Trên Content Service**:
  - Xây dựng `CurriculumController.cs` và `GetCurriculumTreeQuery.cs` truy vấn cơ sở dữ liệu EF Core (`CompetencyDomains`, `Skills`, `Materials`, `Questions`).
  - Phục vụ động toàn bộ sơ đồ tri thức liên môn GraphRAG, công thức KaTeX, câu hỏi mẫu và bài giảng video.
- **Liên Thông Tự Động Practice Service <-> Content Service (Core Flow 2 - API 19)**:
  - Triển khai `IContentHttpClient` và `ContentHttpClient` trong Practice Service kết nối REST API `POST /api/content/exams/quiz` của Content Service.
  - Tự động trích xuất `CommonWeakSkillIds` từ nhóm học tập vi mô khi giáo viên bỏ trống `WorksheetId` để đóng gói tức thì đề củng cố thích ứng.
- **Hợp Nhất Phân Hệ Khảo Sát Năng Lực & Định Vị Vùng Trũng Động**:
  - Nhúng trực tiếp `DiagnosticAssessmentPage` (`embedded = true`) vào Dashboard học sinh.
  - Tự động định vị và gắn cờ củng cố `⚠️ Vùng trũng` cho các kỹ năng có xác suất làm chủ $P(L_t) < 0.60$.
- **Trạng Thái Kiểm Thử Vận Hành Toàn Hệ Thống**:
  - `V-Eval-Content_Service.sln`: Biên dịch sạch 100% (**0 Warning, 0 Error** trên .NET 9).
  - `V-Eval-Practice_Service.sln`: Biên dịch sạch 100% (**0 Warning, 0 Error** trên .NET 9).
  - `V-Eval-Web_Client`: `npm run build` thành công 100% (**0 Error, 0 Warning**).
  - Nhánh duy nhất đồng bộ: `ThinhTT/feature-question-bank-adaptive-quiz`.
