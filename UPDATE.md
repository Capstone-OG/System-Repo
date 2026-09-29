# Nhật Ký Cập Nhật (Update Log) - System Repo

## [29/09/2026] - Triển Khai Hoàn Thiện API 1, 2, 3: Khởi Tạo Lộ Trình, Timeline Cá Nhân Hóa & Chi Tiết Chặng Học 3 Thành Phần

- **Hoàn Thiện API 1 (`POST /api/v1/practice/roadmaps/generate`)**:
  - Xây dựng hoàn chỉnh endpoint theo chuẩn Clean Architecture và Result Pattern, điều phối 7 bước nghiệp vụ.
  - Tích hợp 4 thuật toán đồ thị: Tarjan SCC, Path Pruner 3 tầng, Kahn Topological Sort với Priority Queue sư phạm, Milestone Binder tích hợp 3 thành phần Video - Quiz - Live.
  - Phân nhóm chặng học theo từng Miền năng lực (`stages`), bảo toàn thứ tự `stepOrder` sư phạm.
- **Hoàn Thiện API 2 (`GET /api/v1/practice/roadmaps/my-roadmap`)**:
  - Xây dựng endpoint tra cứu dòng thời gian lộ trình `ACTIVE` của học sinh.
  - Cung cấp đầy đủ thông tin: Tiến độ phần trăm (`ProgressPercentage`), cấu trúc `Stages` gom nhóm theo Miền năng lực và danh sách `Nodes` toàn diện.
- **Hoàn Thiện API 3 (`GET /api/v1/practice/roadmaps/nodes/{nodeId}`)**:
  - Xây dựng endpoint tra cứu chi tiết 1 chặng học (Milestone / RoadmapNode).
  - Trả về chi tiết 3 thành phần: Bài giảng lý thuyết video (`materialId`), Bài Quiz củng cố (`quizExamId`), và Buổi học Live Q&A (`liveSession`).
  - Tích hợp bảo mật phân quyền: chặn học sinh truy cập trái phép chặng học của học sinh khác (`403 Forbidden`).
- **Kiểm Thử Toàn Hệ Thống & Vận Hành Thực Tế**:
  - Cả hai solution `V-Eval-Practice_Service.sln` và `V-Eval-Content_Service.sln` biên dịch sạch 100% (**0 Warning, 0 Error**).
  - Vận hành kiểm thử thực tế đạt `200 OK` trọn vẹn cả 3 API trên Swagger.
