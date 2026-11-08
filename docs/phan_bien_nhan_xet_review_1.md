# PHẢN BIỆN & ĐỐI CHIẾU NHẬN XÉT REVIEW 1 - HỆ THỐNG V-EVAL

> [!NOTE]
> Tài liệu đối chiếu từng góp ý trong [Nhận Xét Review 1.docx](./Nhận%20Xét%20Review%201.docx) với hiện trạng mã nguồn thực tế (tính đến 22/10/2026).
> Mục đích: (1) chứng minh các hạng mục **đã triển khai**, (2) nêu lý do **không phù hợp / không triển khai**, (3) minh bạch các hạng mục **còn trong kế hoạch**.

---

## 0. QUY ƯỚC TRẠNG THÁI

| Ký hiệu | Ý nghĩa |
| :---: | :--- |
| ✅ | **Đã triển khai** - có code, API và dữ liệu chạy được |
| 🟡 | **Triển khai một phần / Điều chỉnh** - đã làm phần lõi, có thay đổi so với góp ý |
| ⛔ | **Không phù hợp - Không triển khai** - có lập luận phản biện |
| ⏳ | **Chưa triển khai** - đồng ý với góp ý, đưa vào kế hoạch giai đoạn sau |

---

## 1. BẢNG TỔNG HỢP NHANH

| Flow | Góp ý của Hội đồng | Trạng thái | Minh chứng / Lý do ngắn |
| :---: | :--- | :---: | :--- |
| 1 | Ngữ cảnh đề chuẩn 120 câu, test rút gọn 30 câu | ✅ | `GET /api/content/diagnostic-test`, chấm thang 30 |
| 1 | Mục tiêu trường/ngành, tra điểm chuẩn 3 năm | 🟡 | Có `TargetScore`, `ExamDate`; chưa có bảng điểm chuẩn ngành |
| 1 | Hồ sơ năng lực IRT 2PL + BKT + thời gian làm bài | ✅ | `diagnostic_engine.py`, `BktEngine.cs` |
| 1 | Dùng điểm học bạ lớp 11-12 | ⛔ | Thang điểm không chuẩn hóa giữa các trường |
| 1 | Bóc tách môn mạnh/yếu, ZPD, điểm có thể tăng | ✅ | `WeakSkillIds`, Radar, ZPD `[0.60, 0.75]`, Knapsack ROI |
| 1 | Tự động phân loại lỗi cẩu thả / hổng kiến thức | 🟡 | Có nhãn `CARELESS`, `MISSING_CONCEPT` nhưng do học sinh tự gắn |
| 1 | Form khảo sát phụ huynh 3 phút | ⛔ | Dữ liệu tự khai thiếu tin cậy, thay bằng dữ liệu hành vi |
| 2 | Tư vấn chọn trường 3 giỏ Reach/Target/Safety | ⛔ | Ngoài phạm vi, rủi ro trách nhiệm tư vấn tuyển sinh |
| 2 | Tách Lead Mentor / Subject Mentor | 🟡 | Mô hình 1 Teacher / lớp 20 HS + Academic Manager |
| 2 | Workshop chung + Micro-coaching | 🟡 | Có nhóm vi mô + phát đề; bỏ Live Session (chuyển offline) |
| 2 | Mentor đồng hành từ đầu, Kickoff, duyệt lộ trình | 🟡 | Có Dashboard cảnh báo; Kickoff là nghiệp vụ ngoài hệ thống |
| 2 | Gom nhóm Micro-cohort theo năng lực | ✅ | K-Means++ / Elbow + `ClassMicroClusterer` (3-5 HS) |
| 3 | Chu trình P-L-A-R | ✅ | 6 API `StagesController` + State Machine |
| 3 | Vòng lặp chấm bài, BKT, Spaced Repetition biến thể | ✅ | SM-2 + Isomorphic + Mastery `>= 0.85` |
| 3 | Phòng tự học ảo Pomodoro check-in | ⛔ | Trùng mô hình học tập trung offline, dễ gian lận check-in |
| 3 | Báo cáo tuần gửi phụ huynh qua App/Email | ⏳ | Đưa vào Core Flow 5 |
| 3 | Thi thử 120 câu / 150 phút / chống gian lận | ✅ | 6 API `MockExamsController` + Mentor review |
| 4 | Gemini Vision bóc đề + phát hiện dạng mới | ✅ | `novelty_detector.py` cosine 0.75 + duyệt Academic |
| 4 | Taxonomy 4 tầng + câu mẫu + bẫy | ✅ | `archetype_patterns`, `pattern_exemplars`, `pattern_traps` |
| 4 | Strict Grounding + Socratic Guardrails | ✅ | Hybrid GraphRAG fail-closed + Socratic Engine |
| 4 | Kiểm chứng 2 tầng (LLM-as-a-Judge + Mentor) | ✅ | `validator_judge.py` + báo cáo sai + override |
| 5 | Phát hiện bất thường học tập | 🟡 | Có phát hiện đoán mò `< 5s`; phần còn lại ở Core Flow 5 |
| 5 | Remedial Sprint 48h | 🟡 | Có gói cứu trợ BR-03 tự động; chưa có bước Mentor duyệt |
| 5 | Kỷ luật 3 cấp | ⏳ | Đã đặc tả BR-18, chưa code |
| 6 | Dự báo khoảng điểm thay vì con số | ✅ | Dải SEM 95% `[Min, Max]` |
| 6 | Kiểm chứng K-Fold, MAE | ⏳ | Chờ dữ liệu thi thử thật |
| 6 | XGBoost/LightGBM + ONNX | ⛔ | Cold-start: chưa có dữ liệu thật để huấn luyện |
| 6 | Phân loại Xanh/Vàng/Đỏ + Mentor can thiệp | ✅ | `SystemAlert` + Resolve + Counseling 3 bên |
| 6 | Chỉ đích danh 1-2 dạng bài cần ôn | ✅ | Toa thuốc Knapsack ROI 2-3 dạng bài |

