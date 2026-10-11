# Nhật Ký Cập Nhật (Update Log) - System Repo

## [11/10/2026] - Hợp Nhất Toàn Diện Hệ Thống: Mô Hình Giảng Dạy Offline (Trần Sĩ Số 20 Em), Phân Nhóm Vi Mô (3 - 5 Em) & Đồng Bộ Core Flow 3

- **Hợp Nhất Toàn Diện Nhánh Develop (Core Flow 2 & Core Flow 3)**:
  - Đồng bộ thành công cấu trúc toàn hệ thống tích hợp đồng thời chặng học P-L-A-R, nhánh cứu trợ Remedial Node, Sổ tay lỗi sai SM-2 và mô hình phân nhóm học tập vi mô.
- **Giao Diện Quản Lý Nhóm Học Tập Vi Mô & Sơ Đồ Bàn Học Offline (`Web Client`)**:
  - Triển khai component `ClassMicroGroupsModal.jsx` hiển thị sơ đồ phân bổ trạm bàn học offline của lớp (Trần sĩ số 20 học sinh, mỗi nhóm bàn từ 3 đến 5 học sinh).
  - Tích hợp bộ chọn quy mô nhóm bàn (`3 bạn/bàn`, `4 bạn/bàn`, `5 bạn/bàn`) kết nối trực tiếp với thuật toán gom cụm đồng nhất (Homogeneous Clustering) theo lỗ hổng kiến thức.
  - Phân phối đề luyện tập thích ứng trực tiếp cho bàn học (`practiceService.assignGroupWorksheet`) và xuất sơ đồ bàn học PDF cho Giảng viên.
- **Nâng Cấp Cổng Điều Hành Học Thuật Cơ Sở (`CampusManagerDashboardView.jsx`)**:
  - Chuẩn hóa danh sách lớp học offline theo cơ chế trần 20 học sinh và số thứ tự tăng dần (`Lớp Nền tảng 01`, `Lớp Nền tảng 02`, `Lớp Tăng tốc 01`, `Lớp Bứt phá 01`).
  - Hiển thị badge sĩ số chuẩn hóa: `Sĩ số: {studentCount}/20` và tích hợp nút mở sơ đồ nhóm bàn học vi mô.
- **Bộ Scripts Đa Nền Tảng Trong System-Repo**:
  - Bổ sung bộ script Bash shell (`.sh`) tương ứng với `.bat`: `pull.sh`, `run_docker.sh`, `run_local.sh`, `setup.sh`, `sync_config.sh` tương thích macOS/Linux/WSL.
- **Kiểm Thử Toàn Diện & Trạng Thái Hệ Thống**:
  - Frontend `Web Client` build Vite thành công 100% (**0 Error, 0 Warning**).
  - Toàn bộ Solution `V-Eval-Practice_Service.sln` biên dịch sạch 100% (**0 Warning, 0 Error**).
  - Cấu hình `docker compose config` hợp lệ 100%.
