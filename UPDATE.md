# UPDATE - SYSTEM REPO

## [23/11/2026]
- **V-Eval-Web_Client**:
  - **Chuẩn Hóa Điều Kiện Hiển Thị Nút Hẹn Tư Vấn 3 Bên Trong Danh Sách Học Sinh Cần Hỗ Trợ (`EarlyWarningsMentorPanel.jsx`)**:
    + *Chỉ hiển thị nút Hẹn Tư Vấn 3 Bên cho Cảnh báo Đỏ*: Điều chỉnh điều kiện ràng buộc trong giao diện danh sách học sinh cần hỗ trợ để nút `Hẹn Tư Vấn 3 Bên` chỉ xuất hiện duy nhất khi học sinh thuộc diện **Cảnh báo Đỏ** (`alert.alertType === 'RED'`).
    + *Phân hóa quy trình can thiệp*: Với các trường hợp lệch mục tiêu (`UNREALISTIC_GOAL`) hoặc nhắc nhở (`YELLOW`), hệ thống chỉ hiển thị nút `Ghi Nhận Can Thiệp`, ngăn ngừa việc đặt lịch tư vấn 3 bên khi chưa có nguy cơ cao.
  - **Tối Ưu Hóa Chiều Dài Cuộn & Công Thái Học Tra Cứu Khung Chương Trình Cho Giảng Viên (`CurriculumExplorerView.jsx`)**:
    + *Tích hợp thanh Tab chọn nhanh Khối lớp (Lớp 10 • 11 • 12)*: Đặt 4 tab chuyển đổi ngay đỉnh danh sách chương kèm số lượng chương thực tế (`Tất cả`, `Lớp 12`, `Lớp 11`, `Lớp 10`), lọc ngay lập tức danh sách từ 14+ chương xuống còn 2–7 chương theo đúng khối lớp giảng dạy, triệt tiêu 70% độ dài phải cuộn trang.
    + *Cơ chế Khung cuộn độc lập (Split Independent Scroll) & Cố định khung chi tiết (Sticky View)*: Cột trái (danh sách chương) và Cột phải (chi tiết 3 tầng) đều có khung cuộn nội bộ độc lập `lg:sticky lg:top-4 lg:max-h-[calc(100vh-100px)] lg:overflow-y-auto`, không làm trôi giao diện tổng thể; khung chi tiết luôn cố định ngang tầm mắt.
    + *Nút công thái học Mở rộng / Thu gọn tất cả*: Bổ sung nút chuyển đổi 1-chạm `Thu gọn hết / Mở tất cả` giúp giáo viên đóng/mở toàn bộ các chương chỉ với 1 click.
    + *Tinh giản mật độ hiển thị thẻ chương (Compact Density)*: Tối ưu padding (`p-2.5 sm:px-3`), thu nhỏ icon `w-7 h-7` và tinh gọn khoảng cách, tăng gấp đôi số lượng chương hiển thị trên cùng một tầm nhìn màn hình.
  - **Tối Ưu Hóa Trải Nghiệm Người Dùng & Loại Bỏ Thuật Ngữ Kỹ Thuật Khung Chương Trình Cho Phân Hệ Giảng Viên (`CurriculumExplorerView.jsx`, `UnifiedNodeDetailView.jsx`, `ExamBankView.jsx`, `ExamWorkspaceHeader.jsx`, `TextbookStandardView.jsx`, `TextbookIngestView.jsx`)**:
    + *Tái cấu trúc giao diện Tra cứu Khung chương trình*: Loại bỏ nhãn kỹ thuật `(Read-only)`, thay thế badge thành `Khung chương trình chuẩn`; đổi thanh tìm kiếm sang `Tìm kiếm chương, bài học, dạng bài...`; chuyển đổi nhãn phân loại năng lực sang thuật ngữ sư phạm (`Cần bổ trợ`, `Cần củng cố`, `Đã nắm vững`).
    + *Chuẩn hóa danh sách chương & bài học*: Đổi tiêu đề thành `Danh sách chương`, ẩn nút quản trị `+ Thêm Chương` với role Giảng viên, loại bỏ hoàn toàn các thông số kỹ thuật nội bộ như trọng số phần trăm `Trọng số: ...%` và số trang phân đoạn `Đã nạp SGK (x trang)`.
    + *Chuẩn hóa hiển thị chi tiết sư phạm*: Loại bỏ nhãn kỹ thuật trọng số và khớp trang SGK DB; chuẩn hóa 3 khối kiến thức thành `Lý Thuyết Trọng Tâm Chuẩn SGK`, `Phương Pháp Giải & Mô Hình Minh Họa Trực Quan`, `Ngân Hàng Câu Hỏi Luyện Tập`; bộ lọc nhận thức hiển thị nhãn sư phạm đầy đủ (`Tất cả`, `Nhận biết`, `Thông hiểu`, `Vận dụng`, `Vận dụng cao`) thay vì mã kỹ thuật L1-L4.
    + *Đồng bộ loại bỏ nhãn `(Read-only)`*: Cập nhật đồng bộ trên Kho đề thi (`ExamBankView.jsx`), Xem đề thi (`ExamWorkspaceHeader.jsx`), SGK chuẩn (`TextbookStandardView.jsx`) và Tra cứu tài liệu (`TextbookIngestView.jsx`).
  - **Tối Ưu Hóa Giao Diện & Đồng Bộ 100% Dữ Liệu Học Sinh Thực Tế Cho Buổi Học Offline (TCH-02) (`TeacherScheduleView.jsx`, `OfflineSessionPreparationModal.jsx`, `offlineSessionStore.js`, `tests/offlineSessionStore.test.js`)**:
    + Tái thiết kế Modal Chuẩn bị Buổi học, loại bỏ toàn bộ thuật ngữ kỹ thuật nội bộ (`Mô hình lớp học đảo ngược`, `ZPD`, `Vi mô`, `Heatmap`).
    + Đồng bộ 100% danh sách học sinh thật từ CSDL (`Trần Thái Thịnh`, `Trần Ngọc Mai`, `Mai Thành Nhân`, `Lê Hoàng Long`, `Nguyễn Hoàng An`, `Phạm Tấn Lộc`), chia bàn học cân đối; tự động thanh lọc cache cũ.
  - **Chuẩn Hóa Phân Quyền Maker - Checker Cho Role Teacher (`TextbookIngestView.jsx`, `TextbookStudioView.jsx`, `CurriculumStudioEditor.jsx`, `ExamWorkspaceHeader.jsx`, `App.jsx`)**:
    + Áp dụng cơ chế phân quyền Maker cho Giảng viên: Biên soạn bản nháp và gửi duyệt (`PENDING_REVIEW`), ẩn nút tự xuất bản và xóa học liệu toàn hệ thống.
  - **Kiểm Thử & Biên Dịch**: `npm run build` hoàn thành 100% trong 1.17s (`3083 modules`, `0 Error`); toàn bộ **24/24 unit tests passed 100%** (`tests/*.test.js`).
