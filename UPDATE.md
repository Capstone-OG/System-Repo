# Nhật Ký Cập Nhật (Update Log) - System Repo

## [09/10/2026] - Triển Khai Hoàn Hảo Module 2: Sổ Tay Lỗi Sai & Thuật Toán Lặp Lại Ngắt Quãng SM-2 (Practice Service)

- **Triển Khai Hoàn Tất Module 2 (Core Flow 3 - Interactive Learning)**:
  - Khởi tạo bảng CSDL `v_eval_practice."MistakeNotebooks"` và thực thể [`MistakeNotebook.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Domain/Entities/MistakeNotebook.cs) quản lý lỗi sai cá nhân của học sinh.
  - Tự động lưu câu sai (Luật sư phạm BR-15) khi học sinh làm sai ở bước `APPLY` của chặng học P-L-A-R, đặt lịch hẹn ôn tập ban đầu vào ngày hôm sau.
  - Hiện thực thuật toán lặp lại ngắt quãng SuperMemo-2 (SM-2): tính toán khoảng cách ngày ôn tập tiếp theo (+1, +3, +7 ngày...), tự động xóa sổ lỗ hổng tri thức (`IsMastered = true`) khi học sinh làm đúng liên tiếp 3 lần.
- **Hoàn Thiện 4 RESTful Endpoints Tại [`MistakesController.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.API/Controllers/MistakesController.cs)**:
  1. `GET /api/practice/mistakes`: Tra cứu Sổ tay lỗi sai cá nhân kèm bộ lọc và thống kê tổng số lỗi đã làm chủ / chưa làm chủ.
  2. `GET /api/practice/mistakes/daily-review`: Lấy các câu hỏi biến thể (*Isomorphic Question*) được lên lịch ôn tập cho ngày hôm nay qua Content gRPC.
  3. `POST /api/practice/mistakes/{id}/tag-error`: Phản tư nhận thức (*Metacognition*), gắn nhãn nguyên nhân sai sư phạm (`CARELESS`, `MISREAD_QUESTION`, `MISSING_CONCEPT`) kèm ghi chú bài học cá nhân.
  4. `POST /api/practice/mistakes/{id}/review-submit`: Nộp bài câu hỏi ôn tập, chấm điểm và tự động nâng khoảng cách lặp lại ngắt quãng SM-2.
- **Kiểm Thử Tự Động & Độ Tin Cậy**:
  - Đã chạy kiểm thử tự động toàn trình qua PowerShell đạt 100% 200 OK cho cả 4 APIs.
  - Toàn bộ Solution `V-Eval-Practice_Service.sln` biên dịch sạch 100% (**0 Warning, 0 Error**).
