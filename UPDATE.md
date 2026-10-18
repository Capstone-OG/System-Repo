# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [18/10/2026] - Sinh Câu Hỏi Rèn Luyện Thích Ứng Bám Sát Dạng Bài Đang Phân Tích, Khắc Phục Lỗi Render Markdown Đầu Dòng (Heading ###, Bold **, Italic ***) & Chuẩn Hóa Sư Phạm Phân Định Rõ STEM vs Ngữ Văn / KHXH

- **Web Client (`V-Eval-Web_Client`) - Sinh Câu Hỏi Bám Sát Dạng Bài & Chuẩn Hóa Sư Phạm**:
  - *Sinh Câu Hỏi Rèn Luyện Thích Ứng Bám Sát 100% Tri Thức Dạng Bài (`CurriculumExplorerView.jsx` & `aiService.js`)*:
    + Đấu nối trực tiếp nút `+ AI Tạo Thêm 2 Bài Mẫu` với API backend AI Engine `POST /api/ai-engine/curriculum/generate-questions`.
    + Truyền tải toàn bộ ngữ cảnh sư phạm của dạng bài đang phân tích: `pattern_name`, `lesson_name`, `domain_name`, `theory_recap`, `solution_method` để Gemini hiểu chính xác tác phẩm văn học, tác giả, trích đoạn, phạm vi dẫn chứng và phương pháp giải.
    + Bộ bóc tách sư phạm phía client `extractPatternPedagogicalContext`: Tự động trích xuất tên tác phẩm trong ngoặc kép (ví dụ: 'Sang thu' của Hữu Thỉnh, 'Viếng lăng Bác' của Viễn Phương...), tác giả, vấn đề nghị luận và các bước giải, làm cơ sở sinh câu hỏi thích ứng bám sát 100% nội dung phân tích.
    + Thêm trạng thái tải spinner và tự động điều hướng đến câu hỏi vừa sinh.
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

- **AI Engine (`V-Eval-Ai_Engine`) - Endpoint Sinh Câu Hỏi Bám Sát Dạng Bài & Domain-Aware Prompting**:
  - *API Sinh Câu Hỏi Rèn Luyện Bám Sát Dạng Bài (`GeneratePatternQuestionsAsync`, `CurriculumEndpoints.cs`, `CurriculumAiDtos.cs`)*:
    + Cung cấp endpoint `POST /api/ai-engine/curriculum/generate-questions`.
    + Prompt Gemini đa tầng: Nếu là môn Ngữ văn/KHXH, bắt buộc khai thác tác phẩm văn học, tác giả, trích đoạn hoặc thao tác nghị luận có trong lý thuyết và phương pháp giải được cung cấp; nghiêm cấm tuyệt đối sinh câu hỏi số học hoặc biến số toán học.
  - *Domain-Aware Prompting*:
    + Helper `IsStemDomain(string? domain)` phân biệt chính xác lĩnh vực STEM vs Khoa học xã hội / Ngữ văn.
    + Với môn Ngữ văn/KHXH: Chỉ thị bắt buộc Gemini **TUYỆT ĐỐI KHÔNG đề cập máy tính Casio**, thay bằng mẹo tư duy đọc hiểu, lập luận, cách dùng từ, dẫn chứng thực tế hoặc phân bổ thời gian làm bài; mục bài mẫu chuyển thành `### 📄 Bài mẫu áp dụng phương pháp:` với đoạn văn mẫu hoặc phân tích mẫu.
    + Với môn STEM: Giữ nguyên hướng dẫn máy tính Casio và bài toán mẫu số học.

- **Kiểm Thử Toàn Diện Hệ Thống**:
  - `V-Eval-Ai_Engine.Infrastructure` & `V-Eval-Ai_Engine.API`: Biên dịch C# .NET 9 Clean Architecture đạt 100% (**0 Error**).
  - `V-Eval-Web_Client`: `npm run build` hoàn thành 100% (**0 Error, 0 Warning**, hoàn thành trong 2.30s trên Vite 8 và React 19).
