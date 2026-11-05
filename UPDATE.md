# NHẬT KÝ CẬP NHẬT HỆ THỐNG (SYSTEM-REPO UPDATE LOG)

## [05/11/2026] - Khắc Phục Triệt Để Phản Hồi Rập Khuôn, Ưu Tiên Gemini-3.6-Flash, Xóa Bỏ Banner Bắt Thi Lại & Tối Giản Icon AI Dashboard

- **AI Engine (`V-Eval-Ai_Engine`)**:
  - **Khắc phục phản hồi rập khuôn & văn mẫu**: Chuyển đổi mô hình ưu tiên số 1 sang `gemini-3.6-flash` (thay cho `gemini-flash-lite-latest` đang chịu tải cao 503 từ Google AI); nâng ngưỡng timeout sinh bản thảo lên 25.0s kèm cơ chế đa mô hình dự phòng.
  - **Phân định rõ ngữ cảnh hội thoại vs bài tập**: Lời chào hỏi (`"hi"`, `"hi gia sư"`, `"chào gia sư"`, `"thầy ơi"`) được AI phản hồi bằng văn phong Socratic truyền cảm hứng tự nhiên 100% thay vì in nhầm công thức tam thức bậc hai hay bất phương trình.
  - **Tối ưu tốc độ thẩm định**: Rút ngắn lượt kiểm tra thẩm định nhanh (timeout 3.0s) và chuyển tiếp ngay sang `_fast_heuristic_guard` khi Google API gặp đợt nghẽn tải, giảm tổng thời gian phản hồi từ >35s xuống ~4-6s, loại bỏ triệt để tình trạng treo `...` vô tận.
  - **Kiểm thử**: Vượt qua 100% kiểm thử pytest (12/12 test cases).
- **Practice Service (`V-Eval-Practice_Service`)**:
  - **Linh hoạt hóa API & Khắc phục lỗi 400 Bad Request**: Cho phép các trường `QuestionId`, `QuestionLatex`, `StudentWrongOption`, `CorrectOption` trong `AskTutorRequest` nhận giá trị nullable; tự động fallback sang `StudentQuery` và sinh UUID mới khi học sinh gửi câu hỏi tự do hoặc lời chào.
  - **Nhận diện lời chào hội thoại**: `AiTutorClient.cs` nhận diện đầy đủ các cụm từ xưng hô tiếng Việt tự nhiên (`"hi gia sư"`, `"chào gia sư"`, `"thầy ơi"`, tiền tố `"hi "`, `"chào "`), đảm bảo phản hồi dự phòng luôn là lời chào sư phạm truyền cảm hứng.
  - **Khởi tạo lộ trình DAG thích ứng**: Tạo thành công lộ trình học tập 470 chuyên đề từ bài khảo sát chẩn đoán đầu vào qua `POST /api/practice/roadmaps/generate`.
  - **Kiểm thử**: .NET 9 SDK biên dịch sạch sẽ (0 Warning, 0 Error), 12/12 unit tests xUnit đạt 100% Passed.
- **Web Client (`V-Eval-Web_Client`)**:
  - **Xóa bỏ triệt để banner bắt thi lại chẩn đoán**: Cải tiến `checkExamHistory` trong `MilestoneCard.jsx`, tách riêng điều kiện `!studentDashboard.needsOnboarding` và tự động kích hoạt `autoGenRoadmap` từ bài khảo sát đầu vào. Học sinh đã thi sẽ không bao giờ bị hiển thị banner bắt thi lại, mở khóa trực tiếp Chặng 01 và danh sách nhiệm vụ ôn luyện.
  - **Tối giản giao diện Dashboard**: Loại bỏ khối widget AI chat cồng kềnh trong lưới nội dung; thay bằng Floating Action Button (FAB) nhỏ gọn, hiện đại ở góc phải phía dưới màn hình với huy hiệu online màu xanh và hiệu ứng viền phát sáng.
  - **Chống treo ba dấu chấm & Xử lý stream**: Đảm bảo giải phóng `isTyping = false` và hủy controller trong callback `onError` của `AISocraticTutorModal.jsx`.
  - **Kiểm thử & Đóng gói**: `npm run build` hoàn thành sạch sẽ trong 905ms (0 syntax error).
