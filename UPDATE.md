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
- **Đồng Bộ Hệ Thống Lịch Học, Điểm Danh, Học Phí Thực Tế & Toàn Bộ Cấu Trúc Toàn Dự Án**:
  - Tích hợp mô hình ERD 3 tầng (Học kỳ `AcademicTerms`, Khung lịch tuần `ClassSchedules`, Buổi học `ClassSessions`, Điểm danh `SessionAttendances`).
  - Đồng bộ tra cứu thanh toán và hóa đơn điện tử PayOS qua CSDL PostgreSQL thật, loại bỏ toàn bộ dữ liệu mock cứng.
  - Bảo vệ tệp cấu hình bí mật và hoàn thiện bộ script vận hành (`start_all.ps1`, `run_local.bat`).
- **Kiểm Thử & Nghiệm Thu**:
  - Toàn bộ 4 repository (`AI Engine`, `Web Client`, `Practice Service`, `System-Repo`) được đồng bộ và kiểm thử vận hành thành công 100%.
