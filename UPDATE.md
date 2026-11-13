# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - V-EVAL CAPSTONE SYSTEM REPO

## [13/11/2026] - Live Ping Mô Hình Gemini, Chuẩn Hóa KaTeX, Đồng Bộ Lộ Trình Học Tập & Hợp Nhất Nhánh Refactor Lên Develop/Main

- **Live Ping Gemini (4 API Keys)**: `gemini-3.1-flash-lite` đạt 100% 200 OK, ~808ms - 882ms; đưa lên ưu tiên số 1 trong [`appsettings.json`](./All%20Services/V-Eval-Ai_Engine/V-Eval-Ai_Engine.API/appsettings.json) và [`Configs/V-Eval-Ai_Engine/appsettings.json`](./Configs/V-Eval-Ai_Engine/appsettings.json). Bóc tách PDF thực tế: Gemini 9.09s, tổng 12.39s.
- **AI Engine ([`CurriculumAiService.cs`](./All%20Services/V-Eval-Ai_Engine/V-Eval-Ai_Engine.Infrastructure/Services/CurriculumAiService.cs))**:
  - Khử trùng lặp dạng bài cùng tên (lỗi duplicate `Dạng 4`), gộp câu hỏi độc bản, đánh số tuần tự `Dạng 1, 2, 3...`.
  - Chuẩn hóa KaTeX: khôi phục `textmol`/`textgam` -> `\text{mol}`/`\text{gam}`, mở rộng `\implies`, bất đẳng thức, bọc biến đơn trước đơn vị, chuẩn hóa chỉ số dưới tiếng Việt.
  - `fullEqPattern` hỗ trợ số mũ (`2^2`, `3^{2}`) và ngoặc đơn (`\times (3 \times 40 - 92)`), không còn tách `2^$2`; ngoặc không cân bằng/bao trọn biểu thức được đưa ra ngoài `$...$`.
  - Không còn can thiệp vào bên trong cặp `$...$` đã có; bước giải phóng văn bản tiếng Việt bỏ qua nội dung `_{...}` / `^{...}` nên `m_{chất béo}` không còn bị gỡ `$`.
  - Tổng **49/49 unit tests C# pass**.
- **Web Client ([`MathText.jsx`](./All%20Services/V-Eval-Web_Client/src/components/common/MathText.jsx), [`App.jsx`](./All%20Services/V-Eval-Web_Client/src/App.jsx), [`StudentCurriculumView.jsx`](./All%20Services/V-Eval-Web_Client/src/components/curriculum/StudentCurriculumView.jsx))**:
  - Đồng bộ bộ chuẩn hóa KaTeX, thay `'$$$1$$'` bằng callback an toàn; chỉ dò từ tiếng Việt bên ngoài `\text{}`/`_{}`/`^{}` để không gỡ `$` nhầm của công thức hợp lệ.
  - Tái cấu trúc bố cục trang Tổng quan (`HeroBanner` đầu trang, `MetricsGrid` 4 KPI, `DiagnosticOnboardingCard` + `StudentParentLinkCard`), nâng cấp ảnh học sinh THPT Việt Nam thực tế.
  - Phân tách 2 chế độ Lộ trình học tập (*🏫 Lớp Học Chung* và *🎯 Lộ Trình Cá Nhân Riêng*) & ràng buộc học phí qua PayOS VietQR (`TuitionRequiredModal.jsx`).
- **Practice Service & Web Client - Khắc phục lỗi Crash 500 nạp lịch sử làm bài thi chẩn đoán ([`ContentGrpcClient.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Infrastructure/GrpcClients/ContentGrpcClient.cs), [`DiagnosticAssessmentPage.jsx`](./All%20Services/V-Eval-Web_Client/src/components/diagnostic/DiagnosticAssessmentPage.jsx))**:
  - Bắt ngoại lệ `RpcException(StatusCode.NotFound)` trả về fallback rỗng an toàn; mở rộng `DiagnosticSubmissionSummaryDto` bổ sung `Theta0` và `PlacementClass`.
- **Đồng Bộ Cấu Hình Về [`Configs`](./Configs), Khắc Phục Routing `v-eval-ai-rag` & Chuẩn Hóa `.gitignore`**:
  - Đổi `AiSettings__ServiceUrl=http://v-eval-ai-rag:8000` cho `v-eval-practice-service` trong [`docker-compose.yml`](./docker-compose.yml); bổ sung các route `/api/socratic/{**catch-all}`, `/api/v1/socratic/{**catch-all}`, `/api/v1/academic-graph/{**catch-all}` vào `ai-rag-cluster` trên Gateway.
  - Chặn riêng `Configs/V-Eval-Ai_Engine/appsettings.json`, `Configs/V-Eval-Ai_Engine/rag-service/.env`, root `.env` trong `.gitignore` của `System-Repo` và `**/appsettings.json`, `**/.env` trong `.gitignore` của `V-Eval-Ai_Engine`.
