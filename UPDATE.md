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
  - **Web Client & AI Engine (Đã nghiệm thu ở commit trước)**:
    + Phục hồi tự động chùm đọc hiểu 118–120 môn Lịch sử; tối ưu hóa hiển thị dạng bài tìm lỗi sai Tiếng Anh (in đậm + gạch chân); nâng cấp thuật toán Line-Following trong PdfPig chống xé lẻ chữ cái đơn.
