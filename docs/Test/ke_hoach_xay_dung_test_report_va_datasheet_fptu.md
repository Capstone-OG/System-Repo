# KẾ HOẠCH TỔNG THỂ (MASTER PLAN): XÂY DỰNG BỘ TEST CASES, DATASHEET EXCEL (`Report5_Test Report.xlsx`) & HOÀN THIỆN CHƯƠNG V (`Report7`)

> [!IMPORTANT]
> Kế hoạch này được thiết kế dựa trên kết quả phân tích trực tiếp cấu trúc XML/Formula của file mẫu **[`FA25SE208_Test_Report.xlsx`](./FA25SE208_Test_Report.xlsx)** kết hợp đối chiếu 100% với **Chương III (SRS: `FE-01` $\rightarrow$ `FE-25`, `UC01` $\rightarrow$ `UC66`, `SCR-00` $\rightarrow$ `SCR-40`, `BR-01` $\rightarrow$ `BR-25`, `MSG01` $\rightarrow$ `MSG13`)** và **Chương V (Software Testing Documentation)** trong **[`Report7_Final Project Report.pdf`](./Report7_Final%20Project%20Report.pdf)**.

---

## 1. PHÂN TÍCH CẤU TRÚC CHUẨN CỦA FILE MẪU FPTU (`FA25SE208_Test_Report.xlsx`)

Qua giải mã cấu trúc gốc của file Excel mẫu đạt chuẩn hội đồng FPTU, một file **`Report5_Test Report.xlsx`** hợp lệ bắt buộc phải có **2 nhóm Sheets liên kết tự động bằng công thức Excel**:

### 1.1 Nhóm 3 Sheets Quản Trị & Thống Kê Tự Động (Control Sheets)
1. **Sheet 1 – `Cover`**:
   - Thông tin định danh dự án:
     - `Project Name`: `AI-powered Personalized Learning Path Platform for Competency Assessment Exam Preparation (V-Eval)`
     - `Project Code`: `FA26SE090`
     - `Document Code`: Công thức tự động `=CONCATENATE(B5,"_001_v",F6)` $\rightarrow$ `FA26SE090_001_v1.0`
     - `Creator`: `LocPT, ThinhTT, KhoiND, NhanMT`
     - `Issue Date`: `25/10/2026` | `Version`: `1.0`
   - Bảng `Record of change` ghi nhận lịch sử tạo và cập nhật các phân hệ kiểm thử theo từng mốc ngày.
2. **Sheet 2 – `Test Cases` (Danh Mục Chức Năng Kiểm Thử Tổng Thể)**:
   - Bảng tra cứu gồm 5 cột: `No | Function Name | Sheet Name | Description | Pre-Condition`.
   - Liệt kê toàn bộ **42 chức năng cốt lõi** của hệ thống V-Eval và trỏ về đúng tên Sheet Role tương ứng.
3. **Sheet 3 – `Test Statistics` (Báo Cáo Thống Kê Tự Động)**:
   - `Reviewer/Approver`: `TaiNT` (Giảng viên hướng dẫn: Nguyễn Trọng Tài).
   - Bảng tổng hợp kết quả theo từng Module/Role (`No | Module code | Passed | Failed | Pending | N/A | Number of test cases`):
     - **Quan trọng**: Các ô số lượng `Passed`, `Failed`, `Pending`, `N/A` không gõ tay mà dùng công thức tham chiếu trực tiếp sang ô tổng của từng Sheet (ví dụ: `='Authentication'!B6`), tự động tính `Sub total = SUM(...)`, `Test coverage = 100%` và `Test successful coverage = 100%`.

### 1.2 Nhóm 7 Sheets Datasheet Chi Tiết Theo Role (Detail Test Case Sheets)
Mỗi Sheet đại diện cho một phân vùng Role trong kiến trúc V-Eval, tuân thủ nghiêm ngặt cấu trúc **Hàng 2 $\rightarrow$ Hàng 10**:
- **Khối Thống Kê Đầu Sheet (Rows 2–8)**:
  - Tự động đếm trạng thái qua công thức chuẩn của mẫu FPTU:
    - `Round 1 Passed`: `=COUNTIF($F10:$F982, B5)` (với `B5 = "Passed"`, `R2:R5` là danh sách Data Validation).
    - `Round 2 Passed`: `=COUNTIF($I10:$I982, B5)`
    - `Round 3 Passed`: `=COUNTIF($L10:$L982, B5)`
    - `Number of TCs (B4)`: `=SUM(B6:E6)`
