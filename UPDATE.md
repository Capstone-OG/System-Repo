# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [26/10/2026] - Hoàn Tất Nghiệm Thu Toàn Diện 74/74 Mối Quan Hệ CSDL V-Eval (Schema V4.1), Đồng Bộ Báo Cáo Kiến Trúc & Chuẩn Hóa MD Editor Plus

- **Nghiệm Thu Toàn Diện 100% (74/74) Mối Quan Hệ Thực Thể trong Báo Cáo Kiểm Định CSDL**:
  - Hoàn tất rà soát, đánh dấu `[x] Nghiệm thu` cho toàn bộ 74 mối quan hệ (42 Khóa ngoại vật lý nội bộ + 32 Tham chiếu logic liên Service) trong [`docs/SQL/Tong_Quan_Chi_Tiet_Moi_Quan_He_Entities.md`](./docs/SQL/Tong_Quan_Chi_Tiet_Moi_Quan_He_Entities.md).
  - Phân tích chi tiết từng cặp bản số (`1-0`, `1-1`, `1-N`, `0-0`, `0-1`) trực tiếp tại bảng Master Matrix và 11 phân mục giải trình kiến trúc chuyên sâu.

- **Nghiệm Thu Đợt Cuối (STT 51 Đến STT 74) - Lõi Nghiệp Vụ Khảo Thí & Thích Ứng Cá Nhân Hóa**:
  - **STT 51–55 (Khảo thí & Lộ trình học thích ứng P-L-A-R)**: Câu trả lời bài thi (`SubmissionAnswers`), lộ trình cá nhân hóa (`LearningRoadmaps`), chặng học kỹ năng (`RoadmapNodes`), cơ chế Dual-Video tiên quyết/bài giảng song song (`Materials`), và đề thi container vượt chặng (`MockExams`).
  - **STT 56–58 (Tiến trình chặng học & Vector Năng lực BKT)**: `StageProgress` theo chu trình 4 bước P-L-A-R; `LearningProfiles` lưu trữ theo từng kỹ năng `UNIQUE(student_id, skill_id)` phục vụ phân nhóm vi mô `ClassMicroClusterer`.
  - **STT 59–60 (Vòng lặp Luyện tập thích ứng ZPD & BKT)**: `AdaptiveQuizAttempts` ghi nhận từng lượt nộp đáp án thích ứng cho 1 câu hỏi, tính toán xác suất đoán mò và cập nhật P(Lt).
  - **STT 61–63 (Sổ tay lỗi sai & Thuật toán SM-2)**: `MistakeNotebooks` lưu trữ chính xác cho từng câu hỏi làm sai `UNIQUE(student_id, question_id)`, điều khiển bởi thuật toán lặp lại ngắt quãng SuperMemo-2 (`ease_factor`, `interval_days`), gán `skill_id` để lọc sổ tay và tính mật độ lỗi sai.
  - **STT 64 (Dự báo điểm số chuỗi thời gian SEM & Toa thuốc Knapsack ROI)**: `ScorePredictions` là bảng chuỗi thời gian Append-Only (không ghi đè); mỗi lần thi thử 120/150 câu hoặc hoàn thành bài tập bù điểm, hệ thống INSERT 1 dòng mới để vẽ Biểu đồ xu hướng tiến bộ điểm số (Trendline) và lưu vết sự thu hẹp sai số đo lường SEM.
  - **STT 65–66 (Hệ thống Cảnh báo Sớm 3 Cấp BR-04 & Phân quyền xử lý)**: `SystemAlerts` phân loại 3 mức (Xanh, Vàng, Đỏ / Mục tiêu ảo); trường `handled_by` trỏ về `Users.user_id` để cả Giáo viên (`Teachers`) và Quản lý học vụ (`AcademicManagers`) đều có thể tiếp nhận can thiệp sư phạm.
  - **STT 67–69 (Ma trận Nhiệt Lớp học & Cảnh báo Sư phạm Bimodal)**: `ClassSkillHeatmaps` lưu từng ô lưới `UNIQUE(class_id, student_id, skill_id)`; `ClassHeatmapSummaries` tổng kết chân cột kỹ năng `UNIQUE(class_id, skill_id)` và phát hiện phân hóa 2 cực `is_bimodal` để gợi ý chia nhóm vi mô.
  - **STT 70–71 (Hoạt động học tập & Chỉ số Sẵn sàng thi)**: `StudentDailyActivities` lưu nhật ký và chuỗi Streak; `StudentReadinessMetrics` ràng buộc `UNIQUE(student_id)` lưu duy nhất 1 bản ghi tổng hợp 4 trụ cột (Tri thức, Tâm lý, Thời gian, Sức bền) để hiển thị Radar Chart.
  - **STT 72–74 (Tích hợp AI Engine & Trợ giảng AI Socratic)**: `archetype_patterns` là mức đào sâu chi tiết của kỹ năng; `ai_tutor_interaction_logs` lưu nhật ký hội thoại Socratic neo vào đúng câu hỏi làm sai (`question_id`), kiên quyết không giải hộ mà gợi mở tư duy (Scaffolding).

- **Chuẩn Hóa 100% Quy Cách Hiển Thị Markdown (MD Editor Plus Compatible)**:
  - Loại bỏ hoàn toàn đường dẫn tuyệt đối `file:///` trong Markdown, chuyển sang đường dẫn tương đối `./`.
  - Bọc công thức và ký hiệu toán học/trắc lượng trong backtick inline code, tránh lỗi escape ký tự.
  - Chuẩn hóa toàn bộ sơ đồ Mermaid theo cú pháp Mermaid 11.15.0+ (bọc ngoặc kép tên node, không dùng liên kết gộp `&`).
