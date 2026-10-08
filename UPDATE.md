# Nhật Ký Cập Nhật (Update Log) - System Repo

## [08/10/2026] - Triển Khai Hoàn Tất Core Flow 3: API 2 - Nộp Bài Quick Check & Chuyển Bước LEARN (SubmitPreview)

- **Hiện Thực Hoàn Tất API 2 Cho Chu Trình P-L-A-R (Practice Service)**:
  - Bổ sung endpoint `POST /api/practice/stages/{stageProgressId}/preview-submit` trong [`StagesController.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.API/Controllers/StagesController.cs).
  - Hoàn thiện CQRS Command `SubmitPreviewCommand` và Handler `SubmitPreviewCommandHandler`.
  - Kiểm tra trạng thái máy trạng thái (State Machine): Xác thực chặng đang ở `PREVIEW`, chấm điểm 3 câu Quick Check và kích hoạt chuyển bước `CurrentStep = "LEARN"`.
  - Cập nhật tài liệu tiến độ và nghiệm thu kiến trúc chuẩn hóa Markdown Editor Plus:
    - [`All Services/V-Eval-Practice_Service/docs/architecture_acceptance.md`](./All%20Services/V-Eval-Practice_Service/docs/architecture_acceptance.md) (Mục 7.3).
    - [`All Services/V-Eval-Practice_Service/docs/daily.md`](./All%20Services/V-Eval-Practice_Service/docs/daily.md)
    - [`All Services/V-Eval-Practice_Service/docs/process.md`](./All%20Services/V-Eval-Practice_Service/docs/process.md) (STT 48).
  - Đã chạy kiểm thử trực tiếp trên Service API: Kết quả trả về `200 OK`, chuyển trạng thái thành công sang bước `LEARN`.
  - Biên dịch toàn bộ Solution `V-Eval-Practice_Service.sln` sạch 100% (**0 Warning, 0 Error**).