- **Khối Header 15 Cột Chuẩn (Row 10)**:
  - `Col A`: `Test Case ID` (ví dụ: `TC_Register_001`, `TC_Diagnostic_001`...)
  - `Col B`: `Test Case Description`
  - `Col C`: `Test Case Procedure` (Các bước thao tác đánh số `1.`, `2.`, `3.`...)
  - `Col D`: `Expected Results` (Kết quả mong đợi, thông báo `MSG01–MSG13`, trạng thái Entity/DB)
  - `Col E`: `Pre-conditions` (Tiền điều kiện đăng nhập, trạng thái dữ liệu)
  - `Col F, G, H`: `Round 1` (`Passed` / `Failed`) | `Test date` (`25/10/2026 - 30/10/2026`) | `Tester`
  - `Col I, J, K`: `Round 2` (`Passed`) | `Test date` (`05/11/2026 - 09/11/2026`) | `Tester`
  - `Col L, M, N`: `Round 3` (`Passed`) | `Test date` (`10/11/2026 - 14/11/2026`) | `Tester`
  - `Col O`: `Note`

---

## 2. QUY HOẠCH PHÂN BỔ 7 SHEETS & 240 TEST CASES CHO DỰ ÁN V-EVAL (`FA26SE090`)

Để tương xứng với quy mô đồ án tốt nghiệp 4 thành viên (file mẫu nhóm 4 người có **212 Test Cases**), bộ Datasheet của V-Eval được thiết kế gồm **7 Sheets chức năng với tổng cộng ~240 Test Cases**, phủ kín 100% màn hình (`SCR-00` $\rightarrow$ `SCR-40`), Use Cases (`UC01` $\rightarrow$ `UC66`) và Business Rules (`BR-01` $\rightarrow$ `BR-25`):

| STT Sheet | Tên Sheet (Tab Excel) | Phạm Vi Tính Năng (`FE` / `UC` / `SCR`) | Số Nhóm Chức Năng | Số Lượng TCs Dự Kiến | Người Test Chính (Round 1) | Người Re-test (Round 2 & 3) |
| :---: | :--- | :--- | :---: | :---: | :--- | :--- |
| **01** | **`Authentication`** | `FE-01` $\rightarrow$ `FE-03` (`UC01–UC08`, `SCR-00–SCR-06`) | 6 nhóm | **36 TCs** | `LocPT` | `NhanMT` / `ThinhTT` |
| **02** | **`Student`** | `FE-04` $\rightarrow$ `FE-11` (`UC09–UC27`, `SCR-08, SCR-11–SCR-20`) | 10 nhóm | **72 TCs** | `LocPT`, `KhoiND`, `NhanMT` | `ThinhTT` / `LocPT` |
| **03** | **`Parent`** | `FE-12` $\rightarrow$ `FE-14` (`UC28–UC33`, `SCR-21–SCR-22`) | 4 nhóm | **24 TCs** | `NhanMT` | `LocPT` / `KhoiND` |
| **04** | **`Teacher_Mentor`** | `FE-15` $\rightarrow$ `FE-18` (`UC34–UC44`, `SCR-23–SCR-28`) | 7 nhóm | **40 TCs** | `ThinhTT`, `NhanMT` | `KhoiND` / `LocPT` |
| **05** | **`Academic_Director`** | `FE-19` $\rightarrow$ `FE-21` (`UC50–UC54`, `SCR-29–SCR-32`) | 5 nhóm | **28 TCs** | `KhoiND`, `ThinhTT` | `LocPT` / `NhanMT` |
| **06** | **`Academic_Manager`** | `FE-22` $\rightarrow$ `FE-23` (`UC45–UC49`, `SCR-33–SCR-36`) | 4 nhóm | **20 TCs** | `ThinhTT` | `NhanMT` / `KhoiND` |
| **07** | **`Admin`** | `FE-24` $\rightarrow$ `FE-25` (`UC55–UC63`, `SCR-37–SCR-40`) | 5 nhóm | **20 TCs** | `LocPT` | `ThinhTT` / `KhoiND` |
| **TỔNG** | **10 Sheets (3 Control + 7 Role)** | **Toàn bộ 25 Features, 66 UCs, 25 BRs, 5 Workflows** | **41 nhóm** | **240 TCs** | **4 Thành viên** | **Chéo 4 Thành viên** |

