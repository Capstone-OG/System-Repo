# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [20/10/2026] - Khắc Phục Lỗi Icon Bài Toán Mẫu, Tone Trắng Panoramic Workspace, Xóa Dòng Bằng Backspace, Chống Cắt Công Thức & Mở Rộng Thư Viện Ký Hiệu GDPT 2018 Toàn Diện

- **Web Client (`V-Eval-Web_Client`) - Tinh Chỉnh Sư Phạm Toàn Diện & Trải Nghiệm Soạn Thảo WYSIWYG**:
  - *Khắc Phục Lỗi Icon Kim Cương ''*: Sử dụng Unicode regex `^[^\p{L}\p{N}\s]+` lọc sạch ký tự Unicode hỏng, thay bằng vector Lucide `FileText` amber-600 sắc nét trong thẻ 'Bài toán mẫu áp dụng phương pháp:'.
  - *Đồng Bộ Tone Trắng Panoramic Workspace*: Chuyển đổi toàn bộ dải gradient tối `slate-900` của modal header và pattern header bar sang nền trắng sáng `bg-white border-b border-slate-200 text-slate-900`, triệt tiêu hoàn toàn độ lệch màu.
  - *Xóa Dòng Bằng Phím Backspace*: Tích hợp logic xử lý sự kiện Backspace trên canvas soạn thảo, tự động xóa dòng rỗng hoặc gộp dòng tại vị trí đầu dòng liền mạch như Microsoft Word.
  - *Loại Bỏ Đoạn Mẹo Dưới Chân Trang*: Đã xóa bỏ toàn bộ dòng chữ hướng dẫn không cần thiết ở footer canvas theo đúng yêu cầu người dùng.
  - *Chống Cắt Cụt '...' Công Thức Dài*: Gỡ bỏ class `truncate`, mở rộng container KaTeX lên 280px kèm cuộn ngang và mở rộng popup inspector lên `max-w-[540px]`.
  - *Khắc Phục Chữ Trắng Trên Nền Trắng*: Thêm class hiển thị `text-slate-900 placeholder:text-slate-400` cho tất cả các ô nhập liệu đề bài, đáp án A-D và form tạo câu hỏi mới trong Khối 4.
  - *Mở Rộng Thư Viện Ký Hiệu Đồ Sộ GDPT 2018 (Lớp 10 - 12)*: Bổ sung toàn diện danh mục công thức cho Ngữ Văn (Tu từ, Lập luận, Cấu trúc đoạn văn, Thể thơ), Địa Lý (Dân số, Khí hậu, Cán cân XNK, Năng suất, Tọa độ), Sinh Học (Di truyền ADN/ARN, Nguyên phân/Giảm phân, Menđen & Hardy-Weinberg), và Toán Học (Hình học Oxyz, Xác suất có điều kiện, Công thức Bayes, Kỳ vọng, Phương sai).

- **Kiểm Thử Toàn Diện Hệ Thống**:
  - `V-Eval-Web_Client`: `npm run build` hoàn thành 100% (**0 Error, 0 Warning**, hoàn tất trong 788ms trên Vite 8 và React 19).
