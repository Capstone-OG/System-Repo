# BỘ DỮ LIỆU KIỂM THỬ & DEMO HỘI ĐỒNG (VISUAL TEST & DEMO DATASHEET)
## Dự án: AI-powered Personalized Learning Path Platform for Competency Assessment Exam Preparation (V-Eval)
- **Mã dự án**: `FA26SE090` | **Nhóm**: `GFA26SE44` | **Học kỳ**: `Fall 2026 (FA26)`
- **Mục đích tài liệu**: Cung cấp toàn bộ dữ liệu mẫu trực quan chia theo từng **Bảng dữ liệu (Database Entities)** và **Bảng Input Cheat Sheet** phục vụ trực tiếp cho quá trình chạy kiểm thử (Testing) và kịch bản thuyết trình Bảo vệ Đồ án tốt nghiệp trước Hội đồng (Capstone Defense Demo).
- **Quy ước trình bày**: Không sử dụng câu lệnh SQL thô; toàn bộ dữ liệu được tổ chức thành các bảng thuộc tính (Columns & Rows) trực quan, hợp lệ 100% với Business Rules (`BR-01` → `BR-25`) và kiến trúc 4 PostgreSQL Schemas của V-Eval.

---

## PHẦN 1: BẢNG TÀI KHOẢN ĐĂNG NHẬP & MÃ XÁC THỰC DÙNG CHO DEMO & TEST (MASTER CREDENTIALS)

### 1.1. Danh sách Tài khoản theo 6 Vai trò (Role-Based Demo Accounts)
> **Mật khẩu chuẩn hợp lệ dùng chung cho tất cả tài khoản Active**: `Veval@2026` (Thỏa mãn `BR`: ≥ 8 ký tự, có chữ hoa, chữ thường, chữ số và ký tự đặc biệt).

| STT | Vai trò (`Role`) | Họ và Tên (`FullName`) | Email đăng nhập (`Email`) | Mật khẩu (`Password`) | Kích hoạt (`IsActive`) | Cơ sở (`Campus`) | Mục đích sử dụng trong Demo & Kiểm thử |
| :---: | :--- | :--- | :--- | :--- | :---: | :--- | :--- |
| 1 | `ADMIN` | Phạm Tấn Lộc | `admin.veval@fpt.edu.vn` | `Veval@2026` | `true` | Toàn hệ thống | Quản trị RBAC, khóa/mở khóa tài khoản (`ToggleUserStatus`), cấu hình Gemini API Key, xem Audit Logs |
| 2 | `ACADEMIC_DIRECTOR` | TS. Nguyễn Trọng Tài | `director.tai@veval.edu.vn` | `Veval@2026` | `true` | Toàn hệ thống | Quản trị Cây tri thức DAG 4 tầng (Tarjan), Ngân hàng câu hỏi 2PL IRT, kho tài liệu RAG, duyệt câu hỏi AI |
| 3 | `ACADEMIC_MANAGER` | Trần Thái Thịnh | `manager.hcm@veval.edu.vn` | `Veval@2026` | `true` | Cơ sở TP.HCM Q9 | Điều phối tải việc Teacher (`BR-21`), duyệt xếp lớp K-Means (`BR-22`), xem Campus Heatmap, xử lý Tier-3 |
| 4 | `TEACHER` (Teacher 1) | Nguyễn Duy Khôi | `teacher.khoi@veval.edu.vn` | `Veval@2026` | `true` | Cơ sở TP.HCM Q9 | Giám sát Class Heatmap (`BR-17`), phát bài tập 1-Click, hậu kiểm thi thử (`BR-18`), duyệt lộ trình Kickoff |
| 5 | `TEACHER` (Teacher 2) | Lê Hoàng Nam | `teacher.nam@veval.edu.vn` | `Veval@2026` | `true` | Cơ sở TP.HCM Q9 | Đang phụ trách tối đa `20/20` học sinh (Dùng để test chặn quá tải `BR-21` khi phân công thêm) |
| 6 | `PARENT` (Phụ huynh 1) | Nguyễn Văn Hùng | `phuhuynh.hung@gmail.com` | `Veval@2026` | `true` | Cơ sở TP.HCM Q9 | Đã liên kết với Học sinh Minh Anh; dùng để demo Dashboard Phụ huynh, thanh toán PayOS & nhận cảnh báo Tier 1–3 |
| 7 | `PARENT` (Phụ huynh 2) | Trần Thị Mai | `phuhuynh.mai@gmail.com` | `Veval@2026` | `true` | Cơ sở Đà Nẵng | Tài khoản mới chưa liên kết con; dùng để test nhập mã ghép nối `PairingCode` 6 ký tự (`BR-15`) |
| 8 | `STUDENT` (Học sinh 1 - Luồng Chuẩn) | Nguyễn Minh Anh | `minhanh.hs@gmail.com` | `Veval@2026` | `true` | Cơ sở TP.HCM Q9 | Đã hoàn thành Diagnostic 30 câu (`715` điểm), mục tiêu `900` (ĐH Bách Khoa), đang học lộ trình DAG & P-L-A-R |
| 9 | `STUDENT` (Học sinh 2 - Gian lận & Sa sút) | Lê Quốc Bảo | `quocbao.hs@gmail.com` | `Veval@2026` | `true` | Cơ sở TP.HCM Q9 | Có bài thi thử bị gắn cờ `UNDER_REVIEW` (rời tab 4 lần), có cảnh báo Tier-2 & Tier-3 và 5 câu đến hạn SM-2 |
| 10 | `STUDENT` (Học sinh 3 - Tân binh Onboarding) | Võ Gia Hân | `giahan.hs@gmail.com` | `Veval@2026` | `true` | Cơ sở Đà Nẵng | Vừa đăng ký xong, chưa thiết lập mục tiêu & chưa làm bài Diagnostic 30 câu (Dùng demo Onboarding từ đầu) |
| 11 | `STUDENT` (Học sinh 4 - Chưa kích hoạt / Bị khóa) | Đặng Tuấn Kiệt | `tuankiet.locked@gmail.com` | `Veval@2026` | `false` | Cơ sở Cần Thơ | Dùng để kiểm thử chặn đăng nhập `AUTH_12` (`Auth.AccountNotActivated`) và chặn quên mật khẩu `AUTH_13` (`Auth.AccountNotActive`) khi `IsActive = false` |