---

## 3. MA TRẬN CHI TIẾT 41 NHÓM CHỨC NĂNG & KỊCH BẢN KIỂM THỬ TRỌNG TÂM

### Sheet 4: `Authentication` (36 TCs — Phụ trách chính: `LocPT`)
1. **Register Account (`TC_Register_001` $\rightarrow$ `008`)**:
   - Happy path đăng ký thành công chuyển sang chờ OTP (`MSG08`).
   - Kiểm tra trùng Email / Số điện thoại (`BR-04`), sai định dạng Email/SĐT 10 số, mật khẩu yếu thiếu chữ hoa/thường/số/ký tự đặc biệt (`BR-03`, `MSG03`), mật khẩu xác nhận không khớp, bỏ trống trường bắt buộc (`MSG02`), chưa tích chọn điều khoản sử dụng.
2. **Verify Account OTP (`TC_VerifyOtp_001` $\rightarrow$ `006`)**:
   - Nhập đúng OTP 6 số trong hạn 10 phút $\rightarrow$ Kích hoạt tài khoản sang `ACTIVE` (`BR-01`).
   - Nhập OTP sai, OTP hết hạn (> 10 phút), OTP đã sử dụng, tài khoản đã kích hoạt trước đó, thử gửi lại OTP trong thời gian chờ cooldown 60s.
3. **Login (`TC_Login_001` $\rightarrow$ `007`)**:
   - Đăng nhập thành công cho từng Role $\rightarrow$ Cấp JWT Access Token + Refresh Token và điều hướng đúng Dashboard.
   - Sai mật khẩu (`MSG09`), email không tồn tại (`MSG09`), tài khoản chưa xác thực OTP (`BR-01`), tài khoản đang bị khóa `SUSPENDED` / `BANNED` (`BR-02`), bỏ trống email/password (`MSG02`).
4. **Forgot & Reset Password (`TC_ForgotPwd_001` $\rightarrow$ `005`)**:
   - Yêu cầu khôi phục mật khẩu qua email hợp lệ (`MSG08`), xác thực OTP và đặt mật khẩu mới thành công.
   - Email chưa đăng ký, OTP khôi phục sai/hết hạn, mật khẩu mới vi phạm độ phức tạp (`BR-03`, `MSG03`).
5. **Change Password (`TC_ChangePwd_001` $\rightarrow$ `005`)**:
   - Đổi mật khẩu thành công khi nhập đúng mật khẩu hiện tại (`MSG05`).
   - Nhập sai mật khẩu hiện tại, mật khẩu mới trùng mật khẩu cũ, mật khẩu mới không đủ 8 ký tự chuẩn (`BR-03`), xác nhận mật khẩu mới lệch.
6. **Manage Profile (`TC_Profile_001` $\rightarrow$ `005`)**:
   - Cập nhật họ tên, trường THPT, điểm học bạ lớp 11–12 tham khảo (`BR-07`), số giờ học mỗi ngày (`0.5–12.0h`), chọn cơ sở campus (`MSG05`).
   - Kiểm tra trường Email ở chế độ chỉ đọc (Read-only), nhập số giờ học ngoài biên (`< 0.5` hoặc `> 12`), số điện thoại trùng người khác (`BR-04`).

---

