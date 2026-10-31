# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [31/10/2026] - Khắc Phục Tương Phản Hiển Thị Gia Sư AI Socratic, Chuẩn Hóa JSON `snake_case` `AiTutorClient` & Phân Tích Socratic Bám Sát Đề Bài

- **Web Client (`All Services/V-Eval-Web_Client`)**:
  - **Khắc phục triệt để lỗi chữ tối trên nền tối (`MathText.jsx`)**: Gỡ bỏ màu chữ tối cố định (`text-slate-700/800/900`) trên bullet list, đoạn văn, `<strong>` và `<em>` để nội dung phản hồi của Gia sư AI Socratic hiển thị chữ trắng sắc nét (`text-white`) trên nền tối; sửa lỗi cắt dấu `**` gây hiển thị `Gợi ý phương pháp giải:**`.
  - **Phân tích Socratic theo đúng ngữ cảnh câu hỏi (`DiagnosticAssessmentPage.jsx`, `practiceService.js`)**: Tự động phân tích phương án học sinh chọn sai, đáp án đúng và định lý/đạo hàm của câu hỏi; chỉ mở tính năng hỏi Gia sư AI ở màn hình xem lại đáp án sau khi nộp bài.
- **Practice Service (`All Services/V-Eval-Practice_Service`)**:
  - **Chuẩn hóa `JsonNamingPolicy.SnakeCaseLower` (`AiTutorClient.cs`)**: Đồng bộ định dạng JSON `snake_case` khi gọi sang Python FastAPI RAG (`:8000/api/v1/socratic/ask-stream`), khắc phục lỗi `422 Unprocessable Entity` và nâng cấp nội dung fallback giàu ngữ cảnh.
- **Kiểm Thử & Xác Thực (Verification)**:
  - `V-Eval-Web_Client`: `npm test` (3/3 pass) & `npm run build` thành công 100%.
  - `V-Eval-Practice_Service`: `dotnet test` (4/4 pass) thành công 100%.
