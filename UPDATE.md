# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [07/11/2026] - Hoàn Tất Chuẩn Hóa 40 Sơ Đồ Chi Tiết (Figure 18 - Figure 57) Phần IV SDD & Rà Soát Phân Hệ 3.7

- **Chuẩn hóa toàn bộ mục `IV.3 Detailed Design` trong [`docs/report_tong_chuan_hoa.md`](./docs/report_tong_chuan_hoa.md) khớp 100% quy chuẩn 1-đối-1 báo cáo mẫu Đồ án Tốt nghiệp FPTU (`6819_HCM_FA25SE208_GFA67_Final_Report.docx`)**:
  - Tách 7 Phân hệ quản lý (`3.1 -> 3.7`) thành **20 chức năng cốt lõi độc lập = 40 sơ đồ (`20 Class Diagrams` số lẻ + `20 Sequence Diagrams` số chẵn từ `Figure 18` đến `Figure 57`)**, bóc tách chi tiết từng hộp/thuộc tính/phương thức từ code C# thực tế.
  - **Rà soát & đối chiếu toàn bộ Phân hệ 3.7 (Multi-Campus Cohort, Heatmap & Early Warning Management)**:
    - `3.7.1 & 3.7.2` (Figure 52 & 53): Tự động phân lớp theo cụm năng lực đầu vào (`StudentKMeansClusterer` - Constrained K-Means phân tầng `FOUNDATIONAL`, `STANDARD`, `INTENSIVE`).
    - `3.7.3 & 3.7.4` (Figure 54 & 55): Khảo sát ma trận nhiệt năng lực lớp học theo mô hình Cache-Aside (`IClassHeatmapCacheService` với `IMemoryCache` nội bộ và chuẩn phân tán Redis 7).
    - `3.7.5 & 3.7.6` (Figure 56 & 57): Hệ thống cảnh báo sớm 3 cấp độ (`TIER_1 / 2 / 3`), phân định rõ luồng chạy ngầm của Worker định kỳ (`EarlyWarningSweepWorker`) và API giao diện của Mentor (`EarlyWarningsController`).
  - **Đối chiếu mã nguồn toàn hệ thống & hoàn thiện Checklist 7 hạng mục hoàn thiện code** ở cuối Phần IV (`Companion Mobile App`, `Thanh toán gói học`, `LinkParentStudentCommand`, `Email OTP`, `Duyệt câu hỏi Academic Director`, `Webcam Proctoring`, và `Dispatcher cảnh báo sớm đa kênh`), bảo toàn 100% văn bản Tiếng Anh chuẩn SDD sẵn sàng nộp.
