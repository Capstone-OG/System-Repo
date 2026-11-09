# NHẬT KÝ CẬP NHẬT HỆ THỐNG (SYSTEM-REPO UPDATE LOG)

## [10/11/2026] - Sửa Lỗi JSON Deserialization Bóc Tách Khung Tri Thức (HF-AI-05), Nâng Cấp SanitizeAndRepairGeminiJson & Ưu Tiên Gemini Flash-Lite

- **Khắc Phục & Đóng Thẻ Hotfix Kiến Trúc HF-AI-05 ([`AI_Engine_Hotfix.md`](./docs_noi_bo/hotfix/AI_Engine_Hotfix.md))**:
  - Ghi nhận và khắc phục triệt để thẻ sự cố `HF-AI-05` (Lỗi Deserialization JSON Bóc Tách Khung Tri Thức do unescaped quotes trong thuật ngữ Hóa học và comment C-style trong prompt template).
  - Trạng thái thẻ: Chuyển từ `🟡 OPEN` sang `🟢 RESOLVED` sau khi vượt qua 100% bộ kiểm thử tự động.

- **Nâng Cấp Bộ Tiền Xử Lý Làm Sạch JSON Phân Tích Ngữ Cảnh (`SanitizeAndRepairGeminiJson`) ([`V-Eval-Ai_Engine`](./All%20Services/V-Eval-Ai_Engine/))**:
  - **Khắc phục lỗi cú pháp JSON**: Sửa lỗi `Strict JSON deserialize gặp lỗi ('l' is an invalid start of a property name. Expected a '"'. Path: $.chapters[0].lessons[0].patterns[0])`.
  - **Làm sạch Prompt Template**: Dời toàn bộ khối chú thích `/* LƯU Ý... */` ra ngoài JSON schema trong [`CurriculumIngestion.prompt.txt`](./All%20Services/V-Eval-Ai_Engine/V-Eval-Ai_Engine.Infrastructure/Templates/Prompts/CurriculumIngestion.prompt.txt); bổ sung chỉ thị nghiêm cấm sinh comment `/*...*/`, `//...` và bắt buộc dùng nháy đơn `'...'` cho tên chất, thuật ngữ hóa học.
  - **Bộ phân tích ngữ cảnh thông minh**: Phân biệt chính xác giữa dấu ngoặc kép đóng thuộc tính (khi theo sau bởi `:` hoặc `,` dẫn tới thuộc tính tiếp theo) và dấu ngoặc kép trích dẫn bên trong nội dung văn bản (chuyển đổi an toàn thành nháy đơn `'...'`).
  - **Loại bỏ chú thích & trailing commas**: Tự động xóa chú thích C-style `/\*[\s\S]*?\*/`, single-line comments `//.*`, và trailing commas trước `}` hoặc `]`.
  - **Bật chế độ an toàn System.Text.Json**: Cấu hình `ReadCommentHandling = JsonCommentHandling.Skip` và `CommentHandling = JsonCommentHandling.Skip` trên toàn bộ các phương thức `JsonSerializer.Deserialize` và `JsonNode.Parse`.

- **Tối Ưu Hóa Độ Trễ Mô Hình AI & Triệt Tiêu Nguy Cơ HTTP 503**:
  - Đảo thứ tự danh sách mô hình AI trong [`appsettings.json`](./All%20Services/V-Eval-Ai_Engine/V-Eval-Ai_Engine.API/appsettings.json) và hàm `ResolveGeminiModels()`: Đưa `gemini-3.5-flash-lite` lên vị trí số 1, tiếp theo là `gemini-3.8-flash` và `gemini-3.6-flash`.
  - Rút ngắn thời gian bóc tách tài liệu scan đa phương thức 18 trang từ ~150s xuống <15s và triệt tiêu lỗi quá tải HTTP 503 của model 3.6-flash.

- **Kiểm Thử Tự Động & Đảm Bảo Vận Hành**:
  - Bổ sung 2 test unit mới trong [`PromptTemplateServiceTests.cs`](./All%20Services/V-Eval-Ai_Engine/V-Eval-Ai_Engine.Tests/Infrastructure/PromptTemplateServiceTests.cs) kiểm thử tự động khả năng làm sạch unescaped quotes trong văn bản Hóa học và xóa comment C-style.
  - Toàn bộ **15/15 unit tests** trong `V-Eval-Ai_Engine.Tests` chạy thành công 100%.
  - Toàn bộ solution `V-Eval-Ai_Engine.sln` biên dịch sạch sẽ 100% trên .NET 9.0 (0 Warning, 0 Error).
