# Nhật Ký Cập Nhật (Update Log) - System Repo

## [28/09/2026] - Hợp Nhất Toàn Diện Hệ Thống: Core Flow 1 (Bloom 6 Cấp, AI Exam Studio & Khóa Đề 24h) & Core Flow 2 (Textbook RAG Streaming, DAG Seeding & Graph Engine 4 Thuật Toán)

- **Hợp Nhất Toàn Diện Toàn Bộ Hệ Thống Microservices**:
  - Hợp nhất thành công mã nguồn và đồng bộ hóa tài liệu tiến độ giữa các nhánh tính năng (`ThinhTT/feat-diagnostic-exam-studio-bloom-flow`) và nhánh `develop` trên toàn bộ các dịch vụ: AI Engine, Content Service, Practice Service và System Repo.
- **Core Flow 1 — Khảo Sát Năng Lực Đầu Vào, Psychometrics IRT & AI Exam Studio**:
  - **Chuẩn Hóa Thang Đo Tư Duy Bloom 6 Mức Độ**:
    - Nâng cấp mô hình IRT 2PL ánh xạ độ khó $b \in [-1.8, +2.2]$ tương ứng 6 cấp độ Bloom (Nhận biết $\rightarrow$ Sáng tạo).
    - Cập nhật schema dữ liệu và phân tích tỷ lệ theo Bloom trên cả AI Engine, Content Service và Practice Service.
  - **Động Cơ Sinh Đề Kép (Dual-Engine AI Exam Studio)**:
    - Endpoint `POST /api/v1/diagnostic/generate-exam` hỗ trợ 2 chế độ: *Gemini Live Cloud* (sinh mới theo prompt, chuẩn LaTeX, cân đối đáp án A/B/C/D) và *Fast Calibrated Bank* (< 0.1s offline fallback).
    - Tự động nhận diện ý định lĩnh vực (Toán, Văn, Logic, KHTN, KHXH) từ prompt và ưu tiên tuyệt đối lựa chọn Dropdown của giáo viên.
  - **Giao Diện Khảo Sát Năng Lực Trực Quan (Web Runner UI)**:
    - Triển khai giao diện web độc lập `view-diagnostic.html` (3 Tab: AI Exam Studio, Phòng thi học sinh với Demo Solver, Báo cáo năng lực & Radar Chart).
    - Quy trình lưu đề chờ duyệt (`IsPublished = false`) và phê duyệt xuất bản (`IsPublished = true`).
  - **Xử Lý Kịch Bản Ngoại Lệ (Unhappy Case 2: Bài Thi Hết Hạn 24 Giờ)**:
    - Phát hiện bài thi bỏ dở > 24h, ghi nhận `Status = "EXPIRED"`, khóa đề và bảo vệ độ tin cậy tham số $\theta_0$.
    - Bổ sung tham số `excludeExamId` trong `GET /api/v1/content/diagnostic-test` cho phép học sinh nhận bộ đề ngẫu nhiên thay thế.
- **Core Flow 2 — Nạp Tri Thức SGK, Đồ Thị Kỹ Năng DAG & Lập Lộ Trình Học Tập Cá Nhân Hóa (Path Planning)**:
  - **Tối Ưu Pipeline Nạp SGK & CryptoStream Streaming (AI Engine)**:
    - Ghi file và tính băm SHA-256 song song qua `CryptoStream` 1 lượt duy nhất, giảm 50% I/O đĩa máy chủ cho file PDF nặng (100MB-250MB).
    - Tự động dọn dẹp file trùng lặp; chuẩn hóa danh mục mô hình Vision AI Gemini 3.x; cấu hình timeout linh hoạt qua `appsettings.json`.
  - **Thực Thể SkillPrerequisites & Seeding Đồ Thị DAG (Content Service)**:
    - Bổ sung entity `SkillPrerequisite` với khóa chính phức hợp `(skill_id, prerequisite_id)`.
    - Tự động seed 12 kỹ năng chuẩn ĐGNL ĐHQG-HCM và 9 cung quan hệ tiên quyết DAG không chu trình; cung cấp RPC `GetSkillsTree`.
  - **Lộ Trình Học Tập & 4 Thuật Toán Đồ Thị Graph Engine (Practice Service)**:
    - Khởi tạo thực thể `LearningRoadmap`, `RoadmapNode`, `LiveSession`, `LiveSessionAttendance`.
    - Triển khai 4 thuật toán cốt lõi:
      1. [`TarjanCycleDetector.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Application/Common/Graph/TarjanCycleDetector.cs): Thuật toán Tarjan SCC phát hiện chu trình kín trong đồ thị tiên quyết.
      2. [`PathPruner.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Application/Common/Graph/PathPruner.cs): Cắt tỉa 3 tầng thông minh (trọng số < 5%, năng lực $P(L_0) \ge 85\%$, dồn trọng tâm khi thời gian < 30 ngày).
      3. [`TopologicalSorter.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Application/Common/Graph/TopologicalSorter.cs): Sắp xếp topo thứ tự học tập theo logic sư phạm với PriorityQueue đa tiêu chí.
      4. [`MilestoneBinder.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Application/Common/Graph/MilestoneBinder.cs): Đóng gói chặng học 3 thành phần (Video + Quiz + Live Q&A) và khởi tạo State Machine.
- **Kiểm Thử & Biên Dịch Toàn Hệ Thống**:
  - Tất cả các service (.NET 9 C# và Python FastAPI) biên dịch sạch 100% (**0 Warning, 0 Error**).
