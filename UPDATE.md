# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [19/10/2026] - Redesign Toàn Diện Hero Banner Khung Chương Trình Chuẩn Tone Trắng Sáng & Tinh Gọn, Khắc Phục Lỗi 500 AI Sinh Câu Hỏi & Làm Sạch Công Thức KaTeX

- **Web Client (`V-Eval-Web_Client`) - Redesign Hero Banner Lộ Trình & Thanh Chọn Miền Kiến Thức (`CurriculumExplorerView.jsx`)**:
  - *Đồng Bộ Tuyệt Đối Tone Trắng Sáng Thanh Lịch*: Thay thế toàn bộ khối banner nền tối `bg-gradient-to-br from-slate-900 via-indigo-950 to-slate-900` bằng container nền trắng sáng `bg-white border border-slate-200/80 rounded-2xl shadow-xs`, xóa bỏ hoàn toàn hiện tượng lệch tone "trên đen dưới trắng".
  - *Bố Cục Tinh Gọn, Gọn Gàng*: Giảm padding `p-8` xuống `p-5 lg:p-6`, chuyển đổi 2 khối thống kê thành các stat chip ngang nhỏ gọn `px-3.5 py-2`, tiêu đề và mô tả sư phạm súc tích.
  - *Căn Đều 5 Miền Năng Lực Trên 1 Hàng Ngang (`lg:grid-cols-5`)*: Bố trí lưới 5 cột đối xứng, không còn bị rớt dòng miền thứ 5. Tab kích hoạt nổi bật với viền `border-2 border-indigo-500` và nền `bg-indigo-50/90`.
  - *Làm Sạch Tiền Tố 'text' Thừa Trước Công Thức Hóa Học (`MathText.jsx`)*: Loại bỏ chữ `text` dính liền trước ion hóa học ($SO_4^{2-}$, $H_2O$, $Fe^{3+}$).

- **AI Engine (`V-Eval-Ai_Engine`) - Khắc Phục Lỗi 500 Khi AI Sinh Câu Hỏi Rèn Luyện (`CurriculumAiService.cs`)**:
  - *Sửa Lỗi `':' is invalid after a value`*: Sử dụng Regex Lookbehind `(?<=[\{\,]\s*)` bảo vệ giá trị trường JSON.
  - *Question Block Slicing Fallback*: Bóc tách câu hỏi dự phòng không bị ngắt bởi dấu `{...}` trong LaTeX.
  - *Bảo Toàn Chuỗi Thoát LaTeX*: Ngăn chặn biến đổi `\t` thành ký tự Tab ASCII.

- **Kiểm Thử Toàn Diện Hệ Thống**:
  - `V-Eval-Ai_Engine`: C# .NET 9 Clean Architecture build thành công 100% (**0 Error, 0 Warning**).
  - `V-Eval-Web_Client`: `npm run build` hoàn thành 100% (**0 Error, 0 Warning**, hoàn tất trong 3.47s trên Vite 8 và React 19).
