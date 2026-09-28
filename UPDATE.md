# Nhật Ký Cập Nhật (Update Log) - System Repo

## [28/09/2026] - Tối Ưu Hóa Luồng Textbook RAG & Chuẩn Hóa Kiến Trúc AI Engine

- **Tối Ưu Single-Pass CryptoStream & Khử Trùng Lặp Tệp (`TextbookEndpoints.cs`)**:
  - Tích hợp `CryptoStream` bọc ngoài `FileStream` khi upload SGK, tính mã băm SHA-256 đồng thời trong 1 lượt đọc, cắt giảm 50% Disk I/O cho file lớn (100MB-250MB) và rút ngắn một nửa thời gian xử lý.
  - Tự động nhận diện và dọn dẹp file tạm trùng lặp (`File.Delete`) khi tệp đang được tiến trình nền xử lý (`PROCESSING`), chống phình đĩa máy chủ.
  - Động hóa danh sách mô hình kiểm tra độ trễ Vision AI `/ping-vision` từ cấu hình `AiSettings:GeminiModels`.
- **Chuẩn Hóa Động Cơ Bóc Tách Đề Thi (`GeminiExamParserService.cs`)**:
  - Triệt tiêu hoàn toàn các mô hình cũ bị lỗi HTTP 404 (`gemini-1.5-flash`, `gemini-2.0-flash`), đồng bộ sang 5 mô hình chuẩn: `gemini-flash-lite-latest`, `gemini-3.5-flash-lite`, `gemini-3.1-flash-lite`, `gemini-3.8-flash`, `gemini-3.6-flash`.
  - Động hóa ngưỡng số câu hỏi thành công (`AiSettings:MinQuestionThreshold`), hỗ trợ các đề thi rút gọn (30-40 câu) mà không bị rơi vào vòng lặp retry quá tải.
  - Hỗ trợ cấu hình `AiSettings:GeminiBaseUrl`, `AiSettings:OpenAiBaseUrl` và bộ thực thi Python đa nền tảng (`python` trên Windows, `python3` trên Linux/Docker).
- **Tối Ưu Cấu Hình Timeout HttpClient Qua `appsettings.json` (`DependencyInjection.cs`)**:
  - Loại bỏ hoàn toàn hardcode timeout, đưa `ExamParserTimeoutMinutes = 8` và `TextbookParserTimeoutMinutes = 10` vào cấu hình hệ thống.
- **Hoàn Tất Hồ Sơ Nghiệm Thu Kiến Trúc 3 Hạng Mục Bởi `ThinhTran2412`**:
  - Cập nhật đầy đủ hồ sơ nghiệm thu chi tiết tại [`All Services/V-Eval-Ai_Engine/docs/architecture_acceptance.md`](./All%20Services/V-Eval-Ai_Engine/docs/architecture_acceptance.md) cho: Minimal API Streaming, Raw SQL Npgsql Repository, và Gemini Vision Exam Parser.
- **Hoàn Thiện Core Flow 1 — Kịch Bản Ngoại Lệ (Unhappy Case 2: Khóa Đề Quá Hạn 24h & Đề Thi Ngẫu Nhiên Mới)**:
  - **Practice Service (`SubmitDiagnosticCommandHandler.cs`)**: Triển khai cơ chế kiểm tra phiên làm bài bỏ dở quá 24h (`TotalHours > 24` hoặc `TimeSpentSeconds > 86400`), tự động ghi nhận bản ghi `Status = "EXPIRED"`, khóa đề thi cũ và trả về mã lỗi chuẩn RFC 7807 `Exam.Expired`. Tự động từ chối nộp lại đề thi đã khóa (`Exam.Locked`) hoặc đã hoàn thành (`Exam.AlreadyCompleted`).
  - **Content Service (`DiagnosticController.cs` & `GetDiagnosticTestQuery.cs`)**: Bổ sung tham số truy vấn `excludeExamId` cho endpoint `GET /api/v1/content/diagnostic-test` phục vụ yêu cầu làm lại bài chẩn đoán ngẫu nhiên khác khi đề cũ đã bị khóa.
  - **Đồng Bộ DTOs Toàn Hệ Thống**: Bổ sung trường `Status` vào `SubmitDiagnosticResponseDto` và `DiagnosticSubmissionSummaryDto`.
- **Kiểm Thử Vận Hành & Build**:
  - Toàn bộ solution liên quan (`V-Eval-Practice_Service.sln`, `V-Eval-Content_Service.sln`, `V-Eval-Ai_Engine.sln`) biên dịch sạch 100% (**0 Error, 0 Warning**).