### 1.2. Bảng Mã Xác Thực `OtpVerifications` (PostgreSQL `v_eval_identity`) & Mã Ghép Nối Phụ Huynh (`PairingCode`) Dùng Khi Test

| Loại mã (`Type`) | Giá trị mã (`OtpCode` / `Code`) | Tài khoản áp dụng (`Email` / `Target`) | Thời hạn (`ExpiresAt`) | Trạng thái trong CSDL (`IsUsed` / `Status`) | Kết quả mong đợi khi nhập |
| :--- | :---: | :--- | :---: | :--- | :--- |
| **`REGISTER_VERIFY` (OTP Đăng ký Hợp lệ)** | `482910` | `newstudent.demo@gmail.com` | `UtcNow + 10 phút` | `IsUsed = false` (Còn hạn trong bảng `OtpVerifications`) | Kích hoạt tài khoản thành công (`Users.IsActive = true`, `OtpVerifications.IsUsed = true`) |
| **`RESET_PASSWORD` (OTP Quên mật khẩu Hợp lệ)** | `739204` | `minhanh.hs@gmail.com` | `UtcNow + 10 phút` | `IsUsed = false` (Còn hạn trong bảng `OtpVerifications`) | Xác thực `POST /api/auth/verify-reset-otp` thành công và cho phép đặt lại mật khẩu mới |
| **`REGISTER_VERIFY` / `RESET_PASSWORD` (OTP Đã hết hạn)** | `110022` | `minhanh.hs@gmail.com` | `ExpiresAt <= UtcNow` (Quá 10p) | `IsUsed = false` (Đã quá hạn `ExpiresAt`) | Báo lỗi HTTP 400 (`Auth.InvalidOtp` / `MSG02`): *"Mã xác thực OTP không chính xác hoặc đã hết hạn."* |
| **`REGISTER_VERIFY` (OTP Đã sử dụng hoặc Nhập sai)** | `999999` | Mọi tài khoản | N/A | `IsUsed = true` hoặc mã không khớp | Báo lỗi HTTP 400 (`Auth.InvalidOtp` / `MSG02`): *"Mã xác thực OTP không chính xác hoặc đã hết hạn."* |
| **Mã ghép nối Phụ huynh (Hợp lệ)** | `VE892K` | Học sinh: `minhanh.hs@gmail.com` | `24 giờ` | Chưa sử dụng (`UNUSED`) | Ghép nối thành công Phụ huynh ↔ Học sinh trong bảng `ParentStudentRelations` |
| **Mã ghép nối Đã hết hạn (> 24h)** | `EX104P` | Học sinh: `quocbao.hs@gmail.com` | Đã quá `24 giờ` | Hết hạn (`EXPIRED`) | Chặn liên kết theo `BR-15`, yêu cầu học sinh sinh mã mới |

---

## PHẦN 2: DỮ LIỆU TRỰC QUAN THEO TỪNG BẢNG CỦA 4 SCHEMA (DATABASE TABLES VISUAL DATA)

### PHÂN KHU 1: `v_eval_identity` (Quản trị Định danh, Cơ sở, Liên kết Phụ huynh & Thanh toán)

#### Bảng 1: `Campuses` (Danh mục Cơ sở Đào tạo)
| `CampusId` (UUID) | `CampusCode` | `CampusName` | `City` | `Address` | `MaxClassCapacity` | `Status` |
| :--- | :---: | :--- | :--- | :--- | :---: | :---: |
| `cam-0001-hcm9` | `HCM-Q9` | V-Eval Campus Khu Công Nghệ Cao Q9 | TP. Hồ Chí Minh | Lô E2a-7, Đường D1, P. Long Thạnh Mỹ, TP. Thủ Đức | `20` | `ACTIVE` |
| `cam-0002-dn01` | `DN-FPT` | V-Eval Campus Khu Đô Thị FPT Đà Nẵng | Đà Nẵng | Phường Hòa Hải, Quận Ngũ Hành Sơn, TP. Đà Nẵng | `20` | `ACTIVE` |
| `cam-0003-hn01` | `HN-HL` | V-Eval Campus Hòa Lạc Hà Nội | Hà Nội | Km29 Đại lộ Thăng Long, Huyện Thạch Thất, Hà Nội | `20` | `ACTIVE` |
| `cam-0004-ct01` | `CT-NK` | V-Eval Campus Ninh Kiều Cần Thơ | Cần Thơ | Số 600 Đường Nguyễn Văn Cừ Nối Dài, Q. Ninh Kiều | `15` | `ACTIVE` |

