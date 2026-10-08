# Nhật Ký Cập Nhật (Update Log) - System Repo

<<<<<<< HEAD
## [03/10/2026] - Bổ Sung Tài Liệu Chuyên Sâu: Tổng Hợp Thuật Toán Toàn Hệ Thống (Flow 1 đến Flow 4)

- **Tài Liệu Kiến Trúc Toán Học & AI**:
  - Tạo mới tài liệu chuyên sâu [`docs/ai_architecture/tong_hop_thuat_toan_va_cong_thuc_toan.md`](./docs/ai_architecture/tong_hop_thuat_toan_va_cong_thuc_toan.md):
    1. Bản đồ tổng thể toàn bộ các thuật toán và mô hình từ Core Flow 1 đến Core Flow 4.
    2. Chi tiết công thức toán học và lý do bắt buộc phải sử dụng của từng giải thuật: IRT 2PL, MAP (Brent), Anti-Guessing Penalty, Sigmoid Mapping, Phân lớp năng lực, Cấu trúc DAG, Thuật toán Tarjan, Cắt tỉa Heuristic, Sắp xếp Tô-pô (Topological Sort), Mô hình BKT (Bayesian Knowledge Tracing), Semantic Embedding 3072 chiều, Cosine Similarity trên pgvector, Phương pháp Socrates và Sinh câu hỏi tương đương.
    3. Bảng tra cứu đối chiếu nhanh toàn diện phục vụ thuyết trình và phản biện Hội đồng.
  - Tạo mới tài liệu [`docs/ai_architecture/phan_biet_sigmoid_irt_va_bkt.md`](./docs/ai_architecture/phan_biet_sigmoid_irt_va_bkt.md):
    1. Phân định rõ ràng bản chất 2 lần xuất hiện của hàm Sigmoid trong Core Flow 1 (Cấp độ câu hỏi trong IRT 2PL vs Cấp độ học sinh quy đổi sang BKT Prior).
    2. Sơ đồ dòng chảy dữ liệu Mermaid chuẩn mực và kịch bản trả lời phản biện giảng viên.
=======
## [07/10/2026] - Triển Khai Hệ Thống Quản Lý Cấu Hình Tập Trung & Khắc Phục Triệt Để Quy Trình Setup / Run Local

- **Thiết Lập Thư Mục Cấu Hình Tập Trung (`Configs/`)**:
  - Tạo cấu trúc thư mục cấu hình chuẩn cho toàn bộ 6 service: Gateway, Identity Service, Content Service, Practice Service, AI Engine (cả .NET API và Python RAG), Web Client.
  - Lưu trữ đầy đủ các chuỗi kết nối Supabase PostgreSQL, JWT Secret Key, Ports, Endpoints gRPC và API Gateway URL sẵn sàng chạy ngay 100% không cần thao tác copy tay từ Notion.
  - Tạo tài liệu hướng dẫn `Configs/README.md`.
- **Phát Triển Công Cụ Đồng Bộ Chuyên Biệt (`Scripts/sync_config/sync_config.bat`)**:
  - Hỗ trợ menu tương tác:
    - `[1]`: Nạp cấu hình chuẩn vào tất cả service (tự động tạo file backup `.bak` an toàn khi ghi đè).
    - `[2]`: Gom cấu hình từ local về thư mục `Configs/` của System-Repo khi muốn chia sẻ cấu hình mới cho cả team.
    - `[3]`: Kiểm tra trạng thái sẵn sàng của file cấu hình trên toàn bộ 7 thành phần.
  - Bổ sung kiểm tra `SVC_ROOT`: Tuyệt đối không tạo trước thư mục con nếu service chưa được clone, tránh xung đột `destination path already exists and is not empty`.
  - Hỗ trợ cờ dòng lệnh `--install-missing`, `--force`, `--check` cho phép tích hợp không xâm lấn vào các script tự động hóa khác.
  - Bổ sung file shortcut `sync_config.bat` tại thư mục gốc của dự án.
- **Khắc Phục Toàn Diện Quy Trình Setup & Run Local Môi Trường Mới**:
  - `Scripts/setup/setup.bat`: Chuyển bước nạp cấu hình `sync_config.bat` ra sau khi tất cả 6 service đã clone hoàn tất 100%. Tự động dọn dẹp thư mục rác nếu lần clone trước bị gián đoạn.
  - `Scripts/run_local/run_local.bat`: Chuyển khởi chạy C# service sang cơ chế `cd /d "%DIR%" && dotnet run`, triệt tiêu hoàn toàn lỗi vỡ đường dẫn chứa khoảng trắng (như `Capstone Test`).
  - `Scripts/pull/pull.bat` & `Scripts/run_docker/run_docker.bat`: Tự động kiểm tra và bù file cấu hình nếu thiếu trước khi chạy.
- **Chuẩn Hóa Bộ File Mẫu (`appsettings.example.json` & `.env.example`)**:
  - Đồng bộ chuẩn xác 100% cấu trúc schema của Gateway, Identity, Content, Practice, AI Engine và Python RAG.
  - Ẩn toàn bộ thông tin nhạy cảm (password, secret key) trên file example mẫu.
>>>>>>> 788342f1aa2acd51551011d6182e62a4348169cb
