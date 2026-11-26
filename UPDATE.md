# CẬP NHẬT TIẾN ĐỘ HỆ THỐNG - V-EVAL CAPSTONE SYSTEM REPO

## [26/11/2026] - Sửa Tiêu Đề Sidebar, Tên Thí Sinh Kiểm Tra Bất Thường, Học Phí 2 Đợt & Dọn Hardcode Seed

- **V-Eval-Web_Client**: Sửa lỗi tiêu đề nhóm menu Sidebar bị xuống dòng (`Sidebar.jsx`); khắc phục hiển thị họ tên thí sinh, tên đề thi, thời gian nộp và điểm số tại tab *Kiểm Tra Bài Thi Bất Thường* (`TeacherDashboardView.jsx`, `TeacherProctoringReviewModal.jsx`); xóa mục `Luyện tập` trùng lặp và chuyển `TuitionPaymentView.jsx` sang đóng học phí 2 đợt. `node --test tests/*.test.js` đạt 115/115; `npm run build` đạt 0 lỗi (`1.68s`).
- **V-Eval-Practice_Service**: Tiêm `IIdentityGrpcClient` vào `GetFlaggedSubmissionsQueryHandler` & `GetMockExamDetailQueryHandler` để trả kèm `StudentName` và `SubmittedAt` cho hàng đợi & chi tiết bài thi bất thường (`dotnet build` 0 lỗi/0 cảnh báo, `dotnet test` 20/20 Passed); bổ sung `TermId` cho `CreatePaymentLinkCommand` và gỡ ~456 dòng seed hardcode khỏi `Program.cs`.
- **V-Eval-Identity_Service**: Chuẩn hóa `DbInitializer.cs` (mật khẩu mặc định `Admin@2026`, không ghi đè mật khẩu khi restart).
- **Supabase Database**: Nạp trọn bộ 6 tầng dữ liệu thực tế cho 144 tài khoản, chuyển `v_eval_enrollment` sang mô hình 2 đợt học và dọn sạch bản ghi hardcode cũ.