### Sheet 5: `Student` (72 TCs — Phụ trách: `LocPT`, `KhoiND`, `NhanMT`)
7. **Configure Target Score & Benchmark (`TC_Target_001` $\rightarrow$ `006` — `FE-04`, `SCR-11`)**:
   - Lưu nguyện vọng trường/ngành (1–3 nguyện vọng), điểm mục tiêu (`300–1200`), ngày thi dự kiến ($\ge 14$ ngày tới) và thời lượng học tuần (`5–50h`).
   - Kiểm tra biên điểm mục tiêu (`< 300` hoặc `> 1200`), ngày thi trong quá khứ hoặc $< 14$ ngày, chọn quá 3 ngành.
8. **Take Diagnostic Test 30 Items (`TC_Diagnostic_001` $\rightarrow$ `008` — `WF-03`, `FE-05`, `SCR-12`)**:
   - Hoàn thành đề chẩn đoán 30 câu chuẩn tỷ lệ ĐGNL (`BR-05`), ước lượng $\theta_0$ qua 2PL IRT và hiển thị hồ sơ năng lực đa miền (`SCR-13`).
   - Kiểm tra cơ chế chống đoán mò ("rapid guessing" $< 5\text{s}$): Hiển thị cảnh báo `MSG11` và tự động giảm trọng số độ phân biệt $a_i = 0.1$ (`BR-06`).
   - Đảm bảo không có câu hỏi `PRACTICE_ONLY` chưa hiệu chuẩn lọt vào đề chẩn đoán (`BR-11`).
9. **View & Follow Personalized DAG Roadmap (`TC_Roadmap_001` $\rightarrow$ `007` — `WF-05`, `FE-06`, `SCR-14`)**:
   - Sinh lộ trình cá nhân hóa theo thứ tự Topological Sort ở trạng thái `DRAFT` (`BR-08`), tự động cắt tỉa (prune) các kỹ năng đã thành thạo $P(L_0) \ge 0.85$ (`BR-14`).
   - Chặn học viên mở khóa chặng sau khi chặng tiên quyết phía trước chưa hoàn thành.
10. **Execute P-L-A-R Learning Stage (`TC_PLAR_001` $\rightarrow$ `008` — `WF-01`, `FE-07`, `SCR-15`)**:
    - Hoàn thành tuần tự 4 bước: Preview (Quick-Check) $\rightarrow$ Learn (Xem video bài giảng $\ge 80\%$ thời lượng) $\rightarrow$ Apply (Luyện tập ZPD) $\rightarrow$ Reflect (Ghi chú phản tư lỗi sai).
    - Chặn bước làm bài Apply khi tỷ lệ xem video `< 80%` (kiểm tra chống tua nhanh video).
11. **Practice Adaptive Quiz in ZPD Band (`TC_AdaptiveQuiz_001` $\rightarrow$ `008` — `WF-01`, `FE-07`, `SCR-16`)**:
    - Hệ thống chọn câu hỏi nằm trong dải xác suất làm đúng ZPD `[0.60, 0.75]`, cập nhật xác suất thành thạo BKT $P(L_t)$ sau mỗi câu.
    - Mở khóa cột mốc khi $P(L_t) \ge 0.85$ và điểm bài tập $\ge 60\%$ (`BR-14`).
    - Làm sai 3 câu liên tiếp cùng một dạng bài $\rightarrow$ Tự động khóa tiến trình thường và chèn chặng bổ trợ `Remedial Node` (`BR-14`).
12. **Consult Socratic AI Tutor (`TC_AITutor_001` $\rightarrow$ `009` — `WF-03`, `FE-08`, `SCR-08`)**:
    - Hỏi đáp gia sư AI Socratic nhận phản hồi streaming SSE dẫn dắt từng bước dựa trên tài liệu chuẩn (`Cosine Similarity >= 0.75`).
    - Học sinh gài bẫy yêu cầu AI cho thẳng đáp án A/B/C/D $\rightarrow$ Bộ lọc Guardrail chặn và viết lại thành câu hỏi gợi mở (`BR-12`, `BR-25`).
    - Nhập câu hỏi ngoài phạm vi kiến thức ĐGNL (`Cosine Similarity < 0.75`) $\rightarrow$ Từ chối an toàn và đẩy vào hàng đợi chờ duyệt.
    - Nhập prompt quá 1000 ký tự hoặc chứa từ ngữ vi phạm (`BR-25`), vượt hạn ngạch token trong ngày (`429 Too Many Requests`).
