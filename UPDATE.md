# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [15/10/2026] - Kiến Trúc Soạn Thảo Đa Chế Độ: Soạn Thảo Trực Quan (Text In Preview Chuẩn Học Sinh) Song Hành Mã Nguồn LaTeX Thuần (Nhập Nhanh Từ AI), Chèn Ký Hiệu Tại Con Trỏ & Bóc Tách Khổ Lớn 79+ Trang

- **Kiến Trúc Soạn Thảo Đa Chế Độ Trực Quan & Mã Nguồn LaTeX Song Hành (`CurriculumStudioEditor.jsx` - Web Client)**:
  - *Đáp Ứng Đúng Bản Chất Soạn Thảo Sư Phạm (Text In Preview)*:
    - Loại bỏ hoàn toàn giải pháp phân rã 4 ô form cứng nhắc (Định nghĩa, Công thức, Quy tắc, Hình ảnh) gây cắt vụn luồng tư duy sư phạm của giáo viên.
    - Chế độ **Soạn Thảo Trực Quan (Text In Preview - Chuẩn Học Sinh)**: Khung soạn thảo văn bản tự nhiên kết hợp trực tiếp với **Khung Hiển Thị Trực Quan (Text In Preview - Giao Diện Học Sinh Thấy)** hiển thị song hành thời gian thực bằng `<MathText />`, render công thức toán học KaTeX thật (phân số, căn thức, giới hạn, đồ thị hình ảnh), không hiển thị text LaTeX thô.
    - Chế độ **Mã Nguồn LaTeX Thuần (Nhập Nhanh Từ AI)**: Khung soạn thảo monospace nền tối chuyên dụng cho việc dán nhanh 1-chạm kết quả trích xuất từ Gemini / ChatGPT / AI Engine.
  - *Cơ Chế Chèn Ký Hiệu KaTeX STEM Chuẩn Xác Tại Vị Trí Con Trỏ (Cursor-Precision Insertion Engine)*:
    - Sử dụng `textareaRefs` theo dõi chính xác vị trí con trỏ chuột (`selectionStart` / `selectionEnd`) trên từng textarea đang active.
    - Click vào bất kỳ ký hiệu nào trên Bảng KaTeX STEM 10 danh mục (120+ công thức toán học) sẽ tự động chèn đúng vị trí con trỏ và khôi phục focus tức thời.
- **Khắc Phục Triệt Để Ký Tự Thoát `\n` Bị Hiển Thị Thô Dạng Text (`MathText.jsx` - Web Client)**:
  - *Negative Lookahead Chính Xác*: Thay thế bằng danh sách bảo vệ đúng 15 lệnh LaTeX thực tế bắt đầu bằng `\n` (`` `\neq` ``, `` `\notin` ``, `` `\nabla` ``, `` `\nu` ``...). Giải phóng 100% các từ tiếng Việt và ngắt dòng thực tế (`` `\nTrong` ``, `` `\nKiểm` ``, `` `\nBước` ``).
  - *Đồng Bộ Textarea Biên Soạn*: Xuất hàm `unescapeLiteralNewlines` giải phóng `\n` thành Enter xuống dòng thực tế khi nạp lý thuyết và phương pháp giải vào khung soạn thảo Studio.
- **Tự Động Bọc KaTeX Cho Ion Đa Nguyên Tử & Hợp Chất Hóa Học**:
  - Tự động nhận diện và bọc KaTeX cho ion đơn/đa nguyên tử có điện tích: `` `H^+` ``, `` `OH^-` ``, `` `SO_4^{2-}` ``, `` `NO_3^-` ``, `` `Fe^{3+}` ``, `` `Na^+` ``, `` `Cl^-` ``.
  - Tự động nhận diện và bọc KaTeX cho các hợp chất có chỉ số dưới: `` `H_2O` ``, `` `H_2SO_4` ``, `` `HNO_3` ``, `` `CO_2` ``, `` `Fe_2O_3` ``, `` `KMnO_4` ``.
- **Khắc Phục Lỗi Type Hint Mapping Tại `documents.py:293` (`V-Eval-Ai_Engine`)**:
  - Khắc phục lỗi static type checking `Expected argument after ** to be a mapping, got: dict[str, Any] | tuple[Any, ...]` bằng cách ánh xạ minh thị từng thuộc tính đối tượng `DocumentVersionItem`.
- **Nâng Cấp Động Cơ Bóc Tách Tài Liệu Khổ Lớn 70-100 Trang (`V-Eval-Ai_Engine`)**:
  - Bảo toàn ngắt dòng `\n` cho tài liệu Word DOCX (`</w:p>`, `</w:tr>`), prompt chuyên sâu 5 bài học và 10 dạng bài, mở rộng `maxOutputTokens = 8192` và timeout 90 giây.
- **Trạng Thái Kiểm Thử Vận Hành Toàn Hệ Thống**:
  - `V-Eval-Ai_Engine.sln`: `dotnet build` đạt 100% (**0 Error, 0 Warning**).
  - `V-Eval-Web_Client`: `npm run build` đạt 100% (**0 Error, 0 Warning**, hoàn thành trong 750ms).
  - `documents.py`: `python -m py_compile` thành công 100% (**0 Error**).
  - Đã kiểm thử trích xuất thực tế tệp 79 trang đạt 10 Dạng bài chuẩn hóa.
