# UPDATE LOG — V-Eval System-Repo

## [24/11/2026] Hoàn thiện trọn bộ 10 hạng mục Feedback UI/UX (MUI), CSDL khóa câu hỏi lỗi, Studio trực tiếp & MathLive WYSIWYG
- **Frontend (`V-Eval-Web_Client`)**:
  - Triển khai MUI (`@mui/material`), làm sạch thuật ngữ kỹ thuật, đồng bộ Kết quả & Lịch sử Chẩn đoán (`DiagnosticSkillOverviewCard`), mở khóa `Đã nắm vững`, lưu/khôi phục trạng thái Preview theo DB & giữ nguyên trang hiện tại khi F5 (`sessionStorage`).
  - Sổ tay lỗi sai ôn theo dạng, Lịch sử & Phòng thi thử chia cụm 7 câu (`AttemptAnswerReviewList`), Camera giám sát chụp ảnh định kỳ (`upload-snapshot`), Sổ tay Gia sư AI dạng Drawer kéo-thả, và 3 cổng Non-Blocking Roadmap Approval.
  - Tinh giản Sidebar (icon trơn không nền khi thu gọn, ẩn icon khi mở rộng), bỏ nền màu icon Navbar & bỏ thanh footer toàn trang; tinh giản Khung chương trình (full-view không cuộn lồng, bo góc `10px`, bỏ nhãn Bloom, mở sẵn Lý thuyết trọng tâm).
  - Vào thẳng Full Studio (`CurriculumStudioEditor`) từ `ExamStudioView` & `FlaggedQuestionsReviewPanel`, tự động thu gọn sidebar khi mở Studio, và tích hợp **MathLive (`VisualMathField`)** sửa công thức trực quan WYSIWYG với thanh công thức cố định không che chữ, bảng màu bàn phím đồng bộ V-Eval và nút đóng nổi (`vite build` pass 100%).
- **Backend (`V-Eval-Practice_Service`, `V-Eval-Content_Service`, `V-Eval-Gateway`, `V-Eval-Ai_Engine`)**:
  - `V-Eval-Practice_Service`: Fix GUID thô ở Suy diễn DAG, enrich chi tiết đáp án Thi thử, thêm cột `preview_submission_json` & 4 trường phê duyệt lộ trình + EF Migration `AddRoadmapTeacherApprovalFields` + auto `ALTER TABLE IF NOT EXISTS`, API `PUT /api/v1/roadmaps/{roadmapId}/approve`.
  - `V-Eval-Content_Service`: Chặn phát câu hỏi thiếu/lỗi đáp án (`HasBrokenOrMissingOptions`), thêm cột `is_flagged`/`flag_reason`/`flagged_at` + API `/api/content/questions/flagged`, `/flag`, `/unflag` và lọc `!q.IsFlagged` khi phát đề; bổ sung đầy đủ dữ liệu học liệu Ngữ văn 10 Ch.5 Bài 2 trên Supabase DB.
  - `V-Eval-Gateway` & `V-Eval-Ai_Engine`: Bổ sung YARP route `/api/v1/roadmaps/{**catch-all}` và chuẩn hóa nhận xét AI thân thiện.
