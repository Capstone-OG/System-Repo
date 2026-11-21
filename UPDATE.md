# UPDATE - SYSTEM REPO

## [21/11/2026]
- **Hotfix Toàn Hệ Thống: Phân Lập Môn Học Tuyệt Đối (Subject Boundary Isolation) Trong Chu Trình PLAR & Tối Ưu Giao Diện Đề Thi**:
  - **Content Service (`ContentGrpcService.cs`, `SubjectTaxonomyHelper.cs`, `ContentGrpcServiceSubjectIsolationTests.cs`)**:
    + Khắc phục triệt để lỗi học sinh học chặng Toán học (Chương 9 - Bài 2: Đường thẳng trong mặt phẳng toạ độ) nhưng nhận câu hỏi môn Ngữ văn ("Trăng quầng thì hạn, trăng... thì mưa").
    + Thiết lập quy tắc **Subject Boundary Isolation**: Khoanh vùng câu hỏi chuẩn xác theo môn học (`targetSubject`), lọc sạch câu hỏi khác môn trong đề thi tổng hợp, xóa bỏ hoàn toàn bước fallback quét bừa toàn bộ bảng `Questions` hay fallback theo Domain chung.
    + Đóng gói thư viện phân loại môn học `SubjectTaxonomyHelper` hỗ trợ chuẩn 9–10 môn GDPT 2018; bổ sung unit tests kiểm tra phân lập môn học đạt 16/16 test passed 100%.
  - **Practice Service (`GetNextQuestionQueryHandler.cs`)**:
    + Chuẩn hóa truy vấn câu hỏi thích ứng Pha Apply (Pha A): Bỏ fallback GUID giả, truyền `examId: null` để Content Service cấp phát câu hỏi thích ứng phong phú từ L1 đến L4 chuẩn theo dạng bài `skillId` và cây kỹ năng của môn học đó.
    + Kiểm thử `dotnet test --no-restore` đạt 20/20 test passed 100%.
  - **Web Client & Kho Tri Thức SGK PLAR (`PlarNodeStudioPanel.jsx`, CSDL PostgreSQL `v_eval_content."Materials"`)**:
    + Khắc phục triệt để lỗi khung lý thuyết trong PLAR bị giới hạn chiều cao / chỉ xem được đoạn đầu:
      * Tích hợp trực tiếp module tri thức SGK `getDefaultLessonTheory` và `getSavedTextbookData` vào Pha Learn của PLAR.
      * Loại bỏ hoàn toàn mọi rào cản chiều cao (`overflow-visible`), hiển thị đầy đủ 100% định nghĩa, công thức KaTeX, phương pháp giải chuẩn GDPT 2018.
      * Nâng cấp `PassageContextBox` với nút `Xem toàn văn / Thu gọn` và tăng trần chiều cao lên `max-h-[460px]`.
      * Cập nhật CSDL PostgreSQL `v_eval_content."Materials"` chuyên đề Toán 10 (Đường thẳng trong mặt phẳng toạ độ) từ 722 ký tự lên 4,270 ký tự toàn văn chuẩn mực (đầy đủ VTCP, VTPT, phương trình tham số, chính tắc, tổng quát, đoạn chắn, vị trí tương đối, góc, khoảng cách, ví dụ và bẫy đề thi ĐGNL).
    + Phục hồi tự động chùm đọc hiểu 118–120 môn Lịch sử; tối ưu hóa hiển thị dạng bài tìm lỗi sai Tiếng Anh (in đậm + gạch chân); nâng cấp thuật toán Line-Following trong PdfPig chống xé lẻ chữ cái đơn.
    + Đã build lại và deploy thành công container Docker `v-eval-web-client`.
