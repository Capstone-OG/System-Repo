# DAILY LOG - SYSTEM REPO

## [23/11/2026]
- **Triển Khai Thành Công Hệ Thống Auto-CD GitHub Actions Lên Máy Chủ Ubuntu Docker Server (`veval.io.vn`)**:
  - **Khảo sát & Tinh chỉnh Docker Compose**:
    - Gỡ bỏ mount ổ cứng thư mục `dist` của `v-eval-web-client` (`./All Services/V-Eval-Web_Client/dist:/usr/share/nginx/html:ro`) trong [docker-compose.yml](../docker-compose.yml) để Nginx phục vụ trực tiếp bản build bên trong image Docker.
    - Bảo mật `DATABASE_URL` của `v-eval-ai-rag`, chuyển sang sử dụng biến môi trường `${DATABASE_URL}` trong file cấu hình `.env`.
    - Kiểm thử syntax Docker Compose bằng lệnh `docker compose config --quiet` đạt chuẩn 100%.
  - **Xây Dựng Script Triển Khai Trung Tâm (`Scripts/deploy_service.sh`)**:
    - Áp dụng cơ chế khóa file `flock /tmp/veval-deploy.lock` chống race-condition khi nhiều service merge `main` cùng thời điểm.
    - Hỗ trợ triển khai chọn lọc (selective rebuild) độc lập cho từng service (`web-client`, `gateway`, `identity`, `content`, `practice`, `ai-engine`, `system`) với tùy chọn `--no-deps` nhằm bảo vệ tuyệt đối container `veval-tunnel` và tránh gián đoạn các service khác.
    - Tự động kiểm tra trạng thái container và dọn dẹp docker images cũ bằng `docker image prune -f`.
  - **Cài Đặt & Kích Hoạt GitHub Self-Hosted Runner Cấp Organization**:
    - Đăng ký Runner v2.338.2 cấp Organization `Capstone-OG` với các nhãn định tuyến `veval-prod` và `ubuntu-server`.
    - Cấu hình dịch vụ nền thông qua `systemd --user` (`actions.runner.service`) kèm thuộc tính `Linger=yes` đảm bảo runner tự khởi động cùng máy chủ và luôn duy trì kết nối outbound an toàn.
  - **Thiết Lập Bộ Workflow CD Tự Động Cho Toàn Bộ 7 Repositories**:
    - Tạo workflow CD [.github/workflows/cd-main.yml](../.github/workflows/cd-main.yml) cho `System-Repo`.
    - Tạo trực tiếp các file workflow [.github/workflows/cd-main.yml](../All%20Services/) trong toàn bộ 6 repositories microservices (`V-Eval-Web_Client`, `V-Eval-Gateway`, `V-Eval-Identity_Service`, `V-Eval-Content_Service`, `V-Eval-Practice_Service`, `V-Eval-Ai_Engine`) với đầy đủ các bước verify build/test, setup gRPC từ `System-Repo`, và kích hoạt runner `[self-hosted, veval-prod]`.
    - Đóng gói sẵn trọn bộ 6 template workflow chuẩn bị sẵn trong thư mục [docs/cd-templates](./cd-templates/).
    - Biên soạn cẩm nang tài liệu kỹ thuật toàn diện từ A đến Z tại [docs/huong_dan_trien_khai_auto_cd_toan_dien.md](./huong_dan_trien_khai_auto_cd_toan_dien.md) bao gồm sơ đồ, full câu lệnh, bảng danh mục đường dẫn chuẩn và sổ tay xử lý sự cố.
  - **Kiểm Thử Thực Tế Vận Hành (End-to-End Verification)**:
    - Kích hoạt kiểm thử thực tế `./Scripts/deploy_service.sh web-client`: container `v_eval_web_client` được build và recreate thành công trong 26 giây.
    - Toàn bộ các service khác và tunnel Cloudflare tiếp tục vận hành liên tục không gián đoạn (Zero-Downtime).

