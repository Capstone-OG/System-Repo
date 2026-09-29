# Nhật Ký Cập Nhật (Update Log) - System Repo

## [29/09/2026] - Triển Khai Hoàn Thiện API 4: Ghi Nhận Tiến Độ Xem Video Lý Thuyết & Điều Kiện Mở Khóa Quiz

- **Hoàn Thiện API 4 (`POST /api/v1/practice/roadmaps/nodes/{nodeId}/track-video`)**:
  - Xây dựng hoàn chỉnh endpoint ghi nhận tiến độ xem bài giảng lý thuyết theo mô hình CQRS & Result Pattern.
  - Tích hợp quy tắc sư phạm mở khóa bài Quiz củng cố: Yêu cầu học sinh xem đạt tối thiểu 80% thời lượng bài giảng lý thuyết (`watchPercentage >= 80.0` -> `IsVideoCompleted = true`, `IsQuizEligible = true`).
  - Kiểm soát bảo mật phân quyền: Chặn học sinh cập nhật tiến độ chặng học của người khác (`403 Forbidden`).
  - Kiểm soát trạng thái chặng học (State Machine): Chặn ghi nhận nếu chặng đang bị khóa (`LOCKED` -> `400 BadRequest`) hoặc đã được cắt tỉa (`SKIPPED_PRUNED` -> `400 BadRequest`).
- **Nâng Cấp CSDL & EF Core Mapping**:
  - Bổ sung 3 trường `video_watched_seconds`, `video_total_seconds`, `is_video_completed` vào bảng `v_eval_practice."RoadmapNodes"` trên Supabase PostgreSQL.
- **Kiểm Thử Toàn Hệ Thống & Vận Hành Thực Tế**:
  - Solution `V-Eval-Practice_Service.sln` biên dịch sạch 100% (**0 Warning, 0 Error**).
  - Vận hành kiểm thử thực tế đạt `200 OK`, `400 BadRequest` và `403 Forbidden` chuẩn xác theo các kịch bản.
