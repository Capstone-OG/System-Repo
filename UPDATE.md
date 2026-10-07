# Nhật Ký Cập Nhật (Update Log) - System Repo

## [07/10/2026] - Triển Khai Hệ Thống Quản Lý Cấu Hình Tập Trung (Centralized Config Management) & Công Cụ Đồng Bộ Tự Động (Auto Sync Tool)

- **Thiết Lập Thư Mục Cấu Hình Tập Trung (`Configs/`)**:
  - Tạo cấu trúc thư mục cấu hình chuẩn cho toàn bộ 6 service: Gateway, Identity Service, Content Service, Practice Service, AI Engine (cả .NET API và Python RAG), Web Client.
  - Lưu trữ đầy đủ các chuỗi kết nối Supabase PostgreSQL, JWT Secret Key, Ports, Endpoints gRPC và API Gateway URL sẵn sàng chạy ngay 100% không cần thao tác copy tay từ Notion.
  - Tạo tài liệu hướng dẫn `Configs/README.md`.
- **Phát Triển Công Cụ Đồng Bộ Chuyên Biệt (`Scripts/sync_config/sync_config.bat`)**:
  - Hỗ trợ menu tương tác:
    - `[1]`: Nạp cấu hình chuẩn vào tất cả service (tự động tạo file backup `.bak` an toàn khi ghi đè).
    - `[2]`: Gom cấu hình từ local về thư mục `Configs/` của System-Repo khi muốn chia sẻ cấu hình mới cho cả team.
    - `[3]`: Kiểm tra trạng thái sẵn sàng của file cấu hình trên toàn bộ 7 thành phần.
  - Hỗ trợ cờ dòng lệnh `--install-missing`, `--force`, `--check` cho phép tích hợp không xâm lấn vào các script tự động hóa khác.
  - Bổ sung file shortcut `sync_config.bat` tại thư mục gốc của dự án.
- **Tích Hợp Kiểm Tra Lót Sàn An Toàn Vào Bộ Script Hệ Thống**:
  - `Scripts/setup/setup.bat`: Tự động nạp cấu hình chuẩn ngay sau khi clone và kiểm tra trạng thái toàn diện, đảm bảo dev mới clone xong là chạy được ngay.
  - `Scripts/pull/pull.bat`: Tự động kiểm tra và bổ sung cấu hình nếu service con bị thiếu file sau khi pull.
  - `Scripts/run_local/run_local.bat` & `Scripts/run_docker/run_docker.bat`: Tự động kiểm tra và bù file cấu hình nếu thiếu trước khi khởi động, triệt tiêu lỗi crash do thiếu cấu hình.
- **Chuẩn Hóa Bộ File Mẫu (`appsettings.example.json` & `.env.example`)**:
  - Đồng bộ chuẩn xác 100% cấu trúc schema của Gateway, Identity, Content, Practice, AI Engine và Python RAG.
  - Ẩn toàn bộ thông tin nhạy cảm (password, secret key) trên file example mẫu.
