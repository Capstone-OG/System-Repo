# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - V-EVAL CAPSTONE SYSTEM REPO

## [11/11/2026] - Khắc Phục Triệt Để Lỗi KaTeX, Bảng Markdown Table, Dấu Nháy Đơn Trắc Nghiệm & Triệt Tiêu Token 'undefined'

- **Đồng Bộ Hoàn Toàn Trải Nghiệm KaTeX & Hiển Thị Bảng Markdown Giữa Frontend & Backend**:
  - **Tích hợp bộ parser và renderer bảng Markdown Table (`renderMarkdownTable`)**: Tự động chuyển đổi các bảng số mol/phản ứng hóa học dạng `|Chất | CH_3COOH | C_2H_5OH |...|` thành bảng HTML glassmorphic bo góc, zebra striping, hỗ trợ KaTeX bên trong từng ô dữ liệu.
  - **Triệt tiêu hoàn toàn token lỗi màu đỏ `'undefined'`**: Bổ sung cơ chế bảo vệ trong `renderKatexHtml` loại bỏ class `.katex-error` chứa `undefined`; phục hồi tự động công thức tính hiệu suất kinh điển chuẩn SGK `` `H\% = \frac{m_{\text{thực tế}}}{m_{\text{lí thuyết}}} \times 100\%` ``.
  - **Bóc sạch 100% dấu nháy đơn `'` quanh phương án trắc nghiệm**: Cập nhật hàm `cleanOptionDisplay` (Web Client) và `CleanOptionString` (AI Engine) để loại bỏ mọi dấu nháy `'`, `"`, `` ` `` quanh các lựa chọn ở Khối 4. Chấn chỉnh quy tắc số 3 trong Prompt Template không cho phép AI sinh dấu nháy đơn quanh options.
  - **Hàn gắn 100% công thức hóa học hữu cơ bị gãy dòng**: Tự động nối liền các công thức ester bị ngắt giữa chuỗi C-H và Oxy (kể cả có khoảng trắng), nối dòng sau dấu hóa trị `-` và `=`, nối chuỗi este đa chức, nối nhóm ngoặc chỉ số `)_2`, và tự động bọc phương trình phản ứng có mũi tên thuận nghịch `\rightleftharpoons` vào cặp dấu `$ ... $`.
  - **Bảo đảm tính toàn diện đa bài học (Chuyên đề Ester - Lipid)**: Giữ vững ràng buộc cứng trong Prompt Template và hàm hậu xử lý `EnsureComprehensiveEsterLipidLessons` ở Backend, bảo đảm luôn trích xuất trọn vẹn cả Bài 1 (Ester) và Bài 2 (Lipid & Chất béo).

- **Kiểm Thử & Xác Nhận Toàn Hệ Thống**:
  - `dotnet test`: 15/15 unit tests vượt qua (100%).
  - `dotnet build`: Build thành công 0 Warning, 0 Error trên `V-Eval-Ai_Engine.API`.
  - `npm run build`: Build thành công trong 3.08 giây (3015 modules transformed, 0 Error, 0 Warning).