#### Bảng 2: `Users` (Tài khoản Người dùng Hệ thống)
| `UserId` (UUID) | `Email` | `FullName` | `PhoneNumber` | `Role` | `IsActive` | `EmailVerified` | `CampusId` |
| :--- | :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| `usr-admin-001` | `admin.veval@fpt.edu.vn` | Phạm Tấn Lộc | `0901234501` | `ADMIN` | `true` (`Hoạt động`) | `true` | `cam-0001-hcm9` |
| `usr-dir-001` | `director.tai@veval.edu.vn` | TS. Nguyễn Trọng Tài | `0901234502` | `ACADEMIC_DIRECTOR` | `true` (`Hoạt động`) | `true` | `cam-0001-hcm9` |
| `usr-mgr-001` | `manager.hcm@veval.edu.vn` | Trần Thái Thịnh | `0901234503` | `ACADEMIC_MANAGER` | `true` (`Hoạt động`) | `true` | `cam-0001-hcm9` |
| `usr-tch-001` | `teacher.khoi@veval.edu.vn` | Nguyễn Duy Khôi | `0901234504` | `TEACHER` | `true` (`Hoạt động`) | `true` | `cam-0001-hcm9` |
| `usr-tch-002` | `teacher.nam@veval.edu.vn` | Lê Hoàng Nam | `0901234505` | `TEACHER` | `true` (`Hoạt động`) | `true` | `cam-0001-hcm9` |
| `usr-par-001` | `phuhuynh.hung@gmail.com` | Nguyễn Văn Hùng | `0908112233` | `PARENT` | `true` (`Hoạt động`) | `true` | `cam-0001-hcm9` |
| `usr-par-002` | `phuhuynh.mai@gmail.com` | Trần Thị Mai | `0908445566` | `PARENT` | `true` (`Hoạt động`) | `true` | `cam-0002-dn01` |
| `usr-stu-001` | `minhanh.hs@gmail.com` | Nguyễn Minh Anh | `0912334455` | `STUDENT` | `true` (`Hoạt động`) | `true` | `cam-0001-hcm9` |
| `usr-stu-002` | `quocbao.hs@gmail.com` | Lê Quốc Bảo | `0912667788` | `STUDENT` | `true` (`Hoạt động`) | `true` | `cam-0001-hcm9` |
| `usr-stu-003` | `giahan.hs@gmail.com` | Võ Gia Hân | `0912990011` | `STUDENT` | `true` (`Hoạt động`) | `true` | `cam-0002-dn01` |
| `usr-stu-004` | `tuankiet.locked@gmail.com` | Đặng Tuấn Kiệt | `0912009988` | `STUDENT` | `false` (`Đã khóa`) | `true` | `cam-0004-ct01` |

#### Bảng 3: `Students` (Hồ sơ Học thuật & Mục tiêu Điểm ĐGNL của Học sinh)
| `StudentId` | `UserId` | `GradeLevel` | `HighSchoolName` | `TargetScore` | `TargetUniversity` | `TargetMajor` | `ReferenceCutoffScore` | `ExamDate` | `AssignedTeacherId` | `CurrentStreakDays` |
| :--- | :--- | :---: | :--- | :---: | :--- | :--- | :---: | :---: | :--- | :---: |
| `stu-profile-001` | `usr-stu-001` | Lớp 12 | THPT Chuyên Lê Hồng Phong | `900` | ĐH Bách Khoa - ĐHQG TP.HCM | Khoa học Máy tính | `885` | `2027-03-28` | `usr-tch-001` | `14 ngày` |
| `stu-profile-002` | `usr-stu-002` | Lớp 12 | THPT Nguyễn Thị Minh Khai | `980` | ĐH Khoa học Tự nhiên - ĐHQG HCM | Trí tuệ Nhân tạo | `940` | `2026-12-15` | `usr-tch-001` | `0 ngày` (Nghỉ 5 ngày) |
| `stu-profile-003` | `usr-stu-003` | Lớp 12 | THPT Phan Châu Trinh | `Chưa đặt` | `Chưa chọn` | `Chưa chọn` | `N/A` | `2027-03-28` | `Chưa gán` | `1 ngày` |

#### Bảng 4: `ParentStudentLinks` (Liên kết Tài khoản Phụ huynh – Học sinh theo `BR-15`)
| `LinkId` | `ParentUserId` | `StudentId` | `PairingCode` | `RelationshipType` | `CodeGeneratedAt` | `CodeExpiresAt` | `LinkStatus` |
| :--- | :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| `lnk-001` | `usr-par-001` | `stu-profile-001` | `VE2026` | Bố ruột (`FATHER`) | `2026-10-01 08:00` | `2026-10-02 08:00` | `ACTIVE` (Đã ghép nối) |
| `lnk-002` | `Chưa nhập` | `stu-profile-001` | `VE892K` | Đang chờ (`PENDING`) | Hiện tại (`Now`) | `Now + 24 giờ` | `PENDING_PAIRING` |
| `lnk-003` | `Chưa nhập` | `stu-profile-002` | `EX104P` | Đang chờ (`PENDING`) | `2026-10-15 09:00` | `2026-10-16 09:00` | `EXPIRED` (Quá hạn 24h) |

#### Bảng 5: `StudyPackages` & `PaymentTransactions` (Gói Học phí & Giao dịch Thanh toán PayOS / VietQR theo `BR-16`)
| `TransactionId` | `OrderCode` | `ParentUserId` | `StudentId` | `PackageName` | `AmountVND` | `PaymentGateway` | `WebhookSignatureValid` | `Status` | `UnlockedFeatures` |
| :--- | :---: | :--- | :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| `pay-tx-001` | `26109001` | `usr-par-001` | `stu-profile-001` | `PRO_ADAPTIVE_6M` (Lộ trình AI Toàn diện 6 tháng) | `2,490,000 VNĐ` | `PayOS / VietQR` | `true` (HMAC-SHA256 khớp) | `PAID` | Mở khóa toàn bộ P-L-A-R, Socratic AI & 10 đề Mock Exam |
| `pay-tx-002` | `26109002` | `usr-par-001` | `stu-profile-001` | `MOCK_EXAM_PASS_5` (Gói 5 lượt Thi thử ĐGNL 150p) | `390,000 VNĐ` | `PayOS / VietQR` | `Chờ thanh toán` | `PENDING` | Chưa mở khóa (Dùng để demo quét QR / bắn Webhook giả lập) |
| `pay-tx-003` | `26109003` | `usr-par-002` | `stu-profile-002` | `PRO_ADAPTIVE_6M` (Lộ trình AI Toàn diện 6 tháng) | `2,490,000 VNĐ` | `PayOS / VietQR` | `false` (Sai chữ ký) | `FAILED` | Bị từ chối kích hoạt theo `BR-16` |

---

### PHÂN KHU 2: `v_eval_content` (Đồ thị Tri thức DAG 4 tầng, Ngân hàng Câu hỏi 2PL IRT & Kho học liệu RAG)

