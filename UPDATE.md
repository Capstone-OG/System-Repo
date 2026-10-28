# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [28/10/2026] - Hoàn Tất Khảo Sát & Điền Toàn Diện Biểu Mẫu BM02 (Self-Review Report) Cho Review 2

- **Hoàn Tất Điền Toàn Diện Biểu Mẫu BM02 (Self-Review Report)**:
  - Khởi tạo và điền đầy đủ 100% dữ liệu vào biểu mẫu chuẩn [`docs/docs/SWP490_R2_BM02_Self_Review_Report_1.docx`](./docs/docs/SWP490_R2_BM02_Self_Review_Report_1.docx) theo quy định Review 2 của bộ môn SWP490.
  - Khai báo thông tin phiên chạy (Run Information):
    - Mã đề tài (Project code): `FA26SE090`.
    - Tên đề tài: `AI-powered Personalized Learning Path Platform for Competency Assessment Exam Preparation`.
    - Nhóm sinh viên thực hiện (Team): `GFA26SE44`.
    - Giảng viên hướng dẫn (Supervisor): `Nguyễn Trọng Tài`.
    - Công cụ AI thực hiện (AI Tool): `Google DeepMind Antigravity (Gemini 3.8 Flash)`.
    - Phiên bản Registration Form: `1.1`.
    - Mốc đối soát: Git Tag `review-2` (Commit SHA: `926b5aa1c64b91ad0b5adcba34c08d7a2c22221b`).

- **Đối Soát Chuyên Sâu 7 Danh Mục Kiểm Toán (23 Phát Hiện Thực Tế)**:
  - Thực hiện chạy Prompt tiêu chuẩn đối soát toàn diện tài liệu SRS, SDD, sơ đồ Activity, ERD logic, kịch bản CSDL và toàn bộ mã nguồn hệ thống:
    1. **Scope (4 phát hiện)**: Nhận diện bất cập giữa phạm vi loại trừ trong BM01 (§1.2) với các FR thừa trong SRS (tư vấn tuyển sinh, giám sát phụ huynh); ghi nhận các FR placeholder chưa hoàn thiện và cam kết BM04 chưa có đặc tả SRS.
    2. **Requirements (3 phát hiện)**: Bổ sung định lượng cho các NFRs về Usability (SUS `>= 75`), Security (OWASP ZAP 0 lỗi High) và hiệu năng (chuẩn hóa tải 100 req/s REST).
    3. **Data (3 phát hiện)**: Nhận diện các thực thể ngoài phạm vi BM01; đối soát và đồng bộ 100% tên trường giữa sơ đồ ERD logic (`docs/diagrams/erd.mmd`) và kịch bản PostgreSQL (`docs/SQL/SQL.sql`).
    4. **States (4 phát hiện)**: Bổ sung các trạng thái thực tế vào State Machine, đồng bộ vòng đời 6 trạng thái Sổ tay lỗi sai (`MistakeNotebooks`), phân tích chuyển trạng thái của `DiagnosticAssessments` và `RoadmapNode`.
    5. **Flows (3 phát hiện)**: Xác định lộ trình triển khai API cho luồng giáo viên phản hồi/đề xuất mẫu bài tập (Core Flow 4), chuẩn hóa luồng giám sát và đối soát chỉ tiêu 34 Unit Tests trên CI.
    6. **Architecture (3 phát hiện)**: Khắc phục sự thiếu hụt dịch vụ `rag-service` trong `docker-compose.yml`, làm rõ phạm vi dùng pgvector và in-memory cache thay cho RabbitMQ/Redis trong phạm vi nghiệm thu.
    7. **Design vs Code (3 phát hiện)**: Nhận diện cấu trúc chương IV trong báo cáo chính, chuẩn hóa thiết kế phân rã microservice cho bài thi chẩn đoán và sửa chú thích nhầm lẫn Core Flow 5/6 trong code `PredictionsController.cs`.

- **Ma Trận Phân Loại & Phân Công Trách Nhiệm Xử Lý (Team Response)**:
  - Tổng số 23 phát hiện kiểm toán được phân loại định lượng:
    - **High**: 10 phát hiện (0 Fixed, 1 Kept, 9 Planned).
    - **Medium**: 9 phát hiện (0 Fixed, 3 Kept, 6 Planned).
    - **Low**: 4 phát hiện (1 Fixed, 1 Kept, 2 Planned).
  - Tổng hợp trạng thái: **1 Fixed**, **5 Kept**, **17 Planned**.
  - Phân công thành viên phụ trách và hạn chót cụ thể cho từng hạng mục Planned (`Nguyễn Duy Khôi` - SRS/SDD/Data Dict; `Trần Thái Thịnh` - Kiến trúc/Docker/K6; `Phạm Tấn Lộc` - Controller/Unit Tests/State Diagram; `Mai Thành Nhân` - CI/CD & Testing).
  - Tổng hợp danh sách Top 5 phát hiện rủi ro cao nhất (`ARC-01`, `DES-01`, `DAT-02`, `FLO-03`, `SCO-01 & SCO-02`) chuẩn bị cập nhật vào mục 5 (Known Gaps) của Design Brief BM01.