13. **Take Proctored Mock Exam 120 Items (`TC_MockExam_001` $\rightarrow$ `009` — `WF-02`, `FE-09`, `SCR-17`)**:
    - Làm bài thi thử 120 câu / 150 phút ở chế độ toàn màn hình (Fullscreen), nộp bài hợp lệ (`IntegrityStatus = NORMAL`), chấm điểm quy đổi thang 1200.
    - Rời khỏi tab/màn hình thi từ 1–3 lần $\rightarrow$ Hiển thị banner cảnh báo `MSG10` (`{số_lần}/3`).
    - Rời khỏi tab quá 3 lần (`> 3`) $\rightarrow$ Không tự động hủy bài thi mà gắn cờ chuyển trạng thái sang `UNDER_REVIEW` chờ Giảng viên hậu kiểm (`BR-21`, `BR-22`).
    - Kiểm tra ảnh chụp webcam định kỳ nén chuẩn WebP `< 300KB` (`BR-22`), tự động thu bài khi hết giờ 150 phút.
14. **Review Mistake Notebook via SM-2 (`TC_Mistake_001` $\rightarrow$ `006` — `WF-04`, `FE-10`, `SCR-18`)**:
    - Tự động đưa câu làm sai vào Sổ tay lỗi sai, phân loại theo dạng bài và nhãn nhận thức, sinh câu hỏi biến thể tương đồng (Isomorphic Variant) theo lịch lặp ngắt quãng SuperMemo-2 (`BR-15`).
    - Đánh giá mức độ nhớ $q \in [0, 5]$: trả lời đúng tăng khoảng cách ngày ôn (`BoxLevel` tăng), trả lời sai reset về chu kỳ ngắn.
15. **View Score Forecast 95% SEM & Knapsack Prescription (`TC_Forecast_001` $\rightarrow$ `006` — `FE-11`, `SCR-19`, `SCR-20`)**:
    - Hiển thị khoảng điểm dự báo 95% `[Min, Max]` theo sai số chuẩn SEM, tính độ thâm hụt $\Delta_{Deficit}$ và kê "Toa thuốc" Top 2–3 dạng bài có ROI cao nhất (`BR-23`).
    - Kiểm tra cảnh báo `UNREALISTIC_GOAL` khi mục tiêu vượt cận trên dự báo quá 150 điểm (`BR-20`).
16. **Generate Parent Pairing Code (`TC_PairingCode_001` $\rightarrow$ `005` — `FE-12`, `UC27`)**:
    - Sinh mã ghép nối 6 ký tự có hiệu lực 15 phút; làm mới mã khi hết hạn.

---

### Sheet 6: `Parent` (24 TCs — Phụ trách chính: `NhanMT`)
17. **Link Student Account via Pairing Code (`TC_ParentLink_001` $\rightarrow$ `006` — `FE-12`, `SCR-21`)**:
    - Phụ huynh nhập mã ghép nối hợp lệ trong 15 phút $\rightarrow$ Liên kết thành công với tài khoản con (`MSG04`).
    - Nhập mã sai, mã đã hết hạn (> 15 phút), mã đã được sử dụng, hoặc liên kết trùng lặp với học sinh đã ghép nối.
18. **Pay Tuition & Study Package (`TC_Payment_001` $\rightarrow$ `007` — `FE-12`, `UC31`, `SCR-21`)**:
    - Chọn gói học/thi thử cho con, thanh toán qua cổng PayOS / VietQR, xác thực chữ ký điện tử Webhook (`gatewayWebhookSignature`) và tự động mở khóa quyền lợi gói học.
    - Kiểm tra hủy giao dịch giữa chừng, chữ ký Webhook không hợp lệ, chống xử lý trùng lặp giao dịch (Idempotency check), phụ huynh chưa liên kết tài khoản con.
19. **Monitor Child Progress Dashboard (`TC_ParentDash_001` $\rightarrow$ `005` — `FE-13`, `SCR-22`)**:
    - Xem biểu đồ giờ học, chuỗi ngày học liên tiếp (Streak), tiến độ hoàn thành lộ trình, khoảng điểm dự báo ở chế độ chỉ đọc (`OS-02`).
    - Chặn truy cập trái phép dữ liệu của học sinh không liên kết với tài khoản phụ huynh đang đăng nhập.
