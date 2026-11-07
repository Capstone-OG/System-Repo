# NHẬT KÝ CẬP NHẬT HỆ THỐNG (SYSTEM-REPO UPDATE LOG)

## [07/11/2026] - Mở Rộng Không Gian Làm Việc Toàn Màn Hình (`w-full`), Tinh Chỉnh Bảng Tài Khoản IAM 1 Dòng Không Cuộn Ngang & Hoàn Thiện Phân Hệ Quản Lý Tài Khoản Ngừng Hoạt Động (Soft Delete / Inactive)

- **Mở Rộng Không Gian Làm Việc Toàn Chiều Ngang (`w-full`) Sát Sidebar & Tinh Chỉnh Giao Diện Bảng Tài Khoản IAM (`V-Eval-Web_Client`)**:
  - **Đồng Bộ Bố Cục `w-full` Không Khoảng Trống Thừa ([`App.jsx`](./All%20Services/V-Eval-Web_Client/src/App.jsx), [`AccountProvisioningView.jsx`](./All%20Services/V-Eval-Web_Client/src/components/admin/AccountProvisioningView.jsx), [`CampusManagerDashboardView.jsx`](./All%20Services/V-Eval-Web_Client/src/components/dashboard/CampusManagerDashboardView.jsx), [`ParentDashboardView.jsx`](./All%20Services/V-Eval-Web_Client/src/components/dashboard/ParentDashboardView.jsx), [`TuitionPaymentView.jsx`](./All%20Services/V-Eval-Web_Client/src/components/payment/TuitionPaymentView.jsx))**: Thay thế `max-w-7xl mx-auto` bằng `w-full` kèm `px-4 sm:px-6` thẳng hàng với `Navbar` và `Sidebar`, xóa bỏ khoảng trống thừa cạnh `Sidebar` và loại bỏ hoàn toàn thanh cuộn ngang trên bảng danh sách tài khoản.
  - **Chuẩn Hóa Bảng Tài Khoản 1 Dòng Duy Nhất (`whitespace-nowrap`) & Command Toolbar ([`AccountProvisioningView.jsx`](./All%20Services/V-Eval-Web_Client/src/components/admin/AccountProvisioningView.jsx))**: Gộp bộ chuyển đổi trạng thái Segmented Switcher, ô tìm kiếm và bộ lọc vai trò vào một thanh công cụ hợp nhất; cố định 1 dòng duy nhất cho toàn bộ huy hiệu vai trò, trạng thái và nút *"Ngừng hoạt động"* / *"Khôi phục"*; bổ sung avatar 2 chữ cái theo màu vai trò và hiển thị đơn vị/chuyên môn thông minh.
  - **Nâng Cấp `apiClient.js` Hỗ Trợ Query Params & `PATCH` ([`apiClient.js`](./All%20Services/V-Eval-Web_Client/src/services/apiClient.js))**: Bổ sung tuần tự hóa `options.params` bằng `URLSearchParams` và phương thức `apiClient.patch()`, đảm bảo lọc chính xác tài khoản theo trạng thái `isActive` từ Backend.

- **Phân Hệ Quản Lý Tài Khoản Ngừng Hoạt Động (Soft Delete / Inactive) Toàn Diện (`V-Eval-Identity_Service` & `V-Eval-Web_Client`)**:
  - **Bảo Toàn Dữ Liệu Sư Phạm Tuyệt Đối (No Hard Delete)**: Không xóa cứng (`DELETE FROM "Users"`), bảo toàn 100% lịch sử bài thi chẩn đoán IRT, phiên luyện tập thích ứng, giao dịch học phí PayOS và liên kết Phụ huynh - Học sinh.
  - **Bộ Lọc Trạng Thái & Thống Kê Realtime (`V-Eval-Identity_Service`)**: Nâng cấp `GetUsersQuery` (`GET /api/v1/users?isActive=...`), `PagedUsersResult` (`ActiveCount`, `InactiveCount`) và `ToggleUserStatusCommand` (`PATCH /api/v1/users/{id}/toggle-status?targetStatus=...`).
  - **Giao Diện Dual-View & Modals Xác Nhận (`V-Eval-Web_Client`)**: Tách biệt tab *"Đang hoạt động"* (ẩn tự động các tài khoản bị vô hiệu hóa) và tab *"Đã ngừng hoạt động (Ẩn)"* kèm Modal xác nhận Ngừng hoạt động / Khôi phục.

- **Tái Thiết Kế Thanh Điều Hướng Segmented Control, Nhận Diện Giám Đốc Học Thuật & Kiểm Tra Email Đa Tầng (`V-Eval-Identity_Service` & `V-Eval-Web_Client`)**:
  - Thiết kế thanh điều hướng Subpage dạng Segmented Control hiện đại trên 1 hàng ngang duy nhất và nhận diện động vai trò Giám đốc Học thuật (`ACADEMIC_DIRECTOR`).
  - Tích hợp kiểm tra email đa tầng DNS MX (`EmailValidationHelper` & `validateEmailComprehensive`) phát hiện lỗi gõ nhầm `@mail.com` -> `@gmail.com`, và chuyển `Student.CampusId` sang `Guid?` khắc phục triệt để lỗi Null `campus_id`.

- **Kiểm Thử & Vận Hành Toàn Hệ Thống**:
  - `V-Eval-Identity_Service`: .NET 9 SDK build sạch 100% (0 Error), 5/5 xUnit unit tests đạt Passed 100%.
  - `V-Eval-Web_Client`: `npm run build` hoàn thành sạch sẽ 100% (`3008 modules transformed`, 0 Error).
