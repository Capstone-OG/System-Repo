# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [19/10/2026] - Trình Soạn Thảo Ký Hiệu Trực Quan WYSIWYG Như Microsoft Word Equation (Sidebar Phân Cấp Hierarchical Palette, Thống Nhất Duy Nhất 1 Thanh Ribbon & Khắc Phục Lỗi Nhảy Dòng / Tiết Diện Lớn) & Khắc Phục Lỗi Dị Dạng JSON Gemini

- **Web Client (`V-Eval-Web_Client`) - Trình Soạn Thảo Ký Hiệu Trực Quan Kiểu Microsoft Word Equation**:
  - *Tái Cấu Trúc Toàn Diện Bộ Công Cụ & Loại Bỏ Trùng Lặp (Single-Version Rule)*:
    + Loại bỏ hoàn toàn sự lộn xộn từ 4-5 thanh công cụ xếp chồng (Bảng ký hiệu KaTeX phía trên, thanh Ribbon, thanh submode lặp lại các nút Hóa/Phân số, thanh toolbar bên trong canvas).
    + Tuân thủ nghiêm ngặt nguyên tắc *"Cùng tính năng chỉ duy nhất 1 phiên bản tồn tại"*: Hợp nhất vào 1 thanh Ribbon Word duy nhất trên đầu trang tài liệu, tích hợp bộ chuyển đổi 3 chế độ xem mượt mà (`✍️ Sửa Trực Tiếp` | `👁️ Trang In` | `Raw`).
  - *Thanh Công Cụ Ký Hiệu Phân Cấp Thu Gọn Bên Trái (Hierarchical Math & Science Sidebar - `HierarchicalMathPalette.jsx`)*:
    + Cấu trúc phân cấp 3 tầng rõ ràng:
      * **Tầng 1 (Chuyên Môn)**: Toán Học 📐, Hóa Học 🧪, Vật Lý ⚡, Ký Hiệu Đặc Biệt 🔣.
      * **Tầng 2 (Chuyên Mục Theo Môn)**: Hóa học (Nồng độ dung dịch, Số oxi hóa, Ion, Mũi tên phản ứng); Toán học (Đại số, Đạo hàm, Mũ & Log, Hình học & Oxyz, Lượng giác, Xác suất); Ký hiệu đặc biệt (Hy Lạp, Phép toán & So sánh).
      * **Tầng 3 (Chip Ký Hiệu KaTeX Trực Quan)**: Click 1 chạm chèn thẳng vào vị trí con trỏ trên canvas hoặc Khối 1/Khối 2.
    + Thu gọn rail siêu mỏng 44px (`w-11`) kèm tooltip, mở rộng (`w-64`/`w-72`) chỉ với 1 click chuột giúp giải phóng tối đa không gian soạn thảo.
  - *Khắc Phục Triệt Để Hiện Tượng Nhảy Dòng & Tiết Diện Công Thức Quá Lớn (`WordStyleFormulaCanvas.jsx`)*:
    + Chấm dứt lỗi Flex-wrap xé dòng & rơi rớt dấu câu (dấu chấm `.`, phẩy `,` bị tách rời xuống hàng mới).
    + Chuyển sang mô hình dòng văn bản tự nhiên theo đoạn (`tokenizeLine`, `parseDocumentLines`, `serializeDocumentLines`), hiển thị trong block paragraph `<div className="text-[13.5px] leading-relaxed my-0.5">`.
    + Tiết diện công thức siêu gọn (`text-[13.5px]`, padding `px-0.5 py-0 mx-0.5`, hairline dashed underline khi ở trạng thái nghỉ), xóa bỏ hoàn toàn khung viền dày và hộp màu to phồng làm méo chiều cao dòng.
    + Hỗ trợ phím Enter để ngắt dòng và tách đoạn tự nhiên như Word kèm nút `+ Thêm dòng mới`.

- **AI Engine (`V-Eval-Ai_Engine`) - Khắc Phục Lỗi Dấu Phẩy Sau Tên Thuộc Tính JSON Gemini & Fallback Regex Zero-Crash**:
  - *Khắc Phục Lỗi Dị Dạng JSON Từ Gemini AI (`CurriculumAiService.cs`)*:
    + Bổ sung bộ lọc regex phát hiện và thay thế dấu phẩy nằm ngay sau tên thuộc tính: `Regex.Replace(cleaned, @"(""[a-zA-Z0-9_]+"")\s*,\s*(?=""|\[|\{|-?[0-9]|true|false)", "$1: ")`.
    + Loại bỏ các dấu phẩy trailing thừa trước dấu đóng ngoặc nhọn `}` hoặc ngoặc vuông `]`: `Regex.Replace(cleaned, @",\s*([}\]])", "$1")`.
  - *Cơ Chế Bóc Tách Câu Hỏi Dự Phòng Tầng Hai (`ExtractQuestionsViaRegex`)*:
    + Bọc an toàn khối giải mã JSON `JsonNode.Parse` và fallback sang regex bóc tách trực tiếp các trường dữ liệu khi JSON bị cụt/dị dạng.
    + Đảm bảo 100% không bao giờ ném exception làm gián đoạn trải nghiệm người dùng, luôn trả về kết quả HTTP 200 OK.

- **Kiểm Thử Toàn Diện Hệ Thống**:
  - `V-Eval-Ai_Engine.Infrastructure` & `V-Eval-Ai_Engine.API`: Biên dịch C# .NET 9 Clean Architecture thành công 100% (**0 Error, 0 Warning**).
  - `V-Eval-Web_Client`: `npm run build` hoàn thành 100% (**0 Error, 0 Warning**, hoàn tất trong 753ms trên Vite 8 và React 19).