**Thống kê**: ✅ 14 mục · 🟡 7 mục · ⛔ 5 mục · ⏳ 3 mục (tổng 29 mục góp ý).

---

## 2. CHI TIẾT THEO TỪNG FLOW

### FLOW 1: CHẨN ĐOÁN NĂNG LỰC BAN ĐẦU & HỒ SƠ HỌC TẬP

#### 1.1 Ngữ cảnh tổ chức bài thi - ✅ ĐÃ TRIỂN KHAI
- Đề chẩn đoán rút gọn **30 câu** giữ tỉ lệ các phần thi, seed tự động (`DiagnosticExamSeeder.cs`).
- Bảo mật đề: `DiagnosticExamDto` loại bỏ `CorrectOption` và `Explanation` (Anti-cheat).
- Khóa đề khi bỏ dở quá 24h, đánh dấu `EXPIRED`, chống nộp lại (Unhappy Case 2).
- Phân hóa theo ngành thể hiện qua `TargetScore` khi lập lộ trình, đúng như góp ý.

#### 1.2 Mục tiêu trường & ngành học - 🟡 MỘT PHẦN
- **Đã có**: `Student.TargetScore`, `ExamDate`, `StudyHoursDay`, `SchoolName` (Identity Service).
- **Đã có**: Cảnh báo `UNREALISTIC_GOAL` khi mục tiêu vượt ngưỡng khả thi + API hẹn tư vấn 3 bên.
- **Chưa có**: Bảng điểm chuẩn ĐGNL 3 năm theo trường/ngành để AI gợi ý Target Score.
- **Phản biện**:
  - Điểm chuẩn ĐGNL theo ngành thay đổi mỗi năm, phụ thuộc chỉ tiêu và phương thức xét tuyển kết hợp.
  - Đưa con số "Bách Khoa = 920" vào hệ thống dễ tạo kỳ vọng sai; nhóm chọn để Mentor nhập/xác nhận `TargetScore`.
  - Có thể bổ sung bảng tra cứu tham khảo (Academic cập nhật thủ công) nếu Hội đồng yêu cầu.

#### 1.3 Cơ sở xác định năng lực & lập Profile - ✅ ĐÃ TRIỂN KHAI (trừ học bạ)
- IRT 2PL ước lượng `θ₀` bằng MAP/Brent, BKT khởi tạo `P(L₀)` theo từng kỹ năng (`diagnostic_engine.py`).
- Ghi nhận `time_spent_seconds` từng câu (`submission_answers`).
- Phạt đoán mò: đúng nhưng `< 5s` với câu khó `b >= 0.50` thì `P(Guess)` tăng lên 0.60 (`BktEngine.cs`).
- Radar Chart so sánh `StudentPct` với `BenchmarkPct` + nhận xét Gemini.
- Tự động phân lớp FOUNDATION / ACCELERATION / BREAKTHROUGH theo `θ₀`.
- **⛔ Điểm học bạ - không triển khai**:
  - Chính Hội đồng đã nhận định "thang điểm học bạ mỗi trường khác nhau".
  - Nếu chỉ "tham khảo" mà không đưa vào mô hình thì giá trị tính toán bằng 0, chỉ tăng gánh nặng nhập liệu.
  - Mentor có thể ghi chú thông tin này ở buổi gặp trực tiếp.
