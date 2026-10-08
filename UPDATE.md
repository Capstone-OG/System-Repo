# Nhật Ký Cập Nhật (Update Log) - System Repo

## [08/10/2026] - Triển Khai Hoàn Tất Core Flow 3: API 4 - Động Cơ Bốc Câu Hỏi Thích Ứng IRT 2PL Trong Vùng ZPD (NextQuestion)

- **Hiện Thực Hoàn Tất API 4 Cho Chu Trình P-L-A-R (Practice Service)**:
  - Xây dựng động cơ thích ứng [`ZpdQuestionSelector.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Application/Common/Adaptive/ZpdQuestionSelector.cs) dựa trên mô hình IRT 2PL và bộ lọc vùng phát triển gần nhất (ZPD: $P \in [0.60, 0.75]$).
  - Bổ sung endpoint `GET /api/practice/stages/{stageProgressId}/next-question` trong [`StagesController.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.API/Controllers/StagesController.cs).
  - Hoàn thiện CQRS Query `GetNextQuestionQuery` và Handler `GetNextQuestionQueryHandler`.
  - Kiểm tra trạng thái máy trạng thái (State Machine): Xác thực chặng đang ở `APPLY`, loại trừ câu hỏi đã làm, ẩn đáp án đúng, xử lý kiểm soát nhánh phụ đạo BR-03 và hoàn thành chặng.
  - Cập nhật tài liệu tiến độ và nghiệm thu kiến trúc chuẩn hóa Markdown Editor Plus:
    - [`All Services/V-Eval-Practice_Service/docs/architecture_acceptance.md`](./All%20Services/V-Eval-Practice_Service/docs/architecture_acceptance.md) (Mục 7.5).
    - [`All Services/V-Eval-Practice_Service/docs/daily.md`](./All%20Services/V-Eval-Practice_Service/docs/daily.md)
    - [`All Services/V-Eval-Practice_Service/docs/process.md`](./All%20Services/V-Eval-Practice_Service/docs/process.md) (STT 50).
  - Đã chạy kiểm thử trực tiếp trên Service API: Kết quả trả về `200 OK`, bốc đúng câu hỏi phù hợp năng lực khởi đầu $P(L_t) = 0.10$ thành công 100%.
  - Toàn bộ Solution `V-Eval-Practice_Service.sln` biên dịch sạch 100% (**0 Warning, 0 Error**).
