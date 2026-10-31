# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [31/10/2026] - Triển Khai Phân Hệ Lịch Sử Làm Bài & Sổ Tay Lỗi Sai Socratic (`SubmissionHistoryView`), Chuẩn Hóa Xem Lại Đáp Án & Hỏi Gia Sư AI

- **Web Client (`All Services/V-Eval-Web_Client`)**:
  - **Triển khai phân hệ Lịch sử làm bài & Sổ tay lỗi sai (`SubmissionHistoryView.jsx`, `Sidebar.jsx`, `App.jsx`)**: Lưu trữ và đồng bộ danh sách các bài khảo sát ĐGNL 30 câu, phiếu luyện tập thích ứng ZPD và bài kiểm tra chuyên đề đã hoàn thành; cho phép học sinh bấm vào bất kỳ bài thi cũ nào để xem lại bảng đáp án chi tiết, lọc sổ tay câu sai và bấm hỏi Gia sư AI Socratic cho từng câu.
  - **Tự động lưu lịch sử ở cả 3 luồng làm bài (`practiceService.js`, `DiagnosticAssessmentPage.jsx`, `AdaptiveQuizModal.jsx`, `CurriculumExplorerView.jsx`)**: Đấu nối API lịch sử bài làm của Practice Service kết hợp lưu trữ đồng bộ, hiển thị danh sách lịch sử làm bài ngay tại trang Khảo thí và Sidebar.
  - **Khắc phục triệt để lỗi chữ tối trên nền tối (`MathText.jsx`)**: Gỡ bỏ màu chữ tối cố định (`text-slate-700/800/900`) để nội dung phản hồi của Gia sư AI Socratic hiển thị chữ trắng sắc nét (`text-white`) trên nền tối.
- **Practice Service (`All Services/V-Eval-Practice_Service`)**:
  - **Chuẩn hóa `JsonNamingPolicy.SnakeCaseLower` (`AiTutorClient.cs`)**: Đồng bộ định dạng JSON `snake_case` khi gọi sang Python FastAPI RAG (`:8000/api/v1/socratic/ask-stream`).
- **Kiểm Thử & Xác Thực (Verification)**:
  - `V-Eval-Web_Client`: `npm test` (3/3 pass) & `npm run build` thành công 100%.
  - `V-Eval-Practice_Service`: `dotnet test` (4/4 pass) thành công 100%.
