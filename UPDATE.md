# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [17/10/2026] - Trình Soạn Thảo Ký Hiệu Trực Quan WYSIWYG (Ẩn Triệt Để Mã \frac), Bộ Công Cụ Hóa Học & Toán Học Thực Tế Chèn Số & Tự Tính Toán (Interactive Smart Science Calculator), Xóa Bỏ Text In Preview, Triệt Tiêu 100% Hardcode AI Engine, Trích Xuất Dữ Liệu Thật, Bộ Renderer Đồ Thị Oxy / Bảng Biến Thiên Nội Sinh & Desmos Calculator

- **Web Client (`V-Eval-Web_Client`) - Trình Soạn Thảo Ký Hiệu Trực Quan WYSIWYG & Bộ Công Cụ Hóa Học / Toán Học Thực Tế**:
  - *Ẩn Hoàn Toàn Mã Code Lệnh Thô `\frac` ("frag"), `\lim`, `\Delta`, `$`*:
    + Chấm dứt hiện tượng lộ mã LaTeX thô trong khung soạn thảo; chuyển sang chế độ **Ký Hiệu Trực Quan WYSIWYG** mặc định: Các công thức toán/hóa hiển thị chuẩn ký hiệu sách giáo khoa (phân số có thanh kẻ ngang tử/mẫu, căn thức, tích phân, số gia, nồng độ mol).
    + Nút chuyển đổi 1-chạm: `[Xem Ký Hiệu Thật (WYSIWYG)]` ⟷ `[Gõ Văn Bản Bàn Phím]`.
  - *Bộ Công Cụ Hóa Học Thực Tế - Chèn Số & Tự Động Tính Toán (`InteractiveFormulaBuilderModal.jsx`)*:
    + 🧪 Nồng độ mol dung dịch ($C_M = \frac{n}{V}$): Nhập $n$ (mol), $V$ (Lít) -> Tự động tính ra $C_M = n / V$ (M) và chèn cả chuỗi: $C_M = \frac{n}{V} = \frac{0.2}{0.5} = 0.4\text{ M}$.
    + 💧 Nồng độ phần trăm ($C\% = \frac{m_{ct}}{m_{dd}} \times 100\%$): Nhập $m_{ct}, m_{dd}$ -> Tự động tính ra $C\%$.
    + ⚖️ Khối lượng chất ($m = n \times M$): Nhập $n, M$ -> Tự động tính ra khối lượng $m$ (gam).
    + ⚡ Hiệu suất phản ứng ($H = \frac{m_{tt}}{m_{lt}} \times 100\%$): Nhập $m_{tt}, m_{lt}$ -> Tự động tính ra $H\%$.
  - *Bộ Tính Toán Phân Số & Đạo Hàm Số Gia SGK*:
    + ➗ Phân số tính toán ($A/B$): Nhập số vào ô Tử và Mẫu -> Tự động rút gọn và tính ra kết quả (ví dụ: $\frac{12}{4} = 3$).
    + 🎯 Đạo hàm bằng số gia ($f'(x_0) = \lim_{\Delta x \to 0}\frac{\Delta y}{\Delta x}$): Tự động tạo quy trình số gia đối số $\Delta x$, số gia hàm số $\Delta y$ và tính toán đạo hàm tại điểm $x_0$.
  - *Xóa Bỏ Mô Hình Text In Preview Thụ Động & Tách Riêng Trang LaTeX Thuần Cho AI*:
    + Xóa bỏ 100% ô Text In Preview thụ động bên dưới; tách riêng tab mã nguồn LaTeX Dark Mode cho AI.
    + Bộ renderer Bảng biến thiên SVG vector 3 dòng (`VariationTable.jsx`), Đồ thị Oxy & Desmos Calculator (`MathGraphView.jsx`), Dán ảnh clipboard Ctrl+V.
- **AI Engine (`V-Eval-Ai_Engine`) - Triệt Tiêu 100% Hardcode & Trích Xuất Dữ Liệu Thật**:
  - Tuân thủ nguyên tắc Dữ liệu thật 100%, xóa bỏ triệt để hơn 1.780 dòng code hardcode, heuristic mock patterns và câu hỏi mẫu tự tạo trước đây trong `CurriculumAiService.cs`.
  - Ném `InvalidOperationException` minh thị nếu AI gặp sự cố thay vì ngụy tạo dữ liệu giả.
  - Tích hợp `System.Diagnostics.Stopwatch` đo lường thời gian thực tế xử lý tệp và bóc tách AI (`ProcessingTimeSeconds`, `IsRealExtraction = true`, `SourceFileName`, `TotalPagesProcessed`, `TotalCharactersExtracted`).
  - Nâng trần `maxOutputTokens` lên `32768`, xây dựng bộ tự động sửa JSON cắt cụt `RepairTruncatedJson` và bộ tokenizer `SanitizeAndRepairGeminiJson` double-escape các ký tự escape LaTeX RFC 8259 (`\\{`, `\\}`, `\\Delta`, `\\frac`, `\\sqrt`...).
  - Nâng cấp độ phủ bóc tách: Bắt buộc quét đủ 5 Phần của tài liệu chuyên đề lớn, mở rộng thành 4-5 Bài học toàn diện và 8-12 Dạng bài chi tiết (tối thiểu 2-3 dạng/bài) kèm bài toán thực tế ĐGNL.
- **Kiểm Thử Biên Dịch Toàn Hệ Thống**:
  - `V-Eval-Ai_Engine`: .NET 9 Clean Architecture biên dịch thành công 100% (**0 Error**).
  - `V-Eval-Web_Client`: `npm run build` hoàn thành 100% (**0 Error, 0 Warning**, hoàn thành trong 743ms trên Vite 8 và React 19).
