# Nhật Ký Cập Nhật (Update Log) - System Repo

## [29/09/2026] - Triển Khai Hoàn Thiện API 5: Lấy Đề Thi Quiz Củng Cố Của Chặng Học & Tích Hợp gRPC Content Service

- **Hợp Đồng Giao Thức gRPC Liên Dịch Vụ (`content.proto`)**:
  - Mở rộng RPC `GetMilestoneQuiz` kết nối giữa Practice Service và Content Service.
  - Phía Content Service: Triển khai endpoint gRPC tự động sinh hoặc truy vấn đề thi củng cố theo `SkillId` hoặc `ExamId`, lưu vết `MockExams` và `ExamQuestions` cho việc chấm điểm sau này, đồng thời bảo mật tuyệt đối ẩn đáp án đúng.
- **Hoàn Thiện API 5 Trong Practice Service (`GET /api/v1/practice/roadmaps/nodes/{nodeId}/quiz`)**:
  - Triển khai `GetMilestoneQuizQuery` và `GetMilestoneQuizQueryHandler` theo chuẩn Clean Architecture và Result Pattern.
  - Tích hợp kiểm tra điều kiện tiên quyết: Yêu cầu học sinh xem $\ge 80\%$ thời lượng bài giảng lý thuyết trước (`IsVideoCompleted = true`), chặn `400 BadRequest` nếu chưa xem đủ.
  - Tích hợp bảo mật phân quyền (`403 Forbidden` khi truy cập chặng học sinh khác) và kiểm soát trạng thái máy chặng học (`LOCKED` / `SKIPPED_PRUNED`).
  - Tự động gắn kết và lưu trữ nguyên tử `QuizExamId` vào `RoadmapNode` trong CSDL Supabase PostgreSQL.
- **Mở Rộng Đặc Tả Core Flow 2 (Giai Đoạn 4 & 5 - APIs 14 đến 21)**:
  - Bổ sung phân hệ Quản trị Ngân hàng câu hỏi, Đề thi & Bài giảng video gốc cho **Academic Director** bên Content Service (APIs 14–19).
  - Bổ sung phân hệ Điều phối lớp học, Giám sát chuyên cần & Can thiệp sư phạm học sinh sa sút cho **Academic Manager** bên Practice Service (APIs 20–21).
- **Kiểm Thử Toàn Hệ Thống & Vận Hành Thực Tế**:
  - Cả hai solution `V-Eval-Content_Service.sln` và `V-Eval-Practice_Service.sln` biên dịch sạch 100% (**0 Warning, 0 Error**).
  - Vận hành kiểm thử thực tế đạt `200 OK` (trả về 5 câu hỏi có LaTeX và 4 phương án lựa chọn không lộ đáp án), `400 BadRequest` và `403 Forbidden` chuẩn xác.