- **⏳ Chưa có**: cờ "bế tắc > 3 phút" và ô ghi chú quan sát của Mentor trên Dashboard.

#### 1.4 Bóc tách phổ điểm môn mạnh / yếu - ✅ ĐÃ TRIỂN KHAI
- `SkillBreakdown`, `WeakSkillIds` (độ chính xác `< 60%`), `DifficultyBreakdown` theo 6 cấp Bloom.
- **ZPD**: chọn câu hỏi có xác suất đúng IRT trong dải `[0.60, 0.75]` (`GetNextQuestionQueryHandler`).
- **"Điểm có thể tăng"**: Knapsack ROI theo dạng bài (Core Flow 6) - đúng tinh thần góp ý.
- **🟡 Phân loại lỗi**: có nhãn `CARELESS`, `MISREAD_QUESTION`, `MISSING_CONCEPT` (`TagCognitiveError`).
  - Hiện do **học sinh tự phản tư gắn nhãn**, chưa tự động phân loại bằng máy.
  - Lập luận: phản tư (metacognition) có giá trị sư phạm; tự động hóa sẽ bổ sung khi có đủ log hành vi.

#### 1.5 Hồ sơ thông tin từ phụ huynh - ⛔ KHÔNG TRIỂN KHAI
- **Phản biện**:
  - Dữ liệu tự khai ("mức độ tự giác", "điểm yếu tâm lý") mang tính chủ quan, phụ huynh có xu hướng đánh giá cao con mình.
  - Hệ thống đo **hành vi thực tế** đáng tin hơn: thời gian làm bài, tỉ lệ hoàn thành chặng, số lần sai liên tiếp.
  - Thông tin quỹ thời gian học đã có qua trường `StudyHoursDay`.
- **Thay thế**: Mentor trao đổi trực tiếp ở buổi tư vấn 3 bên (`ScheduleCounseling`).

---

### FLOW 2: QUY HOẠCH LỘ TRÌNH CÁ NHÂN HÓA & TÍCH HỢP MENTOR

#### 2.1 Tư vấn chọn trường 3 giỏ Reach/Target/Safety - ⛔ KHÔNG TRIỂN KHAI
- **Phản biện**:
  - Phạm vi đề tài là **lộ trình học tập cá nhân hóa**, không phải hệ thống tư vấn tuyển sinh.
  - Cần bộ dữ liệu điểm chuẩn chính thức đầy đủ của mọi ngành - không có nguồn mở ổn định.
  - Gợi ý nộp hồ sơ sai gây hậu quả thật cho học sinh; trách nhiệm tư vấn phải thuộc về con người.
- **Phần đã đáp ứng tinh thần góp ý**: dải điểm dự báo `[Min, Max]` + `UNREALISTIC_GOAL` + tư vấn 3 bên do Mentor chủ trì.

#### 2.2 Phân công Lead Mentor / Subject Mentor - 🟡 ĐIỀU CHỈNH
- **Đã có**: vai trò `Teacher`, `AcademicManager`, `AcademicDirector`; API phân công giáo viên cho lớp (`PUT /classes/{classId}/assign-teacher`).
- **Đã có**: giới hạn sĩ số `MaxClassCapacity = 20`, tự động mở lớp mới.
- **Phản biện**: hệ thống vận hành theo mô hình **lớp học offline tại cơ sở** - 1 giáo viên phụ trách 1 lớp 20 HS là đơn vị tổ chức thực tế; tách 2 vai trò là quyết định nhân sự của trung tâm, không phải chức năng phần mềm bắt buộc.
- **⏳ Chưa có**: AI gợi ý cân bằng tải và cảnh báo Mentor quá tải.

#### 2.3 Hình thức buổi học: Workshop + Micro-coaching - 🟡 ĐIỀU CHỈNH
- **Đã có**: chia nhóm vi mô trong lớp + phát đề luyện tập thích ứng cho từng nhóm (`assign-worksheet`).
- **Đã loại bỏ**: toàn bộ phân hệ Live Session (8 API) do chuyển sang mô hình giảng dạy **tập trung offline**.
- **⏳ Chưa có**: AI đề xuất 3-5 dạng bài cả lớp sai nhiều nhất cho Workshop (dữ liệu đã có trong `MistakeNotebooks`, chỉ cần thêm API tổng hợp).

