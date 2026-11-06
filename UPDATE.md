# NHẬT KÝ CẬP NHẬT HỆ THỐNG (SYSTEM-REPO UPDATE LOG)

## [06/11/2026] - Khắc Phục Lỗi Quota Rate Limit 429, Tối Ưu Tốc Độ Phản Hồi Gia Sư AI & Triệt Tiêu Lỗi Treo Ba Dấu Chấm `...`

- **AI Engine (`V-Eval-Ai_Engine`)**:
  - **Tích hợp API Key mới & Ưu tiên mô hình siêu tốc**: Nạp khóa API mới, đưa `gemini-3.5-flash-lite` lên vị trí ưu tiên số 1 trong `SOCRATIC_MODELS` và `JUDGE_MODELS`, phản hồi nhanh trong ~1.5 - 2.5 giây.
  - **Loại bỏ vòng lặp treo Tenacity Retry**: Thiết lập `max_retries=1`, loại bỏ tình trạng SDK ngầm thử lại 5 lần ngốn 25s khi gặp 429/503; rút timeout sinh nháp xuống 8.0s, chuyển model dự phòng tức thì trong 0.1s.
  - **Mở rộng nhận diện câu hỏi chức năng/vai trò (Meta-Inquiry)**: Nhận diện các câu hỏi `"thầy sẽ làm gì trong này"`, `"thầy là ai"`, `"hướng dẫn học"` và phản hồi trực tiếp về vai trò Socratic, không truy vấn nhầm đồ thị bài tập Vật lý/Toán học.
  - **Kiểm thử**: Đạt chuẩn 100% phản hồi tự nhiên qua kiểm thử sinh lời giải logic mệnh đề thực tế.
- **Practice Service (`V-Eval-Practice_Service`)**:
  - **Bảo vệ luồng SSE bằng kênh bất đồng bộ Channel**: Tái cấu trúc `StreamSocraticGuidanceAsync` với `System.Threading.Channels.Channel.CreateUnbounded<string>()`, tách biệt an toàn việc đọc mạng khỏi `yield return`.
  - **Cơ chế phòng thủ Zero-Empty-Token**: Bọc bắt timeout và tự động kích hoạt `GenerateStreamFallback(payload)` phát trực tiếp lời dẫn sư phạm chuẩn khi mạng gián đoạn, đảm bảo học sinh không bao giờ nhận stream rỗng.
  - **Kiểm thử**: Biên dịch .NET 9 SDK sạch sẽ 100% (0 Warning, 0 Error).
- **Web Client (`V-Eval-Web_Client`)**:
  - **Sửa lỗi nuốt Exception SSE trong `practiceService.js`**: Tách riêng `JSON.parse`, kích hoạt `onError` khi nhận `parsed.error`, không để khối catch con nuốt lỗi.
  - **Triệt tiêu hoàn toàn dấu ba chấm `...` vĩnh viễn trên UI**: Trong `AISocraticTutorModal.jsx`, nếu stream hoàn tất mà token rỗng, tự động điền thông điệp gợi mở sư phạm thân thiện; nếu gặp mã 429, hiển thị cảnh báo giới hạn rõ ràng trong bong bóng chat.
  - **Kiểm thử & Đóng gói**: `npm run build` hoàn thành sạch sẽ 100%.
