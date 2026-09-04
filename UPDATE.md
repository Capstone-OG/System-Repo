# Nhật Ký Cập Nhật (Update Log)

## [04/09/2026] - Trích Xuất Toàn Diện 120 Câu Hỏi, Đa Mô Hình Fallback & Render Biểu Đồ/Bảng Số Liệu Trực Quan
- **Khắc phục triệt để giới hạn Token bóc tách trọn vẹn 120 câu hỏi V-ACT**:
  - Phát hiện nguyên nhân trích xuất bị cắt cụt ở câu 6 (do chạm trần `maxOutputTokens = 8192` mặc định của Gemini API, trong khi 120 câu kèm LaTeX và passages cần ~18.000 tokens / 75 KB JSON).
  - Cấu hình tường minh `maxOutputTokens: 65536` trong `generationConfig`, đảm bảo bóc tách toàn vẹn 16 trang từ Câu 1 đến Câu 120.
  - Tắt suy luận ngầm `thinkingBudget: 0` đối với `gemini-3.1-flash-lite` để in thẳng JSON, không bị rỗng nội dung.
  - Đưa `gemini-3.6-flash` lên Top 1 ưu tiên: Bóc tách thành công 100% toàn bộ 120 câu hỏi (17 chùm đọc hiểu, 62 câu đơn lẻ) chỉ trong ~2 phút 50 giây.
- **Cơ chế Đa mô hình linh hoạt & Giới hạn thử nghiệm (`MaxAttempts = 5`)**:
  - Đưa toàn bộ cấu hình mô hình sang `appsettings.json` và `appsettings.Development.json`:
    - Hỗ trợ 4 mô hình OpenAI (`gpt-4o`, `gpt-4o-mini`, `o3-mini`, `chatgpt-4o-latest`) ưu tiên đầu bảng nếu cấu hình Key.
    - Tự động chuyển thẳng sang 5 mô hình Gemini (`gemini-3.6-flash`, `gemini-3.1-flash-lite`, `gemini-flash-latest`, `gemini-flash-lite-latest`, `gemini-2.5-flash`) nếu không có Key OpenAI.
    - Hỗ trợ mảng đa API Key dự phòng (`GeminiApiKeys`) tự động luân chuyển khi gặp HTTP 429 / 503.
    - Khóa giới hạn tối đa 5 lần thử để tránh lặp vô tận, tự động lấy kết quả tốt nhất hoặc chuyển sang Local Fallback Parser.
- **Xử lý chuyên sâu câu hỏi đặc thù (Bảng số liệu & Biểu đồ thống kê)**:
  - **Bảng số liệu (Table - Câu 64 đến 67)**: Nâng cấp bộ parser Markdown Table trong `view-exam.html` nhận diện toàn bộ các dạng bảng (kể cả không có dấu `|` ở hai đầu biên), chuyển đổi thành HTML `<table>` sang trọng Dark-mode, viền phát sáng, header cyan.
  - **Biểu đồ thống kê (Chart.js - Câu 61-63 và 68-70)**: Tích hợp Chart.js tự động vẽ Biểu đồ cột (Bar Chart) và Biểu đồ tròn (Doughnut Chart) chuẩn vector canvas, bổ sung plugin in số liệu trực quan `${val}%` ngay trên đỉnh từng cột và trên từng lát bánh.
  - **Đính kèm hình vẽ gốc**: Bổ sung nút `📷 Đính kèm / Chèn ảnh gốc` trên từng Card chùm câu và câu hỏi để đính kèm ảnh chụp đề thi gốc trước khi lưu vào Database.
- **Quản lý đề thi 2 chiều & Tài liệu hóa Content Service**:
  - Triển khai API truy vấn danh sách đề (`GET /api/content/exams`), chi tiết đề thi (`GET /api/content/exams/{id}`) và xóa cascade (`DELETE /api/content/exams/{id}`).
  - Cấu hình CORS cho phép giao diện AI Engine Web Viewer tải và xóa đề thi trực tiếp trên Supabase PostgreSQL.
  - Xây dựng trọn bộ tài liệu kỹ thuật Content Service trong `All Services/V-Eval-Content_Service/docs`:
    - `content_service_architecture.md`: Kiến trúc Clean Architecture 4 tầng, ERD thực thể Supabase schema `content`.
    - `daily_process_and_planning.md`: Kế hoạch và nhật ký chi tiết các milestone.
    - `exam_management_api.md`: Đặc tả endpoints, JSON payload và quy trình tích hợp.

---

## [03/09/2026] - Nâng Cấp Phân Hệ AI Engine: High-Precision Verbatim OCR & Native JPEG Rendering
- **Khắc phục lỗi font nhúng MathType & hiện tượng nhòe ảnh PDF trong phân hệ AI Engine**:
  - Tích hợp thư viện `PDFtoImage` (SkiaSharp/PDFium) render trực tiếp 16 trang PDF thành ảnh JPEG độ nét cao (150 DPI) trong 1.5 giây, gửi đồng thời sang Gemini Vision.
  - Triệt tiêu 100% việc mất hệ số sau dấu bằng (giữ nguyên số 2 trong $y = 2x^3$ ở Câu 41) và lỗi font ẩn khiến mất dấu gạch trị tuyệt đối $|\int ...|$ ở Câu 45.
- **Khóa cứng `temperature = 0.0` (Greedy Deterministic Decoding)**:
  - Loại bỏ hoàn toàn tình trạng kết quả xê dịch giữa các lần chạy, đảm bảo 100 lần chạy ra kết quả giống nhau 100%.
- **Thiết lập Bộ luật Verbatim OCR Zero-Tolerance & Chống sửa bẫy đề thi trắc nghiệm**:
  - Nghiêm cấm AI tự ý giải toán hay chia tách tích phân, bảo tồn nguyên vẹn các phương án gây nhiễu (distractor options) phục vụ luyện thi.
- **Tối ưu hóa thời gian xử lý**:
  - Rút ngắn thời gian bóc tách toàn bộ 16 trang đề thi ĐGNL (120 câu hỏi) từ 50s xuống chỉ còn **~17–25 giây**.
- **Đồng bộ hóa tài liệu kiến trúc**:
  - Cập nhật chi tiết quy trình Ingestion trong `docs/V-Eval_Architecture_Plan.md` và `docs/ai_architecture/roadmap_phat_trien_ai.md`.

---

- Fix CI error in github action