#### Bảng 6: `CompetencyNodes` (Các Đỉnh Kỹ năng trên Đồ thị Tri thức 4 tầng: Domain → Subject → Skill → Pattern)
| `NodeId` | `NodeCode` | `TierLevel` | `ParentNodeId` | `NodeName` | `DomainGroup` | `WeightInExam` | `VideoUrl` | `Status` |
| :--- | :---: | :---: | :---: | :--- | :--- | :---: | :--- | :---: |
| `node-dom-02` | `DOM-MATH` | `1 - DOMAIN` | `NULL` | Toán học, Tư duy Logic & Phân tích số liệu | Phần 2: Toán & Logic (30 câu) | `25.0%` | `N/A` | `ACTIVE` |
| `node-sub-021` | `SUB-CALC` | `2 - SUBJECT` | `node-dom-02` | Giải tích & Hàm số THPT | Phần 2: Toán & Logic | `10.0%` | `N/A` | `ACTIVE` |
| `node-skl-101` | `SKL-FUNC-01` | `3 - SKILL` | `node-sub-021` | Khảo sát sự biến thiên và cực trị của hàm số | Phần 2: Toán & Logic | `4.5%` | `https://cdn.veval.edu.vn/videos/skl-func-01.mp4` | `ACTIVE` |
| `node-skl-102` | `SKL-INTG-02` | `3 - SKILL` | `node-sub-021` | Nguyên hàm, Tích phân và Ứng dụng hình học | Phần 2: Toán & Logic | `4.0%` | `https://cdn.veval.edu.vn/videos/skl-intg-02.mp4` | `ACTIVE` |
| `node-skl-201` | `SKL-LOGI-01` | `3 - SKILL` | `node-dom-02` | Tư duy Logic mệnh đề & Xếp chỗ (Analytical Reasoning) | Phần 2: Toán & Logic | `5.0%` | `https://cdn.veval.edu.vn/videos/skl-logi-01.mp4` | `ACTIVE` |
| `node-skl-202` | `SKL-DATA-01` | `3 - SKILL` | `node-dom-02` | Đọc hiểu & Phân tích bảng số liệu / Biểu đồ thống kê | Phần 2: Toán & Logic | `5.5%` | `https://cdn.veval.edu.vn/videos/skl-data-01.mp4` | `ACTIVE` |
| `node-skl-301` | `SKL-VIET-01` | `3 - SKILL` | `node-dom-01` | Đọc hiểu văn bản & Xác định lỗi ngữ pháp Tiếng Việt | Phần 1: Ngôn ngữ (40 câu) | `8.0%` | `https://cdn.veval.edu.vn/videos/skl-viet-01.mp4` | `ACTIVE` |
| `node-skl-401` | `SKL-PHYS-01` | `3 - SKILL` | `node-dom-03` | Dao động cơ học & Điện xoay chiều (Giải quyết vấn đề) | Phần 3: Giải quyết vấn đề (50 câu) | `4.0%` | `https://cdn.veval.edu.vn/videos/skl-phys-01.mp4` | `ACTIVE` |

#### Bảng 7: `CompetencyEdges` (Cạnh Điều kiện Tiên quyết DAG – Kiểm chứng bằng Thuật toán Tarjan & Kahn `BR-04`, `BR-19`)
| `EdgeId` | `PrerequisiteNodeId` (Đỉnh Tiên quyết u) | `DependentNodeId` (Đỉnh Phụ thuộc v) | `RelationType` | `TarjanValidationStatus` | Giải thích Nghiệp vụ trong Kiểm thử & Demo |
| :--- | :--- | :--- | :---: | :---: | :--- |
| `edge-001` | `SKL-FUNC-01` (Đạo hàm & Khảo sát hàm số) | `SKL-INTG-02` (Nguyên hàm & Tích phân) | `HARD_PREREQ` | `VALID_DAG` | Học sinh phải đạt `P(L_t) ≥ 0.85` ở `SKL-FUNC-01` mới mở khóa `SKL-INTG-02` (`BR-05`) |
| `edge-002` | `SKL-LOGI-01` (Tư duy Logic mệnh đề) | `SKL-DATA-01` (Phân tích bảng số liệu) | `SOFT_PREREQ` | `VALID_DAG` | Kahn Topological Sort luôn xếp `SKL-LOGI-01` đứng trước `SKL-DATA-01` |
| `edge-test-cycle` | `SKL-INTG-02` (Nguyên hàm & Tích phân) | `SKL-FUNC-01` (Đạo hàm & Khảo sát hàm số) | `INVALID_TEST` | `REJECTED_BY_TARJAN` | Dữ liệu dùng để demo tạo chu trình `SKL-FUNC-01 → SKL-INTG-02 → SKL-FUNC-01` → Hệ thống báo lỗi `MSG09` |

