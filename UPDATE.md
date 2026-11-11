# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - V-EVAL CAPSTONE SYSTEM REPO

## [12/11/2026] - Khắc Phục Triệt Để Vòng Lặp Retry 503 (Key-First Smart Failover), Tinh Gọn Prompt Bóc Tách Đa Bài Học & Khắc Phục 4 Lỗi Render KaTeX Hóa Học

- **Khắc Phục Triệt Để Cơ Chế Vòng Lặp Thử Lại (Smart Key-First & Model-Inner Failover) ([`CurriculumAiService.cs`](./All%20Services/V-Eval-Ai_Engine/V-Eval-Ai_Engine.Infrastructure/Services/CurriculumAiService.cs), [`MultiCloudExamParserService.cs`](./All%20Services/V-Eval-Ai_Engine/V-Eval-Ai_Engine.Infrastructure/Services/MultiCloudExamParserService.cs))**:
  - Đảo ngược thứ tự vòng lặp: Key-outer duyệt trước, Model-inner duyệt sau.
  - Phân loại lỗi chính xác:
    - Khi gặp lỗi Key/Quota (`HTTP 401 Unauthorized`, `HTTP 403 Forbidden`, `HTTP 429 Too Many Requests`): Đánh dấu `keyInvalidOrQuotaExceeded = true` và `break` model loop để chuyển sang API Key tiếp theo.
    - Khi gặp lỗi Model/Server quá tải (`HTTP 503 Service Unavailable`, `HTTP 500`, `HTTP 504`, `HTTP 404`, `HTTP 400`): Giữ nguyên API Key và `continue` model loop để thử ngay Model tiếp theo với cùng key. Triệt tiêu hoàn toàn hiện tượng thử lại 4 lần cùng 1 model bị 503.
  - Hạ timeout từng request xuống `35 giây` (`TimeSpan.FromSeconds(35)`), bắt ngoại lệ `OperationCanceledException` để chuyển model tức thì.

- **Tinh Gọn Directive Bóc Tách & Prompt Theo Nhánh Main ([`CurriculumAiService.cs`](./All%20Services/V-Eval-Ai_Engine/V-Eval-Ai_Engine.Infrastructure/Services/CurriculumAiService.cs), [`CurriculumIngestion.prompt.txt`](./All%20Services/V-Eval-Ai_Engine/V-Eval-Ai_Engine.Infrastructure/Templates/Prompts/CurriculumIngestion.prompt.txt))**:
  - Giữ vững nguyên tắc đa bài học (Multi-Lesson Extraction): Chương "Ester - Lipid" bắt buộc tách thành 2 bài học riêng biệt ("Bài 1: Ester" và "Bài 2: Lipid & Chất béo").
  - Cân bằng số lượng dạng bài: Mỗi bài học trích xuất 2-3 dạng bài cốt lõi (tổng 4-6 dạng bài), mỗi dạng có 2-3 câu hỏi trắc nghiệm kèm giải thích chi tiết, đầy đủ 4 khối sư phạm. Loại bỏ việc ép bóc tách 12+ dạng bài gây quá tải token kích hoạt lỗi 503 từ Google AI Studio.

- **Cấu Hình Thứ Tự Ưu Tiên Gemini Chống 503 ([`appsettings.json`](./Configs/V-Eval-Ai_Engine/appsettings.json), [`All Services/V-Eval-Ai_Engine/V-Eval-Ai_Engine.API/appsettings.json`](./All%20Services/V-Eval-Ai_Engine/V-Eval-Ai_Engine.API/appsettings.json))**:
  - Ưu tiên số 1: `gemini-3.5-flash-lite` (~1.0s latency, chịu tải cao, không bị 503).
  - Tiếp nối: `gemini-3.6-flash`, `gemini-3.5-flash`, `gemini-3.1-flash-lite`, `gemini-flash-lite-latest`.
  - Loại bỏ hoàn toàn `gemini-3.8-flash` (gây 503 liên tục).

- **Khắc Phục Triệt Để 4 Lỗi Render KaTeX Hóa Học Trên Giao Diện ([`MathText.jsx`](./All%20Services/V-Eval-Web_Client/src/components/common/MathText.jsx))**:
  - Triệt tiêu hộp lỗi đỏ KaTeX (#cc0000) bằng cơ chế Emergency Sanitization 2 tầng trong `renderKatexHtml`.
  - Làm sạch dấu `$` đặt nhầm cạnh dấu bằng `\$\s*=\s*\$?|(?<=\w|\})\s*\$\s*=` biến thành `= ` (sửa lỗi `$n_{\text{triglyceride}} = \frac{...}{...}$`).
  - Đóng dấu `$` trước dấu chấm câu có văn bản giải thích tiếng Việt: `$C_{17}H_{33}$. 1 mol`, ngăn ngừa chữ nghiêng dính chùm.
  - Tách nhãn mở đầu `Phương trình: ...` và bọc phương trình phản ứng hóa học có mũi tên vào display math `$$...$$`.
  - `npm run build` thành công trong **2.39 giây**, nạp bundle mới vào Nginx container `v_eval_web_client`.

- **Kiểm Thử & Đảm Bảo Vận Hành**:
  - Toàn bộ **19/19 unit tests** trong AI Engine vượt qua thành công 100% trong 309 ms.
  - Rebuild và khởi động container `v_eval_ai_engine` và `v_eval_web_client` trên Docker.
