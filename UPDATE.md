# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [21/10/2026] - Khắc Phục Lỗi Nạp Tri Thức CSDL & Chuẩn Hóa Universal Ingestion (0% Hardcode), Động Cơ Bảng Biến Thiên Vector (Vạch Kép ||), Đồ Thị Vi Tích Phân 2D & Triệt Tiêu Vách Lưới Trắng 3D

- **Tài Liệu Đặc Tả Kiến Trúc Chuẩn Tổng Thể Hệ Thống V-Eval (`docs/kien_truc_chuan_tong_the_he_thong_v_eval.md`)**:
  - Biên soạn tài liệu chuẩn kiến trúc toàn diện 10 chương: Tầm nhìn & phạm vi 6 Core Flows, bản đồ phân bổ 6 Microservices, ranh giới CSDL Supabase PostgreSQL 3 schema, giao tiếp gRPC HTTP/2 Protobuf, cây tri thức 3 tầng & 4 khối sư phạm, cơ chế Universal Ingestion 0% hardcode, MathLab Native Engine (2D/3D/Bảng biến thiên vector), mô hình toán học khảo thí (IRT 2PL, BKT, Constrained K-Means, Topological Sort), và quy trình DevOps Multi-Repo.

- **Content Service (`V-Eval-Content_Service`) - Bộ Chuyển Đổi Dữ Liệu Universal Ingestion (0% Hardcode)**:
  - *Khắc Phục Triệt Để Lỗi 400 Validation Error (`The JSON value could not be converted to System.Char`)*: Trường `CorrectOption` trong DTOs (`ImportQuestionDto`, `CreateQuestionRequestDto`, `UpdateQuestionRequestDto`, `QuestionDto`) được chuyển đổi an toàn thông qua `FlexibleCharJsonConverter` và `FlexibleNullableCharJsonConverter`.
  - Hỗ trợ linh hoạt mọi định dạng từ AI OCR và trích xuất tài liệu: ký tự kèm dấu (`"A."`, `"(B)"`, `"[C]"`, `"D:"`), từ khóa (`"Đáp án C"`, `"Phương án B"`, `"Option A"`), số nguyên (`0..3`), chuỗi rỗng và `null` mà không bao giờ ném ngoại lệ.
  - Đăng ký toàn cục tại `Program.cs` (`.AddJsonOptions(...)`) và phòng thủ đa tầng trong `ImportCurriculumCommandHandler.cs`.

- **AI Engine (`V-Eval-Ai_Engine`) - Chuẩn Hóa Bóc Tách `NormalizeCorrectOption`, Bảng Biến Thiên (`[VARIATION_TABLE]`) & Đồ Thị (`[MATH_GRAPH]`)**:
  - *Chuẩn Hóa Toàn Diện Đáp Án Đúng*: Xây dựng `NormalizeCorrectOption` và `ExtractJsonNodeAsString` trong `CurriculumAiService.cs`, bảo vệ toàn diện cả 5 luồng: bóc tách PDF SGK (`ExtractCurriculumAsync`), sinh câu hỏi dạng bài (`GeneratePatternQuestionsAsync`), trích xuất regex dự phòng (`ExtractFallbackCurriculumFromText`, `ExtractQuestionsViaRegex`), và phân tích bản chất dạng bài (`AnalyzePatternAsync`).
  - *Đặc tả thẻ `[VARIATION_TABLE]`*: Hỗ trợ toàn diện các hàm đa thức liên tục (bậc 3, bậc 4, bậc 2) và phân thức hữu tỉ có tiệm cận đứng đứt đoạn (1/1 `(ax+b)/(cx+d)`, 2/1 `(ax^2+bx+c)/(dx+e)`) với cú pháp vạch kép `||` trong cả hàng đạo hàm `y'` và hàng biến thiên `y`.
  - *Mở rộng thẻ `[MATH_GRAPH]`*: Hỗ trợ 6 loại hàm số (`cubic`, `quartic`, `rational`, `rational_21`, `quadratic`, `custom`), tham số `a`, `b`, `c`, `d`, `e`, nhãn công thức, khoảng hiển thị và tiệm cận. Sửa lỗi thoát chuỗi nội suy C# cho phân thức LaTeX `\\frac{{ax+b}}{{cx+d}}`.
  - *Phủ kín toàn diện quy trình sư phạm*: Nhúng chỉ thị bóc tách vào `ExtractCurriculumAsync`, `GeneratePatternQuestionsAsync`, `GeneratePracticeQuestionsAsync` và `GeminiExamParserService.cs`, ép buộc LLM tự động tái tạo thẻ tương tác vào CẢ 4 vị trí: Lý thuyết SGK (Khối 1), Phương pháp giải (Khối 2), Nội dung câu hỏi (`contentLatex`) và Lời giải chi tiết (`explanation`), loại bỏ hoàn toàn hardcode.

