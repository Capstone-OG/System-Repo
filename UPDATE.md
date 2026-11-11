# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - V-EVAL CAPSTONE SYSTEM REPO

## [12/11/2026] - Khảo Sát Bể 4 Khóa Gemini, Cập Nhật Gemini-3.6-Flash Triệt Tiêu 503, Khắc Phục Hoàn Toàn Lỗi KaTeX Đa Dòng & Đồng Bộ Triển Khai Docker

- **Khảo Sát Thực Tế Bể 4 Khóa Gemini & Cập Nhật Mô Hình Ưu Tiên Chống Lỗi 503 ([`appsettings.json`](./Configs/V-Eval-Ai_Engine/appsettings.json), [`docker-compose.yml`](./docker-compose.yml))**:
  - Thực hiện ping kiểm tra trực tiếp 4 API keys Gemini trong hệ thống với các dòng mô hình:
    - `gemini-3.6-flash`: **HTTP 200 OK** trên cả 4/4 keys (phản hồi siêu tốc, độ ổn định tuyệt đối).
    - `gemini-3.5-flash-lite`: **HTTP 200 OK** trên cả 4/4 keys (~1.0s).
    - `gemini-3.5-flash`, `gemini-3.1-flash-lite`, `gemini-flash-lite-latest`: **HTTP 200 OK**.
    - `gemini-3.8-flash`: **HTTP 503 Service Unavailable / Timeout** trên cả 4 keys (xác nhận chính xác nguyên nhân gây nghẽn và timeout như log người dùng cung cấp).
  - Tái cấu trúc `GeminiModels`: Đưa `gemini-3.6-flash` lên làm mô hình chủ lực số 1, tiếp nối bởi `gemini-3.5-flash-lite`, `gemini-3.5-flash`, `gemini-3.1-flash-lite`, `gemini-flash-lite-latest`; gỡ bỏ hoàn toàn `gemini-3.8-flash`.

- **Khắc Phục Triệt Để Lỗi Render KaTeX Math & Cân Bằng Cú Pháp Giao Diện ([`MathText.jsx`](./All%20Services/V-Eval-Web_Client/src/components/common/MathText.jsx))**:
  - Giới hạn inline math strictly trên từng dòng (`\$[^\$\r\n]+?\$`), loại bỏ triệt để hiện tượng rò rỉ math mode nuốt nhiều dòng văn bản tiếng Việt (`suyragốcacidlà`).
  - Tự động nhận diện nhãn mở đầu `Phương trình: ...` hoặc `PTHH: ...`, tách nhãn và bọc phương trình phản ứng hóa học thành khối display math `$$...$$` độc lập.
  - Sửa lỗi khoảng trắng sau dấu gạch dưới `(OH)_ 3` -> `(OH)_3`.
  - Tự động chuẩn hóa và bọc công thức có chỉ số dưới `C_{15}H_{31} COOH` -> `$C_{15}H_{31}COOH$`.
  - Ghép nối công thức ester bị gãy dòng `$C_nH_{2n}\nO_2` -> `$C_nH_{2n}O_2$`.
  - Đóng gói SPA bằng `npm run build` (2.82s, 3015 modules transformed, 0 lỗi) và nạp lại cấu hình Nginx trong Docker container `v_eval_web_client` (`nginx -s reload`).

- **Chuẩn Hóa Hậu Xử Lý Chuỗi KaTeX Phía Backend ([`CurriculumAiService.cs`](./All%20Services/V-Eval-Ai_Engine/V-Eval-Ai_Engine.Infrastructure/Services/CurriculumAiService.cs))**:
  - Đồng bộ logic xử lý nhãn phương trình phản ứng hóa học, sửa khoảng trắng chỉ số dưới và bọc công thức hữu cơ phức tạp.
  - Cân bằng dấu `$` an toàn từng dòng `EnsureBalancedDollars(s)` và bảo toàn dấu `$` trước dấu chấm câu (`$C_{17}H_{33}$.`).
  - Toàn bộ **19/19 unit tests** trong AI Engine vượt qua thành công 100% trong 294 ms. Rebuild và triển khai container `v_eval_ai_engine` trên Docker.
