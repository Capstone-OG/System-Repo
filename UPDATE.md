# Nhật Ký Cập Nhật (Update Log) - System Repo

## [07/10/2026] - Đặc Tả Chi Tiết Mục 3 (Functional Requirements) & Tích Hợp 25 Business Rules (BR-01 Đến BR-25)

- **Biên Soạn Toàn Diện Tài Liệu Mục 3 Chuẩn Nghiệp Vụ [`docs/muc_3_dac_ta_chuc_nang_chi_tiet.md`](./docs/muc_3_dac_ta_chuc_nang_chi_tiet.md)**:
  - Tích hợp trọn vẹn danh mục 25 Quy tắc nghiệp vụ (**BR-01 đến BR-25**) phân theo từng mảng: Xác thực & Bảo mật, Khảo thí, Psychometrics IRT 2PL & BKT, Sư phạm, RAG AI Guardrails, K-Means Clustering, Kỷ luật học tập và Liêm chính thi cử.
  - Phân tích và đặc tả chi tiết 100% tất cả các chức năng **đã được triển khai** theo đúng mẫu tài liệu Software Requirements Specification (SRS):
    - \`Function trigger\`: Sự kiện kích hoạt từ người dùng hoặc hệ thống.
    - \`Function description\`: Actors tham gia và Mục đích nghiệp vụ (\`Purpose\`).
    - \`Function details\`: Yêu cầu dữ liệu (\`Data requirement\`), Tiêu chuẩn kiểm tra tính hợp lệ (\`Validation\`) và Quy tắc nghiệp vụ liên đới (\`Business rules\`).
    - \`Vị trí kỹ thuật thực tế\`: Ánh xạ chính xác tới từng Service, Controller, Command/Query Handler, CSDL Supabase.
  - Đối với các chức năng **chưa triển khai** (như phân hệ Phụ huynh P3, xuất báo cáo PDF/Excel, dự phóng điểm thi...): Giữ nguyên cấu trúc định danh UC, Actors, Mục đích và gắn cờ \`[Chưa triển khai / Backlog]\` rõ ràng.
  - Đảm bảo tuân thủ 100% quy chuẩn hiển thị trên **MD Editor Plus** (không dùng ký tự \`$\` thô, liên kết tương đối \`./\`).
