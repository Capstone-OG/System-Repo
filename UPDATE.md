# NHẬT KÝ CẬP NHẬT HỆ THỐNG (SYSTEM-REPO UPDATE LOG)

## [06/11/2026] - Triển Khai Kiến Trúc 2 Luồng Phân Tách (Decoupled Dual-Track Architecture) & Ma Trận 5 Intent Cho Gia Sư Socratic

- **AI Engine (`V-Eval-Ai_Engine`)**:
  - **Triển khai kiến trúc 2 luồng phân tách (Decoupled Dual-Track Architecture)**:
    - *Track 1 (Task Grounding)*: Chỉ embed `question_latex + options` vào Knowledge Graph pgvector, triệt tiêu hoàn toàn ô nhiễm vector (Semantic Contamination) từ lời chat học sinh.
    - *Track 2 (Dynamic Intent & Tone Router)*: Module `socratic/intent_router.py` bóc tách `student_query` thành Ma trận 5 tình huống (C1: Persona/Chit-chat, C2: Thái độ + Bài toán, C3: Nghi ngờ tính hợp lệ đề bài, C4: Thắc mắc chuyên môn trong KG, C5: Đề bài ngoài hệ thống) kèm nhận diện tâm trạng (`NEUTRAL`, `SKEPTICAL`, `FRUSTRATED`, `CURIOUS`).
    - *Song song hóa*: Kích hoạt đồng thời Track 1 và Track 2 qua `asyncio.gather`. Bỏ qua vector search khi học sinh chào hỏi C1 (0ms KG latency).
  - **Hệ thống Prompt Modular 2 khối**: Khối 1 Persona Core (người thầy ấm áp, khiêm tốn, sắc sảo, không máy móc, cấm giải thay, cấm lộ đáp án) + Khối 2 Dynamic Case Injection (tiêm chỉ thị sư phạm theo mã Case C1–C5).
  - **Hội đồng Thẩm định Thích ứng (Adaptive LLM-as-a-Judge)**: Tiêu chí thẩm định linh hoạt theo Category (`validator_judge.py`), không đánh trượt oan lời chào xã giao C1.
  - **SSE Status Hydration**: Phát sự kiện `event: status` và `intent_category` trong `event: metadata` cho giao diện người dùng.
  - **Khắc phục lỗi Quota 429 & Tối ưu tốc độ**: Nạp API key mới, cấu hình `max_retries=1` loại bỏ treo 25s Tenacity retry, ưu tiên `gemini-3.5-flash-lite` phản hồi nhanh trong ~1.5 - 2.5s.
  - **Kiểm thử**: 50/50 unit tests `pytest` đạt 100%.
- **Practice Service (`V-Eval-Practice_Service`)**:
  - **Bảo vệ luồng SSE bằng kênh bất đồng bộ Channel**: Tái cấu trúc `StreamSocraticGuidanceAsync` với `System.Threading.Channels.Channel.CreateUnbounded<string>()`, tách biệt an toàn việc đọc mạng khỏi `yield return`.
  - **Cơ chế phòng thủ Zero-Empty-Token**: Tự động phát sinh fallback sư phạm chuẩn khi mạng gián đoạn, đảm bảo học sinh không bao giờ nhận stream rỗng.
  - **Kiểm thử**: Biên dịch .NET 9 SDK sạch sẽ 100% (0 Warning, 0 Error).
- **Web Client (`V-Eval-Web_Client`)**:
  - **Sửa lỗi nuốt Exception SSE trong `practiceService.js`**: Tách riêng `JSON.parse`, kích hoạt `onError` khi nhận `parsed.error`.
  - **Triệt tiêu hoàn toàn dấu ba chấm `...` vĩnh viễn trên UI**: Trong `AISocraticTutorModal.jsx`, nếu stream hoàn tất mà token rỗng, tự động điền thông điệp gợi mở sư phạm thân thiện; nếu gặp mã 429, hiển thị cảnh báo giới hạn rõ ràng trong bong bóng chat.
  - **Kiểm thử & Đóng gói**: `npm run build` hoàn thành sạch sẽ 100%.
