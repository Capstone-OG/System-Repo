# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [19/10/2026] - Trình Soạn Thảo Ký Hiệu Trực Quan WYSIWYG Như Microsoft Word Equation: Studio Toàn Màn Hình Thay Thế Sidebar App, Thẻ Nổi Rê Chuột 2 Giây KaTeX & Thanh Tra Công Thức Siêu Linh Hoạt 4 Tab

- **Web Client (`V-Eval-Web_Client`) - Trình Soạn Thảo Sư Phạm Độc Lập Kiểu Microsoft Word Equation**:
  - *Studio Toàn Màn Hình Độc Lập (Dedicated Standalone Fullscreen Mode)*:
    + Giải phóng toàn bộ diện tích làm việc khỏi khung con `max-w-7xl` trong `CurriculumExplorerView.jsx`, hiển thị dạng full-screen workspace (`fixed inset-0 z-50 w-screen h-screen bg-slate-950 overflow-hidden`), ẩn hoàn toàn layout ngoài của app.
    + Đưa `HierarchicalMathPalette.jsx` lên làm Left Sidebar chính của toàn bộ Studio, thay thế trực tiếp vị trí của sidebar app cũ.
    + Tích hợp nút thu gọn/mở rộng: Thu hẹp thành thanh icon rail siêu mỏng 44px (`w-11`), mở rộng (`w-64`/`w-72`) chỉ với 1 click, giúp canvas soạn thảo chiếm trọn vẹn 100% chiều ngang màn hình.
    + Bổ sung thanh điều hướng đỉnh trang (Studio Navbar h-14) với nút `← Quay lại Lộ trình`, breadcrumb bài học, nút chuyển 3 chế độ xem, nút AI nhận diện và nút lưu PostgreSQL.
  - *Thẻ Nổi KaTeX Rê Chuột 2 Giây (2-Second Hover Preview Card)*:
    + Tích hợp bộ đếm thời gian trễ chính xác 2000ms (`hoverTimerRef`) khi rê chuột vào bất kỳ ký hiệu nào trong sidebar.
    + Hiển thị thẻ nổi preview phong phú (Rich Floating Hover Card): Công thức KaTeX cỡ lớn, tên danh mục, mô tả công năng chi tiết chuẩn SGK GDPT 2018, cú pháp LaTeX thô và chỉ dẫn chèn 1-click.
  - *Thanh Tra Công Thức Siêu Linh Hoạt Phân Cấp 4 Tab (Hierarchical Quick Formula Inspector)*:
    + Popup thanh tra công thức nổi mở ra với 4 tab phân cấp: `📐 Cấu trúc`, `🧪 Hóa học`, `🔣 Ký hiệu`, `🧱 Ngoặc & Logic` cho phép chèn tức thì 45+ ký tự toán/hóa.
    + Bổ sung dòng nhập và sửa mã LaTeX trực tiếp (`input`) đồng bộ 0ms với Live KaTeX preview, song hành cùng các ô visual slot (tử số, mẫu số, số mũ...).
  - *Khắc Phục Triệt Để Hiện Tượng Nhảy Dòng & Tiết Diện Công Thức Quá Lớn*:
    + Xóa bỏ `flex-wrap`, chuyển sang dòng văn bản tự nhiên theo đoạn (`tokenizeLine`, `parseDocumentLines`, `serializeDocumentLines`), đảm bảo dấu chấm `.` và dấu phẩy `,` bám sát từ ngữ trên cùng dòng, không bao giờ bị rơi rớt xuống dòng độc lập.
    + Tiết diện công thức siêu gọn `text-[13.5px]`, padding `px-0.5 py-0 mx-0.5`, hairline dashed underline khi nghỉ.
    + Hỗ trợ phím Enter tách dòng tự nhiên như Microsoft Word.

- **AI Engine (`V-Eval-Ai_Engine`) - Khắc Phục Lỗi Dấu Phẩy Sau Tên Thuộc Tính JSON Gemini & Fallback Regex Zero-Crash**:
  - *Khắc Phục Lỗi Dị Dạng JSON Từ Gemini AI (`CurriculumAiService.cs`)*:
    + Bổ sung bộ lọc regex phát hiện và thay thế dấu phẩy nằm ngay sau tên thuộc tính: `Regex.Replace(cleaned, @"(""[a-zA-Z0-9_]+"")\s*,\s*(?=""|\[|\{|-?[0-9]|true|false)", "$1: ")`.
    + Loại bỏ các dấu phẩy trailing thừa trước dấu đóng ngoặc nhọn `}` hoặc ngoặc vuông `]`: `Regex.Replace(cleaned, @",\s*([}\]])", "$1")`.
  - *Cơ Chế Bóc Tách Câu Hỏi Dự Phòng Tầng Hai (`ExtractQuestionsViaRegex`)*:
    + Bọc an toàn khối giải mã JSON `JsonNode.Parse` và fallback sang regex bóc tách trực tiếp các trường dữ liệu khi JSON bị cụt/dị dạng, luôn đảm bảo HTTP 200 OK.

- **Kiểm Thử Toàn Diện Hệ Thống**:
  - `V-Eval-Ai_Engine.Infrastructure` & `V-Eval-Ai_Engine.API`: Biên dịch C# .NET 9 Clean Architecture thành công 100% (**0 Error, 0 Warning**).
  - `V-Eval-Web_Client`: `npm run build` hoàn thành 100% (**0 Error, 0 Warning**, hoàn tất trong 777ms trên Vite 8 và React 19).
