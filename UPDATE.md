# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [18/10/2026] - Khởi Tạo Nhánh Core Flow 6, CSDL Chuẩn Hóa Schema V3 & Bản Đặc Tả ERD Mức Khái Niệm (46 Entities)

- **Khởi Tạo CSDL Hợp Nhất Schema V3 (`docs/SQL/V_EVAL_SCHEMA_V3.sql`)**:
  - Tích hợp 100% các thực thể đã triển khai từ cả 3 service cốt lõi (`Identity_Service`, `Content_Service`, `Practice_Service`) cùng phân hệ `Ai_Engine` (RAG pgvector).
  - Tinh gọn lược bỏ các thực thể Live trực tuyến (`LiveSessions`, `LiveSessionAttendance`) do chuyển dịch sang mô hình đào tạo trực tiếp tại lớp. Giữ nguyên trạng 100% file gốc `docs/SQL/SQL.sql`.
  - Bổ sung các thực thể vận hành thực tế: `RefreshTokens`, `OtpVerifications`, `SkillPrerequisites` (Đồ thị DAG tiên quyết), `ClassGroups` & `ClassGroupMembers` (Nhóm vi mô 3–5 học sinh), `StageProgress` (P-L-A-R), `AdaptiveQuizAttempts` (BKT & IRT ZPD), `MistakeNotebooks` (SM-2 Spaced Repetition), `ProctoringSnapshots` (Webcam giám sát thi cử).
  - Bổ sung đầy đủ thực thể Core Flow 6: `ScorePredictions` (dải điểm SEM, thâm hụt điểm, Toa thuốc bù điểm Knapsack ROI trong `prescription_items` JSONB) và `SystemAlerts` (cảnh báo sớm 3 cấp BR-04, phân quyền Mentor can thiệp sư phạm `handled_by`).
- **Nâng Cấp Bản Đặc Tả ERD Mức Khái Niệm Toàn Diện (`docs/SQL/Mo_Ta_Thiet_Ke_ERD_Concept.md`)**:
  - Hệ thống hóa toàn diện **10 Miền Nghiệp Vụ (Bounded Contexts)** chứa trọn vẹn **46 Thực thể**.
  - Xây dựng sơ đồ **Mermaid Conceptual ERD chi tiết** với từng khối thực thể chứa đầy đủ thuộc tính định danh (PK), khóa ngoại (FK) và các trường thông tin ngữ nghĩa (không còn hộp rỗng).
  - Biên soạn **Từ điển thực thể khái niệm (Concept Entity Dictionary)** phân tích sâu sắc vai trò sư phạm và dữ liệu cho toàn bộ 46 thực thể.
  - Cung cấp **Ma trận bản số quan hệ (Cardinality Matrix)** và bộ Prompt chuẩn cho các công cụ AI và phần mềm trực quan hóa ERD.
