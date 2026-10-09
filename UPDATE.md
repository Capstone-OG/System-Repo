# Nhật Ký Cập Nhật (Update Log) - System Repo

## [09/10/2026] - Tích Hợp Động Trực Tiếp Content Service Cho Nhánh Cứu Trợ (Remedial Node) & Hoàn Tất Module 2

- **Tích Hợp Động 100% Content Service Cho Gói Cứu Trợ (Remedial Node - BR-03)**:
  - Loại bỏ hoàn toàn mã hardcode Guid tĩnh trong câu hỏi và đáp án cứu trợ.
  - Phân phối câu hỏi cứu trợ từ Ngân hàng đề của Content Service qua gRPC (`GetMilestoneQuizAsync`), tự động loại trừ các câu hỏi đã làm ở các đợt trước để chống học vẹt và cấp bộ câu hỏi biến thể (*Isomorphic Questions*) mới khi học sinh làm lại.
  - Chấm điểm và đối soát đáp án, lời giải chi tiết trực tiếp từ CSDL của Content Service thông qua `GetQuestionDetailAsync`.
  - Khắc phục lỗi `DbUpdateConcurrencyException` của EF Core trong [`StageProgressRepository.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Infrastructure/Persistence/Repositories/StageProgressRepository.cs).
- **Hoàn Tất Module 2: Sổ Tay Lỗi Sai & Thuật Toán Lặp Lại Ngắt Quãng SM-2 (Mistake Notebook & Spaced Repetition)**:
  - Khởi tạo bảng CSDL `v_eval_practice."MistakeNotebooks"` và thực thể [`MistakeNotebook.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Domain/Entities/MistakeNotebook.cs) quản lý lỗi sai cá nhân của học sinh.
  - Tự động lưu câu sai (Luật sư phạm BR-15) khi học sinh làm sai ở bước `APPLY` của chặng học P-L-A-R, đặt lịch hẹn ôn tập ban đầu vào ngày hôm sau.
  - Hiện thực thuật toán SuperMemo-2 (SM-2): tính toán khoảng cách ngày ôn tập tiếp theo (+1, +3, +7 ngày...), tự động gắn cờ làm chủ (`IsMastered = true`) khi làm đúng liên tiếp 3 lần.
  - Hoàn thiện 4 RESTful Endpoints tại [`MistakesController.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.API/Controllers/MistakesController.cs): `GET /mistakes`, `GET /mistakes/daily-review`, `POST /mistakes/{id}/tag-error`, `POST /mistakes/{id}/review-submit`.
- **Kiểm Thử Trực Tiếp Hai Dịch Vụ Đang Chạy (Live Services)**:
  - Chạy đồng thời `Content Service` (Port 5249/5250) và `Practice Service` (Port 5261).
  - Kiểm thử qua Swagger và PowerShell: Chấm điểm bài cứu trợ trực tiếp từ Content Service đạt 100% chính xác, xoay vòng câu hỏi biến thể hoạt động hoàn hảo.
  - Biên dịch toàn bộ Solution `V-Eval-Practice_Service.sln` sạch 100% (**0 Warning, 0 Error**).