20. **Receive 3-Tier Academic Alerts (`TC_ParentAlert_001` $\rightarrow$ `006` — `FE-14`, `UC32`)**:
    - Nhận thông báo tự động khi con gián đoạn học tập theo ngưỡng 1 ngày (Tier 1), 3 ngày (Tier 2), và 5 ngày / mục tiêu vượt ngưỡng (Tier 3 — `BR-18`, `BR-19`, `BR-20`).

---

### Sheet 7: `Teacher_Mentor` (40 TCs — Phụ trách: `ThinhTT`, `NhanMT`)
21. **Supervise Class Competency Heatmap (`TC_Heatmap_001` $\rightarrow$ `006` — `WF-05`, `FE-15`, `SCR-23`)**:
    - Hiển thị ma trận nhiệt năng lực của lớp phụ trách (< 300ms qua Cache-Aside), tô màu đỏ cảnh báo các ô kỹ năng có $P(L_t) < 0.50$.
    - Lọc theo miền kiến thức, bấm làm mới (Force Aggregate) cập nhật tức thì bảng nhiệt.
22. **Approve Student Roadmap in Kickoff (`TC_ApproveRoadmap_001` $\rightarrow$ `006` — `FE-18`, `SCR-24`, `BR-08`)**:
    - Lead Mentor xem lộ trình `DRAFT`, điều chỉnh cột mốc và bấm phê duyệt chuyển sang `APPROVED` (`MSG04`).
    - Chặn phê duyệt nếu lộ trình không ở trạng thái `DRAFT` hoặc giảng viên không phải Lead Mentor được phân công.
23. **Manage Micro-Cohorts & 1-Click Intervention (`TC_MicroCohort_001` $\rightarrow$ `006` — `FE-16`, `SCR-25`, `SCR-26`)**:
    - Xem danh sách nhóm học phụ đạo chuyên sâu ($\le 6$ học sinh chung lỗ hổng dạng bài qua K-Means — `BR-17`) và giao phiếu bài tập can thiệp 1-Click.
    - Chặn thêm học sinh thứ 7 vào nhóm vượt quá giới hạn 6 học sinh (`BR-17`).
24. **Schedule Mentoring Session (`TC_ScheduleSession_001` $\rightarrow$ `005` — `UC35`, `SCR-26`)**:
    - Lên lịch buổi phụ đạo với thời gian tương lai hợp lệ; báo lỗi nếu chọn thời gian trong quá khứ.
25. **Audit Flagged Mock Exam Submissions (`TC_AuditExam_001` $\rightarrow$ `006` — `WF-02`, `FE-17`, `SCR-27`)**:
    - Mở bài thi thử bị gắn cờ `UNDER_REVIEW`, kiểm tra nhật ký rời tab và ảnh chụp webcam WebP, gắn nhãn lỗi nhận thức (`CARELESS`, `MISSING_CONCEPT`) và ra phán quyết `APPROVED` (công nhận điểm) hoặc `DISQUALIFIED` (hủy kết quả — `BR-21`, `BR-22`).
26. **Resolve Early Warning Tasks & 3-Way Counseling (`TC_ResolveAlert_001` $\rightarrow$ `006` — `SCR-28`, `BR-19`, `BR-20`, `BR-24`)**:
    - Xử lý nhiệm vụ cảnh báo sớm, bắt buộc nhập `resolutionNotes` khi chuyển trạng thái sang `RESOLVED`; hẹn lịch tư vấn 3 bên cho ca `UNREALISTIC_GOAL`.
27. **Curate Content & Override AI Explanation (`TC_OverrideAI_001` $\rightarrow$ `005` — `FE-18`, `BR-13`)**:
    - Giảng viên biên soạn câu hỏi nháp và ghi đè lời giải mẫu khi phát hiện lời giải AI chưa sát phương pháp sư phạm.

---

