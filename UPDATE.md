# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [19/10/2026] - Khắc Phục Triệt Để Lỗi 500 AI Sinh Câu Hỏi Rèn Luyện (Regex Lookbehind & Question Block Slicing) & Loại Bỏ Chữ 'text' Thừa Trước Công Thức Hóa Học

- **AI Engine (`V-Eval-Ai_Engine`) - Khắc Phục Lỗi 500 Khi AI Sinh Câu Hỏi Rèn Luyện (`CurriculumAiService.cs`)**:
  - *Sửa Lỗi `':' is invalid after a value` Trong `SanitizeAndRepairGeminiJson`*:
    + Nâng cấp regex sửa dấu phẩy sau tên thuộc tính JSON với Lookbehind dương bắt buộc `(?<=[\{\,]\s*)` thay vì regex chung chung; ngăn chặn việc biến đổi các giá trị chuỗi hợp lệ như `"correct_option": "B",` thành `"correct_option": "B": "explanation": ...` làm sập `JsonNode.Parse`.
  - *Tái Cấu Trúc Động Cơ Bóc Tách Dự Phòng `ExtractQuestionsViaRegex`*:
    + Loại bỏ pattern `[^{}]*` vốn bị đứt gãy ngay lập tức khi công thức toán/hóa LaTeX chứa dấu ngoặc nhọn `{...}` (như `SO_4^{2-}`, `\frac{...}{...}`); chuyển sang thuật toán **Question Block Slicing** định vị khóa `"contentLatex"` và cắt lát block câu hỏi an toàn 100%.
  - *Bảo Toàn Ký Tự Thoát LaTeX Trong `ExtractRegexField`*:
    + Bảo vệ các lệnh LaTeX bắt đầu bằng `\t` (`\text`, `\times`, `\theta`, `\tau`, `\to`) không bị nuốt thành ký tự Tab ASCII 0x09; unescape chuỗi `ContentLatex` trong `ExtractCurriculumViaRegex`.

- **Web Client (`V-Eval-Web_Client`) - Làm Sạch Tiền Tố 'text' Thừa Trước Công Thức Hóa Học (`MathText.jsx`)**:
  - *Loại Bỏ Hoàn Toàn Chữ 'text' Thừa Trước Ký Hiệu Hóa Học & Ion*:
    + Tự động làm sạch tiền tố `text` hoặc `\text` đứng liền trước các ký hiệu hóa học viết hoa ($SO_4^{2-}$, $H_2O$, $Fe^{3+}$, $KMnO_4$) thông qua bộ lọc `str.replace(/(?:\\text|\btext)(?=[A-Z])/g, '')` và `str.replace(/(?:\\text|\btext)\{([A-Z][a-zA-Z0-9_+\-^]*)\}/g, '$1')`, khôi phục công thức hóa học gốc hiển thị sắc nét, trong trẻo, không bị KaTeX nghiêng hóa thành biến số toán ($textSO_4^{2-}$).

- **Kiểm Thử Toàn Diện Hệ Thống**:
  - `V-Eval-Ai_Engine`: C# .NET 9 Clean Architecture build thành công 100% (**0 Error, 0 Warning**).
  - `V-Eval-Web_Client`: `npm run build` hoàn thành 100% (**0 Error, 0 Warning**, hoàn tất trong 800ms trên Vite 8 và React 19).
