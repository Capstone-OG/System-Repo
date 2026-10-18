# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [19/10/2026] - Chuẩn Hóa Toàn Diện Studio Soạn Thảo Sư Phạm WYSIWYG: Chèn Công Thức Tại Vị Trí Con Trỏ, Giao Diện Trắng Sáng Thanh Lịch, Cây Thư Mục Accordion Hợp Chất & Ký Hiệu Đồ Sộ, Nhấp Khoảng Trống Nhảy Cuối Dòng & Xóa Sổ Lỗi Ký Tự

- **Web Client (`V-Eval-Web_Client`) - Nâng Cấp Studio Soạn Thảo Sư Phạm Trực Tiếp**:
  - *Chèn Công Thức Ngay Tại Vị Trí Con Trỏ (Active Caret Precision Insertion)*:
    + Nâng cấp `WordStyleFormulaCanvas` bằng `forwardRef` và `useImperativeHandle` xuất bản hàm `insertSnippet`.
    + Bắt chính xác vị trí con trỏ văn bản (`activePositionRef`) khi người dùng gõ hoặc click. Khi chọn ký hiệu từ sidebar, hệ thống chia tách text token tại `caretOffset`, chèn công thức ngay vị trí con trỏ thay vì nối vào cuối văn bản (`. a/b a/b a/b`).
    + Kết nối `theoryCanvasRef` và `methodCanvasRef` trong `CurriculumStudioEditor.jsx` điều hướng chính xác vào khối đang chỉnh sửa.
  - *Giao Diện Trắng Sáng Thanh Lịch (Clean White Tone Reversion)*:
    + Chuyển toàn bộ khung thanh công cụ ký hiệu (`HierarchicalMathPalette.jsx`) từ dark theme `bg-slate-900` về giao diện màu trắng sáng hiện đại `bg-white border-r border-slate-200 text-slate-800 shadow-sm`.
    + Bổ sung thanh tìm kiếm nhanh tức thì `🔍 Tìm nhanh H2SO4, NaOH, √x, a/b, sin...` tìm kiếm trên toàn bộ hàng trăm công thức trong thời gian thực.
  - *Cây Thư Mục Accordion Toggle & Kho Tàng Ký Hiệu, Hợp Chất Đồ Sộ*:
    + Tổ chức danh mục ký hiệu theo các folder Accordion Toggle mở/đóng mượt mà (`ChevronDown` / `ChevronRight`) với badge số lượng phần tử.
    + Nhãn nút tối giản, gọn nhẹ sắp xếp lưới 2 cột, hỗ trợ hàng trăm công thức toán học, hợp chất hóa học (Axit, Bazơ, Muối, Oxit, Hữu cơ, Ion, Số oxi hóa), vật lý và ký hiệu logic.
    + Thẻ nổi 2 giây (Hover Card) nền trắng mờ viền cyan sắc nét, hiển thị KaTeX cỡ lớn, giải thích chuẩn SGK GDPT 2018 và mã LaTeX.
  - *Tự Động Nhảy Con Trỏ Về Cuối Dòng Khi Nhấp Khoảng Trống (Whitespace Click Focus)*:
    + Xử lý sự kiện nhấp chuột trên khoảng đệm trống của từng dòng (`handleLineRowClick`), tự động focus vào span text cuối dòng và collapse con trỏ về đuôi chữ như Microsoft Word.
  - *Loại Bỏ Nút "+ Thêm dòng mới" Dư Thừa & Xóa Sổ Ký Tự `\` Cuối Dòng*:
    + Sử dụng phím `Enter` để tách dòng tự nhiên, loại bỏ nút bấm dư thừa dưới chân canvas.
    + Làm sạch triệt để các dấu gạch chéo ngược thừa `\` hoặc `/` ở cuối câu (`sanitizeLineText`).
  - *Khắc Phục Lỗi Hiển Thị Emoji `📝`*:
    + Thay thế toàn diện emoji `📝` bằng các icon vector Lucide chuẩn (`FileEdit`, `FileText`, `BookOpen`, `AlertTriangle`, `Sparkles`), khắc phục triệt để lỗi tofu/ô vuông trên Windows.

- **AI Engine (`V-Eval-Ai_Engine`) - Chuẩn Hóa Tiêu Đề Bài Mẫu Sư Phạm**:
  - Chuẩn hóa tiền tố bài toán mẫu trong `CurriculumAiService.cs` từ `### 📝` sang `### 📄` tương thích hoàn hảo với bộ giải mã Markdown / KaTeX trên Web Client.

- **Kiểm Thử Toàn Diện Hệ Thống**:
  - `V-Eval-Web_Client`: `npm run build` hoàn thành 100% (**0 Error, 0 Warning**, hoàn tất trong 773ms trên Vite 8 và React 19).
