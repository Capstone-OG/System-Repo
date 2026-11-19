# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - V-EVAL CAPSTONE SYSTEM REPO

## [19/11/2026] - Nâng Cấp Toàn Diện Cổng Phụ Huynh: Chuẩn Hóa Giao Diện Modern SaaS & Kết Nối 100% Dữ Liệu Thực Tế

- **Tái Thiết Kế Thanh Điều Hướng Dọc Tinh Giản 1 Dòng - Phương Án 1 ([`Sidebar.jsx`](./All%20Services/V-Eval-Web_Client/src/components/layout/Sidebar.jsx))**:
  - **Triệt tiêu hoàn toàn lỗi cụt chữ (Zero Truncation)**: Loại bỏ huy hiệu `VietQR` cồng kềnh chiếm hơn 60px gây ép cụt chữ thành `Đóng Học phí & ...`; rút gọn nhãn danh mục thành `Học phí & Gói học` thanh thoát, rõ ràng trên khung rộng 288px.
  - **Bố cục 1 dòng tinh gọn (Single-Line Compact Row - ~40px)**: Chuyển các mục điều hướng từ khối hộp 2 dòng (tiêu đề + mô tả) dày cộm sang hàng ngang 1 dòng tiêu chuẩn Modern SaaS (Linear & Notion style).
  - **Biểu tượng inline tinh tế**: Sử dụng Lucide icon trực quan (`w-4.5 h-4.5`), loại bỏ các ô vuông xám xịt buồn tẻ; chuyển mô tả phụ vào tooltip tiêu chuẩn `title={item.sublabel ? `${item.label} (${item.sublabel})` : item.label}` giúp thanh điều hướng thông thoáng, không bị ngợp thị giác.
  - **Tối ưu thẻ chân trang học sinh liên kết (Footer Student Card)**: Hiển thị tên học sinh kèm tên trường THPT thực tế (`${firstChild.studentName} • ${firstChild.school}`) thay vì chuỗi tên chuyên đề dài 54 ký tự gây tràn chữ.
- **Tái Cấu Trúc Toàn Diện Hero Header Cổng Phụ Huynh ([`ParentDashboardView.jsx`](./All%20Services/V-Eval-Web_Client/src/components/dashboard/ParentDashboardView.jsx))**:
  - **Chuẩn hóa 100% dữ liệu thực tế từ CSDL**: Toàn bộ thông tin học sinh (`child.studentName`, `child.school`, `child.grade`, `child.targetMajor`) được tải từ Backend API. Khi trường thông tin chưa có dữ liệu trong CSDL, hệ thống hiển thị thông điệp trang nhã: `"Chưa cập nhật trường THPT"`, `"Chưa phân lớp học"`, `"Chưa thiết lập mục tiêu"`.
  - **Hồ sơ học sinh trang nhã (Top Row)**: Bổ sung avatar ký tự con (`childInitials` - ví dụ `PL`), chấm xanh live trực quan, tiêu đề nổi bật và nhãn ĐGNL ĐHQG-HCM tinh gọn.
  - **Dải thông tin 3 cột cân đối (Bottom Strip)**: Trường THPT (`GraduationCap` cyan), Khóa học & Lớp học (`BookOpen` amber, `truncate` kèm tooltip), Nguyện vọng mục tiêu NV1 (`Target` emerald).
  - **Hài hòa hóa nút hành động**: Chuyển nút `+ Liên kết con` từ màu vàng chói sang phong cách kính mờ cao cấp (`bg-white/10 hover:bg-white/20 border border-white/20`).
- **Tối Ưu Bố Cục Top Navbar Theo Concept "EdTech Mission Control" ([`AccountNavbar.jsx`](./All%20Services/V-Eval-Web_Client/src/components/layout/AccountNavbar.jsx))**:
  - **Khắc phục triệt để lỗi ép cụt chữ (Zero Title Truncation)**: Cố định tiêu đề `Tổng quan Đồng hành` hiển thị sắc nét, thoáng đãng không bị co cụt (`whitespace-nowrap shrink-0`).
  - **Viên Nang Đếm Ngược 1 Dòng Kính Mờ (Center Pill)**: Viên nang thanh mảnh 1 dòng (`● ĐGNL Đợt 1 (2027) • Còn 129 ngày (28/03/2027)`), nằm chính giữa thanh điều hướng; click mở Modal chi tiết 2 đợt thi và cấu trúc 120 câu / 150 phút.
  - **Tối Ưu Cụm Hành Động & Phân Nhánh Quyền (Right Actions)**: Chuyển chip học sinh đồng hành sang góc phải nhỏ gọn (`👦 Con: [Tên con]`), ẩn bớt ngày tháng thứ yếu, tích hợp chuông cảnh báo tương tác Flow 6 và căn chỉnh chấm xanh online chuẩn xác.
- **Đồng Bộ Dữ Liệu Đóng Học Phí & Khóa Học Cho Phụ Huynh ([`TuitionPaymentView.jsx`](./All%20Services/V-Eval-Web_Client/src/components/payment/TuitionPaymentView.jsx), [`practiceService.js`](./All%20Services/V-Eval-Web_Client/src/services/practiceService.js), [`App.jsx`](./All%20Services/V-Eval-Web_Client/src/App.jsx))**:
  - Truyền ngữ cảnh học sinh (`activeChild`, `childrenList`) vào `TuitionPaymentView`, tự động giải quyết `studentId` về ID của con thay vì ID tài khoản phụ huynh.
  - Tải danh sách khóa học thực tế từ CSDL qua `practiceService.getCourses`, hiển thị chính xác tên gói, học phí và mã khóa học thật khi tạo liên kết thanh toán PayOS.
  - Xóa bỏ hoàn toàn hàm mock dữ liệu mẫu trong `practiceService.js`, trả về danh sách con rỗng và kích hoạt giao diện liên kết học sinh khi phụ huynh chưa liên kết con.
- **Chuẩn Hóa Backend Microservices (Identity Service & Practice Service)**:
  - Identity Service gRPC: Trả về chính xác `SchoolName` và `TargetScore` từ CSDL PostgreSQL; trả về chuỗi rỗng khi chưa có dữ liệu.
  - Practice Service: Truy vấn lớp học thật từ `v_eval_practice.ClassEnrollments`, ngành mục tiêu theo điểm số thật, và giáo viên thật qua gRPC. Tự động seed các khóa học chuẩn hóa vào `v_eval_enrollment."Courses"`.
- **Kiểm Thử & Biên Dịch Toàn Hệ Thống**:
  - `V-Eval-Web_Client`: `npm run build` thành công trong 1.06s, **22/22 unit tests passed**.
  - `V-Eval-Practice_Service`: **20/20 unit tests passed**.
  - `V-Eval-Identity_Service`: **5/5 unit tests passed**.