- **Web Client (`V-Eval-Web_Client`) - Chuẩn Hóa Payload Nạp Tri Thức Client-Side, Động Cơ Vector Bảng Biến Thiên, Đồ Thị 2D & Sửa Lỗi UI 3D / KaTeX**:
  - *Chuẩn Hóa Payload Client-Side (`contentService.js` & `CurriculumExplorerView.jsx`)*: Triển khai `normalizeCorrectOption` và `sanitizeCurriculumPayload`, tự động chuẩn hóa đáp án đúng về `'A'..'D'` và định dạng lỗi chi tiết Problem Details trên modal nạp CSDL.
  - *Động Cơ Bảng Biến Thiên Vector (`VariationTable.jsx`)*: Hỗ trợ vạch kép SVG `||` cho hàm phân thức, tự động suy luận hướng mũi tên (`directions`) từ dấu của `y'`, xử lý an toàn dấu phân cách `,` và `|`.
  - *Đồ Thị Vi Tích Phân 2D & Tiệm Cận (`InteractiveMathRenderer.jsx`)*: Tự động tính và vẽ đường tiệm cận đứng, ngang, xiên nét đứt cùng tâm đối xứng `I` cho hàm phân thức 1/1 và 2/1; ngắt nét gián đoạn qua tiệm cận (`discontinuous: isRational`).
  - *Khắc Phục Lỗi Sinh Nhầm Card Oxy Đè Lên Bảng Biến Thiên (`mathGraphUtils.js`, `MathText.jsx`)*: Chặn đứng hiện tượng nhận diện nhầm câu hỏi chứa bảng biến thiên thành đồ thị 2D, loại bỏ hoàn toàn việc nhồi nhét text đề bài và chuỗi mã thô `[VARIATION_TABLE]` lên canvas JSXGraph; hỗ trợ bảng biến thiên trên một dòng và bảo vệ toàn vẹn cú pháp thẻ.
  - *Triệt Tiêu Khối Trắng Cắt Ngang Hình Học 3D (`InteractiveMathRenderer.jsx` & `InteractiveMathWorkbenchModal.jsx`)*: Thiết lập `xPlaneRear: { visible: false }, yPlaneRear: { visible: false }, zPlaneRear: { visible: false }` và các mặt phẳng trước. Loại bỏ hoàn toàn mắt lưới thành hộp phía sau; tích hợp công tắc bật/tắt hệ trục Oxyz chuẩn SGK.
  - *Khắc Phục Lỗi Nuốt Dấu `**` & Unrendered KaTeX Tại Thẻ Bài Toán Mẫu (`MathText.jsx`)*: Thu hẹp regex `isSampleHeadingCallout`, phân định rõ ràng dòng tiêu đề và nội dung bài tập, tự động vá dấu sao mồ côi `Bài toán mẫu:**`.
  - *Bảo Toàn Trạng Thái Bài Toán Mẫu Studio (`CurriculumStudioEditor.jsx`)*: Đồng bộ trường `sampleProblem` trong state và bộ lưu trữ.

- **Kiểm Thử Toàn Diện Hệ Thống**:
  - `V-Eval-Content_Service.sln`: Biên dịch .NET 9 SDK thành công 100% (**0 Error, 0 Warning**).
  - `V-Eval-Ai_Engine.sln`: Biên dịch .NET 9 SDK thành công 100% (**0 Error, 0 Warning**).
  - `V-Eval-Web_Client`: `npm run build` hoàn thành 100% (**0 Error, 0 Warning**, hoàn tất trong 2.50s trên Vite 8 và React 19).
  - Kiểm thử trực tiếp `POST /api/content/curriculum/import` với các định dạng thô (`"A."`, `"Đáp án C"`, `0..3`, `null`, `"(B)"`) nạp thành công 200 OK vào CSDL PostgreSQL.
