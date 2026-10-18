# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [18/10/2026] - Sinh Câu Hỏi Rèn Luyện Thích Ứng Bám Sát Dạng Bài Đang Phân Tích (Zero-Hardcode & Anti-Duplication), Khắc Phục Lỗi Render Markdown Đầu Dòng (Heading ###, Bold **, Italic ***) & Chuẩn Hóa Sư Phạm Phân Định Rõ STEM vs Ngữ Văn / KHXH

- **Web Client (`V-Eval-Web_Client`) - Sinh Câu Hỏi Bám Sát Dạng Bài & Chuẩn Hóa Sư Phạm**:
  - *Sinh Câu Hỏi Rèn Luyện Thích Ứng Bám Sát 100% Tri Thức Dạng Bài (Zero-Hardcode & Anti-Duplication)*:
    + Loại bỏ hoàn toàn toàn bộ mã lệnh hardcode và hàm fallback giả lập (`extractPatternPedagogicalContext`), tuân thủ 100% nguyên tắc Dữ liệu thật của hệ thống.
    + Sửa lỗi tham chiếu biến `selectedLesson` chưa được khai báo khiến tiến trình bị nhảy vào khối catch; chuẩn hóa trích xuất `currentLessonName` an toàn từ `previewSelectedLessonKey` và `targetPattern.lessonName`.
    + Đấu nối trực tiếp nút `+ AI Tạo Thêm 2 Bài Mẫu` với API backend AI Engine `POST /api/ai-engine/curriculum/generate-questions`.
    + Gửi toàn bộ ngữ cảnh sư phạm của dạng bài đang phân tích: `pattern_name`, `lesson_name`, `domain_name`, `theory_recap`, `solution_method` và danh sách đề bài các câu hỏi đã có (`existing_questions`).
    + Tự động cập nhật số lượng badge và điều hướng con trỏ đến câu hỏi vừa sinh; nếu có lỗi API sẽ hiển thị thông báo lỗi minh thị thay vì ngụy tạo câu hỏi giả.
  - *Khắc Phục Triệt Để Lỗi Render Đầu Dòng (`MathText.jsx`)*:
    + Cập nhật Regex bullet từ `^(\s*)(?:[-*•]|\u2022)\s*` sang `^(\s*)(?:[-+•\u2022]|\*(?!\*))\s+(?:[-+•\u2022]\s+)?(.*)$`, ngăn chặn tuyệt đối lỗi nuốt ký tự in đậm `**Ví dụ:**` thành bullet `• Ví dụ:**`.
    + Hỗ trợ đầy đủ cú pháp Markdown Headings (`#`, `##`, `###`, `####`).
    + Thiết kế riêng Component Callout Card thanh lịch:
      * `### 📌 Ví dụ minh họa SGK:`: Render Thẻ Ví Dụ Minh Họa SGK màu Emerald/Teal (`bg-teal-50/70 border border-teal-200/80 rounded-xl`).
      * `### 📝` / `### 📄 Bài toán mẫu áp dụng phương pháp:`: Render Thẻ Bài Toán Mẫu Áp Dụng màu Amber/Orange (`bg-amber-50/70 border border-amber-200/80 rounded-xl`).
    + Tự động khép cặp in đậm đối với nhãn mồ côi `([A-ZÀ-Ỹa-zà-ỹ0-9\s&]{2,30}):\*\*` -> `**$1:**`.
  - *Chuẩn Hóa Sư Phạm Đa Miền: Phân Biệt Rõ STEM vs Ngữ Văn / KHXH (`CurriculumStudioEditor.jsx` & `CurriculumExplorerView.jsx`)*:
    + Loại bỏ hoàn toàn nhãn `Mẹo Casio` cho môn Ngữ văn và KHXH; thay bằng Thẻ `💡 Mẹo tư duy & Chiến thuật làm bài (Ngữ văn)` với viền tím violet sư phạm, hướng dẫn chiến thuật đọc hiểu, cấu trúc đoạn văn, dẫn chứng và phân bổ thời gian.
    + Đối với môn STEM (Toán, Lý, Hóa, Sinh, Tin): Giữ nguyên Thẻ `💡 Kỹ thuật Casio & mẹo tư duy nhanh` với hướng dẫn phím bấm fx-580 / fx-880.
    + Xóa bỏ hoàn toàn hiện tượng sinh nhầm biến số đại số $X$ trong môn Ngữ văn.
    + Cập nhật bộ parser `parseTheoryRecapSections` và `parseSolutionMethodSections` unescape ký tự `\n` thô và hỗ trợ cả icon `📄` lẫn tiêu đề Ngữ văn.

- **AI Engine (`V-Eval-Ai_Engine`) - Endpoint Sinh Câu Hỏi Bám Sát Dạng Bài & Chống Trùng Lặp**:
  - *API Sinh Câu Hỏi Rèn Luyện Bám Sát Dạng Bài (`GeneratePatternQuestionsAsync`, `CurriculumEndpoints.cs`, `CurriculumAiDtos.cs`)*:
    + Cung cấp endpoint `POST /api/ai-engine/curriculum/generate-questions`.
    + Prompt Gemini đa tầng: Nếu là môn Ngữ văn/KHXH, bắt buộc khai thác tác phẩm văn học, tác giả, trích đoạn hoặc thao tác nghị luận có trong lý thuyết và phương pháp giải được cung cấp; nghiêm cấm tuyệt đối sinh câu hỏi số học hoặc biến số toán học.
    + **Chống trùng lặp tuyệt đối khi bấm tạo nhiều lần**: Bổ sung `existing_questions` trong DTO và prompt, chỉ thị Gemini khai thác các trích đoạn, khía cạnh cảm thụ và góc độ mới; nâng nhiệt độ sáng tạo `temperature = 0.7` để mỗi lần bấm tạo đều sinh ra bộ câu hỏi mới mẻ.
  - *Domain-Aware Prompting*:
    + Helper `IsStemDomain(string? domain)` phân biệt chính xác lĩnh vực STEM vs Khoa học xã hội / Ngữ văn.
    + Với môn Ngữ văn/KHXH: Chỉ thị bắt buộc Gemini **TUYỆT ĐỐI KHÔNG đề cập máy tính Casio**, thay bằng mẹo tư duy đọc hiểu, lập luận, cách dùng từ, dẫn chứng thực tế hoặc phân bổ thời gian làm bài; mục bài mẫu chuyển thành `### 📄 Bài mẫu áp dụng phương pháp:` với đoạn văn mẫu hoặc phân tích mẫu.
    + Với môn STEM: Giữ nguyên hướng dẫn máy tính Casio và bài toán mẫu số học.

- **Kiểm Thử Toàn Diện Hệ Thống**:
  - `V-Eval-Ai_Engine.Infrastructure` & `V-Eval-Ai_Engine.API`: Biên dịch C# .NET 9 Clean Architecture đạt 100% (**0 Error**).
  - `V-Eval-Web_Client`: `npm run build` hoàn thành 100% (**0 Error, 0 Warning**, hoàn thành trong 770ms trên Vite 8 và React 19).
