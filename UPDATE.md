# Nhật Ký Cập Nhật (Update Log) - System Repo

## [08/10/2026] - Triển Khai Hoàn Tất Core Flow 3: API 3 - Ghi Nhận Tiến Độ Video & Mở Khóa Bước APPLY (TrackVideo)

- **Hiện Thực Hoàn Tất API 3 Cho Chu Trình P-L-A-R (Practice Service)**:
  - Bổ sung endpoint `POST /api/practice/stages/{stageProgressId}/track-video` trong [`StagesController.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.API/Controllers/StagesController.cs).
  - Hoàn thiện CQRS Command `TrackVideoCommand` và Handler `TrackVideoCommandHandler`.
  - Kiểm tra trạng thái máy trạng thái (State Machine): Xác thực tỷ lệ thời lượng xem video bài giảng lý thuyết; khi học sinh xem đạt $\ge 80\%$, tự động chuyển `CurrentStep = "APPLY"` và đồng bộ `IsVideoCompleted = true` sang `RoadmapNode`.
  - Cập nhật tài liệu tiến độ và nghiệm thu kiến trúc chuẩn hóa Markdown Editor Plus:
    - [`All Services/V-Eval-Practice_Service/docs/architecture_acceptance.md`](./All%20Services/V-Eval-Practice_Service/docs/architecture_acceptance.md) (Mục 7.4).
    - [`All Services/V-Eval-Practice_Service/docs/daily.md`](./All%20Services/V-Eval-Practice_Service/docs/daily.md)
    - [`All Services/V-Eval-Practice_Service/docs/process.md`](./All%20Services/V-Eval-Practice_Service/docs/process.md) (STT 49).
  - Đã chạy kiểm thử trực tiếp trên Service API: Kết quả trả về `200 OK`, chuyển trạng thái thành công sang bước `APPLY` (83.33% thời lượng).
  - Toàn bộ Solution `V-Eval-Practice_Service.sln` biên dịch sạch 100% (**0 Warning, 0 Error**).
