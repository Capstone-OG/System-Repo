# Nhật Ký Cập Nhật (Update Log)

## [11/09/2026] - Thiết Kế Ma Trận Định Tuyến Microservices & Middleware V-Eval Gateway
- **Cấu Hình Routing & Cluster Matrix (`appsettings.json`)**:
  - Thiết lập bảng định tuyến YARP cho 4 phân hệ chính: AI Engine (`:5104`), Content Service (`:5249`), Identity Service (`:5001`), Practice Service (`:5002`).
  - Định tuyến các URL `/api/ai-engine/*`, `/view-exam`, `/extracted_images/*`, `/api/content/*` về đúng service xử lý.
- **Tích Hợp Middleware & Distributed Tracing**:
  - Bổ sung middleware tự động sinh và chuyển tiếp `X-Correlation-ID` header cho distributed tracing giữa các microservice.
  - Thiết lập chính sách CORS cho phép tất cả các nguồn truy cập từ Frontend/SPA.

## [10/09/2026] - Khởi Tạo API Gateway & Tích Hợp Thư Viện YARP Reverse Proxy
- **Khởi Tạo Cấu Trúc YARP API Gateway (`V-Eval-Gateway`)**:
  - Tích hợp gói NuGet `Yarp.ReverseProxy` (v2.3.0) cho dự án API Gateway .NET 9.
  - Đồng bộ hóa các hợp đồng giao tiếp gRPC (.proto) chung (`ai.proto`, `content.proto`, `auth.proto`, `practice.proto`).

## [09/09/2026] - Cập Nhật Tiến Độ Toàn Diện & Rà Soát Tài Liệu Kiến Trúc V-Eval
- **Đồng Bộ Tài Liệu Quy Trình & Kiến Trúc**:
  - Hoàn thiện chi tiết luồng xử lý và kết nối hệ thống thi đánh giá năng lực V-ACT.
  - Cập nhật nhật ký các mốc phát triển và đồng bộ trạng thái hệ thống.

## [08/09/2026] - Chuẩn Hóa Đặc Tả Luồng Phân Tích & Hiển Thị Đề Thi, Đồng Bộ Kiến Trúc V-Eval
- **Hoàn Thiện Tài Liệu Đặc Tả Luồng Xử Lý (docs/luong_phan_tich_va_hien_thi_de_thi.md)**:
  - Xây dựng tài liệu chi tiết quy trình 3 luồng: AI Exam Ingestion Flow, Exam Rendering & Interactive UI, Database Persistence Flow.
  - Thiết kế sơ đồ kiến trúc Mermaid đồng bộ hóa luồng giữa AI Engine, Content Service và Client Web.
  - Tổng hợp ma trận ánh xạ file code (Code Mapping Matrix) và các mốc hoàn thành cho hệ thống V-Eval.
- **Rà Soát & Tối Ưu Hóa Clean Architecture**:
  - Kiểm tra tính tương thích giữa DTO chuẩn hóa từ AI Engine và các Entity trong Content Service.
  - Chuẩn bị pipeline phân tích và render đề thi toàn diện cho hệ thống thi trực tuyến.

## [07/09/2026] - Sửa Lỗi Hiển Thị Công Thức Vật Lý & Hóa Học, Tái Tạo Delta (\Delta) & Bảng Số Liệu 2 Tầng
- **Khắc Phục Triệt Để Lỗi Công Thức Vật Lý & Hóa Học (Câu 93 & Đoạn Văn Truyền Tải Điện)**:
  - **Khôi phục ký tự thoát JSON cho LaTeX**: Sửa lỗi JSON Deserialization nuốt các ký tự điều khiển ASCII biến `\frac` thành `rac` (form-feed), `\times` thành `	imes` (tab), `\text` thành `	ext`, `\bar` thành `ar`.
  - **Sửa lỗi nhận diện ký hiệu Delta ($\Delta$)**: Khắc phục hiện tượng OCR nhìn nhầm ký hiệu tam giác biến thiên $\Delta$ thành `ar{ ext{A}}` hoặc `\bar{\text{A}}`. Tự động khôi phục về $\Delta[\text{Acetone}]$, $\Delta t$, $R = -\frac{\Delta[\text{Acetone}]}{\Delta t}$.
  - **Tự động bọc dấu `$...$` cho công thức**: Các công thức Vật lý / Hóa học dài chưa có dấu đô-la (như $H = \frac{P_n - P_{hp}}{P_n} \times 100\%$, $P_{hp}$, $P_n$, $k^2$) và các đơn vị có số mũ âm ($2,33 \cdot 10^{-3}\text{ mol}\cdot\text{l}^{-1}\cdot\text{phút}^{-1}$) được tự động bọc thẻ KaTeX để hiển thị đúng chuẩn typographic Toán - Lý - Hóa.
  - **Chống lỗi nhân đôi chữ khi Copy từ KaTeX**: Bổ sung CSS `user-select: none` cho `.katex-mathml`, khắc phục tình trạng copy công thức bị dính 2 lần (như `k 2 k 2` hoặc `P h p P hp`).
  - **Bổ sung Bộ Lọc C# Backend (`GeminiExamParserService.cs`)**: Thêm hàm `SanitizeJsonForLatex` xử lý chuỗi JSON trước khi deserialize và `CleanExamDto` làm sạch toàn bộ DTO trước khi trả về.
- **Tự Động Nhận Diện & Tái Tạo Bảng Tiêu Đề 2 Tầng (2-Tier Nested Header with Colspan/Rowspan)**:
  - Nâng cấp thuật toán `convertMarkdownTableToHtml`: Tự động nhận diện cấu trúc tiêu đề cha - con (như `Số giờ chiếu sáng vào ban đêm (giờ): 0,5` đi cùng các cột `1, 2, 3, 4, 5` trong Chùm câu 109–111) và tự động dựng lại `<thead>` 2 tầng chuẩn mực với `colspan="6"` và `rowspan="2"`.
  - Tinh chỉnh CSS `.exam-table`: Kẻ viền ô dạng lưới `1px solid`, căn giữa theo phương dọc (`vertical-align: middle`) và phương ngang, căn trái cột danh mục đầu tiên.
- **Khôi Phục & Tối Ưu Hóa Chart.js & HTML Table Tương Tác**:
  - Khắc phục lỗi Regex trong `view-exam.html` đối với `Biểu đồ cột` và `Biểu đồ hình tròn`: Xử lý triệt để trường hợp nhãn số liệu chứa dấu đóng ngoặc đơn (ví dụ: `Đầu tư (20%)`), bóc tách trọn vẹn tất cả danh mục và số liệu phần trăm.
- **Phân Tuyến Thông Minh Bộ Trích Xuất Hình Ảnh (`PdfImageExtractor.cs`)**:
  - Bổ sung bộ lọc `isChartOrTable`: Loại trừ toàn bộ các biểu đồ cột/tròn hoặc bảng số liệu khỏi việc gán ảnh tĩnh cắt từ PDF; chỉ cắt ảnh cho đồ thị tọa độ $a-x$ (Câu 75), hình chụp thực tế (Câu 78) và sơ đồ thí nghiệm (Chùm 106–108).
