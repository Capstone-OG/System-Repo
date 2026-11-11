# GIẢI PHÁP XỬ LÝ ĐỒ THỊ, HÌNH VẼ & CÔNG THỨC TOÁN - LÝ - HÓA (2 CHIỀU)
## Dự án: Hệ thống cá nhân hóa lộ trình học và luyện thi Đánh giá năng lực tích hợp AI (V-ACT 2026)

Tài liệu này đặc tả phương án giải quyết kỹ thuật để hệ thống AI vừa **hiểu đề** vừa **tự động sinh đề mới** chứa các yếu tố phức tạp (Hình học 3D, đồ thị hàm số giải tích, sơ đồ thí nghiệm vật lý, phương trình hóa học) một cách tối ưu, tiết kiệm token nhất.

---

## I. MA TRẬN GIẢI PHÁP KỸ THUẬT (2 CHIỀU)

| Loại Nội Dung | AI Đọc & Hiểu Đề (Input) | AI Tự Sinh Đề Mới (Output) | Cách Hiển Thị Phía Frontend |
| :--- | :--- | :--- | :--- |
| **Công thức Toán / Lý** | GPT-4o đọc hiểu trực tiếp mã LaTeX. | AI sinh câu hỏi mới dưới dạng văn bản có chứa ký hiệu LaTeX. | Sử dụng thư viện **KaTeX** (React) hoặc **flutter_math_fork** (Flutter) để vẽ vector sắc nét. |
| **Phương trình Hóa học** | GPT-4o hiểu cấu trúc chuỗi phản ứng viết bằng chữ/LaTeX. | AI sinh phương trình phản ứng hóa học định dạng chữ chuẩn hóa LaTeX. | Render trực tiếp bằng KaTeX/Markdown. |
| **Bảng số liệu (Tables)** | Gemini / GPT bóc tách bảng số liệu dạng Markdown Table (`| Cột 1 | Cột 2 | ...`). | AI sinh bảng số liệu chuẩn Markdown. | Bộ parser `markdownToHtml` tự động chuyển đổi sang thẻ HTML `<table>` Dark-mode viền phát sáng, header cyan. |
| **Biểu đồ số liệu (Charts)** | Gemini / GPT đọc hiểu ảnh biểu đồ cột, tròn, đường và trích xuất nhãn kèm tỷ lệ %. | AI sinh dữ liệu nhãn kèm số liệu (Label: Value). | Sử dụng **Chart.js** tự động dựng Canvas Bar Chart / Pie Chart, plugin in trực tiếp số liệu `${val}%` trên từng cột và lát cắt. |
| **Đồ thị hàm số (Graphs)** | GPT-4o Vision nhìn hình ảnh đồ thị và phân tích tính chất (cực trị, tiệm cận). | AI chỉ sinh ra **phương trình hàm số** (Ví dụ: `y = x^3 - 3x`). | Sử dụng thư viện **function-plot** (Canvas ở Frontend) hoặc vẽ tự động bằng **Matplotlib** (Python ở Backend). |
| **Hình học không gian (3D)** | GPT-4o Vision phân tích ảnh hình chóp, lăng trụ (base64/url) để hướng dẫn học sinh. | AI **chỉ định một mã hình mẫu** trong thư viện ảnh có sẵn và sinh ra các thông số giả định (cạnh bên, góc). | Tải ảnh tĩnh mẫu từ thư mục tài nguyên của hệ thống dựa trên ID hình vẽ hoặc hỗ trợ đính kèm/paste ảnh chụp đề gốc. |
| **Công thức cấu tạo Hóa học** | GPT-4o Vision nhìn và phân tích liên kết hóa học. | AI sinh đề dựa trên các hình vẽ mẫu có sẵn trong kho dữ liệu hữu cơ. | Hiển thị ảnh tĩnh mẫu. |

---

## II. CHI TIẾT CÁC GIẢI PHÁP ĐẶC THÙ

### 1. Đồ thị hàm số Giải tích (Cực trị, Tích phân, Tiệm cận)
Để tránh việc lưu trữ hàng nghìn hình ảnh đồ thị tĩnh và tiết kiệm token sinh ảnh, hệ thống áp dụng cơ chế **Vẽ đồ thị động bằng Phương trình**:
* **Quy trình hoạt động:**
  1. AI sinh ra thông số phương trình hoặc tọa độ các điểm đặc biệt dưới dạng JSON.
  2. Frontend (React/Flutter) sử dụng thư viện canvas vẽ đồ thị động nhận đầu vào là chuỗi phương trình đó để tự động vẽ đồ thị hàm số chuẩn xác.
* **Thư viện đề xuất:**
  * **React Web:** Thư viện **function-plot** (dựa trên D3 và HTML5 Canvas).
  * **Flutter Mobile:** Tự vẽ bằng CustomPainter dựa trên phương trình hoặc dùng thư viện đồ thị toán học.

