# BẢNG THEO DÕI HOTFIX KIẾN TRÚC - V-EVAL AI ENGINE

> [!IMPORTANT]
> **QUY ƯỚC QUẢN LÝ HOTFIX (CARD-BASED TRACKING)**
> - Bảng này tổng hợp các thẻ sự cố (Hotfix Cards) phát hiện trong quá trình nghiệm thu mã nguồn.
> - Mỗi thẻ chứa đầy đủ trạng thái, mức độ, người phát hiện, mốc thời gian, mô tả và phương án khắc phục chi tiết.

---

## 📋 DANH SÁCH THẺ HOTFIX (HOTFIX ISSUE CARDS)

### 🎫 THẺ 01: [HF-AI-01] Thiếu Ngữ Pháp Thẻ Toán Học 3D & Cơ Chế Failover Trong Python RAG

| Thuộc tính | Chi tiết |
| :--- | :--- |
| **Mã Thẻ (Issue ID)** | `HF-AI-01` |
| **Trạng Thái (Status)** | `🟡 OPEN (Chờ triển khai)` |
| **Mức Độ (Severity)** | `CRITICAL (Ảnh hưởng hiển thị trực quan đề thi)` |
| **Người Phát Hiện** | **`ThinhTran2412`** |
| **Thời Gian Ghi Nhận** | `22/10/2026 - 15:42:00 (GMT+7)` |
| **Tệp Mã Nguồn** | [`All Services/V-Eval-Ai_Engine/rag-service/routers/diagnostic.py`](./../../All%20Services/V-Eval-Ai_Engine/rag-service/routers/diagnostic.py#L577) |

#### 📝 Mô Tả Chi Tiết & Bản Chất Lỗi:
- Trong hàm `_call_gemini_exam_generator`, chỉ thị `sys_prompt` chỉ thêm 1 câu bề nổi: *"BẮT BUỘC nhúng thẻ tương tác [MATH_GRAPH_3D] hoặc [MATH_GRAPH]"* nhưng **hoàn toàn không cung cấp quy chuẩn cú pháp (Schema Grammar)**.
- Gemini không biết các thuộc tính `shapeType`, `vertices`, `auxLines` nên sẽ tự "ảo giác" cú pháp ➔ Bộ Three.js/Canvas của Frontend không đọc được tọa độ, gây lỗi crash hoặc trắng màn hình.
- Kho câu hỏi dự phòng RAM (`QUESTION_TEMPLATES`) 100% là chữ thô.
- Python chỉ gọi duy nhất 1 model `gemini-flash-lite-latest`, không có cơ chế xoay vòng Failover (`gemini-3.6-flash`...) và dùng `json.loads` thô dễ sập khi gặp ngoặc kép tiếng Việt (`0xC4`/`N`).

#### 🛠️ Phương Án Giải Quyết:
1. Nhúng toàn bộ block đặc tả cú pháp chuẩn của thẻ `[MATH_GRAPH_3D]`, `[VARIATION_TABLE]`, `[MATH_GRAPH]` từ C# sang `sys_prompt` của Python.
2. Nâng cấp danh sách model dự phòng (Multi-Model Failover) và thêm bộ tiền xử lý khử dấu ngoặc kép tiếng Việt trước khi parse JSON.
3. Bổ sung các câu hỏi mẫu chứa thẻ 3D vào mảng `QUESTION_TEMPLATES` trong RAM.

---

### 🎫 THẺ 02: [HF-AI-02] Gán Cứng Ngầm Định Môn Toán Học Khi Thiếu Tham Số Input

| Thuộc tính | Chi tiết |
| :--- | :--- |
| **Mã Thẻ (Issue ID)** | `HF-AI-02` |
| **Trạng Thái (Status)** | `🟡 OPEN (Chờ triển khai)` |
| **Mức Độ (Severity)** | `HIGH (Nguy cơ phá vỡ ngữ nghĩa bóc tách tài liệu)` |
| **Người Phát Hiện** | **`ThinhTran2412`** |
| **Thời Gian Ghi Nhận** | `22/10/2026 - 15:56:00 (GMT+7)` |
| **Tệp Mã Nguồn** | [`All Services/V-Eval-Ai_Engine/V-Eval-Ai_Engine.API/Endpoints/CurriculumEndpoints.cs`](./../../All%20Services/V-Eval-Ai_Engine/V-Eval-Ai_Engine.API/Endpoints/CurriculumEndpoints.cs#L26-L30) |

#### 📝 Mô Tả Chi Tiết & Bản Chất Lỗi:
- Tại endpoint `/extract`, hệ thống khởi tạo mặc định:
  ```csharp
  string domainId = "dom_math_analysis";
  string domainName = "Toán học & Tư duy định lượng";
  ```
- Nếu client (Frontend hoặc bên thứ ba) upload file mà quên gửi hoặc gửi rỗng trường `domainId`/`domainName`:
- Hệ thống âm thầm gán file đó thành môn Toán. Dẫn đến tài liệu **Ngữ văn**, **Lịch sử**, **Địa lý** hoặc **Tiếng Anh** bị ép chạy theo Prompt của Toán học: bắt tìm công thức KaTeX, dựng hình 3D, vẽ bảng biến thiên, sinh phương pháp 4 bước và mẹo Casio, làm sai lệch hoàn toàn cây tri thức bài học.

#### 🛠️ Phương Án Giải Quyết:
1. Loại bỏ gán cứng mặc định `dom_math_analysis`.
2. Bổ sung **Strict Input Validation**: Kiểm tra nếu cả Form và Body JSON đều không có `domainId`/`domainName` thì trả về ngay `HTTP 400 Bad Request` kèm thông báo: *"Vui lòng chọn lĩnh vực môn học trước khi tải lên tài liệu."*
3. Tùy chọn nâng cao: Cho AI đọc lướt 1–2 trang đầu để tự nhận diện môn học nếu người dùng không chọn.

---

### 🎫 THẺ 03: [HF-AI-03] Hardcoded Prompt Dài Dằng Dặc Trong Mã Nguồn C# (Prompt-in-Code Smell)

| Thuộc tính | Chi tiết |
| :--- | :--- |
| **Mã Thẻ (Issue ID)** | `HF-AI-03` |
| **Trạng Thái (Status)** | `🟡 OPEN (Đề xuất tái cấu trúc)` |
| **Mức Độ (Severity)** | `MEDIUM (Bảo trì & Vận hành kiến trúc LLMOps)` |
| **Người Phát Hiện** | **`ThinhTran2412`** |
| **Thời Gian Ghi Nhận** | `22/10/2026 - 16:15:00 (GMT+7)` |
| **Tệp Mã Nguồn** | [`V-Eval-Ai_Engine.Infrastructure/Services/CurriculumAiService.cs`](./../../All%20Services/V-Eval-Ai_Engine/V-Eval-Ai_Engine.Infrastructure/Services/CurriculumAiService.cs#L210-L400), [`GeminiExamParserService.cs`](./../../All%20Services/V-Eval-Ai_Engine/V-Eval-Ai_Engine.Infrastructure/Services/GeminiExamParserService.cs#L55-L100) |

#### 📝 Mô Tả Chi Tiết & Bản Chất Lỗi:
- Các chuỗi Prompt điều khiển AI dài hàng nghìn ký tự (đặc tả thẻ 3D, bảng biến thiên, quy chuẩn sư phạm, phân chia STEM vs Xã hội) đang bị gán cứng trực tiếp dưới dạng chuỗi string literal trong các file code C#.
- **Hạn chế trong thực tế vận hành (Production Bottleneck)**:
  - Mỗi khi giáo viên hoặc chuyên gia AI muốn tinh chỉnh prompt, thêm dạng hình 3D mới hay sửa tiêu chuẩn câu hỏi, bắt buộc phải: sửa code C# ➔ biên dịch lại giải pháp ➔ đóng gói lại Docker container ➔ deploy lại server.
  - Không thể thực hiện thử nghiệm so sánh A/B Testing giữa các phiên bản prompt khác nhau.
  - Vi phạm nguyên tắc phân tách mối quan tâm (Separation of Concerns): Trộn lẫn logic điều khiển mạng với nội dung tri thức sư phạm của AI.

#### 🛠️ Phương Án Giải Quyết:
1. **Phương án tức thời (File-based Templates)**:
   - Tách các chuỗi prompt ra thành các file template độc lập trong thư mục `Templates/Prompts/` (ví dụ: `curriculum_math.prompt.md`, `math_graph_3d.prompt.md`).
   - Sử dụng Template Engine (như `Scriban` hoặc `Handlebars.Net`) để nạp biến động. Khi deploy Docker, chỉ cần mount volume thư mục prompt, chỉnh sửa prompt trực tiếp mà không cần build lại code C#.
2. **Phương án dài hạn (Prompt Catalog in DB / LLMOps)**:
   - Lưu trữ prompt vào bảng `v_eval_ai."PromptTemplates"` trên Supabase PostgreSQL kết hợp bộ nhớ đệm In-Memory Cache, cho phép quản lý và cập nhật prompt tức thì qua màn hình Admin Web UI (Zero-Downtime Tuning).

---

## 📊 BẢNG TỔNG KẾT TRẠNG THÁI HOTFIX

| Mã Thẻ | Phân Hệ | Vấn Đề Trọng Tâm | Mức Độ | Người Đưa Ra | Trạng Thái |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `HF-AI-01` | Python (`diagnostic.py`) | Thiếu grammar thẻ 3D & cơ chế Failover | `CRITICAL` | `ThinhTran2412` | `🟡 OPEN` |
| `HF-AI-02` | C# (`CurriculumEndpoints.cs`) | Gán cứng ngầm định môn Toán khi thiếu input | `HIGH` | `ThinhTran2412` | `🟡 OPEN` |
| `HF-AI-03` | C# (`CurriculumAiService.cs`) | Hardcoded Prompt dài trong code C# | `MEDIUM` | `ThinhTran2412` | `🟡 OPEN` |
