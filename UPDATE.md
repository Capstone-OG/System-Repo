# Nhật Ký Cập Nhật (Update Log) - System Repo

## [29/09/2026] - Tích Hợp Web Client Repository, Nâng Cấp Bộ Script Điều Khiển & Mở Rộng Hệ Thống

- **Tích Hợp Repository Web Client**:
  - Bổ sung cấu hình tracking repository [`git_config.txt`](./git_config.txt):
    ```ini
    V-Eval-Web_Client=https://github.com/Capstone-OG/v-eval-web-client.git|develop
    ```
  - Khởi tạo thư mục dịch vụ chuẩn [`All Services/V-Eval-Web_Client`](./All%20Services/V-Eval-Web_Client) liên kết nhánh `develop` của repo `https://github.com/Capstone-OG/v-eval-web-client.git`.
- **Nâng Cấp Bộ Script Hệ Thống (`Scripts/`)**:
  - [`Scripts/setup/setup.bat`](./Scripts/setup/setup.bat): Bổ sung kiểm tra `package.json` (`IS_NODE=1`) để tự động nhận diện ứng dụng Node/Web, ngăn chặn khởi tạo nhầm Clean Architecture của .NET.
  - [`Scripts/run_local/run_local.bat`](./Scripts/run_local/run_local.bat): Bổ sung tùy chọn [1] Khởi chạy Full 7 dịch vụ (kèm Web Client cổng 5173) và tùy chọn [4] Khởi chạy riêng Web Client (Vite Dev Server).
  - [`All Services/V-Eval-Web_Client/Scripts/push.bat`](./All%20Services/V-Eval-Web_Client/Scripts/push.bat): Thiết lập script push độc lập tương tự như các Microservices backend.
- **Hệ Thống Đặc Tả & Ma Trận Dịch Vụ**:
  - Cập nhật ma trận dịch vụ trong [`README.md`](./README.md).
  - Khởi tạo tài liệu hợp nhất 22 công thức hệ thống [`docs/he_thong_toan_hoc_va_cong_thuc_v_eval.md`](./docs/he_thong_toan_hoc_va_cong_thuc_v_eval.md).
- **Kiểm Thử Hoàn Tất**:
  - `npm install` và `npm run build` cho Web Client thành công 100% (thời gian build 3.87s).
