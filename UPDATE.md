# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - V-EVAL CAPSTONE SYSTEM REPO

## [16/11/2026] - Kiến Trúc Dynamic Federated Curriculum Retrieval (Zero-Hardcode), Tích Hợp Bộ Nhớ Hội Thoại Đa Lượt & Khắc Phục Triệt Để Gán Nhầm Anchor Socratic

- **Kiến Trúc Dynamic Federated Curriculum Retrieval (Zero-Hardcode) Cho Gia Sư Socratic**:
  - **Khắc phục triệt để lỗi gán nhầm anchor ([`hybrid_retriever.py`](./All%20Services/V-Eval-Ai_Engine/rag-service/graph/hybrid_retriever.py))**:
    - Xóa bỏ bộ từ khóa tĩnh `keywords_map` và vòng lặp so khớp từ đơn (`for w in name.split(): if len(w) >= 3 ...`), vốn gây ra hiện tượng từ nối tiếng Việt như *"của"* trong đề bài Hình học không gian bị gán nhầm vào *"Tính đơn điệu của hàm số đa thức và phân thức"* với điểm tương đồng ảo 0.85.
    - Triển khai phương thức `_fetch_material_from_content`: Khi học sinh hỏi về một câu hỏi thi, hệ thống thực hiện truy vấn quan hệ JOIN trực tiếp giữa `v_eval_content."Questions"` và `v_eval_content."Materials"` qua khóa ngoại `skill_id`.
    - Tự động nạp toàn bộ bài học SGK chuẩn GDPT 2018 (định lý bản lề, phương pháp giải, ví dụ minh họa) và lời giải vàng (`golden_solution`) vào Socratic Subgraph với độ tin cậy 0.98 và phạm vi `CURRICULUM_MATERIAL`.
    - Với các câu hỏi mở ngoài chương trình hoặc câu hỏi mới chưa có bài giảng, hệ thống fail-closed an toàn về `STATUS_LOW_CONFIDENCE` (nếu vector cosine $< 0.75$), tuyệt đối không bịa đặt hoặc gán ép sang chủ đề không liên quan.
  - **Triệt tiêu 100% Hardcode trong Bộ Fallback Sư Phạm ([`socratic_engine.py`](./All%20Services/V-Eval-Ai_Engine/rag-service/socratic/socratic_engine.py))**:
    - Xóa bỏ toàn bộ các nhánh `if/elif` hardcode từng chủ đề ($P \Rightarrow Q$, cấp số cộng, logarit, chính tả).
    - Bộ tạo phản hồi an toàn (`build_fallback_guidance`) tự động bám sát định lý SGK đã truy xuất hoặc đưa ra câu hỏi gợi mở sư phạm trung lập, phản chiếu điều kiện giả thiết và áp dụng chuẩn xác cho mọi môn học.
  - **Đồng bộ Forward `question_id` & `skill_id` Qua Các Tầng**:
    - **Backend ([`socratic_tutor.py`](./All%20Services/V-Eval-Ai_Engine/rag-service/routers/socratic_tutor.py))**: `_resolve_dual_track` forward `question_id` sang `retriever.retrieve`.
    - **Web Client ([`AISocraticTutorModal.jsx`](./All%20Services/V-Eval-Web_Client/src/components/modals/AISocraticTutorModal.jsx), [`AdaptiveQuizModal.jsx`](./All%20Services/V-Eval-Web_Client/src/components/modals/AdaptiveQuizModal.jsx))**: Lưu trữ `skillId` vào phiên chat và forward `skillId` trong payload stream SSE `practiceService.askAiTutorStream`.
