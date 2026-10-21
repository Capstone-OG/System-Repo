# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [22/10/2026] - Khắc Phục Lỗi 404 Xóa Chương Tổng Hợp, Hộp Thoại Xác Nhận Xóa In-App, Tinh Gọn Modal Sửa Nhanh (Icon Cây Bút) & Hệ Thống Toast Toàn Cục

- **Content Service - Khắc Phục Lỗi HTTP 404 Khi Xóa Chương Tổng Hợp (`DELETE /api/content/curriculum/nodes/{id}`)**:
  - Chuyển đổi route constraint tại `CurriculumController.cs` từ `[HttpDelete("nodes/{id:guid}")]` sang `[HttpDelete("nodes/{id}")]` với tham số `[FromRoute] string id`, cho phép tiếp nhận cả Guid thực tế lẫn synthetic container ID (`chap-general-...`).
  - Mở rộng `DeleteNodeCommand.cs`: Tự động nhận diện prefix `chap-general-`, bóc tách `domainId` và cascade delete toàn bộ các kỹ năng phẳng (flat skills) thuộc miền tri thức (`s.DomainId == domainId && s.ParentId == null`), đồng thời dọn dẹp sạch tài liệu (`Materials`), ngân hàng câu hỏi (`Questions`) và quan hệ đồ thị (`SkillPrerequisites`) trong CSDL PostgreSQL.
  - Solution `V-Eval-Content_Service.sln` biên dịch sạch 100% (**0 Warning, 0 Error** trên .NET 9 SDK), dịch vụ đang chạy ổn định trên cổng 5249/5250.

- **Web Client - Hộp Thoại Xác Nhận Xóa In-App Hiện Đại (Zero Native Browser Confirm / Alert)**:
  - Loại bỏ hoàn toàn hộp thoại chặn luồng `window.confirm()` của trình duyệt khi xóa Chương, Bài học hoặc Dạng bài trong `CurriculumExplorerView.jsx`.
  - Triển khai modal xác nhận in-app `confirmDeleteDialog` đồng bộ ngôn ngữ thiết kế Glassmorphism, hiển thị cảnh báo đỏ (`rose-500`), icon `<AlertTriangle />`, chi tiết các nội dung con bị xóa cascade và nút "Xác Nhận Xóa" chuyên nghiệp.
  - Trong `CurriculumStudioEditor.jsx`, cơ chế xóa câu hỏi được thay thế bằng xác nhận 2 chạm (Two-Tap Confirmation) đếm ngược 3 giây an toàn.

- **Web Client - Tinh Gọn Modal Sửa Nhanh (Metadata-Only) & Chuyển Nút Sửa Nhanh Sang Icon Cây Bút**:
  - Chuyển đổi nút bấm văn bản "Sửa nhanh" trên thanh công cụ thành icon button `<Pencil className="w-4 h-4" />` tinh gọn kèm tooltip "Sửa thông tin nhanh".
  - Tái cấu trúc modal `isEditModalOpen`: Chỉ cho phép chỉnh sửa siêu dữ liệu (Tên Dạng bài / Tiêu đề, Chương học trực thuộc, Khối lớp 10-12, Mức độ nhận thức chuẩn Bloom, và Trọng số năng lực %), loại bỏ 4 tab biên soạn nội dung bên trong và bổ sung banner điều hướng sang Studio Sư Phạm.

- **Web Client - Tự Động Nạp & Mở Dạng Bài Đầu Tiên Khi Chọn Chương / Bài Học**:
  - Cập nhật `toggleChapter` và `toggleLesson` trong `CurriculumExplorerView.jsx`: Khi người dùng nhấp vào tiêu đề Chương hoặc Bài học, hệ thống tự động tìm và chọn dạng bài đầu tiên (`selectedPattern`), giải quyết dứt điểm tình trạng khung bài học bên phải bị trống khi mới chọn chương.

- **Web Client - Khắc Phục Cảnh Báo KaTeX Strict Mode Đối Với Ký Tự Tiếng Việt (`MathText.jsx`)**:
  - Bổ sung cấu hình `strict: 'ignore'` trong trình dựng `renderKatexHtml` của `MathText.jsx`, triệt tiêu hoàn toàn cảnh báo `LaTeX-incompatible input Unicode text character "Đ" used in math mode`.

- **Web Client - Hệ Thống Thông Báo Toàn Cục (Global Toast Notification System)**:
  - Triển khai `ToastContext.jsx` & `GlobalToastContainer.jsx` thay thế triệt để `window.alert()`.
  - Hỗ trợ 4 nhóm trạng thái (Success, Error, Warning, Info), thanh đếm ngược tự động dừng khi rê chuột, và cơ chế bọc tự động chặn `window.alert()` toàn hệ thống.

- **Kiểm Thử Toàn Diện Hệ Thống**:
  - `V-Eval-Content_Service`: `dotnet build` đạt **0 Warning, 0 Error**.
  - `V-Eval-Web_Client`: `npm run build` hoàn thành 100% (**0 Error, 0 Warning**, hoàn tất trong 940ms trên Vite 8 và React 19).
