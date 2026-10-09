# Nhật Ký Cập Nhật (Update Log) - System Repo

## [09/10/2026] - Hiện Thực Nhánh Cứu Trợ Phụ Đạo (Remedial Node) Động Theo Ngân Hàng Đề Content Service

- **Khép Kín Toàn Diện Vòng Lặp Sư Phạm P-L-A-R (Practice Service)**:
  - Bổ sung 2 APIs trong [`StagesController.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.API/Controllers/StagesController.cs):
    1. `GET /api/practice/stages/{stageProgressId}/remedial`: Lấy gói cứu trợ phụ đạo (Remedial Node) gồm video clip, tóm tắt phương pháp cốt lõi và 3 câu hỏi cơ bản ($b < 0.0$) bốc trực tiếp từ Ngân hàng đề của `Content Service` qua gRPC.
    2. `POST /api/practice/stages/{stageProgressId}/remedial-submit`: Nộp bài cứu trợ, chấm điểm, reset chuỗi sai liên tiếp (`ConsecutiveIncorrect = 0`) và khôi phục trạng thái `IN_PROGRESS` để học sinh tiếp tục bước `APPLY`.
- **Loại Bỏ Hardcode & Tích Hợp Động Ngân Hàng Đề**:
  - Tự động lấy câu hỏi thuộc đúng kỹ năng/chuyên đề (`SkillId`) từ Content Service qua `IContentGrpcClient`.
  - Sinh tóm tắt lý thuyết, công thức cốt lõi tương ứng với chuyên đề đang hổng.
  - Hỗ trợ cơ chế dự phòng an toàn (Fallback Graceful Degradation) khi tạm ngắt kết nối gRPC.
- **Kiểm Thử Biên Dịch**:
  - Toàn bộ Solution `V-Eval-Practice_Service.sln` biên dịch sạch 100% (**0 Warning, 0 Error**).
