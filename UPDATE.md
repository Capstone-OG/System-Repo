# UPDATE - SYSTEM REPO

## [21/11/2026]
- **V-Eval-Web_Client**:
  - **Chuẩn Hóa Dữ Liệu Động Toàn Diện & Triệt Tiêu Giá Trị Tĩnh Cho Phân Hệ Giáo Viên (`TeacherScheduleView.jsx`, `AiTutorModerationView.jsx`, `ClassMicroGroupsModal.jsx`, `TeacherStudentDrillDownModal.jsx`, `practiceService.js`)**:
    - Xóa bỏ giá trị tĩnh `'Teacher Khôi'`, `'P.301'`, nhận diện hình thức linh hoạt (`Online` / `Offline`) theo phòng học.
    - Chuyển đổi thẻ "GraphRAG Monitor" sang tính toán tự động tỷ lệ tin cậy và số lượng bẫy tư duy từ cơ sở dữ liệu thực.
    - Kích hoạt cơ chế tự động đóng gói 5 câu hỏi thích ứng trực tiếp từ Content Service API khi phát phiếu bài tập vi mô; tích hợp lệnh in thực tế `window.print()`.
    - Thay thế mô phỏng `setTimeout` bằng hệ thống lưu trữ bền vững lịch sử dặn dò sư phạm theo từng học sinh; hiển thị danh sách dặn dò gần đây.
    - Xóa bỏ dữ liệu giả lập `_source: 'seed_fallback'` trong `forceAggregateClassHeatmap`.
  - **Loại Bỏ 2 Nút Thu Gọn Sidebar Trùng Lặp Ở Mép Brand Header & Navbar (`Sidebar.jsx`, `AccountNavbar.jsx`)**:
    - Triệt tiêu 2 nút thu gọn/mở rộng sidebar (`PanelLeftClose`/`PanelLeftOpen`) nằm kề nhau gây rối mắt giữa Sidebar và Top Navbar.
    - Giữ nguyên nút menu điều hướng responsive mobile (`Menu`), làm phẳng và thoáng đãng thanh tiêu đề desktop.
  - **Tối Giản Cảnh Báo Sư Phạm Thành Nút Bấm Popup (Pedagogical Alerts Modal) (`TeacherDashboardView.jsx`)**:
    - Gom danh sách thẻ cảnh báo trải dài thô xuống màn hình thành 1 dải mỏng nhẹ và 1 nút bấm: `Xem danh sách chuyên đề ({count})`.
    - Khi bấm, hiển thị Modal danh sách chuyên đề cuộn mượt (`max-h-[85vh]`), hiển thị chi tiết tỷ lệ hiểu bài, số học sinh chưa đạt và nút mở nhanh tạo nhóm bồi dưỡng vi mô 3–5 em.
  - **Tối Giản & Tái Cấu Trúc Ma Trận Thời Khóa Biểu Tuần 8 Cột (Weekly Timetable Matrix Grid) (`TeacherScheduleView.jsx`)**:
    - Loại bỏ khối banner hero xanh đen cồng kềnh giúp giao diện phẳng đồng điệu; đưa nút làm mới (`RefreshCw`) vào thanh công cụ.
    - Xây dựng bảng ma trận 8 cột (Slot 1-6 + Thứ 2 đến Chủ nhật), làm nổi bật ngày hiện tại, ô trống hiển thị `-`, thẻ ca học đầy đủ thông tin sư phạm kèm modal điểm danh trực tiếp tại lớp.
  - **Tối Ưu Hóa Trình Bày Câu Hỏi Tìm Lỗi Sai Tiếng Anh, Tự Động Phục Hồi Chùm Đọc Hiểu 118–120 & Nâng Cấp Bộ Parser Đề Thi PDF**:
    - Bổ sung cơ chế tự động chữa lành chùm đọc hiểu (`normalizeExamData`): giải cứu các câu hỏi bị nuốt vào bên trong thân đoạn văn do dữ liệu cũ, tách riêng thành 3 câu hỏi con 118, 119, 120 với đầy đủ phương án A/B/C/D (chuyển trạng thái từ "0 câu" thành "3 câu"); phục hồi nguyên bản đoạn văn Lịch sử 11 trang 155 không còn ký tự rác.
    - Xóa bỏ các nhãn `(A)`, `(B)`, `(C)`, `(D)` lơ lửng trên câu hỏi; định dạng từ cần tìm lỗi sai thành **in đậm + gạch chân** (`font-bold underline`).
    - Nâng cấp `STORAGE_KEY` lên `v3` để trình duyệt tự động xóa cache cũ và kích hoạt logic phục hồi.
  - **Kiểm Thử & Biên Dịch**: `npm run build` thành công 100% trong 1.29s (`3081 modules`, `0 Error`).
  - **Hotfix Giao Diện PLAR & Kho Tri Thức SGK PLAR (`PlarNodeStudioPanel.jsx`, CSDL PostgreSQL `v_eval_content."Materials"`)**:
    - Khắc phục triệt để lỗi khung lý thuyết trong PLAR bị giới hạn chiều cao / chỉ xem được đoạn đầu:
      * Tích hợp trực tiếp module tri thức SGK `getDefaultLessonTheory` và `getSavedTextbookData` vào Pha Learn của PLAR.
      * Loại bỏ hoàn toàn mọi rào cản chiều cao (`overflow-visible`), hiển thị đầy đủ 100% định nghĩa, công thức KaTeX, phương pháp giải chuẩn GDPT 2018.
      * Nâng cấp `PassageContextBox` với nút `Xem toàn văn / Thu gọn` và tăng trần chiều cao lên `max-h-[460px]`.
      * Cập nhật CSDL PostgreSQL `v_eval_content."Materials"` chuyên đề Toán 10 (Đường thẳng trong mặt phẳng toạ độ) từ 722 ký tự lên 4,270 ký tự toàn văn chuẩn mực.
    - Đã build lại và deploy thành công container Docker `v-eval-web-client`.