#### Bảng 8: `Questions` (Ngân hàng Câu hỏi Chuẩn hóa Tham số Tâm trắc học 2PL IRT `a, b` theo `BR-20`)
| `QuestionId` | `NodeCode` | `StemContent` (Nội dung câu hỏi ĐGNL ĐHQG-HCM) | `Options` (A / B / C / D) | `CorrectOption` | `IRT_a` (Độ phân biệt) | `IRT_b` (Độ khó) | `SourceType` | `ApprovalStatus` |
| :--- | :---: | :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| `q-math-001` | `SKL-FUNC-01` | Cho hàm số `y = x³ − 3x² + 2`. Giá trị cực đại của hàm số đã cho bằng bao nhiêu? | `A. 2` \| `B. −2` \| `C. 0` \| `D. 4` | `A` | `1.25` | `−0.40` | `EXPERT_CREATED` | `APPROVED` (Dùng cho cả Thi & Luyện) |
| `q-math-002` | `SKL-FUNC-01` | Tìm tất cả các giá trị thực của tham số `m` để hàm số `y = x³ − 3mx² + 3(m² − 1)x + 1` đạt cực đại tại `x = 1`. | `A. m = 1` \| `B. m = 2` \| `C. m = −1` \| `D. m = 0` | `B` | `1.50` | `+0.65` | `EXPERT_CREATED` | `APPROVED` (Khớp ZPD cho `θ = 0.20`) |
| `q-math-003` | `SKL-INTG-02` | Biết tích phân từ `0` đến `1` của `(2x + 1)e^x dx = a + b·e` với `a, b` nguyên. Tính `S = a + b`. | `A. 1` \| `B. 2` \| `C. 3` \| `D. 0` | `B` | `1.65` | `+1.15` | `EXPERT_CREATED` | `APPROVED` |
| `q-logi-001` | `SKL-LOGI-01` | Trong một hội nghị có 5 diễn giả M, N, P, Q, R phát biểu liên tiếp. Biết M phát biểu trước N nhưng sau P; Q không phát biểu cuối cùng. Ai không thể phát biểu đầu tiên? | `A. P` \| `B. Q` \| `C. N` \| `D. R` | `C` | `1.40` | `+0.25` | `EXPERT_CREATED` | `APPROVED` |
| `q-ai-var-009` | `SKL-FUNC-01` | **[Biến thể AI sinh từ `q-math-002`]** Tìm tham số `m` để hàm số `y = x³ − 3(m+1)x² + 3(m² + 2m)x − 5` đạt cực tiểu tại `x = 2`. | `A. m = 0` \| `B. m = 1` \| `C. m = 2` \| `D. m = −1` | `A` | `1.48` | `+0.60` | `AI_GENERATED` | `PRACTICE_ONLY` (Chặn đưa vào đề thi theo `BR-20`) |

---

### PHÂN KHU 3: `v_eval_practice` (Chẩn đoán Đầu vào, Lộ trình Cá nhân P-L-A-R, Thi thử Giám sát & Sổ tay SM-2)

#### Bảng 9: `DiagnosticSubmissions` (Kết quả Bài thi Chẩn đoán Đầu vào 30 câu theo `BR-02`, `BR-03`)
| `DiagSubmissionId` | `StudentId` | `TotalQuestions` | `CorrectCount` | `DurationSeconds` | `OverallTheta` (`θ`) | `ConvertedScore` (Thang 1200) | `TargetScore` | `GapScore` (`Δ`) | `TriggeredAlert` |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :--- |
| `diag-sub-001` | `stu-profile-001` (Minh Anh) | `30 / 30` | `19 / 30` | `2,140s` (~35p) | `+0.32` | `715 / 1200` | `900` | `185 điểm` | `NONE` (Mục tiêu khả thi trong 140 ngày) |
| `diag-sub-002` | `stu-profile-002` (Quốc Bảo) | `30 / 30` | `12 / 30` | `1,890s` (~31p) | `−0.55` | `550 / 1200` | `980` | `430 điểm` | `UNREALISTIC_GOAL` (`Δ = 430 > 250` và còn `< 60` ngày theo `BR-01`) |

#### Bảng 10: `PersonalRoadmaps` & `LearningStages` (Chặng Học Tập Thích Ứng 4 Bước P-L-A-R theo `BR-04` → `BR-08`)
| `StageId` | `StudentId` | `NodeCode` | `TopologicalOrder` | `CurrentPLARStep` | `VideoWatchPercent` | `CurrentBKT_P_Lt` | `CurrentIRT_Theta` | `RapidGuessCount` (`< 5s`) | `StageStatus` |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| `stg-001` | `stu-profile-001` (Minh Anh) | `SKL-VIET-01` | `Chặng #1` | `4 - REVIEW` | `100%` | `0.89` (`≥ 0.85`) | `+0.82` | `0` | `MASTERED` (Đã mở khóa chặng kế tiếp) |
| `stg-002` | `stu-profile-001` (Minh Anh) | `SKL-FUNC-01` | `Chặng #2` | `3 - ADAPT` | `86.5%` (`≥ 80%`) | `0.78` (Đang tiệm cận `0.85`) | `+0.45` | `0` | `IN_PROGRESS` (Đang luyện câu hỏi vùng ZPD) |
| `stg-003` | `stu-profile-001` (Minh Anh) | `SKL-INTG-02` | `Chặng #3` | `1 - PROBE` | `0%` | `0.25` (Khởi tạo `P(L_0)`) | `−0.30` | `0` | `LOCKED` (Chờ `SKL-FUNC-01` đạt `0.85` theo `BR-05`) |
| `stg-004` | `stu-profile-002` (Quốc Bảo) | `SKL-FUNC-01` | `Chặng #1` | `2 - LEARN` | `62.0%` (`< 80%`) | `0.41` | `−0.40` | `2 lần` (Bị đóng băng BKT `BR-07`) | `IN_PROGRESS` (Bị chặn sang bước ADAPT do Video `< 80%` `BR-06`) |

