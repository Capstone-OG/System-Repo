# NHẬT KÝ CẬP NHẬT HỆ THỐNG (SYSTEM-REPO UPDATE LOG)

## [09/11/2026] - Tinh Gọn AI Engine: Tách Template Prompt Độc Lập, Refactor MultiCloudExamParserService Chuẩn Hóa Kiến Trúc Đa Đám Mây & Hoàn Thiện Bộ Kiểm Thử Tự Động

- **Hoàn Tất Thẻ Hotfix Kiến Trúc HF-AI-03 & HF-AI-04 ([`AI_Engine_Hotfix.md`](./docs_noi_bo/hotfix/AI_Engine_Hotfix.md))**:
  - Ghi nhận và nghiệm thu 100% hai thẻ sự cố kiến trúc trọng điểm của phân hệ AI Engine: `HF-AI-03` (Hardcoded Prompt trong code C#) và `HF-AI-04` (Thiếu Failover xoay vòng đa đám mây Gemini <-> OpenAI).

- **Tách File Prompt Template Độc Lập & Xây Dựng Prompt Template Service ([`V-Eval-Ai_Engine`](./All%20Services/V-Eval-Ai_Engine/))**:
  - **Triệt tiêu toàn bộ chuỗi Prompt gán cứng trong C#**: Di dời các chuỗi System Prompt dài hàng nghìn ký tự trong [`CurriculumAiService.cs`](./All%20Services/V-Eval-Ai_Engine/V-Eval-Ai_Engine.Infrastructure/Services/CurriculumAiService.cs), [`SocraticTutorService.cs`](./All%20Services/V-Eval-Ai_Engine/V-Eval-Ai_Engine.Infrastructure/Services/SocraticTutorService.cs), và [`MultiCloudExamParserService.cs`](./All%20Services/V-Eval-Ai_Engine/V-Eval-Ai_Engine.Infrastructure/Services/MultiCloudExamParserService.cs) ra 5 file template độc lập trong [`Templates/Prompts/`](./All%20Services/V-Eval-Ai_Engine/V-Eval-Ai_Engine.Infrastructure/Templates/Prompts/):
    - `CurriculumIngestion.prompt.txt`: Bóc tách chuyên đề, bài học và dạng bài SGK GDPT 2018.
    - `PatternAnalysis.prompt.txt`: Phân tích bản chất dạng bài, 4 bước giải, bẫy đề thi và kỹ thuật Casio fx-580/880.
    - `PracticeQuestionGenerator.prompt.txt`: Sinh câu hỏi rèn luyện thích ứng L3/L4 chống trùng lặp (`antiDuplicationNote`).
    - `SocraticTutor.prompt.txt`: Gia sư Socrates dẫn dắt tư duy, bảo mật đáp án.
    - `ExamIngestionVerbatimOcr.prompt.txt`: Bóc tách scan OCR nguyên văn 120 câu hỏi đề thi V-ACT.
  - **Dịch vụ nạp & cache Prompt hiệu năng cao**: Xây dựng [`IPromptTemplateService`](./All%20Services/V-Eval-Ai_Engine/V-Eval-Ai_Engine.Application/Interfaces/IPromptTemplateService.cs) và [`PromptTemplateService`](./All%20Services/V-Eval-Ai_Engine/V-Eval-Ai_Engine.Infrastructure/Services/PromptTemplateService.cs) với In-Memory Cache `ConcurrentDictionary`, cơ chế thế biến động `{{variable}}`, và Safe Defense Fallback string phòng thủ khi thiếu file. Cấu hình tự động copy template sang output directory khi build.

- **Refactor Chuẩn Hóa Kiến Trúc Đa Đám Mây: Đổi Tên `GeminiExamParserService` Thành `MultiCloudExamParserService`**:
  - **Khắc phục mùi mã nguồn Naming Smell**: Lớp bóc tách đề thi thực tế ưu tiên chạy **OpenAI GPT-4o Vision** ở Bước 1 và xoay vòng sang **Google Gemini** ở Bước 2. Đổi tên class & file thành `MultiCloudExamParserService` phản ánh chính xác 100% bản chất nghiệp vụ đa đám mây.
  - Tách 80 dòng chuỗi prompt OCR cũ ra file template `ExamIngestionVerbatimOcr.prompt.txt` và nạp động qua `IPromptTemplateService`.
  - Cập nhật đăng ký DI sạch sẽ trong `DependencyInjection.cs` (`services.AddHttpClient<IExamParserService, MultiCloudExamParserService>`).

- **Cơ Chế Failover Xoay Vòng Đa Đám Mây 2 Tầng (Gemini <-> OpenAI Cascade) & Ngưỡng An Toàn**:
  - Tích hợp `ResolveOpenAiKey()` và `ResolveOpenAiModels()` (`gpt-4o-mini`, `gpt-4o`, `o3-mini`) kết nối OpenAI Chat Completions với định dạng JSON (`response_format: { "type": "json_object" }`).
  - Thiết lập Failover 2 tầng: Tầng 1 (Google Gemini multi-models/multi-keys) -> Tầng 2 (OpenAI Chat Completions) -> Tầng 3 (Regex Real-Data Parser).
  - Kiểm soát Ngưỡng an toàn (Safety Threshold): `minChaptersThreshold >= 1` và `maxAttempts = 5`. Nếu mô hình trả về dưới ngưỡng, hệ thống tự động kích hoạt model fallback kế tiếp thay vì chấp nhận dữ liệu cụt lủn.
  - Áp dụng đồng bộ cho cả 3 luồng nghiệp vụ: `ExtractCurriculumAsync`, `AnalyzePatternAsync`, và `GeneratePatternQuestionsAsync`.

- **Kiểm Thử Tự Động & Đảm Bảo Vận Hành**:
  - Bổ sung bộ test unit mới [`PromptTemplateServiceTests.cs`](./All%20Services/V-Eval-Ai_Engine/V-Eval-Ai_Engine.Tests/Infrastructure/PromptTemplateServiceTests.cs) (6/6 tests).
  - Toàn bộ 12/12 tests trong `V-Eval-Ai_Engine.Tests` chạy thành công 100%.
  - Biên dịch toàn bộ solution `V-Eval-Ai_Engine.sln` đạt 100% Succeeded trên .NET 9.0 (0 Warning, 0 Error).

- **Nâng Cấp Multimodal Vision Ingestion Cho PDF Scan & Tối Đa Hóa Số Lượng Dạng Bài (6 - 12+ Patterns) ([`V-Eval-Ai_Engine`](./All%20Services/V-Eval-Ai_Engine/))**:
  - **Khắc phục triệt để hiện tượng PDF scan thiếu dạng bài**: Phân tích file Hóa học mẫu 55 trang (`Bài 1 - ĐA.pdf`), phát hiện file chứa 100% ảnh scan độ phân giải cao (`4260x6021`) và 0 ký tự text số hóa, khiến trước đây AI chỉ nhận câu placeholder và sinh ra 2 dạng sơ sài.
  - **Tự động kích hoạt Multimodal Vision Ingestion**: Khi phát hiện tài liệu ảnh scan (`actualTextChars < 300`), tự động trích xuất và tối ưu hóa các trang scan đại diện (chiều dài tối đa 960px, JPEG quality 65) truyền trực tiếp qua kênh Multimodal `inlineData` của Google Gemini và `image_url` của OpenAI GPT-4o.
  - **Tối đa hóa số lượng Dạng bài**: Nâng cấp `depthDirective` và template `CurriculumIngestion.prompt.txt` ép buộc AI bóc tách đầy đủ từ 6 đến 12+ dạng bài cho tài liệu chuyên đề lớn; phân định rõ thẻ hình học MathLab 3D cho Toán học và công thức phản ứng LaTeX chuẩn cho môn Hóa học/Khoa học tự nhiên.
  - Bộ kiểm thử `V-Eval-Ai_Engine.Tests` đạt 13/13 tests vượt qua 100%.

- **Khắc Phục Lỗi HTTP 413 Payload Too Large & Nâng Giới Hạn Tải Tệp Lên 250 MB ([`V-Eval-Gateway`](./All%20Services/V-Eval-Gateway/), [`V-Eval-Content_Service`](./All%20Services/V-Eval-Content_Service/))**:
  - **Xử lý nguyên nhân gốc rễ**: Khi tải tệp SGK hoặc đề thi PDF kích thước lớn (>28.6MB), Kestrel tại Gateway mặc định từ chối với lỗi `BadHttpRequestException: Request body too large. The max request body size is 30000000 bytes` (HTTP 413) khiến Web Client báo lỗi mất kết nối Gateway.
  - **Mở rộng Kestrel & FormOptions**: Nâng cấu hình `Limits.MaxRequestBodySize = 262_144_000` (250 MB) và `FormOptions.MultipartBodyLengthLimit = 262_144_000` tại cả `V-Eval-Gateway` và `V-Eval-Content_Service`, đồng bộ 100% với `V-Eval-Ai_Engine`.
  - Biên dịch sạch `0 Warning, 0 Error` trên toàn bộ các dịch vụ liên quan.
