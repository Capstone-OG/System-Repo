# Nhật Ký Cập Nhật (Update Log) - System Repo

## [02/10/2026] - Hoàn Thiện Khảo Sát 30 Câu: Tích Hợp Đề Content Service & AI Cloud, Bảng Đáp Án Chi Tiết, Phân Tích Tốc Độ Pacing & Render KaTeX

- **Nâng Cấp Web Client (`V-Eval-Web_Client`)**:
  - **Hỗ Trợ 3 Nguồn Đề Thi Khảo Sát**: Tích hợp lấy trực tiếp từ Database Content Service (`/api/v1/content/exams/...`), sinh đề Live AI Cloud bằng Google Gemini, hoặc lấy từ AI Calibrated Bank (&lt;500ms).
  - **Bảng Tra Cứu & Đáp Án Chi Tiết 30 Câu**: Cho phép thí sinh đối chiếu từng câu hỏi (phương án chọn vs đáp án đúng), xem lời giải chi tiết KaTeX, và lọc theo câu đúng/sai/phân vân.
  - **Phân Tích Tốc Độ & Chiến Thuật Pacing**: Đo lường thời gian trung bình từng câu, phân loại nhóm làm nhanh (&lt;25s), chuẩn nhịp độ (25-90s), tốn nhiều thời gian (&gt;90s) và câu phân vân gắn cờ 🚩.
  - **Biểu Đồ Năng Lực Chuẩn Xác & Không Bịa**: Dữ liệu Recharts Radar Chart 5 trục và năng lực IRT 2PL `\theta_0` phản ánh chính xác kết quả 30 câu làm bài thực tế của thí sinh.
  - **Tích Hợp Bộ Render Toán Học KaTeX**: Xử lý toàn diện các công thức toán học phân số, căn thức, số mũ đa thức, khoảng vô cực cho câu hỏi, đáp án, gia sư AI Socratic và bảng giải thích.
- **Cấu hình & Sửa Lỗi API Gateway YARP (`V-Eval-Gateway`)**:
  - Khắc phục lỗi thiếu dịch vụ `IAuthenticationSchemeProvider`: Bổ sung package `Microsoft.AspNetCore.Authentication.JwtBearer` và đăng ký `services.AddAuthentication(...).AddJwtBearer(...)`.
  - Mở rộng định tuyến tới cả 2 thành phần AI Engine: `.NET Core AI Engine` (Port `:5104`) và `Python FastAPI RAG Service` (Port `:8000`).
- **Kiểm Thử Vận Hành & Tuân Thủ Quy Chuẩn**:
  - `dotnet build V-Eval-Gateway.sln` đạt 100% (**0 Error, 0 Warning**).
  - `npm run build` trên Web Client thành công trong 1.26s (0 lỗi cú pháp, toàn bộ assets font KaTeX được đóng gói).
  - Cú pháp [`docker-compose.yml`](./docker-compose.yml) đạt chuẩn 100% qua lệnh `docker compose config`.
