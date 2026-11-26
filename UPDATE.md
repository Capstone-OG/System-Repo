# CẬP NHẬT TIẾN ĐỘ HỆ THỐNG - V-EVAL CAPSTONE SYSTEM REPO

## [26/11/2026] - Học Phí Theo 2 Đợt, Dọn Sidebar Dư & Loại Bỏ Hardcode Seed Toàn Hệ Thống

- **V-Eval-Web_Client**: Xóa mục `Luyện tập` trùng lặp với `Luyện tập (P-L-A-R)` trong `Sidebar.jsx`; chuyển màn hình `TuitionPaymentView.jsx` sang đóng học phí theo 2 đợt (`Đợt 1` & `Đợt 2`), truyền `termId` sang PayOS. Build kiểm thử đạt 0 lỗi (`4272 modules transformed`).
- **V-Eval-Practice_Service**: Bổ sung `TermId` cho `CreatePaymentLinkCommand`; gỡ bỏ ~456 dòng seed dữ liệu demo hardcode khỏi `Program.cs`.
- **V-Eval-Identity_Service**: Chuẩn hóa `DbInitializer.cs` (mật khẩu mặc định `Admin@2026`, không ghi đè mật khẩu khi restart).
- **Supabase Database**: Nạp trọn bộ 6 tầng dữ liệu thực tế cho 144 tài khoản (2 cơ sở, 20 giảng viên, 60 học sinh, 60 phụ huynh), chuyển `v_eval_enrollment` sang mô hình 2 đợt học và dọn sạch bản ghi hardcode cũ.
