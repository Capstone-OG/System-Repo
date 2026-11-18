# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - V-EVAL CAPSTONE SYSTEM REPO

## [19/11/2026] - Chuẩn Hóa Trải Nghiệm Người Dùng Cổng Phụ Huynh (User-Centric UX): Loại Bỏ 100% Thuật Ngữ Kỹ Thuật

- **Thanh Lọc Toàn Diện Thuật Ngữ Kỹ Thuật Trên Giao Diện Phụ Huynh ([`ParentDashboardView.jsx`](./All%20Services/V-Eval-Web_Client/src/components/dashboard/ParentDashboardView.jsx))**:
  - Loại bỏ hoàn toàn các thuật ngữ nội bộ của developer: `Core Flow 5`, `● Live Identity + Practice gRPC`, `R_exam`, `PLAR`, `tâm trắc học IRT & BKT`, `thích ứng ZPD`, `chống treo máy ảo`.
  - Thay thế bằng ngôn ngữ thân thiện, chuẩn góc nhìn cha mẹ:
    - *Top Badge*: Chuyển thành `"Không Gian Đồng Hành Cùng Con"` kèm chấm xanh *"Cập nhật trực tiếp theo thời gian thực"*.
    - *Khối Học phí*: Chuyển thành `"Nộp Học Phí Để Mở Khóa Lộ Trình Học Cá Nhân Hóa Cho Con"`, nút `"Nộp Học Phí Cho Con"`.
    - *4 Thẻ tổng quan*: `"Chỉ Số Sẵn Sàng Thi ĐGNL"`, `"Mức độ bao quát kiến thức các phần thi ĐGNL"`.
    - *3 Trụ cột đánh giá*: Đổi thành `"3 Trụ Cột Đánh Giá Mức Độ Sẵn Sàng Đi Thi Của Con"` (Năng lực giải đề 50%, Độ vững kiến thức 35%, Kỷ luật học tập 15%).
    - *Khung giờ học*: Đổi thành giải thích sư phạm nhân văn, loại bỏ các từ ngữ kỹ thuật treo máy ảo.
- **Tối Ưu Ngôi Xưng Nhắc Nhở Học Tập ([`StudentEarlyWarningsCard.jsx`](./All%20Services/V-Eval-Web_Client/src/components/dashboard/StudentEarlyWarningsCard.jsx))**:
  - Chuyển đổi ngôi xưng sang *"nhắc nhở con ôn bài..."* và *"Con đang duy trì nhịp độ học tập rất tốt!"*.
- **Chuẩn Hóa Sidebar & Footer ([`Sidebar.jsx`](./All%20Services/V-Eval-Web_Client/src/components/layout/Sidebar.jsx), [`App.jsx`](./All%20Services/V-Eval-Web_Client/src/App.jsx))**:
  - Sidebar: Loại bỏ các nhãn kỹ thuật `R_exam`, đổi nhãn thanh toán thành `"Đóng Học phí & Gói học"`.
  - Footer: Đổi hiển thị từ `"Vai trò hiện tại: PARENT"` thành `"Tài khoản: Phụ huynh"`.
- **Kiểm Thử & Biên Dịch**:
  - `V-Eval-Web_Client`: `npm run build` thành công trong 1.19s, **22/22 tests passed**.
  - `V-Eval-Practice_Service`: 20/20 unit tests passed.
  - `V-Eval-Identity_Service`: 5/5 unit tests passed.