#### 2.4 Mentor & Teacher đồng hành từ đầu - 🟡 MỘT PHẦN
- **Đã có**: lộ trình sinh tự động ngay sau test chẩn đoán (`POST /roadmaps/generate`, 4 thuật toán đồ thị Tarjan / Pruner / Topological / Milestone).
- **Đã có**: Dashboard cảnh báo sớm cho Mentor từ ngày đầu (`GET /early-warnings/dashboard`).
- **⏳ Chưa có**: cổng "Mentor phê duyệt lộ trình trước khi áp dụng" (trạng thái `PENDING_APPROVAL`).
- **⛔ Buổi Kickoff 15 phút**: là hoạt động gặp mặt trực tiếp, hệ thống chỉ hỗ trợ ghi nhận lịch hẹn.

#### 2.5 Gom nhóm học tập cá nhân hóa - ✅ ĐÃ TRIỂN KHAI
- **Lớp chuyên đề**: K-Means++ + Elbow Method phân cụm theo lỗ hổng 4 miền năng lực (`POST /classes/auto-cluster`).
- **Nhóm vi mô trong lớp**: gom đồng nhất theo điểm nghẽn kiến thức, ràng buộc **3-5 HS/nhóm** (`ClassMicroClusterer.cs`).
- Ghi chú: chọn 3-5 thay vì 4-6 để phù hợp sĩ số lớp 20 (chia đều 4-6 nhóm).

---

### FLOW 3: LUYỆN TẬP THÍCH ỨNG & THI THỬ

#### 3.1 Chu trình học P-L-A-R - ✅ ĐÃ TRIỂN KHAI
| Bước | API | Logic |
| :--- | :--- | :--- |
| Preview | `start`, `preview-submit` | 3 câu Quick Check |
| Learn | `track-video` | Chuyển bước khi xem `>= 80%` video |
| Apply | `next-question`, `submit-answer` | ZPD IRT 2PL + BKT, BR-01 Mastery, BR-03 Remedial |
| Reflect | `reflect-complete` | Ghi độ tự tin, mở khóa chặng kế tiếp |

#### 3.2 Vòng lặp bài tập & chấm điểm - ✅ ĐÃ TRIỂN KHAI
- Cập nhật BKT `P(Lt)` sau mỗi câu; tinh thông khi `P(Lt) >= 0.85` và 2 câu khó liên tiếp đúng.
- Câu sai tự động vào Sổ tay lỗi sai với `next_review_date = ngày mai` (BR-15).
- Ôn tập ngắt quãng **SM-2** bằng câu **biến thể Isomorphic** cùng dạng bài; `is_mastered` khi đúng 3 lần liên tiếp.
- **🟡**: sai liên tiếp `>= 3` câu kích hoạt gói cứu trợ tự động; chưa đẩy thông báo cho Mentor.

#### 3.3 Phòng tự học ảo Pomodoro - ⛔ KHÔNG TRIỂN KHAI
- **Phản biện**:
  - Mô hình hiện tại là **học tập trung tại cơ sở offline**, thời gian học đã được quản lý bởi lịch lớp.
  - Check-in/check-out tự bấm không chứng minh học sinh thực sự học (bật rồi bỏ đi).
  - Thời gian học thực được đo chính xác hơn qua log `time_spent_seconds`, tiến độ video, số câu đã làm.
- **⏳ Báo cáo tuần gửi phụ huynh**: đồng ý, đưa vào Core Flow 5 (Learning Analytics).

#### 3.4 Thi thử & kiểm soát gian lận - ✅ ĐÃ TRIỂN KHAI
- `POST /mock-exams/{examId}/start`: 120 câu, đếm ngược 150 phút.
- `log-tab-departure`: rời tab quá 3 lần tự động gắn cờ `FLAGGED_FOR_REVIEW` (BR-20).
- `upload-snapshot`: ảnh webcam ngẫu nhiên + cờ `FaceDetected`.
- `submit`: phân luồng `UNDER_REVIEW` / `COMPLETED`, câu sai vào Sổ tay lỗi sai.
- `mentor-review`: Mentor kết luận `APPROVED` hoặc `DISQUALIFIED` kèm lý do (Human-in-the-loop).
- **⏳ Chưa có**: cờ "làm quá nhanh" và bước ghi nhận đồng ý của phụ huynh trước khi bật camera.

