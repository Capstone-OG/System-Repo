# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [26/10/2026] - Nghiệm Thu STT 1–50 Mối Quan Hệ CSDL, Phân Tích Chuyên Sâu Many-To-One (N - 1), JSONB Hybrid Patterns & Đối Chiếu Barem Review 2 SWP490

- **Nghiệm Thu Toàn Diện STT 1 Đến STT 50 Trong Báo Cáo Kiểm Định CSDL**:
  - Cập nhật [`docs/SQL/Tong_Quan_Chi_Tiet_Moi_Quan_He_Entities.md`](./docs/SQL/Tong_Quan_Chi_Tiet_Moi_Quan_He_Entities.md): Đánh dấu `[x] Nghiệm thu` chính thức cho 50 mối quan hệ đầu tiên (toàn bộ 42 Khóa ngoại vật lý nội bộ + 8 Tham chiếu logic liên Service đầu tiên).
  - Phân tích chi tiết từng cặp bản số (`1-0`, `1-1`, `1-N`, `0-0`, `0-1`) trực tiếp vào từng dòng của Bảng Master Checklist và các mục giải trình chuyên sâu.

- **Làm Rõ Bản Số Many-to-One (N - 1) & Kiến Trúc AI Đa Dạng Bài / Đa Bẫy Tư Duy (STT 41–43)**:
  - **Chiều `N — 1` (Many-to-One)**: Nhiều bản ghi con (đề xuất câu hỏi mới, phiên chat AI Tutor) cùng trỏ về 1 bản ghi cha (dạng bài chủ đạo, bẫy tư duy kinh điển).
  - **Cơ chế Hybrid Pattern & Multi-traps qua JSONB**: Khóa ngoại cứng chỉ lưu Top-1 dạng gần nhất hoặc bẫy kích hoạt ban đầu để bảo đảm chuẩn hóa 3NF; toàn bộ $N$ dạng bài lai ghép được lưu trong `extracted_metadata jsonb`, và diễn biến $N$ bẫy liên tiếp trong phiên chat Socratic được lưu trong `ai_guidance_transcript jsonb`.

- **Nghiệm Thu Nhóm Tham Chiếu Logic Liên Service (STT 44–50)**:
  - **STT 44–46 (`Classes`)**: Cơ sở offline tổ chức lớp học (`campus_id NOT NULL`), giáo viên Lead Mentor điều hành lớp (`teacher_id` Nullable), lớp học được tạo tự động bởi thuật toán Batch K-Means Placement (`assigned_by = NULL`).
  - **STT 47–48 (`ClassEnrollments`, `ClassGroupMembers`)**: Phân định rõ học sinh tự học online tại nhà (`0` lớp, `0` nhóm) vs học sinh theo học offline tại cơ sở (`1..N` lớp, `1..N` nhóm vi mô 3–5 bạn).
  - **STT 49–50 (`ExamSubmissions`)**: Học sinh mới đăng ký chưa làm bài test nào (`0` bài thi); Đề thi mới tạo bản nháp `is_published = false` chưa lên kệ (`0` lượt nộp).

- **Đối Chiếu & Xác Nhận Chuẩn Quy Cách Review 2 SWP490 (v1.0 - 10/2026)**:
  - Rà soát toàn bộ hướng dẫn môn học: Xác nhận hệ thống yêu cầu **`Logical ERD`** và **`database script khớp với ERD`**, hoàn toàn không yêu cầu Conceptual ERD riêng lẻ.
  - Mô hình 47 bảng và 74 mối quan hệ liên kết qua các bảng trung gian (Junction Tables) bảo đảm 100% chuẩn hóa 3NF và vượt qua kiểm thử tự động của Prompt rà soát Mục 05.
