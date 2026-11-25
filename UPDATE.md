# UPDATE LOG — V-Eval System-Repo

## [24/11/2026] Thanh lọc toàn diện dữ liệu hardcode phân hệ Giảng viên (100% Real Data), Tinh gọn Dashboard & Sư phạm hóa Gia sư AI
- **Frontend (`V-Eval-Web_Client`)**:
  - **Thanh lọc triệt để 100% dữ liệu hardcode và fallback tĩnh trong toàn bộ phân hệ Giảng viên (Teacher Role)**:
    - `TeacherDashboardView.jsx`: Thay thế tooltip gán cứng số 66 chuyên đề bằng số lượng chuyên đề thực tế động `${columns.length || 0}`.
    - `AiTutorModerationView.jsx`: Xóa bỏ fallback `'class_01'` tránh rò rỉ đàm thoại; xóa bỏ `'PAT_DEFAULT'` và `'TRAP_LOGIC'`; ẩn hoàn toàn thẻ bẫy khi câu hỏi thực tế chưa được phân loại bẫy tư duy.
    - `TeacherScheduleView.jsx`: Xóa bỏ phòng học fallback cứng `'Phòng phụ đạo P.204'` và `'Phòng P.204'`; hiển thị trung thực `'Chưa xếp phòng'` hoặc `'Trực tuyến'`.
    - `ClassMicroGroupsModal.jsx`: Xóa bỏ phòng học mặc định `'Phòng phụ đạo vi mô P.204'`; liên kết động với phòng học thực tế của lớp (`classData?.room`).
    - `EarlyWarningsMentorPanel.jsx`: Xóa bỏ địa điểm và điểm mục tiêu đề xuất cứng 850; tự động đề xuất dựa trên điểm mục tiêu thực tế của học sinh.
    - `TeacherSubmissionHistoryView.jsx`: Xóa bỏ fallback tên lớp tĩnh `'Lớp nền tảng'` và điểm giả lập 780; hiển thị trung thực `'Lớp phụ trách'` và điểm số thực từ bài làm (`f.score ?? f.rawScore`).
    - `RoadmapApprovalStudioView.jsx`: Khởi tạo điểm mục tiêu theo dữ liệu lộ trình thực tế của học sinh (`data?.targetScore`), loại bỏ hoàn toàn số 850 tĩnh.
    - `AccountSettingsPage.jsx`: Thay thế các tham chiếu tĩnh từ `mockUser` trong bản xem trước Học bạ điện tử bằng thông tin tài khoản thực tế (`currentUser`).
  - **Tối ưu hóa Bảng điều khiển Giảng viên (`TeacherDashboardView.jsx`)**: Thu gọn tầng trên thành Compact Executive Header và Quick Stats Strip 4 ô; bộ lọc chuyên đề thông minh chống cuộn ngang 66 cột (Top 8 trọng tâm bồi dưỡng, 4 Miền năng lực, Tất cả); bổ sung chế độ xem Thẻ học sinh trực quan.
  - **Sư phạm hóa giao diện Kiểm duyệt Gia sư AI cho Giảng viên (`AiTutorModerationView.jsx`)**: Làm sạch 100% thuật ngữ kỹ thuật, tinh giản KPI còn 3 thẻ sư phạm thuần Việt; phân quyền giới hạn phạm vi đàm thoại strictly theo lớp và học sinh phụ trách; ẩn tab "Toàn bộ" và ẩn hoàn toàn panel xét duyệt câu hỏi bị gắn cờ khỏi Giảng viên.
  - **Tối ưu hóa Vite Dev Server (`vite.config.js`)**: Loại bỏ `optimizeDeps.include` thủ công, triệt tiêu lỗi quét dependency scan trên Vite 8, đảm bảo HMR và reload tức thì.
  - **Kiểm thử**: Toàn bộ 115/115 unit tests pass 100% (`pass 115, fail 0`), Vite build pass 100% trong 1.59s.
- **Backend (`V-Eval-Practice_Service`, `V-Eval-Content_Service`, `V-Eval-Gateway`, `V-Eval-Ai_Engine`)**:
  - `V-Eval-Practice_Service`: Fix GUID thô ở Suy diễn DAG, enrich chi tiết đáp án Thi thử, thêm cột `preview_submission_json` & 4 trường phê duyệt lộ trình + EF Migration `AddRoadmapTeacherApprovalFields` + auto `ALTER TABLE IF NOT EXISTS`, API `PUT /api/v1/roadmaps/{roadmapId}/approve`.
  - `V-Eval-Content_Service`: Chặn phát câu hỏi thiếu/lỗi đáp án (`HasBrokenOrMissingOptions`), thêm cột `is_flagged`/`flag_reason`/`flagged_at` + API `/api/content/questions/flagged`, `/flag`, `/unflag` và lọc `!q.IsFlagged` khi phát đề; bổ sung đầy đủ dữ liệu học liệu Ngữ văn 10 Ch.5 Bài 2 trên Supabase DB.
  - `V-Eval-Gateway` & `V-Eval-Ai_Engine`: Bổ sung YARP route `/api/v1/roadmaps/{**catch-all}` và chuẩn hóa nhận xét AI thân thiện.
