# NHẬT KÝ CẬP NHẬT HỆ THỐNG (SYSTEM-REPO UPDATE LOG)

## [04/11/2026] - Phân Tách Lời Chào / Hội Thoại Tự Do Khỏi Luồng Đề Bài Thi Của Gia Sư AI Socratic & Tối Ưu Hóa Số Liệu Dashboard

- **Web Client (`V-Eval-Web_Client`)**:
  - Phân tách rõ ràng giữa chế độ hỏi đề thi (`In-Exam Question Mode`) và trò chuyện tự do (`General Freeform Mode`): khi mở chat từ icon nổi, đặt `options = null`, `studentWrongOption = null`, `correctOption = null`, tránh tự ý tiêm phương án A/B giả lập.
  - Gỡ bỏ widget `AISocraticTutorWidget` cồng kềnh trên dashboard; thay bằng nút nổi Floating Action Button (FAB) góc dưới bên phải (`fixed bottom-6 right-6 z-40`), có hiệu ứng aura phát sáng và chấm xanh trực tuyến 24/7.
  - Sửa API `getMyRoadmap` gửi kèm `studentId` và header `X-User-Id` để lấy trực tiếp lộ trình học thích ứng 470 mốc từ database, loại bỏ lỗi bắt làm lại bài thi chẩn đoán 30 câu.
  - Lọc bỏ các bài thi hết hạn/bị hủy dở dang và ưu tiên điểm số thực tế từ Backend (320/1200 điểm, dải dự báo `275 - 365`), chấm dứt triệt để hiện tượng điểm bị hạ về 0 trên các thẻ chỉ số Metrics.
  - Kiểm thử: `npm test` đạt 6/6 tests pass (100%), `npm run build` thành công trong 1.08s.
- **Practice Service (`V-Eval-Practice_Service`)**:
  - Mở rộng `AskTutorRequest` cho phép `StudentWrongOption` và `CorrectOption` là nullable (`string?`), mặc định gán `null`.
  - Tự động chuẩn hóa phương án rỗng thành `"NONE"` khi gọi sang FastAPI RAG, giúp học sinh trò chuyện tự do không bị ép buộc gửi phương án trắc nghiệm.
  - Bổ sung bộ chặn lời chào tức thì trong `GenerateStreamFallback` của `AiTutorClient.cs`.
  - Kiểm thử: `dotnet test` đạt 4/4 tests pass (100%).
- **AI Engine (`V-Eval-Ai_Engine`)**:
  - Tích hợp nhận diện lời chào `is_greeting`: bỏ qua truy vấn pgvector khi học sinh chỉ chào hỏi, gán `subgraph_status = "GENERAL_CHAT"`, chấm dứt triệt để lỗi vô tình gán ghép chữ "hi" vào bài toán tam thức bậc hai và bẫy xét dấu.
  - Xây dựng prompt sư phạm linh hoạt cho hội thoại tự do khi `student_selected_option == "NONE"`: hướng dẫn học sinh đặt câu hỏi mà không quy chụp chọn sai phương án A; tự động pass LLM-as-a-Judge đối với lời chào.
  - Kiểm thử: Endpoint `/api/v1/socratic/ask` và SSE `/api/v1/socratic/ask-stream` trả về 200 OK với lời chào thân thiện, tự nhiên.
