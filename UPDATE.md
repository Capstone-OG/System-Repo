# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - V-EVAL CAPSTONE SYSTEM REPO

## [13/11/2026] - Live Ping Mô Hình Gemini, Khử Trùng Lặp Dạng Bài, Nâng Cấp Chuẩn Hóa KaTeX & Vận Hành Hệ Thống Qua Terminal (Không Dùng Docker)

- **Live Ping Gemini (4 API Keys)**: `gemini-3.1-flash-lite` đạt 100% 200 OK, ~808ms - 882ms; đưa lên ưu tiên số 1 trong [`appsettings.json`](./All%20Services/V-Eval-Ai_Engine/V-Eval-Ai_Engine.API/appsettings.json) và [`Configs/V-Eval-Ai_Engine/appsettings.json`](./Configs/V-Eval-Ai_Engine/appsettings.json). Bóc tách PDF thực tế: Gemini 9.09s, tổng 12.39s.
- **AI Engine ([`CurriculumAiService.cs`](./All%20Services/V-Eval-Ai_Engine/V-Eval-Ai_Engine.Infrastructure/Services/CurriculumAiService.cs))**:
  - Khử trùng lặp dạng bài cùng tên (lỗi duplicate `Dạng 4`), gộp câu hỏi độc bản, đánh số tuần tự `Dạng 1, 2, 3...`.
  - Chuẩn hóa KaTeX: khôi phục `textmol`/`textgam` -> `\text{mol}`/`\text{gam}`, mở rộng `\implies`, bất đẳng thức, bọc biến đơn trước đơn vị, chuẩn hóa chỉ số dưới tiếng Việt.
  - `CurriculumLatexNormalizationTests`: 14/14 pass; tổng 32/32 pass.
- **Web Client ([`MathText.jsx`](./All%20Services/V-Eval-Web_Client/src/components/common/MathText.jsx))**: đồng bộ bộ chuẩn hóa KaTeX, thay `'$$$1$$'` bằng callback an toàn.
- **Vận hành qua terminal**: AI Engine `5104`, Gateway `5212`, Web Client `5173` (AI Engine đã build lại và khởi động lại để nạp code mới).

- **Khắc Phục Lỗi KaTeX Còn Sót (Mũ `^`, Ngoặc Đơn, Chỉ Số Dưới Tiếng Việt) ([`CurriculumAiService.cs`](./All%20Services/V-Eval-Ai_Engine/V-Eval-Ai_Engine.Infrastructure/Services/CurriculumAiService.cs), [`MathText.jsx`](../All%20Services/V-Eval-Ai_Engine/V-Eval-Web_Client/src/components/common/MathText.jsx))**:
  - `fullEqPattern` hỗ trợ số mũ (`2^2`, `3^{2}`) và ngoặc đơn (`\times (3 \times 40 - 92)`), không còn tách `2^$2`; ngoặc không cân bằng/bao trọn biểu thức được đưa ra ngoài `$...$`.
  - Không còn can thiệp vào bên trong cặp `$...$` đã có; bước giải phóng văn bản tiếng Việt bỏ qua nội dung `_{...}` / `^{...}` nên `m_{chất béo}` không còn bị gỡ `$`.
  - Thêm test hồi quy `Regression_NoBareOrBrokenMath` (8 ca từ ảnh lỗi thực tế); tổng **42/42 tests pass**.

- **Khắc Phục Lỗi KaTeX Trần Do Web Client Gỡ `$` Nhầm (Lần 2)**:
  - Nguyên nhân gốc: bộ phục hồi trong [`MathText.jsx`](./All%20Services/V-Eval-Web_Client/src/components/common/MathText.jsx) dò từ tiếng Việt (`chất`, `muối`...) ngay cả bên trong `\text{...}` và `_{...}`, nên gỡ `$` của các công thức hợp lệ như `$n_{\text{NaOH}} = 3 \times n_{\text{chất béo}}$`. Nay chỉ dò phần ngoài `\text{}`/`_{}`/`^{}`.
  - Bộ nhận diện phương trình không còn nuốt xuống dòng kế tiếp (chỉ `[ \t]` giữa các vế); chỉ số dưới cho phép ngoặc đơn (`m_{muối (xà phòng)}`).
  - Kiểm chứng JS bằng Node trên các ca ảnh lỗi và 49/49 unit tests C# pass.

- **Đồng Bộ Cấu Hình Về [`Configs`](./Configs) (Nguồn Cấu Hình Chuẩn) & Deploy Tự Động Nạp Một Chiều**:
  - Gom `appsettings.json` / `.env` của toàn bộ service con vào `Configs/` bằng `Scripts/sync_config/sync_config.sh` (chế độ `[2]` Services -> Configs): Gateway, Identity, Content, Practice, AI Engine (kèm `rag-service/.env`), Web Client.
  - Khi deploy, [`start_docker.sh`](./start_docker.sh) và [`run_docker.bat`](./Scripts/run_docker/run_docker.bat) gọi `sync_config --force`: chỉ nạp **Configs -> Services** (ghi đè, có file `.bak`), tuyệt đối không đồng bộ ngược ra ngoài.
  - Build lại toàn bộ Docker image từ mã nguồn hiện tại bằng `docker compose build`.

