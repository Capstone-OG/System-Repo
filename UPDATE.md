# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - V-EVAL CAPSTONE SYSTEM REPO

## [16/11/2026] - Đồng Bộ Bộ Nhớ Hội Thoại Đa Lượt (Multi-Turn Context) Cho Gia Sư Socratic & Khắc Phục Triệt Để Hiện Tượng Lặp Từ Kép, Chuẩn Hóa Xóa Phiên (Tombstones)

- **Đồng Bộ Bộ Nhớ Hội Thoại Đa Lượt (Multi-Turn Context) Trên Cả 3 Phân Hệ**:
  - **Web Client ([`AISocraticTutorModal.jsx`](./All%20Services/V-Eval-Web_Client/src/components/modals/AISocraticTutorModal.jsx), [`practiceService.js`](./All%20Services/V-Eval-Web_Client/src/services/practiceService.js))**: Trích xuất tối đa 6 lượt trò chuyện gần nhất của học sinh và gia sư AI gửi kèm payload stream SSE qua `practiceService.askAiTutorStream`.
  - **Practice Service ([`IAiTutorClient.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Application/Common/Interfaces/IAiTutorClient.cs), [`AiTutorController.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.API/Controllers/AiTutorController.cs))**: Mở rộng DTO `ConversationTurnDto` và hợp đồng `SocraticAskRequestPayload`, tiếp nhận `ConversationHistory` trong `AskTutorRequest` và forward liền mạch sang AI Engine trên cả 2 endpoint stream và JSON.
  - **AI Engine ([`socratic_tutor.py`](./All%20Services/V-Eval-Ai_Engine/rag-service/routers/socratic_tutor.py), [`socratic_engine.py`](./All%20Services/V-Eval-Ai_Engine/rag-service/socratic/socratic_engine.py), [`intent_router.py`](./All%20Services/V-Eval-Ai_Engine/rag-service/socratic/intent_router.py))**:
    - Tiếp nhận `conversation_history` và định dạng thành khối ngữ cảnh `[LỊCH SỬ TRAO ĐỔI VỪA RỒI CỦA 2 THẦY TRÒ]`, bơm trực tiếp vào prompt của học sinh.
    - Mở rộng `_TASK_MARKERS` và bảo vệ trong heuristic router: không bao giờ phân loại nhầm câu hỏi nối tiếp của học sinh ("ví dụ", "minh họa", "làm sao", "giải thích") sang Case C1 (Chit-chat / Lời chào xã giao) khi đang trong phiên bài tập.
    - Nâng hạn mức timeout sinh nháp LLM từ 8.0s lên 18.0s nhằm khắc phục lỗi timeout mạng giả và hạn chế rơi vào Resilient Fallback.
- **Chuẩn Hóa Kiến Trúc Xóa Phiên & Phân Tách Rạch Ròi Audit Log ([`AISocraticTutorModal.jsx`](./All%20Services/V-Eval-Web_Client/src/components/modals/AISocraticTutorModal.jsx), [`aiSessionManager.js`](./All%20Services/V-Eval-Web_Client/src/utils/aiSessionManager.js), [`aiSessionManager.test.js`](./All%20Services/V-Eval-Web_Client/tests/aiSessionManager.test.js))**:
  - Phân định rõ ràng giữa **Audit Log kiểm toán bất biến** của nhà trường (`v_eval_ai.ai_tutor_interaction_logs` dành cho Mentor/Quản lý học thuật ở Core Flow 4) và **User Chat Sessions** dành cho học sinh. Tuyệt đối không xóa thô (hard-delete) dữ liệu kiểm toán hệ thống.
  - Ngắt hoàn toàn việc gọi nhầm API kiểm duyệt Mentor trong modal học sinh.
  - Khắc phục lỗi React State Closure khi xóa phiên bằng functional state updater nguyên tử `setSessions(prev => ...)`.
  - Triển khai cơ chế Tombstones vĩnh viễn (`markSessionDeleted`, `isSessionDeleted`) ngăn chặn 100% hiện tượng hồi sinh phiên đã xóa.
- **Khắc Phục Lỗi Lặp Từ Kép Khi AI Stream Phản Hồi ([`AISocraticTutorModal.jsx`](./All%20Services/V-Eval-Web_Client/src/components/modals/AISocraticTutorModal.jsx), [`AISocraticTutorWidget.jsx`](./All%20Services/V-Eval-Web_Client/src/components/dashboard/AISocraticTutorWidget.jsx))**:
  - Tách biệt nguồn dữ liệu tích lũy SSE bằng `useRef` (`streamedTextRef`), xóa bỏ biến đổi state in-place, giúp giao diện miễn nhiễm 100% trước cơ chế chạy lặp 2 lần của React StrictMode.
  - Loại bỏ 200+ lần gọi `saveSessions` dư thừa mỗi turn; chỉ lưu phiên 1 lần khi kết thúc stream (`onComplete`).
  - Tự động chữa lành các phiên cũ bị lặp từ trong `localStorage` bằng hàm `cleanDoubledWords`.
- **Kiểm Thử & Nghiệm Thu**:
  - AI Engine: `pytest tests -k "socratic"` đạt **18/18 tests pass 100%**.
  - Practice Service: `dotnet build` đạt **0 Warning, 0 Error**.
  - Web Client: `npm run build` thành công trong 1.15s, `node --test` đạt **22/22 unit tests pass 100%**.