- **Đồng Bộ Bộ Nhớ Hội Thoại Đa Lượt (Multi-Turn Context) & Khắc Phục Lỗi Gán Nhầm Lời Chào**:
  - **Web Client ([`AISocraticTutorModal.jsx`](./All%20Services/V-Eval-Web_Client/src/components/modals/AISocraticTutorModal.jsx), [`practiceService.js`](./All%20Services/V-Eval-Web_Client/src/services/practiceService.js))**: Trích xuất tối đa 6 lượt trò chuyện gần nhất của học sinh và gia sư AI gửi kèm payload stream SSE qua `practiceService.askAiTutorStream`.
  - **Practice Service ([`IAiTutorClient.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Application/Common/Interfaces/IAiTutorClient.cs), [`AiTutorController.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.API/Controllers/AiTutorController.cs))**: Tiếp nhận `conversation_history` và forward sang AI Engine trên cả 2 endpoint stream và JSON.
  - **AI Engine ([`socratic_tutor.py`](./All%20Services/V-Eval-Ai_Engine/rag-service/routers/socratic_tutor.py), [`socratic_engine.py`](./All%20Services/V-Eval-Ai_Engine/rag-service/socratic/socratic_engine.py), [`intent_router.py`](./All%20Services/V-Eval-Ai_Engine/rag-service/socratic/intent_router.py))**:
    - Tiếp nhận `conversation_history` và định dạng thành khối ngữ cảnh `[LỊCH SỬ TRAO ĐỔI VỪA RỒI CỦA 2 THẦY TRÒ]`, bơm trực tiếp vào prompt sinh nháp.
    - Mở rộng `_TASK_MARKERS` và bảo vệ trong heuristic router: không bao giờ phân loại nhầm câu hỏi nối tiếp của học sinh ("ví dụ", "minh họa", "làm sao", "giải thích") sang Case C1 (Chit-chat / Lời chào xã giao) khi đang trong phiên bài tập.
    - Nâng hạn mức timeout sinh nháp LLM từ 8.0s lên 18.0s.
- **Chuẩn Hóa Kiến Trúc Xóa Phiên & Phân Tách Rạch Ròi Audit Log ([`AISocraticTutorModal.jsx`](./All%20Services/V-Eval-Web_Client/src/components/modals/AISocraticTutorModal.jsx), [`aiSessionManager.js`](./All%20Services/V-Eval-Web_Client/src/utils/aiSessionManager.js), [`aiSessionManager.test.js`](./All%20Services/V-Eval-Web_Client/tests/aiSessionManager.test.js))**:
  - Phân định rõ ràng giữa **Audit Log kiểm toán bất biến** của nhà trường (`v_eval_ai.ai_tutor_interaction_logs` dành cho Mentor/Quản lý học thuật ở Core Flow 4) và **User Chat Sessions** dành cho học sinh. Tuyệt đối không xóa thô (hard-delete) dữ liệu kiểm toán hệ thống.
  - Ngắt hoàn toàn việc gọi nhầm API kiểm duyệt Mentor trong modal học sinh.
  - Khắc phục lỗi React State Closure khi xóa phiên bằng functional state updater nguyên tử `setSessions(prev => ...)`.
  - Triển khai cơ chế Tombstones vĩnh viễn (`markSessionDeleted`, `isSessionDeleted`) ngăn chặn 100% hiện tượng hồi sinh phiên đã xóa.
- **Khắc Phục Lỗi Lặp Từ Kép Khi AI Stream Phản Hồi ([`AISocraticTutorModal.jsx`](./All%20Services/V-Eval-Web_Client/src/components/modals/AISocraticTutorModal.jsx), [`AISocraticTutorWidget.jsx`](./All%20Services/V-Eval-Web_Client/src/components/dashboard/AISocraticTutorWidget.jsx))**:
  - Tách biệt nguồn dữ liệu tích lũy SSE bằng `useRef` (`streamedTextRef`), xóa bỏ biến đổi state in-place, giúp giao diện miễn nhiễm 100% trước cơ chế chạy lặp 2 lần của React StrictMode.
  - Loại bỏ 200+ lần gọi `saveSessions` dư thừa mỗi turn; chỉ lưu phiên 1 lần khi kết thúc stream (`onComplete`).
  - Tự động chữa lành các phiên cũ bị lặp từ trong `localStorage` bằng hàm `cleanDoubledWords`.
- **Kiểm Thử & Nghiệm Thu Toàn Diện**:
  - AI Engine: `pytest tests/test_hybrid_retriever.py tests/test_socratic_engine.py tests/test_socratic_mentor.py` đạt **26/26 tests pass 100%**. Kiểm thử trực tiếp câu hỏi Hình học Không gian giao tuyến `SO` (`4e59df20-e11b-4d14-ab8f-0ac4cb734d0b`): Trích xuất chính xác 100% bài học `Dạng 2: Xác định giao tuyến của hai mặt phẳng phân biệt cắt nhau` và `core_theorems` SGK tương ứng.
  - Practice Service: `dotnet build` đạt **0 Warning, 0 Error**.
  - Web Client: `npm run build` thành công trong 1.06s, `node --test` đạt **22/22 unit tests pass 100%**.