---

### FLOW 4: TRỢ LÝ GIA SƯ AI

#### 4.1 Academic không bao quát hết dạng đề - ✅ ĐÃ TRIỂN KHAI
- Gemini Vision OCR bóc tách PDF thành câu hỏi (giữ LaTeX, bảng HTML 2 tầng, ảnh minh họa).
- **Novelty Detector**: so cosine với kho dạng bài, `< 0.75` thì đưa vào `novel_pattern_proposals`.
- API Academic duyệt `APPROVED` / `MERGED` / `REJECTED` trước khi vào kho chính thức.

#### 4.2 Taxonomy & phổ dạng đề - ✅ ĐÃ TRIỂN KHAI
- `CompetencyDomain` → `Skill` (DAG tiên quyết) → `archetype_patterns` (dạng bài chuẩn).
- Mỗi dạng bài có `pattern_exemplars` (câu mẫu + lời giải chuẩn) và `pattern_traps` (bẫy + gợi ý Socratic).
- Đề do AI sinh lưu `IsPublished = false`, chỉ xuất bản sau khi duyệt.

#### 4.3 Kỹ thuật Prompt chống AI giải sai - ✅ ĐÃ TRIỂN KHAI
- **Strict Grounding**: Hybrid GraphRAG 2-hop (pgvector → Graph), độ tương đồng `< 0.75` trả về `LOW_CONFIDENCE` thay vì bịa (fail-closed).
- Đáp án lấy từ `correct_option` do con người nhập; AI chỉ giải thích.
- **Socratic Guardrails**: chỉ ra lỗi tư duy và đặt câu hỏi gợi mở, không đưa đáp án.

#### 4.4 Kiểm chứng kiến thức 2 tầng - ✅ ĐÃ TRIỂN KHAI
- **Tầng 1**: `validator_judge.py` (LLM-as-a-Judge chống lộ đáp án + Heuristic guard), không đạt thì fallback.
- **Tầng 2**: học sinh báo cáo sai (`POST /ai-tutor/report`), Mentor ghi đè lời giải chuẩn trên Mentor Studio.
- Toàn bộ tương tác lưu `ai_tutor_interaction_logs` để kiểm toán.

---

### FLOW 5: PHÂN TÍCH TIẾN ĐỘ & HỌC SINH LƯỜI

> [!IMPORTANT]
> Core Flow 5 (Learning Analytics) đã được quy hoạch (API 22, 23) nhưng **chưa triển khai**. Đây là phần cần trình bày trung thực với Hội đồng.

#### 5.1 Phân tích bất thường - 🟡 MỘT PHẦN
- **Đã có**: phát hiện đoán mò `< 5s` và giảm trọng số trong BKT.
- **⏳ Chưa có**: cảnh báo điểm tụt `> 30%`, học lúc 2h-4h sáng.
- Đồng ý nguyên tắc: hệ thống chỉ báo "dấu hiệu", không chẩn đoán tâm lý/sức khỏe.

#### 5.2 Can thiệp đúng phần yếu (Remedial Sprint) - 🟡 MỘT PHẦN
- **Đã có**: gói cứu trợ BR-03 gồm video tóm tắt + công thức cốt lõi + 3 câu cơ bản (`b < 0.0`), phải đúng 3/3 mới mở lại tiến trình.
- **Khác góp ý**: kích hoạt tự động tức thì trong chặng thay vì gói 48h chờ Mentor duyệt - giúp học sinh không bị gián đoạn.
- **⏳ Chưa có**: Mentor duyệt/kèm thêm và quyết định tạm khóa chặng mới.

#### 5.3 Cơ chế kỷ luật 3 cấp - ⏳ CHƯA TRIỂN KHAI
- Đã đặc tả nghiệp vụ BR-18 trong [muc_3_dac_ta_chuc_nang_chi_tiet.md](./muc_3_dac_ta_chuc_nang_chi_tiet.md).
- Hạ tầng tái sử dụng được: `SystemAlert` (cảnh báo + Mentor resolve) và `ScheduleCounseling` (họp 3 bên).
- Cần bổ sung: Background Job quét số ngày không hoạt động, Streak, push notification.

---

### FLOW 6: DỰ BÁO KẾT QUẢ & CẢNH BÁO SỚM

