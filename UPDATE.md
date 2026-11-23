# V-Eval System-Repo — Cập Nhật Tiến Độ

## [23/11/2026] - Công Cụ Bổ Sung Ngân Hàng Câu Hỏi Tự Động & Đồng Bộ Tiến Độ Phiên Làm Việc

- **Script Bổ Sung Ngân Hàng Câu Hỏi Theo Từng Dạng Bài (`Scripts/seed_questions_batch.py`)**:
  - Viết script Python chuẩn không cần thư viện ngoài (chỉ dùng stdlib Python 3.11), tự nạp toàn bộ cây kỹ năng GDPT 2018 từ `V-Eval-Content_Service` (`GET /api/content/curriculum`), kiểm tra số câu hiện có của từng dạng bài và dùng Gemini API (tự động fallback `gemini-3.5-flash-lite` -> `gemini-3.6-flash` -> `gemini-3.8-flash`) sinh bổ sung các câu hỏi còn thiếu (Bloom L1-L4, lọc trùng nội dung, hỗ trợ resume) rồi lưu trực tiếp qua `POST /api/content/questions`.
  - Đã kiểm thử & chèn thành công hơn 2,188 câu hỏi mới vào CSDL PostgreSQL.
- **Đồng Bộ Phiên Bản Các Service Liên Quan**:
  - `V-Eval-Practice_Service`: Cố định `StepOrder` bất biến khi đọc lộ trình & triển khai luồng phê duyệt lộ trình 2 cấp (`DRAFT_PENDING_TEACHER` -> `PENDING_DIRECTOR_APPROVAL` -> `ACTIVE`).
  - `V-Eval-Content_Service`: Xáo trộn ngẫu nhiên & chống trùng lặp theo nội dung (`ContentLatex`) trong gRPC `GetMilestoneQuiz`.
  - `V-Eval-Web_Client`: Nút `Nháp Toán`, sửa hiển thị `MathText.jsx`, tối ưu thanh lọc lộ trình, thiết kế lại thẻ Pha Reflect & Hoàn thành chặng, ẩn dấu nháy caret trên text thường và bổ sung trang `RoadmapApprovalStudioView.jsx` cho Giảng viên & Director.
## [23/11/2026]
- **V-Eval-Web_Client**:
  - **Khắc Phục Lỗi Mất Ngữ Cảnh Khi Nhấn "Xem Nhóm Phụ Đạo" Từ Thời Khóa Biểu (`TeacherScheduleView.jsx`, `ClassMicroGroupsModal.jsx`)**:
    + Khắc phục triệt để hiện tượng khi nhấn "Xem nhóm phụ đạo" từ thẻ Thời khóa biểu thì modal lại hiển thị thông tin nhóm chung chung (Reading Comprehension / Pronoun) và hiện nút "Lên lịch" thay vì ca học đã lên.
    + Cập nhật `mappedRemedial` và `handleOpenMicroGroups` trong `TeacherScheduleView.jsx` truyền toàn vẹn ngữ cảnh: `focusSkill`, `focusSkillId`, `targetGroupId`, `targetStudentIds`, `initialMembers`.
    + Nâng cấp `ClassMicroGroupsModal.jsx`: tích hợp cơ chế đối chiếu lịch phụ đạo đa tiêu chí (theo `groupId`, `targetGroupId` hoặc theo `focusArea`/`topic`), đảm bảo khi mở modal từ Thời khóa biểu, hệ thống luôn hiển thị đúng 100% chuyên đề bồi dưỡng, học sinh trong nhóm và huy hiệu lịch học đã lên.
  - **Cô Lập Hoàn Toàn Lịch Học Nhóm Phụ Đạo Giữa Các Chuyên Đề Khác Nhau (`ClassMicroGroupsModal.jsx`, `remedialSessionStore.js`, `tests/classMicroGroups.test.js`, `tests/remedialSessionStore.test.js`)**:
    + Chuẩn hóa chuỗi slug tiếng Việt (`skillSlug`) từ tên chuyên đề để tạo mã nhóm định danh riêng biệt `GRP-${skillSlug}-01` (ví dụ: `GRP-giai-quyet-van-de-h-01` tách biệt tuyệt đối với `GRP-dang-1-co-che-sinh-h-01`).
    + Dữ liệu lịch phụ đạo lưu trữ trong Local Storage được cô lập 100% theo từng chuyên đề kỹ năng, không bao giờ bị ghi đè hay hiển thị chéo.
  - **Chuẩn Hóa Khung 6 Slot Thời Khóa Biểu Đồng Bộ Hệ Thống (`ClassMicroGroupsModal.jsx`, `remedialSessionStore.js`)**:
    + Khai báo bộ hằng số `STANDARD_ACADEMIC_SLOTS` đồng bộ với 6 ca học chuẩn: Slot 1 (07:30–09:30), Slot 2 (09:45–11:45), Slot 3 (13:00–15:00), Slot 4 (15:15–17:15), Slot 5 (18:00–20:00), Slot 6 (20:15–22:30).
    + Thay thế các nút ca học tự do bằng lưới chọn 6 Slot học chuẩn (3x2), tự động điền `startTime`, `endTime`, `slotNo` và gợi ý phòng phụ đạo P.204.
  - **Đồng Bộ Hai Chiều & Hiển Thị Thẻ Phụ Đạo Chuyên Biệt Trên Thời Khóa Biểu Giảng Viên (`TeacherScheduleView.jsx`)**:
    + Nạp các ca phụ đạo từ `remedialSessionStore`, ánh xạ chính xác vào ngày học và slot tương ứng.
    + Tích hợp event listener phản ứng tức thời (`veval:remedial-session-scheduled`, `veval:remedial-session-deleted`), tự động cập nhật thời khóa biểu ngay khi Giảng viên tạo hoặc hủy lịch mà không cần tải lại trang.
    + Thiết kế thẻ phụ đạo màu tím Pastel nổi bật với huy hiệu `⚡ Phụ đạo vi mô` ở cả 2 chế độ Weekly Grid và Agenda View.
  - **Lọc Chuẩn Xác Đối Tượng Học Sinh Bồi Dưỡng Chuyên Đề & Ngăn Ngừa Gom Cả Lớp (`ClassMicroGroupsModal.jsx`, `TeacherDashboardView.jsx`)**:
    + Lọc chuẩn xác theo học sinh thực tế chưa đạt (< 50%) thay vì kéo cả lớp; với 4 học sinh chưa đạt tự động tạo đúng 1 bàn bồi dưỡng 4 bạn; tích hợp nút chuyển đổi phạm vi `🎯 Chỉ học sinh chưa đạt` vs `👥 Cả lớp`.
    + Đồng bộ số liệu hiển thị cảnh báo sư phạm ngoài danh sách (`57% (4 học sinh)`), triệt tiêu mâu thuẫn số liệu.
  - **Kiểm Thử & Biên Dịch**:
    + 36/36 unit tests passed 100% (`tests/classMicroGroups.test.js`, `tests/remedialSessionStore.test.js`, ...).
    + `npm run build`: Hoàn thành 100% trong 1.28s (`3086 modules transformed`, `0 Error`).

- **V-Eval-Ai_Engine**:
  - **Cấu Hình Supabase Transaction Mode Pooler Cho RAG Service (`rag-service/.env`)**:
    + Chuyển đổi cổng `DATABASE_URL` từ `5432` (Session Mode - giới hạn 15 clients) sang `6543` (Transaction Mode), giải quyết triệt để lỗi `FATAL: (EMAXCONNSESSION) max clients reached in session mode - max clients are limited to pool_size: 15`.
