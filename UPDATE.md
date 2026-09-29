# Nhật Ký Cập Nhật (Update Log) - System Repo

## [29/09/2026] - Triển Khai Hoàn Thiện API 7: Nộp Bài Quiz Bù Cho Học Sinh Vắng Mặt Buổi Live Q&A & Giải Phóng Phong Tỏa Chặng

- **Hoàn Thiện API 7 Trong Practice Service (`POST /api/v1/practice/roadmaps/nodes/{nodeId}/submit-makeup-quiz`)**:
  - Triển khai trọn vẹn kịch bản ngoại lệ **Unhappy Case 3 (Absenteeism Fallback)**: Quản lý học sinh có trạng thái điểm danh buổi Live Q&A cơ sở là `ABSENT`.
  - Kiểm tra điều kiện tiên quyết xem video lý thuyết $\ge 80\%$ (`IsVideoCompleted = true`) và trạng thái điểm danh `ABSENT` (chặn `400 BadRequest` nếu vi phạm).
  - Tự động nạp đề Quiz bù và lấy bảng đáp án gốc bảo mật từ Content Service qua gRPC `GetExamAnswerKeys`.
  - Chấm điểm vi mô từng câu, ghi nhận bản ghi làm bài vào `ExamSubmissions` (`ExamType = "MAKEUP_QUIZ"`).
  - **Cơ Chế Máy Trạng Thái Hữu Hạn Liên Hoàn (Dual-Key State Machine Unlock)**:
    - Khi học sinh đạt điểm $\ge 60\%$ (`IsMakeupQuizPassed = true`) VÀ đã đạt bài Quiz củng cố chuyên đề (`node.IsQuizPassed = true`): Hệ thống chính thức gỡ bỏ điều kiện phong tỏa do vắng mặt, đánh dấu chặng `Status = "COMPLETED"`, cập nhật `CompletedAt = UtcNow`, tăng `roadmap.CompletedMilestones++` và tự động tìm chặng `LOCKED` tiếp theo mở khóa thành `IN_PROGRESS` (`UnlockedAt = UtcNow`).
    - Nếu trượt bài Quiz bù ($< 60\%$): Chặng tiếp tục giữ `IN_PROGRESS`, nhắc học sinh xem lại video ghi hình buổi Live (`recording_url`) và làm lại bài Quiz bù.
- **Tích Hợp Kiểm Soát Chặt Chẽ Tại API 6**:
  - Cập nhật [SubmitMilestoneQuizCommandHandler.cs](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Application/Features/Roadmaps/Commands/SubmitMilestoneQuiz/SubmitMilestoneQuizCommandHandler.cs): Nếu học sinh làm Quiz củng cố đạt 100% nhưng đang bị `ABSENT` buổi Live, hệ thống không mở khóa chặng ngay mà yêu cầu hoàn thành thêm bài Quiz bù.
- **Kiểm Thử Toàn Hệ Thống & Vận Hành Thực Tế (Live End-to-End Test)**:
  - Solution `V-Eval-Practice_Service.sln` biên dịch sạch 100% (**0 Warning, 0 Error**).
  - Kiểm thử trực tiếp 5 kịch bản qua REST API & gRPC:
    1. Chặn khi chưa xem đủ 80% video lý thuyết: Trả về `400 BadRequest` chuẩn xác.
    2. Chặn khi học sinh không thuộc diện `ABSENT`: Trả về `400 BadRequest` chuẩn xác.
    3. Nộp bài Quiz củng cố khi đang bị `ABSENT`: Ghi nhận 100% điểm quiz củng cố nhưng State Machine chặn không cho hoàn thành chặng (chờ Quiz bù).
    4. Nộp bài Quiz bù điểm dưới 60%: Trả về `scorePercentage: 0%`, `isPassed: false`, chặng học giữ `IN_PROGRESS`.
    5. Nộp bài Quiz bù đạt chuẩn $\ge 60\%$ (100%): Gỡ bỏ hoàn toàn phong tỏa chặng, Node 2 ("Đại số, Hàm số & Giải tích") chuyển thành `COMPLETED`, tự động mở khóa Node 3 ("Ngữ pháp & Logic câu Tiếng Việt") thành `IN_PROGRESS`, `CompletedMilestones` tăng lên 2/437!
