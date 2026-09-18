# AGENT RULE: MARKDOWN & MERMAID FORMATTING FOR MD EDITOR PLUS

> [!IMPORTANT]
> Quy tắc định dạng tài liệu Markdown và sơ đồ Mermaid tương thích 100% với extension MD Editor Plus và các trình xem Markdown mặc định trên Chromium.

---

## 🎨 CHUẨN HÓA TRÌNH TRÌNH BÀY MARKDOWN & MERMAID

Khi tạo mới hoặc cập nhật bất kỳ file tài liệu `.md` nào trong dự án, AI Assistant **BẮT BUỘC** phải tuân thủ các nguyên tắc sau:

### 1. Đường dẫn liên kết (File Links)
- Tuyệt đối **KHÔNG dùng URL tuyệt đối `file:///`** trong các file Markdown tài liệu repo.
- Luôn sử dụng đường dẫn tương đối dạng `./` (Ví dụ: `[SQL.sql](./docs/SQL/SQL.sql)`).

### 2. Công thức KaTeX & Ký tự Escape
- **KHÔNG dùng dấu `$` thô** (`$formula$`) bao quanh mã LaTeX trong văn bản danh sách/bullet text, vì MD Editor Plus sẽ render thành chuỗi text màu đỏ/lỗi hiển thị.
- **Cơ chế bọc an toàn**: Bọc các mã lệnh LaTeX, chuỗi OCR thô và công thức trong thẻ inline code backtick (ví dụ: `` `H = \frac{P_n - P_{hp}}{P_n} \times 100\%` ``) hoặc khối code block.
- Tránh các chuỗi escape chưa bọc backtick như `\b`, `\t` làm nuốt ký tự khi deserialize/render Markdown.

### 3. Chuẩn hóa Sơ đồ Mermaid (Tương thích Mermaid 11.15.0+)
- **Bọc ngoặc kép `"` tất cả tên node/participant** có chứa ký tự đặc biệt, dấu ngoặc đơn `()`, dấu hai chấm `:`, ngoặc vuông `[]`.
- **Cấm cú pháp liên kết gộp**: KHÔNG dùng `A & B --> C`. Hãy tách thành 2 dòng `A --> C` và `B --> C`.
- **Cấm khối lồng nhau sai chuẩn**: KHÔNG lồng khối `loop` bên trong khối `par`, KHÔNG lồng `loop` trong `loop` trong `sequenceDiagram`.
