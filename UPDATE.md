# Nhật Ký Cập Nhật (Update Log) - System Repo

## [11/10/2026] - Triển Khai Giai Đoạn 5 Core Flow 4 GraphRAG AI Tutor: Tích Hợp Practice Service .NET 9 & SSE Streaming Proxy

- **Hoàn Thành Giai Đoạn 5 (Tích Hợp Practice Service .NET 9 & SSE Streaming Proxy — `V-Eval-Practice_Service`)**:
  - `Application/Common/Interfaces/IAiTutorClient.cs`: Định nghĩa hợp đồng client gọi Socratic Tutor với phương thức stream thời gian thực `StreamSocraticGuidanceAsync` (`IAsyncEnumerable<string>`) và gọi đồng bộ `AskSocraticGuidanceAsync` (`Task<SocraticAskResponseDto?>`).
  - `Infrastructure/HttpClients/AiTutorClient.cs`: Hiện thực hóa HTTP client đọc dòng dữ liệu SSE từ FastAPI AI Engine, phân tích cú pháp JSON token sự kiện, tích hợp cơ chế Resilient Socratic Fallback tự động khi AI Engine bận hoặc mạng lỗi.
  - `API/Program.cs`: Cấu hình Rate Limiting `StrictTutorPolicy` (10 requests/phút) với HTTP 429 và kích hoạt middleware `UseRateLimiter`.
  - `API/Controllers/AiTutorController.cs`: Triển khai 2 endpoint `POST /api/practice/ai-tutor/ask-stream` (SSE text/event-stream) và `POST /api/practice/ai-tutor/ask` (JSON đồng bộ), giải mã định danh học sinh từ Gateway Header `X-User-Id`.
  - Kiểm thử & Vận hành: Biên dịch toàn bộ solution `V-Eval-Practice_Service.sln` đạt 100% thành công (0 warning, 0 error).
- **Tài Liệu Kỹ Thuật & Cập Nhật Hệ Thống**:
  - Cập nhật chi tiết tiến độ tại `docs/daily.md`, `docs/process.md` (mục 47), và `docs/architecture_acceptance.md` (Mục 7).
