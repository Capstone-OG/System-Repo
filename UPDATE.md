# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [18/10/2026] - Khắc Phục Lỗi Render Markdown Đầu Dòng (Heading ###, Bold **, Italic ***), Chuẩn Hóa Sư Phạm Phân Định Rõ STEM vs Ngữ Văn / KHXH & Loại Bỏ Triệt Để Mẹo Casio Trong Ngữ Văn

- **Web Client (`V-Eval-Web_Client`) - Khắc Phục Lỗi Render Markdown & Chuẩn Hóa Sư Phạm Phân Hệ Môn Học**:
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
    + Cập nhật bộ parser `parseTheoryRecapSections` và `parseSolutionMethodSections` unescape ký tự `\n` thô và hỗ trợ cả icon `📄` lẫn tiêu đề Ngữ văn.
- **AI Engine (`V-Eval-Ai_Engine`) - Domain-Aware Prompting Trong `CurriculumAiService.cs`**:
  - Bổ sung helper `IsStemDomain(string? domain)` phân biệt chính xác lĩnh vực STEM vs Khoa học xã hội / Ngữ văn.
  - Tinh chỉnh Prompt Gemini trong `ExtractCurriculumStructureAsync` và `AnalyzePatternAsync`:
    + Với môn Ngữ văn/KHXH: Chỉ thị bắt buộc Gemini **TUYỆT ĐỐI KHÔNG đề cập máy tính Casio**, thay bằng mẹo tư duy đọc hiểu, lập luận, cách dùng từ, dẫn chứng thực tế hoặc phân bổ thời gian làm bài; mục bài mẫu chuyển thành `### 📄 Bài mẫu áp dụng phương pháp:` với đoạn văn mẫu hoặc phân tích mẫu.
    + Với môn STEM: Giữ nguyên hướng dẫn máy tính Casio và bài toán mẫu số học.
- **Kiểm Thử Toàn Diện Hệ Thống**:
  - `V-Eval-Ai_Engine.Infrastructure`: Biên dịch C# .NET 9 Clean Architecture đạt 100% (**0 Error, 0 Warning**).
  - `V-Eval-Web_Client`: `npm run build` hoàn thành 100% (**0 Error, 0 Warning**, hoàn thành trong 5.26s trên Vite 8 và React 19).