### Sheet 8: `Academic_Director` (28 TCs — Phụ trách: `KhoiND`, `ThinhTT`)
28. **Manage 4-Tier Competency Taxonomy & Tarjan DAG (`TC_Taxonomy_001` $\rightarrow$ `007` — `WF-05`, `FE-19`, `SCR-30`)**:
    - Tạo và cập nhật cây tri thức 4 tầng (`Domain -> Subject -> Skill -> Pattern`, `BR-09`), thêm cạnh tiên quyết hợp lệ.
    - Cố tình nối cạnh tạo chu trình khép kín (`A -> B -> A`) $\rightarrow$ Thuật toán Tarjan phát hiện SCC và chặn lưu kèm cảnh báo lỗi chu trình.
29. **Verify & Approve AI-Generated Questions (`TC_VerifyQuestion_001` $\rightarrow$ `006` — `FE-20`, `SCR-31`, `BR-10`, `BR-11`)**:
    - Kiểm duyệt câu hỏi từ trạng thái `PRACTICE_ONLY`, hiệu chuẩn tham số 2PL IRT $(a, b)$ và chuyển sang `APPROVED` để đưa vào ngân hàng đề chuẩn.
    - Từ chối phê duyệt nếu câu hỏi thiếu 4 lựa chọn hoặc thiếu lời giải gốc chuẩn (`completeness validation`).
30. **Ingest RAG Reference Corpus to pgvector (`TC_RagCorpus_001` $\rightarrow$ `005` — `FE-21`, `UC52`)**:
    - Tải lên tài liệu chuẩn (PDF/DOCX $\le 25\text{MB}$), băm nhỏ (chunking) và lập chỉ mục vector HNSW 768 chiều vào PostgreSQL `pgvector`.
    - Báo lỗi khi tải file sai định dạng hoặc vượt quá 25MB.
31. **Resolve Escalated Knowledge Errors (`TC_KnowledgeErr_001` $\rightarrow$ `005` — `SCR-32`, `BR-12`, `BR-13`)**:
    - Xử lý báo cáo sai sót học thuật, khóa bất biến đáp án gốc và tái đồng bộ vector RAG.
32. **Configure Psychometric Algorithm Parameters (`TC_AlgoConfig_001` $\rightarrow$ `005` — `UC53`, `SCR-40`)**:
    - Cấu hình ngưỡng thành thạo BKT (`0.70–0.95`, mặc định `0.85`) và ngưỡng thời gian đoán mò (`3–10s`, mặc định `5s` — `BR-06`, `BR-14`).

---

### Sheet 9: `Academic_Manager` (20 TCs — Phụ trách chính: `ThinhTT`)
33. **Assign Mentors & Enforce Workload Quota (`TC_AssignMentor_001` $\rightarrow$ `005` — `FE-22`, `SCR-34`, `BR-16`)**:
    - Phân công học sinh cho Lead Mentor trong định mức ($\le 20$ học sinh).
    - Phân công vượt quá 20 học sinh/Mentor $\rightarrow$ Hệ thống chặn và phát cảnh báo vượt tải (`BR-16`).
34. **Approve Automated K-Means Class Placement (`TC_KMeansCluster_001` $\rightarrow$ `005` — `FE-22`, `UC47`)**:
    - Kích hoạt phân cụm K-Means xếp lớp tự động theo vector năng lực 4 miền thành 3 tầng (`FOUNDATIONAL`, `STANDARD`, `INTENSIVE`) đúng sĩ số quy định.
35. **Monitor Campus Comparative Heatmap (`TC_CampusHeatmap_001` $\rightarrow$ `005` — `FE-23`, `SCR-35`)**:
    - Xem biểu đồ so sánh tỷ lệ làm chủ kỹ năng giữa các lớp trong phạm vi cơ sở quản lý; chặn xem cơ sở không thuộc thẩm quyền.
36. **Coordinate Tier-3 Escalation Conferences (`TC_Tier3Case_001` $\rightarrow$ `005` — `FE-23`, `SCR-36`, `BR-20`)**:
    - Lên lịch họp 3 bên (Phụ huynh – Học sinh – Mentor) và lưu biên bản kế hoạch hành động cho học sinh nghỉ học $\ge 5$ ngày liên tiếp.