#### Bảng 11: `ExamSubmissions` & `ProctoringLogs` (Kết quả Thi thử ĐGNL 120 câu / 150 phút & Nhật ký Giám sát Chống gian lận `BR-10`, `BR-11`, `BR-18`)
| `ExamSubId` | `StudentId` | `ExamTitle` | `AnsweredCount` | `TimeSpent` | `RawScore` (Thang 1200) | `TabDepartureCount` | `WebcamSnapshots` (Cloud Storage WebP `< 300KB`) | `SubmissionStatus` | `TeacherVerdict` |
| :--- | :--- | :--- | :---: | :---: | :---: | :---: | :--- | :---: | :--- |
| `exm-sub-001` | `stu-profile-001` (Minh Anh) | Đề Thi Thử ĐGNL ĐHQG-HCM Đợt 1 - Mã đề 101 | `120 / 120` | `142 phút` | `785 / 1200` | `1 lần` (`≤ 3`) | `15 ảnh WebP` (Hợp lệ, bình thường) | `COMPLETED` | Tự động công nhận điểm (`Valid`) |
| `exm-sub-002` | `stu-profile-002` (Quốc Bảo) | Đề Thi Thử ĐGNL ĐHQG-HCM Đợt 1 - Mã đề 101 | `114 / 120` | `150 phút` (Auto-Submit) | `840 / 1200` (Tạm khóa) | `4 lần` (`> 3` vi phạm `BR-11`) | `16 ảnh WebP` (Ảnh #7, #11 phát hiện nhìn tài liệu ngoài) | `UNDER_REVIEW` | Chờ Teacher `teacher.khoi` duyệt `APPROVED` hoặc `DISQUALIFIED` |

#### Bảng 12: `MistakeNotebooks` (Sổ tay Lỗi sai & Lịch Ôn tập Ngắt quãng Thuật toán SM-2 theo `BR-12`)
| `MistakeId` | `StudentId` | `OriginalQuestionId` | `VariantQuestionId` (Câu biến thể khi ôn) | `RepetitionCount` (`n`) | `EasinessFactor` (`EF ≥ 1.3`) | `IntervalDays` (`I_n`) | `NextReviewDate` | `SM2Status` |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| `mst-001` | `stu-profile-001` (Minh Anh) | `q-math-002` | `q-ai-var-009` | `1` | `2.50` | `1 ngày` | Hôm nay (`Due Today`) | `DUE_FOR_REVIEW` (Hiển thị trên hàng đợi ôn tập hôm nay) |
| `mst-002` | `stu-profile-001` (Minh Anh) | `q-logi-001` | `q-logi-var-02` | `2` | `2.60` | `6 ngày` | `+6 ngày tới` | `SCHEDULED` |
| `mst-003` | `stu-profile-002` (Quốc Bảo) | `q-math-003` | `q-ai-var-012` | `0` (Vừa trả lời sai) | `1.30` (Chạm sàn `EF_min`) | `1 ngày` | Quá hạn 3 ngày (`Overdue`) | `OVERDUE` (Kích hoạt cảnh báo tồn đọng) |

#### Bảng 13: `Classes` & `StudyGroups` (Lớp học Phân cụm Tự động K-Means 4 Miền Năng lực theo `BR-22`)
| `ClassId` | `ClassCode` | `CampusId` | `KMeansClusterLabel` | `CentroidVector` (`[Ngôn ngữ, Toán-Logic, Số liệu, KH Tự nhiên-XH]`) | `TeacherId` | `StudentCount` | `ClassStatus` |
| :--- | :---: | :---: | :--- | :---: | :--- | :---: | :---: |
| `cls-hcm-01` | `FA26-HCM-C1` | `cam-0001-hcm9` | Cụm 1: Mạnh Ngôn ngữ – Yếu Toán & Phân tích Số liệu | `[0.78, 0.42, 0.39, 0.65]` | `usr-tch-001` (Duy Khôi) | `18 / 20` | `APPROVED` |
| `cls-hcm-02` | `FA26-HCM-C2` | `cam-0001-hcm9` | Cụm 2: Mạnh Tự nhiên – Cần tăng tốc Đọc hiểu & Logic | `[0.48, 0.76, 0.72, 0.81]` | `usr-tch-002` (Hoàng Nam) | `20 / 20` (Đầy tải `BR-21`) | `APPROVED` |
| `grp-rem-01` | `REM-FUNC-01` | `cam-0001-hcm9` | Nhóm Phụ đạo Chuyên sâu Kỹ năng Cực trị Hàm số (`SKL-FUNC-01`) | Các học sinh có `P(L_t) < 0.50` (`BR-17`) | `usr-tch-001` (Duy Khôi) | `5 / 6` (Tối đa 6 HS) | `ACTIVE_INTERVENTION` |

---

### PHÂN KHU 4: `v_eval_ai` (Dự báo Điểm 95% SEM, Đơn thuốc Bài tập Knapsack, Phiên Gia sư Socratic & Cảnh báo 3 Tầng)

#### Bảng 14: `ScorePredictions` (Dự báo Điểm ĐGNL Khoảng Tin Cậy 95% SEM & Xác suất Đậu Đại học theo `BR-13`)
| `PredictionId` | `StudentId` | `ThetaVector` (`[θ_NN, θ_Toán, θ_KH]`) | `PredictedScore` (`S_pred`) | `SEM_Value` | `ConfidenceInterval95` (`S_pred ± 1.96 × SEM`) | `TargetUniversity` | `TargetCutoff` | `PassProbability` |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- | :---: | :---: |
| `prd-001` | `stu-profile-001` (Minh Anh) | `[+0.65, +0.42, +0.50]` | `812 điểm` | `18.5 điểm` | `[776 – 848 điểm]` | ĐH Bách Khoa - ĐHQG TP.HCM (`900`) | `885` | `64.5%` (Cần bù `88 điểm` qua Knapsack) |
| `prd-002` | `stu-profile-002` (Quốc Bảo) | `[−0.30, −0.55, −0.40]` | `565 điểm` | `24.0 điểm` | `[518 – 612 điểm]` | ĐH Khoa học Tự nhiên (`980`) | `940` | `11.2%` (Nguy cơ trượt rất cao) |

#### Bảng 15: `RemedialPrescriptions` (Đơn thuốc Bài tập Bù đắp Thâm hụt Giải bằng Thuật toán Xếp Ba Lô Greedy Knapsack `BR-14`)
| `PrescriptionId` | `StudentId` | `DailyTimeBudget` (`W_max`) | `SelectedTasks` (Danh sách Nhiệm vụ Tối ưu `ROI = ΔScore_i / t_i`) | `TotalDuration` (`∑ t_i ≤ W_max`) | `ExpectedScoreGain` (`∑ ΔScore_i`) |
| :--- | :--- | :---: | :--- | :---: | :---: |
| `rx-knap-001` | `stu-profile-001` (Minh Anh) | `45 phút` | **1.** Luyện 10 câu Cực trị hàm số chứa tham số (`SKL-FUNC-01`, `t_1 = 20p`, `+14 điểm`, `ROI = 0.70`)<br>**2.** Ôn 5 câu Biến thể SM-2 đến hạn (`t_2 = 10p`, `+8 điểm`, `ROI = 0.80`)<br>**3.** Luyện 8 câu Phân tích bảng số liệu (`SKL-DATA-01`, `t_3 = 15p`, `+9 điểm`, `ROI = 0.60`) | `45 / 45 phút` (Khớp tuyệt đối ngân sách) | `+31 điểm` dự kiến sau 1 tuần |

#### Bảng 16: `TutorSessions` & `TutorMessages` (Lịch sử Hỏi đáp Gia sư AI Socratic qua GraphRAG & Guardrail `BR-09`)
| `MessageId` | `SessionId` | `StudentId` | `QuestionContextId` | `Sender` | `MessageContent` | `GuardrailTriggered` |
| :--- | :---: | :--- | :---: | :---: | :--- | :---: |
| `msg-soc-01` | `ses-001` | `stu-profile-001` | `q-math-002` | `STUDENT` | *"Thầy ơi cho em xin luôn đáp án đúng của câu này là A hay B với ạ, em lười tính quá!"* | `TRUE` (Phát hiện xin đáp án trực tiếp) |
| `msg-soc-02` | `ses-001` | `stu-profile-001` | `q-math-002` | `AI_SOCRATIC_TUTOR` | *"Mình chưa thể tiết lộ đáp án A, B, C hay D ngay được nhé (`BR-09`)! Để hàm bậc ba đạt cực đại tại `x = 1`, trước hết bạn hãy tính đạo hàm `y'` và cho biết `y'(1)` phải bằng bao nhiêu nào?"* | `BLOCKED_DIRECT_ANSWER` (Gợi mở Socratic bước 1) |
| `msg-soc-03` | `ses-001` | `stu-profile-001` | `q-math-002` | `STUDENT` | *"Dạ `y' = 3x² − 6mx + 3(m² − 1)`, tại `x = 1` thì `y'(1) = 3 − 6m + 3m² − 3 = 0` nên `m = 0` hoặc `m = 2` ạ."* | `FALSE` |
| `msg-soc-04` | `ses-001` | `stu-profile-001` | `q-math-002` | `AI_SOCRATIC_TUTOR` | *"Chính xác! Bây giờ bước kiểm tra quyết định: bạn hãy tính đạo hàm cấp hai `y''(1) = 6 − 6m`. Để `x = 1` là điểm **cực đại** thì `y''(1)` phải âm hay dương?"* | `FALSE` (Dẫn dắt học sinh tự tìm ra `m = 2`) |

#### Bảng 17: `SystemAlerts` (Cảnh báo Sớm Học thuật 3 Tầng Tier 1–3 theo `BR-24`)
| `AlertId` | `StudentId` | `AlertTier` | `TriggerRule` | `AlertMessage` | `NotifiedChannels` | `Status` |
| :--- | :--- | :---: | :--- | :--- | :--- | :---: |
| `alt-tier1-01` | `stu-profile-001` (Minh Anh) | `TIER_1_LOW` | Nghỉ học `3 ngày` liên tiếp hoặc chậm 1 cột mốc tuần | *"Nhắc nhở nhẹ: Minh Anh chưa hoàn thành chặng `SKL-FUNC-01` trong 3 ngày qua. Hãy dành 20 phút luyện tập hôm nay để giữ chuỗi Streak nhé!"* | In-App Notification cho Học sinh | `RESOLVED` |
| `alt-tier2-01` | `stu-profile-002` (Quốc Bảo) | `TIER_2_MEDIUM` | Nghỉ học `5 ngày` liên tiếp & `P(L_t)` sụt giảm `> 15%` | *"Cảnh báo Trung bình (Tier 2): Học sinh Lê Quốc Bảo đã ngưng luyện tập 5 ngày và điểm thành thạo Giải tích giảm 18%. Hệ thống đã thông báo cho Phụ huynh và Teacher."* | Push App + Email cho Phụ huynh & Teacher (`teacher.khoi`) | `OPEN` |
| `alt-tier3-01` | `stu-profile-002` (Quốc Bảo) | `TIER_3_CRITICAL` | Dự báo điểm trượt sâu dưới mục tiêu `> 200 điểm` kèm vi phạm quy chế thi thử | *"Cảnh báo Nghiêm trọng (Tier 3): Khoảng cách mục tiêu của Lê Quốc Bảo đang thiếu hụt 415 điểm và có bài thi thử bị gắn cờ gian lận. Yêu cầu Academic Manager tổ chức họp 3 bên."* | Escalate lên Academic Manager (`manager.hcm`), Teacher & Phụ huynh | `ESCALATED` |

---

## PHẦN 3: BẢNG GIÁ TRỊ INPUT CHEAT SHEET KHI CHẠY TEST CASE & DEMO TRỰC TIẾP

> Bảng dưới đây tổng hợp các bộ giá trị **Valid (Hợp lệ)**, **Boundary (Biên)** và **Invalid (Bất hợp lệ)** để thành viên nhóm copy/paste trực tiếp vào giao diện Web hoặc Swagger/Postman khi thực hiện kiểm thử 240 Test Cases:

| Nhóm Chức năng | Trường dữ liệu (`Input Field`) | Giá trị Hợp lệ (`Valid Input`) | Giá trị Biên (`Boundary Input`) | Giá trị Bất hợp lệ (`Invalid Input`) | Mã thông báo / Quy tắc kiểm chứng |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **1. Đăng ký & Bảo mật** | `Email` | `hocvien.test01@gmail.com` | Độ dài 6–254 ký tự | `hocvien.gmail.com` (thiếu `@`), `minhanh.hs@gmail.com` (đã tồn tại) | Báo lỗi định dạng hoặc trùng Email |
| **1. Đăng ký & Bảo mật** | `Password` | `Veval@2026` | Đúng `8` ký tự: `Ve@2026a` | `1234567` (`< 8` ký tự), `veval2026` (thiếu chữ hoa & ký tự đặc biệt) | Báo lỗi độ mạnh mật khẩu |
| **2. Thiết lập Mục tiêu (`FE-04`)** | `TargetScore` (Điểm mục tiêu ĐGNL) | `900` | Biên dưới: `300`<br>Biên trên: `1200` | `250` (`< 300`), `1250` (`> 1200`), `-100`, `abc` | `BR-01` & `MSG03`: Chỉ nhận số nguyên `[300, 1200]` |
| **2. Thiết lập Mục tiêu (`FE-04`)** | Kịch bản kích hoạt `UNREALISTIC_GOAL` | `TargetScore = 850` (Khi điểm chẩn đoán `= 715`, còn `140` ngày) | `Gap Δ = 250`, thời gian còn đúng `60` ngày | Đặt `TargetScore = 1050` khi điểm chẩn đoán `= 600` (`Δ = 450 > 250`) và ngày thi còn `45` ngày (`< 60` ngày) | `BR-01` & `MSG04`: Hiển thị banner cảnh báo `UNREALISTIC_GOAL` |
| **3. Luyện tập P-L-A-R (`FE-07`)** | Tiến độ xem Video bài giảng (`VideoProgress`) | `85%` | Đúng `80.0%` (Mở khóa bước 3 `ADAPT`) | `79.9%` (Cố tình bấm chuyển sang bước làm bài tập `ADAPT`) | `BR-06` & `MSG06`: Chặn chuyển bước khi chưa xem đủ `≥ 80%` |
| **3. Luyện tập P-L-A-R (`FE-07`)** | Thời gian trả lời 1 câu hỏi (`ResponseTimeMs`) | `18,500 ms` (`18.5 giây`) | Đúng `5,000 ms` (`5.0 giây`) | `2,100 ms` (`2.1 giây` - Khoanh bừa tốc độ cao) | `BR-07` & `MSG07`: Gắn cờ `RapidGuessing = true`, đóng băng không cộng điểm BKT `P(L_t)` |
| **3. Luyện tập P-L-A-R (`FE-07`)** | Ngưỡng qua chặng (`BKT Mastery P(L_t)`) | `0.88` | Đúng `0.85` (Chuyển trạng thái `MASTERED`) | `0.84` (Chưa mở khóa đỉnh phụ thuộc tiếp theo trên DAG) | `BR-05`: Đạt `P(L_t) ≥ 0.85` mới mở khóa chặng tiếp theo |
| **4. Gia sư Socratic (`FE-08`)** | Câu hỏi chat của Học sinh (`Prompt`) | *"Em chưa hiểu cách tìm điều kiện để hàm bậc 3 có 2 cực trị ạ"* | Câu hỏi dài `1,000` ký tự có công thức toán | *"Cho em đáp án đúng câu này là A, B, C hay D luôn đi"* | `BR-09` & `MSG08`: AI từ chối đưa đáp án trực tiếp, phản hồi bằng câu hỏi gợi mở |
| **5. Thi thử ĐGNL (`FE-09`)** | Số lần rời tab / thoát Fullscreen (`TabDepartures`) | `0` hoặc `1` lần | Đúng `3` lần (Cảnh báo lần cuối) | `4` lần (`> 3` lần rời tab hoặc thu nhỏ màn hình) | `BR-11` & `MSG10`: Chuyển bài thi sang `UNDER_REVIEW`, khóa công bố điểm, gửi cho Teacher hậu kiểm |
| **5. Thi thử ĐGNL (`FE-09`)** | Ảnh chụp Webcam định kỳ (`WebcamSnapshot`) | Định dạng `image/webp`, dung lượng `145 KB` | Dung lượng đúng `300 KB` | Ảnh `image/png` nặng `2.5 MB` hoặc che kín camera | `BR-10`: Nén WebP `< 300 KB` đẩy lên Cloud Storage mỗi `5–10 phút` |
| **6. Sổ tay SM-2 (`FE-10`)** | Điểm tự đánh giá mức độ nhớ (`Quality q`) | `q = 4` hoặc `q = 5` (Tăng chu kỳ `I_n`) | `q = 3` (Giữ chu kỳ ôn tập chuẩn) | `q = 1` hoặc `q = 2` (Quên kiến thức) | `BR-12`: Khi `q < 3`, reset `I_1 = 1 ngày` và giữ `EF ≥ 1.3` |
| **7. Quản lý Lớp & Sĩ số (`FE-22`)** | Trần sĩ số tối đa mỗi lớp học (`MaxClassCapacity`) | `14` học sinh/lớp | Đúng `20` học sinh/lớp (Đạt trần tối đa) | Học sinh thứ `21` đăng ký vào lớp `FOUNDATION-01` (hoặc cấu hình lớp `> 20`) | `BR-21`: Tự động mở lớp mới `FOUNDATION-02` khi lớp cũ chạm trần `20/20` |
| **8. Cây tri thức DAG (`FE-19`)** | Thêm cạnh tiên quyết mới (`u → v`) | `SKL-FUNC-01 → SKL-INTG-02` | Đồ thị sâu 4 tầng không chu trình | Thêm cạnh ngược `SKL-INTG-02 → SKL-FUNC-01` khi đã có `SKL-FUNC-01 → SKL-INTG-02` | `BR-19` & `MSG09`: Thuật toán Tarjan phát hiện chu trình (`SCC > 1`) và từ chối lưu |
| **9. Ngân hàng câu hỏi (`FE-20`)** | Tham số IRT (`a, b`) khi tạo đề thi chuẩn | `a = 1.35`, `b = 0.50`, `Status = APPROVED` | `a ∈ [0.5, 2.5]`, `b ∈ [−3.0, +3.0]` | Câu hỏi AI sinh có `Status = PRACTICE_ONLY` hoặc `a = -0.5` | `BR-20`: Chặn tuyệt đối đưa câu hỏi `PRACTICE_ONLY` vào đề Diagnostic / Mock Exam |

