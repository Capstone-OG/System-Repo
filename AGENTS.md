# AGENT RULES - V-EVAL CAPSTONE SYSTEM REPO

> [!IMPORTANT]
> Đây là file quy tắc hệ thống dành cho AI Assistant (Antigravity). Tất cả công việc phát triển trong dự án V-Eval phải tuân thủ nghiêm ngặt các quy tắc dưới đây.

---

## 📝 QUY TẮC CẬP NHẬT TÀI LIỆU VÀ TIẾN ĐỘ BẮT BUỘC (DOCUMENTATION FIRST RULE)

### 1. THỨ TỰ THỰC HIỆN BẮT BUỘC (STRICT ORDER OF OPERATIONS)
Khi thực hiện bất kỳ công việc nào (tạo mới, sửa lỗi, nâng cấp kiến trúc, refactor):

1. **Bước 1: Code & Kiểm thử vần hành**
   - Viết code và chạy lệnh kiểm thử (`dotnet build`, `docker compose config`...) đảm bảo code sạch 100%.
2. **Bước 2: Cập nhật Tài liệu & UPDATE.md TRƯỚC TIÊN (MANDATORY)**
   - Cập nhật nhật ký tiến độ vào bộ 3 file tài liệu chuẩn trong thư mục `docs/` của các service liên quan:
     - **`docs/daily.md`**: Nhật ký cập nhật tiến độ hằng ngày (`[DD/MM/YYYY]`).
     - **`docs/process.md`**:
       - *Phần trên*: Kiến trúc dịch vụ & danh sách các thành phần cần triển khai.
       - *Phần dưới*: Bảng theo dõi tiến độ cho từng mục (mô tả rõ từng hạng mục đang ở đâu, trạng thái và tiến độ chi tiết ra sao).
     - **`docs/architecture_acceptance.md`**: Báo cáo nghiệm thu & thấu hiểu kiến trúc (Tiếng Anh).
   - Làm mới và cập nhật file `UPDATE.md` của từng service vừa đụng tới và `UPDATE.md` của `System-Repo`:
     - **XÓA TOÀN BỘ NỘI DUNG CỦA CÁC NGÀY TRƯỚC (MANDATORY)**: File `UPDATE.md` chỉ được phép chứa duy nhất 1 mục tiến độ của **ngày hiện tại `[DD/MM/YYYY]`**.
     - Ghi chép tiến độ súc tích, chuẩn xác của ngày hiện tại để `UPDATE.md` luôn gọn gàng và tập trung 100% vào commit mới nhất.
3. **Bước 3: Mới được phép hỏi hoặc thực hiện Git Add / Commit / Push**
   - Chỉ khi Bước 2 hoàn thành 100%, AI mới được phép đề xuất hoặc thực hiện `git add`, `git commit` và `git push` (hoặc hướng dẫn dùng `Scripts/push.bat`).

---

## 🛡️ QUY TẮC AN TOÀN BỘ SCRIPT HỆ THỐNG
- Tất cả các script trong thư mục `Scripts/` (`pull.bat`, `push.bat`, `setup.bat`, `run_docker.bat`, `run_local.bat`) phải luôn duy trì cú pháp chuẩn Windows Batch (tránh escape quote `\"` ở `pushd`, không dùng ngoặc `()` gây lỗi trong chuỗi `echo`).

---

## 🎨 QUY TẮC CHUẨN HÓA MARKDOWN & MERMAID (MD EDITOR PLUS COMPATIBLE RULE)

Để đảm bảo tất cả file tài liệu `.md` hiển thị hoàn hảo 100% trên extension **MD Editor Plus** (và các trình preview Markdown dựa trên Chromium):

1. **Đường dẫn liên kết (File Links)**:
   - Tuyệt đối **KHÔNG dùng URL tuyệt đối `file:///`** trong các file Markdown tài liệu của repo.
   - Luôn sử dụng đường dẫn tương đối dạng `./` (Ví dụ: `[SQL.sql](./docs/SQL/SQL.sql)`).

2. **Công thức KaTeX & Ký tự Escape**:
   - **KHÔNG dùng dấu `$` thô** (`$formula$`) bao quanh mã LaTeX trong văn bản danh sách/bullet text nếu môi trường preview là MD Editor Plus tiêu chuẩn, vì parser sẽ render thành chuỗi text màu đỏ/lỗi hiển thị.
   - **Cơ chế bọc an toàn**: Bọc các mã lệnh LaTeX, chuỗi OCR thô và công thức trong thẻ inline code backtick (ví dụ: `` `H = \frac{P_n - P_{hp}}{P_n} \times 100\%` ``) hoặc khối code block.
   - Tránh các chuỗi escape chưa bọc backtick như `\b`, `\t` làm nuốt ký tự khi deserialize/render Markdown.

3. **Chuẩn hóa Sơ đồ Mermaid (Tương thích Mermaid 11.15.0+)**:
   - **Bọc ngoặc kép `"` tất cả tên node/participant** có chứa ký tự đặc biệt, dấu ngoặc đơn `()`, dấu hai chấm `:`, ngoặc vuông `[]`.
   - **Cấm cú pháp liên kết gộp**: KHÔNG dùng `A & B --> C`. Hãy tách thành 2 dòng `A --> C` và `B --> C`.
   - **Cấm khối lồng nhau sai chuẩn**: KHÔNG lồng khối `loop` bên trong khối `par`, KHÔNG lồng `loop` trong `loop` trong `sequenceDiagram`.

