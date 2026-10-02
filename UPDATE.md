# Nhật Ký Cập Nhật (Update Log) - System Repo

## [02/10/2026] - Ra Mắt Trang Khảo Sát Năng Lực 30 Câu Thật Với AI, Tích Hợp KaTeX Toán Học, Đồng Bộ YARP Gateway & Kích Hoạt JWT Authentication

- **Cấu hình & Sửa Lỗi API Gateway YARP (`V-Eval-Gateway`)**:
  - Khắc phục lỗi thiếu dịch vụ `IAuthenticationSchemeProvider`: Bổ sung package `Microsoft.AspNetCore.Authentication.JwtBearer` và đăng ký `services.AddAuthentication(...).AddJwtBearer(...)`.
  - Mở rộng định tuyến tới cả 2 thành phần AI Engine: `.NET Core AI Engine` (Port `:5104`) và `Python FastAPI RAG Service` (Port `:8000`).
  - Đăng ký cụm `ai-rag-cluster` và 5 tuyến đường chuyên biệt: `/api/v1/diagnostic/{**catch-all}`, `/api/v1/chat/{**catch-all}`, `/api/v1/documents/{**catch-all}`, `/view-diagnostic`, `/view-textbook`.
- **Nâng Cấp Web Client (`V-Eval-Web_Client`)**:
  - **Trang Khảo Sát 30 Câu Thật (`DiagnosticAssessmentPage.jsx`)**: Cho phép thí sinh làm đề thi 30 câu fetch trực tiếp từ AI Engine (Gemini Cloud hoặc Calibrated Bank) với đồng hồ 45 phút, điều hướng 30 ô, gắn cờ phân vân 🚩, tích hợp Gia sư AI Socratic RAG, ước lượng năng lực IRT 2PL `\theta_0`, phân lớp học viên, vẽ Recharts Radar Chart 5 trục và hiển thị nhận xét sư phạm từ Gemini.
  - **Tích hợp Bộ Render Toán Học KaTeX Toàn Diện (`MathText.jsx`)**: Tự động nhận diện công thức LaTeX (phân số `\frac{...}{...}`, số mũ đa thức `y = x^4 + 2x^2`, căn thức, khoảng vô cực `(-\infty; +\infty)`), render mượt mà trên cả đề thi, các phương án A/B/C/D và lời giải gia sư Socratic AI.
  - Tái cấu trúc và mở rộng toàn diện [`src/services/aiService.js`](./All%20Services/V-Eval-Web_Client/src/services/aiService.js) với hơn 14 API chuyên biệt (OCR đề thi, nạp SGK 250MB, sinh đề thi AI Bloom, phân tích IRT/BKT, và SSE Token Streaming).
- **Kiểm Thử Vận Hành & Tuân Thủ Quy Chuẩn**:
  - `dotnet build V-Eval-Gateway.sln` đạt 100% (**0 Error, 0 Warning**).
  - Khởi chạy Gateway thành công 100%, lắng nghe cổng `http://localhost:5212`.
  - `npm run build` trên Web Client thành công trong 6.24s (0 lỗi cú pháp, toàn bộ assets font KaTeX được đóng gói).
  - Cú pháp [`docker-compose.yml`](./docker-compose.yml) đạt chuẩn 100% qua lệnh `docker compose config`.
