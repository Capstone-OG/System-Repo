# Nhật Ký Cập Nhật (Update Log)

## [07/09/2026] - Khôi Phục Hiển Thị Chart.js, Hỗ Trợ Bảng Tiêu Đề 2 Tầng & Phân Tuyến Cắt Ảnh
- **Khôi Phục & Tối Ưu Hóa Chart.js & HTML Table Tương Tác (AI Engine)**:
  - Khắc phục lỗi Regex trong `view-exam.html` đối với `Biểu đồ cột` và `Biểu đồ hình tròn`: Xử lý triệt để trường hợp nhãn số liệu chứa dấu đóng ngoặc đơn (ví dụ: `Đầu tư (20%)`), bóc tách trọn vẹn tất cả danh mục và số liệu phần trăm thay vì dừng lại ở dấu đóng ngoặc đầu tiên.
  - Khôi phục hiển thị trực quan dạng Canvas Chart.js tương tác và HTML `<table>` viền phát sáng chuẩn đẹp cho tất cả các câu hỏi/chùm bài có biểu đồ cột, biểu đồ tròn và bảng số liệu.
- **Tự Động Nhận Diện & Tái Tạo Bảng Tiêu Đề 2 Tầng (2-Tier Nested Header with Colspan/Rowspan)**:
  - Nâng cấp thuật toán `convertMarkdownTableToHtml`: Tự động phát hiện cấu trúc tiêu đề cha - con (như `Số giờ chiếu sáng vào ban đêm (giờ): 0,5` đi cùng các cột `1, 2, 3, 4, 5` trong Chùm câu 109–111) và tự động dựng lại `<thead>` 2 tầng chuẩn mực với `colspan="6"` và `rowspan="2"`.
  - Giữ trọn vẹn tiêu đề cha bao phủ toàn bộ các cột dữ liệu con, sửa triệt để tình trạng các cột số liệu bị trơ trọi mất ngữ cảnh.
  - Cập nhật System Prompt trong `GeminiExamParserService`: Hướng dẫn trích xuất bảng 2 tầng qua thẻ HTML `<table>` chuẩn mực có `rowspan` và `colspan`.
  - Tinh chỉnh CSS `.exam-table`: Kẻ viền ô dạng lưới `1px solid`, căn giữa theo phương dọc (`vertical-align: middle`) và phương ngang, căn trái cột danh mục đầu tiên.
- **Phân Tuyến Thông Minh Bộ Trích Xuất Hình Ảnh (`PdfImageExtractor.cs`)**:
  - Bổ sung bộ lọc `isChartOrTable`: Tự động bỏ qua việc cắt và gán ảnh PDF cho các câu hỏi là biểu đồ cột/tròn hoặc bảng số liệu thống kê.
  - **Chỉ cắt và hiển thị ảnh cho các hình vẽ, đồ thị và sơ đồ thực tế không thể vẽ bằng chart**:
    - Đồ thị tọa độ dao động điều hòa $a-x$ (Câu 75).
    - Hình chụp thực tế thiết bị gương cong tại khúc cua đường đèo (Câu 78).
    - Chuỗi sơ đồ thí nghiệm liên hoàn ghép tế bào tảo (Chùm câu 106–108).
- **Đồng Bộ Giao Diện Web Viewer (`view-exam.html`)**:
  - Ưu tiên hiển thị Canvas Chart.js và HTML Table khi phát hiện cấu trúc biểu đồ hoặc bảng số liệu; tự động ẩn khung ảnh tĩnh nếu mục đó đã được biểu diễn bằng chart tương tác.