#### 6.1 Cơ sở kiểm chứng dự báo - ✅ / ⏳
- **✅** Dự báo khoảng điểm tin cậy 95%: `[điểm - 1.96 × SEM, điểm + 1.96 × SEM]` (`RecalculatePredictionCommandHandler`).
- **⏳** K-Fold Cross Validation, MAE: chờ dữ liệu thi thử thật - đúng như góp ý của Hội đồng.

#### 6.2 Mô hình XGBoost / LightGBM + ONNX - ⛔ KHÔNG TRIỂN KHAI Ở GIAI ĐOẠN NÀY
- **Phản biện**:
  - **Cold-start**: chưa có tập dữ liệu (đặc trưng học tập → điểm thi thật) để huấn luyện.
  - Huấn luyện trên dữ liệu mô phỏng thì mô hình chỉ "học lại" công thức sinh dữ liệu - độ chính xác ảo, không có giá trị khoa học.
  - Mô hình tâm trắc học (IRT + SEM) **giải thích được** từng con số cho Mentor/phụ huynh; Gradient Boosting là hộp đen.
- **Lộ trình**: khi tích lũy đủ dữ liệu thi thử + điểm thi thật, mới huấn luyện ML và so sánh MAE với baseline IRT/SEM.
- **✅ Phân loại 3 mức**: `GREEN` / `YELLOW` / `RED` + `UNREALISTIC_GOAL`; Mentor xử lý qua `resolve` và `schedule-counseling`.

#### 6.3 Chỉ dẫn cải thiện cụ thể - ✅ ĐÃ TRIỂN KHAI
- Toa thuốc **Greedy Knapsack ROI** chọn 2-3 dạng bài có tỉ lệ điểm tăng / thời gian cao nhất.
- Số điểm tính từ phổ dạng đề và mức thành thạo, không do AI tự nói ra - đúng yêu cầu.
- Học sinh luyện 3-5 câu biến thể theo dạng bài; hoàn thành thì trừ `deficit_score`, đánh dấu `is_remedied`.
- **🟡**: chưa có bước Mentor xác nhận đưa vào kế hoạch ôn tập.

---

## 3. ĐIỂM YẾU CẦN CHUẨN BỊ TRƯỚC KHI HỘI ĐỒNG HỎI

> [!WARNING]
> Các điểm dưới đây có trong code hiện tại, nhóm nên chủ động sửa hoặc chuẩn bị câu trả lời.

| # | Vấn đề | Vị trí | Hướng xử lý |
| :---: | :--- | :--- | :--- |
| 1 | `SemScore` đang là hằng số `24.5` | `RecalculatePredictionCommandHandler.cs` | Tính SEM từ Test Information Function của IRT: `SEM = 1 / sqrt(I(θ))` |
| 2 | Điểm dự báo = `tỉ lệ đúng × 1200` (chưa dùng `θ`) | Cùng file | Quy đổi từ `θ` sang thang 1200 như tài liệu Core Flow 6 |
| 3 | Mỗi dạng bài hoàn thành `+15` điểm cố định | Cùng file | Dùng ROI ước lượng của chính dạng bài đó |
| 4 | Core Flow 5 chưa có code | `ClassesController.cs` (API 22, 23) | Trình bày là phạm vi giai đoạn sau, nêu hạ tầng đã sẵn sàng |

---

## 4. KỊCH BẢN TRẢ LỜI NGẮN CHO CÁC MỤC ⛔

| Góp ý | Câu trả lời đề xuất |
| :--- | :--- |
| Điểm học bạ | "Thang điểm không đồng nhất giữa các trường nên không thể đưa vào mô hình; nhóm ưu tiên dữ liệu đo trên cùng một thang là bài test chẩn đoán." |
| Khảo sát phụ huynh | "Dữ liệu tự khai thiếu khách quan; hệ thống đo hành vi thực, phụ huynh tham gia qua buổi tư vấn 3 bên." |
| Reach/Target/Safety | "Tư vấn tuyển sinh ngoài phạm vi đề tài và đòi hỏi trách nhiệm của con người; hệ thống cung cấp dải điểm dự báo để Mentor tư vấn." |
| Pomodoro | "Mô hình học tập trung tại cơ sở; thời gian học thật được đo qua log làm bài thay vì check-in tự bấm." |
| XGBoost/ONNX | "Chưa có dữ liệu thật thì ML chỉ học lại dữ liệu mô phỏng; nhóm dùng IRT + SEM có tính giải thích làm baseline, ML là bước tiếp theo khi có dữ liệu." |