- **V-Eval-Content_Service**:
  - **Hotfix Toàn Hệ Thống: Phân Lập Môn Học Tuyệt Đối (Subject Boundary Isolation) Trong Chu Trình PLAR (`ContentGrpcService.cs`, `SubjectTaxonomyHelper.cs`, `ContentGrpcServiceSubjectIsolationTests.cs`)**:
    - Khắc phục triệt để lỗi học sinh học chặng Toán học nhưng nhận câu hỏi môn Ngữ văn.
    - Thiết lập quy tắc **Subject Boundary Isolation**: Khoanh vùng câu hỏi chuẩn xác theo môn học (`targetSubject`), lọc sạch câu hỏi khác môn trong đề thi tổng hợp, xóa bỏ hoàn toàn bước fallback quét bừa toàn bộ bảng `Questions` hay fallback theo Domain chung.
    - Đóng gói thư viện phân loại môn học `SubjectTaxonomyHelper` hỗ trợ chuẩn 9–10 môn GDPT 2018; bổ sung unit tests kiểm tra phân lập môn học đạt 16/16 test passed 100%.
- **V-Eval-Practice_Service**:
  - **Đồng Bộ Danh Tính Họ Tên Học Sinh Thực Tế Cho Ma Trận Nhiệt Lớp Học (`GetClassHeatmapQueryHandler.cs`, `IIdentityGrpcClient.cs`)**:
    - Tiêm `IIdentityGrpcClient` vào `GetClassHeatmapQueryHandler`, gọi gRPC `GetStudentNamesAsync` sang Identity Service để truy vấn họ tên người dùng từ bảng `v_eval_identity."Users"`.
    - Thay thế hoàn toàn mã định danh giả lập `Học sinh #...` bằng danh tính thực tế: `Nguyễn Hoàng An`, `Trần Ngọc Mai`, `Phạm Tấn Lộc`, `Mai Thành Nhân`, `Trần Thái Thịnh`, `Lê Hoàng Long`.
    - Tự động bỏ qua bộ đệm cache khi phát hiện dữ liệu cũ và tái đồng bộ vào MemoryCache.
    - `dotnet build`: Hoàn thành 100%, 0 lỗi, 0 cảnh báo; `dotnet test`: 20/20 unit tests Passed.
  - **Hotfix Pha Apply Chu Trình PLAR (`GetNextQuestionQueryHandler.cs`)**:
    - Chuẩn hóa truy vấn câu hỏi thích ứng Pha Apply (Pha A): Bỏ fallback GUID giả, truyền `examId: null` để Content Service cấp phát câu hỏi thích ứng phong phú từ L1 đến L4 chuẩn theo dạng bài `skillId` và cây kỹ năng của môn học đó.
    - Kiểm thử `dotnet test --no-restore` đạt 20/20 test passed 100%.
- **V-Eval-Ai_Engine**:
  - Chuyển sang thuật toán **Line-Following (Nearest-Neighbor Horizontal Chain)** trong `ExtractOrderedPageText`: loại bỏ 100% tình trạng xé lẻ chữ cái đơn (`o`, `g`, `n`, `u`, `V`, `i`, `đ`) và chống trộn dòng khi trang scan bị nghiêng.
  - Mở rộng nhận diện câu hỏi số trần (`91.`, `92.`, `118.`, `119.`, `120.`), chống chùm đọc hiểu nuốt câu hỏi con.
  - `dotnet build --no-restore` 0 Error, `dotnet test --no-build` `65/65` passed.