### 2. Biểu đồ Thống kê (Cột & Tròn) & Bảng số liệu Ma trận (Đã triển khai - 04/09/2026)
Đối với dạng bài Đọc hiểu số liệu trong đề thi V-ACT (như Câu 61-63, 64-67, 68-70):
* **Bảng số liệu ma trận**: Hệ thống chuẩn hóa prompt AI xuất ra định dạng Markdown Table. Giao diện sử dụng thuật toán parser tự động phát hiện hàng/cột (kể cả bảng không có gạch biên `|`), sinh mã HTML `<table>` chuẩn, hỗ trợ xem rõ nét và responsive trên mọi thiết bị.
* **Biểu đồ cột (Bar Chart) & Biểu đồ tròn (Pie Chart)**:
  * Tích hợp thư viện **Chart.js** trực tiếp vào UI.
  * Tự động bóc tách cặp nhãn - giá trị (ví dụ: `Đầu tư: 20%`, `A: 22%`).
  * Tích hợp plugin vẽ số liệu trực tiếp (`barDirectDataLabels`, `pieDirectDataLabels`) sử dụng hook `afterDatasetsDraw` của Canvas để in số liệu trực quan `${val}%` ngay trên đỉnh từng cột và bên trong từng lát cắt, bám sát trực quan đề thi thật.

### 3. Hình học không gian 3D & Thí nghiệm thực hành
Vì các mô hình tạo ảnh (như DALL-E) không thể vẽ chính xác các nét đứt hình học không gian hoặc vị trí các đỉnh, hệ thống sử dụng giải pháp **Template Library & Đính kèm ảnh gốc**:
* **Quy trình hoạt động:**
  * Đồ án xây dựng sẵn 30-50 hình vẽ hình học không gian tiêu chuẩn (hình chóp tứ giác, hình chóp tam giác đều, hình hộp chữ nhật...) được gán mã `image_id`.
  * Đồng thời, trên giao diện quản trị đề thi cung cấp nút `📷 Đính kèm / Chèn ảnh gốc`, cho phép giáo viên đính kèm hoặc dán (Ctrl+V) trực tiếp ảnh chụp từ đề thi PDF vào từng câu hỏi trước khi lưu vào cơ sở dữ liệu.

### 4. Đa phương thức (OpenAI / Gemini Vision) để AI hiểu hình ảnh
Khi học sinh tương tác với AI Tutor tại câu hỏi có hình ảnh:
* Client gửi request kèm `{question_id}` lên Backend.
* Backend truy vấn link ảnh tương ứng (`image_url`) trong database.
* Backend tải ảnh và chuyển đổi sang chuỗi **Base64**, đóng gói gửi lên OpenAI API kèm prompt hỏi đáp. GPT-4o Vision sẽ phân tích ảnh và trả về phản hồi định hướng tư duy cho học sinh.

### 5. Kết Xuất Ảnh Cục Bộ Siêu Tốc (PDFium + SkiaSharp + PdfPig) & Quy Tắc Chống Lộ Đáp Án (Đã triển khai - 05/09/2026)
Đối với các câu hỏi đặc thù không thể vẽ bằng code thuần (Đồ thị dao động điều hòa $a-x$ Câu 75, Hình chụp gương cầu lồi khúc cua Câu 78, Chuỗi thí nghiệm cắt ghép rễ-tán tảo *Acetabularia* chùm 106-108):
* **Định vị & Kết xuất Cục bộ (100% Offline, 0 Tokens, 0.15s)**:
  * Không dùng Cloud AI để cắt ảnh. Sử dụng `UglyToad.PdfPig` quét toạ độ Bounding Box của ảnh trên trang.
  * Sử dụng `PDFtoImage` (Google PDFium Core C++) kết xuất trực tiếp vùng hình ảnh từ trang PDF với độ phân giải cao 150 DPI trên nền trắng tinh khiết (`SKColors.White`).
  * *Xử lý triệt để FlateDecode (Câu 75)*: Xuất ra tệp PNG hoàn chỉnh 100%, bảo toàn trọn vẹn hệ trục tọa độ $a-x$, các mốc số $40, -40, 1, -1$ và gốc tọa độ $O$.
  * *Xử lý triệt để Mặt nạ trong suốt (SMask) & Chú thích bên ngoài (Chùm 106-108)*: Loại bỏ 100% các khối đen xì (do mất mask trong suốt khi trích xuất thô), tự động bao bọc lề an toàn 20pt thu trọn vẹn các nhãn chữ Word bên ngoài ("tán", "thân", "gốc", "A. crenulata", "Tế bào ghép hoàn chỉnh 1 & 2") thành một sơ đồ duy nhất (`p14_combined.png`).
  * Tự động lọc Header logo ĐHQG-HCM (<160pt top) và các icon/ký tự nhiễu (<50px).
* **Quy tắc Chống Lộ Đáp Án (Zero-Spoiler Rule)**:
  * Khi sinh nội dung câu hỏi mô tả hình ảnh, cấm AI sử dụng tên thiết bị hoặc từ khóa mục tiêu của 4 phương án trắc nghiệm (ví dụ: với Câu 78 về "Gương cầu lồi", AI chỉ được viết *"thiết bị dạng mặt gương thường đặt tại các khúc cua đường đèo"* thay vì nói toạc móng heo *"gương cầu lồi"* trong đề bài).
* **Tự động Ánh xạ & Trình chiếu Lightbox**:
  * Gắn tự động `image_url` vào DTO câu hỏi và bài đọc theo số trang.
  * Frontend hỗ trợ xem hình trực quan, click để mở Lightbox phóng to toàn màn hình, và hỗ trợ dán ảnh nhanh từ bộ nhớ tạm (`Ctrl + V`).
  * Backend Content Service tự động nhúng cú pháp Markdown `![Hình minh họa](image_url)` vào trường `ContentLatex` của câu hỏi khi lưu vào PostgreSQL Supabase.

