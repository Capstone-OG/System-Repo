# UPDATE - SYSTEM REPO

## [23/11/2026]
- **V-Eval-Web_Client**:
  - **Tối Ưu Hóa Trải Nghiệm Người Dùng & Loại Bỏ Thuật Ngữ Kỹ Thuật Khung Chương Trình Cho Phân Hệ Giảng Viên (`CurriculumExplorerView.jsx`, `UnifiedNodeDetailView.jsx`, `ExamBankView.jsx`, `ExamWorkspaceHeader.jsx`, `TextbookStandardView.jsx`, `TextbookIngestView.jsx`)**:
    + *Tái cấu trúc giao diện Tra cứu Khung chương trình*: Loại bỏ nhãn kỹ thuật `(Read-only)`, thay thế badge thành `Khung chương trình chuẩn`; đổi thanh tìm kiếm sang `Tìm kiếm chương, bài học, dạng bài...`; chuyển đổi nhãn phân loại năng lực sang thuật ngữ sư phạm (`Cần bổ trợ`, `Cần củng cố`, `Đã nắm vững`).
    + *Chuẩn hóa danh sách chương & bài học*: Đổi tiêu đề thành `Danh sách chương & bài học`, ẩn nút quản trị `+ Thêm Chương` với role Giảng viên, loại bỏ hoàn toàn các thông số kỹ thuật nội bộ như trọng số phần trăm `Trọng số: ...%` và số trang phân đoạn `Đã nạp SGK (x trang)`.
    + *Chuẩn hóa hiển thị chi tiết sư phạm*: Loại bỏ nhãn kỹ thuật trọng số và khớp trang SGK DB; chuẩn hóa 3 khối kiến thức thành `Lý Thuyết Trọng Tâm Chuẩn SGK`, `Phương Pháp Giải & Mô Hình Minh Họa Trực Quan`, `Ngân Hàng Câu Hỏi Luyện Tập`; bộ lọc nhận thức hiển thị nhãn sư phạm đầy đủ (`Tất cả`, `Nhận biết`, `Thông hiểu`, `Vận dụng`, `Vận dụng cao`) thay vì mã kỹ thuật L1-L4.
    + *Đồng bộ loại bỏ nhãn `(Read-only)`*: Cập nhật đồng bộ trên Kho đề thi (`ExamBankView.jsx`), Xem đề thi (`ExamWorkspaceHeader.jsx`), SGK chuẩn (`TextbookStandardView.jsx`) và Tra cứu tài liệu (`TextbookIngestView.jsx`).
  - **Tối Ưu Hóa Giao Diện & Đồng Bộ 100% Dữ Liệu Học Sinh Thực Tế Cho Buổi Học Offline (TCH-02) (`TeacherScheduleView.jsx`, `OfflineSessionPreparationModal.jsx`, `offlineSessionStore.js`, `tests/offlineSessionStore.test.js`)**:
    + Tái thiết kế Modal Chuẩn bị Buổi học, loại bỏ toàn bộ thuật ngữ kỹ thuật nội bộ (`Mô hình lớp học đảo ngược`, `ZPD`, `Vi mô`, `Heatmap`).
    + Đồng bộ 100% danh sách học sinh thật từ CSDL (`Trần Thái Thịnh`, `Trần Ngọc Mai`, `Mai Thành Nhân`, `Lê Hoàng Long`, `Nguyễn Hoàng An`, `Phạm Tấn Lộc`), chia bàn học cân đối; tự động thanh lọc cache cũ.
  - **Chuẩn Hóa Phân Quyền Maker - Checker Cho Role Teacher (`TextbookIngestView.jsx`, `TextbookStudioView.jsx`, `CurriculumStudioEditor.jsx`, `ExamWorkspaceHeader.jsx`, `App.jsx`)**:
    + Áp dụng cơ chế phân quyền Maker cho Giảng viên: Biên soạn bản nháp và gửi duyệt (`PENDING_REVIEW`), ẩn nút tự xuất bản và xóa học liệu toàn hệ thống.
  - **Kiểm Thử & Biên Dịch**: `npm run build` hoàn thành 100% trong 1.18s (`3083 modules`, `0 Error`); toàn bộ **24/24 unit tests passed 100%** (`tests/*.test.js`).