---

### Sheet 10: `Admin` (20 TCs — Phụ trách chính: `LocPT`)
37. **Manage User Accounts & RBAC Roles (`TC_AdminUser_001` $\rightarrow$ `005` — `FE-24`, `SCR-38`)**:
    - Tạo tài khoản nhân sự, gán quyền RBAC chuẩn, kiểm tra chặn trùng lặp Email/SĐT (`BR-04`).
38. **Lock / Unlock Violating Accounts (`TC_BanUser_001` $\rightarrow$ `005` — `UC58`, `SCR-38`, `BR-02`)**:
    - Khóa tài khoản vi phạm (`SUSPENDED`/`BANNED`) kèm lý do bắt buộc (`banReason`) và thu hồi toàn bộ Refresh Token đang hoạt động; mở khóa khôi phục quyền truy cập.
39. **Manage Campus Directory (`TC_CampusCRUD_001` $\rightarrow$ `004` — `UC60`)**:
    - Thêm mới và cập nhật thông tin cơ sở đào tạo; chặn trùng mã `campusCode`.
40. **Configure System Settings & API Quotas (`TC_SysConfig_001` $\rightarrow$ `003` — `FE-25`, `SCR-40`)**:
    - Cấu hình khóa API Gemini, hạn ngạch token mỗi ngày và giới hạn tần suất gọi (Rate Limit 10 tin nhắn/phút).
41. **Monitor Infrastructure Health & Database Backup (`TC_SysHealth_001` $\rightarrow$ `003` — `FE-25`, `SCR-37`, `UC62`, `UC63`)**:
    - Theo dõi trạng thái container microservices, truy vấn Audit Logs (lưu trữ $\ge 90$ ngày) và thực thi sao lưu CSDL định kỳ.

---

## 4. LỘ TRÌNH THỰC HIỆN TỰ ĐỘNG HÓA 3 BƯỚC (SINH TRỰC TIẾP FILE `.XLSX` HỢP LỆ 100%)

Thay vì bạn phải copy-paste thủ công từng bảng vào Excel rất dễ lệch cột hoặc mất công thức `COUNTIF` / `SUM`, mình đã thiết kế lộ trình 3 bước để hỗ trợ bạn từ A đến Z:

1. **Bước 1 — Duyệt Kế Hoạch & Quy Ước**:
   - Xác nhận danh sách **10 Sheets (3 Control Sheets + 7 Role Sheets)** và phân bổ **240 Test Cases** cho 4 thành viên (`LocPT`, `ThinhTT`, `KhoiND`, `NhanMT`) cùng 3 mốc thời gian:
     - `Round 1`: `25/10/2026 – 30/10/2026`
     - `Round 2`: `05/11/2026 – 09/11/2026`
     - `Round 3`: `10/11/2026 – 14/11/2026`
2. **Bước 2 — Sinh Tự Động File Excel Chuẩn FPTU (`Report5_Test Report.xlsx`)**:
   - Mình sẽ viết script tự động kế thừa **100% định dạng chuẩn (Style, Font, Màu Header, Border, Công thức `COUNTIF`/`SUM` tự động nhảy số, Data Validation)** từ file mẫu `FA25SE208_Test_Report.xlsx` để xuất ra file hoàn chỉnh:
     👉 `d:\Capstone\docs\Test\Report5_Test_Report_FA26SE090.xlsx`
   - Bạn mở bằng Microsoft Excel sẽ thấy toàn bộ 240 Test Cases đầy đủ 15 cột, tự động cộng tổng sang Sheet `Test Statistics` với tỷ lệ **Test Coverage = 100%**.
3. **Bước 3 — Hoàn Thiện Mục `V.5 Test Reports` Trong Báo Cáo Tổng (`Report7`)**:
   - Mình soạn sẵn bảng thống kê kết quả kiểm thử (Test Result Summary Table) và đoạn phân tích đánh giá chất lượng bằng Tiếng Anh chuẩn học thuật khớp 100% với con số trong file Excel để bạn dán vào trang 119 của `Report7_Final Project Report`.

