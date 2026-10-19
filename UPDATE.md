# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [19/10/2026] - Tái Cấu Trúc Header Chi Tiết Dạng Bài Tránh Chèn Ép Tiêu Đề, Khắc Phục Triệt Để Lỗi Mờ Tab 'Khoa Học Tự Nhiên' & Redesign Hero Banner Tone Trắng Sáng

- **Web Client (`V-Eval-Web_Client`) - Tái Cấu Trúc Header Dạng Bài, Khắc Phục Lỗi Mờ Tab 'Khoa Học Tự Nhiên' & Redesign Hero Banner (`CurriculumExplorerView.jsx`)**:
  - *Tái Cấu Trúc Header Chi Tiết Dạng Bài Tránh Vỡ Chữ*: Phân tách hàng 1 (Meta badges bên trái, 3 nút hành động bên phải) và hàng 2 (Tiêu đề `h2` toàn bề ngang), chấm dứt hoàn toàn hiện tượng tiêu đề dài ("Nhận biết sự kiện lịch sử") bị 3 nút bên phải chèn ép bẻ thành 3 dòng cụt lủn.
  - *Khắc Phục Lỗi Mờ / Faded Tab Khoa Học Tự Nhiên*: Xóa bỏ hoàn toàn khối cầu trang trí nền `bg-cyan-50/70 blur-3xl` tại tọa độ `left-1/3 bottom-0` từng nằm trực tiếp phía sau tab "Khoa học tự nhiên", loại bỏ hoàn toàn hiện tượng suy hao tương phản và lỗi làm mờ chữ do bộ lọc blur GPU. Thiết lập `relative z-10` và chuẩn hóa nền trắng thuần `bg-white`, viền sắc nét `border-slate-200` và text tương phản cao cho toàn bộ 5 tab miền năng lực.
  - *Đồng Bộ Tuyệt Đối Tone Trắng Sáng Thanh Lịch*: Thay thế toàn bộ khối banner nền tối `slate-900` bằng container nền trắng sáng `bg-white border border-slate-200/80 rounded-2xl shadow-xs`, xóa bỏ hoàn toàn hiện tượng lệch tone "trên đen dưới trắng".
  - *Bố Cục Tinh Gọn, Gọn Gàng*: Giảm padding `p-8` xuống `p-5 lg:p-6`, chuyển đổi 2 khối thống kê thành các stat chip ngang nhỏ gọn `px-3.5 py-2`, tiêu đề và mô tả sư phạm súc tích.
  - *Căn Đều 5 Miền Năng Lực Trên 1 Hàng Ngang (`lg:grid-cols-5`)*: Bố trí lưới 5 cột đối xứng, không còn bị rớt dòng miền thứ 5. Tab kích hoạt nổi bật với viền `border-2 border-indigo-600` và nền `bg-indigo-50/90`.
  - *Làm Sạch Tiền Tố 'text' Thừa Trước Công Thức Hóa Học (`MathText.jsx`)*: Loại bỏ chữ `text` dính liền trước ion hóa học ($SO_4^{2-}$, $H_2O$, $Fe^{3+}$).

- **AI Engine (`V-Eval-Ai_Engine`) - Khắc Phục Lỗi 500 Khi AI Sinh Câu Hỏi Rèn Luyện (`CurriculumAiService.cs`)**:
  - *Sửa Lỗi `':' is invalid after a value`*: Sử dụng Regex Lookbehind `(?<=[\{\,]\s*)` bảo vệ giá trị trường JSON.
  - *Question Block Slicing Fallback*: Bóc tách câu hỏi dự phòng không bị ngắt bởi dấu `{...}` trong LaTeX.
  - *Bảo Toàn Chuỗi Thoát LaTeX*: Ngăn chặn biến đổi `\t` thành ký tự Tab ASCII.

- **Kiểm Thử Toàn Diện Hệ Thống**:
  - `V-Eval-Ai_Engine`: C# .NET 9 Clean Architecture build thành công 100% (**0 Error, 0 Warning**).
  - `V-Eval-Web_Client`: `npm run build` hoàn thành 100% (**0 Error, 0 Warning**, hoàn tất trong 763ms trên Vite 8 và React 19).
