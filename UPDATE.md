# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - V-EVAL CAPSTONE SYSTEM REPO

## [12/11/2026] - Khắc Phục Triệt Để Lỗi Render KaTeX Math, Chống Nuốt Văn Bản Tiếng Việt Vào Math Mode & Đồng Bộ Hot-Reload Toàn Hệ Thống

- **Khắc Phục Lỗi Render KaTeX Math & Cân Bằng Cú Pháp Giao Diện ([`MathText.jsx`](./All%20Services/V-Eval-Web_Client/src/components/common/MathText.jsx))**:
  - Loại bỏ hoàn toàn lỗi cú pháp KaTeX đỏ (`<span class="katex-error">`) trên công thức đốt cháy triglyceride: Tự động khử các ký tự `$` chưa thoát nằm bên trong chuỗi công thức LaTeX trước khi kết xuất và tự động cân bằng dấu ngoặc nhọn `{` và `}`.
  - Chấm dứt hiện tượng nuốt văn bản tiếng Việt vào chế độ toán học (math mode):
    - Gỡ bỏ regex chia tách chuỗi lỗi thời khiến các nhóm chức phân tử như `$-OH$` hay `$-COOH$` bị cắt sai thành `$-$OH$`, gây đảo lộn tính chẵn lẻ của dấu đô la trên toàn bộ đoạn văn.
    - Triển khai cơ chế tự động phục hồi ngôn ngữ tự nhiên: Các khối toán học đơn `$...$` chứa nguyên âm tiếng Việt có dấu (`àáạ...`) mà không nằm trong `\text{}` được tự động giải phóng về văn bản thuần túy.
  - Cô lập phương trình phản ứng hóa học (`\xrightarrow`, `\rightleftharpoons`, `\longrightarrow`) theo từng dòng độc lập không chứa tiếng Việt, triệt tiêu hiện tượng dính chuỗi đa dòng và lỗi thừa dấu `$$`.
  - Đóng gói SPA bằng `npm run build` (3015 modules transformed, 0 lỗi) và nạp lại cấu hình Nginx trong Docker container `v_eval_web_client` (`nginx -s reload`).

- **Chuẩn Hóa Hậu Xử Lý Chuỗi KaTeX Phía Backend ([`CurriculumAiService.cs`](./All%20Services/V-Eval-Ai_Engine/V-Eval-Ai_Engine.Infrastructure/Services/CurriculumAiService.cs))**:
  - Gỡ bỏ regex `Regex.Replace(s, @"(?<=[.,;])\$|\$(?=[.,;])", "")` - tác nhân đã xóa mất dấu đóng `$` trước dấu chấm câu trong các công thức hóa học như `$C_{17}H_{33}$.` hoặc `$-CH = CH_2.$`.
  - Thay thế bằng hàm cân bằng an toàn `EnsureBalancedDollars(s)` chỉ thêm `$` ở cuối chuỗi nếu tổng số lượng dấu `$` bị lẻ.
  - Bổ sung unit test hồi quy `NormalizeCurriculumLatex_WithChemistryFormulas_ShouldNotCorruptVietnameseOrDollarPlacement` trong `PromptTemplateServiceTests.cs`.
  - Toàn bộ **18/18 unit tests** trong AI Engine vượt qua thành công 100% trong 415 ms. Rebuild và triển khai container `v_eval_ai_engine` trên Docker.
