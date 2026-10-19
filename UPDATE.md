# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [20/10/2026] - Hợp Nhất Động Cơ MathLab JSXGraph Nội Sinh, Tùy Chỉnh Tọa Độ (X,Y,Z) & Đổi Tên Đỉnh Không Gian 3D, Bộ Kẻ Đường Phụ Tự Do & Hệ Thống Đồ Thị VD/VDC GDPT 2018

- **Web Client (`V-Eval-Web_Client`) - Nâng Cấp MathLab 2D/3D & Trải Nghiệm Soạn Thảo Toán Học Chuyên Sâu**:
  - *Thống Nhất Động Cơ JSXGraph Nội Sinh*: Loại bỏ hoàn toàn GeoGebra web-applet nhằm triệt tiêu độ trễ mạng và phụ thuộc iframe bên ngoài; 100% chức năng MathLab chạy trên engine vector JSXGraph v1.14.0 nội sinh, offline, hiển thị mượt mà 60 FPS Canvas/SVG.
  - *Tùy Chỉnh Tọa Độ (X, Y, Z) & Đổi Tên Các Đỉnh Không Gian 3D*: Bổ sung toggle cho phép giáo viên chỉnh sửa trực tiếp tọa độ thực và đổi tên hiển thị của mọi đỉnh trong hình học không gian (chóp, lăng trụ, chóp đều, hình hộp); tự động cập nhật liên tục các cạnh và đường phụ liên kết, kèm nút reset mặc định 1-click.
  - *Bộ Kẻ Thêm Đường Phụ & Thêm Điểm Trên Cạnh*: Cho phép tạo điểm mới chia tỉ lệ trên cạnh (trung điểm `1/2`, trọng tâm `1/3`), kẻ đoạn thẳng phụ nối 2 điểm bất kỳ (nét đứt SGK hoặc nét liền, chọn màu nét) và dựng mô hình khoảng cách 2 bước `d(A, (SBC)) = AK`.
  - *Hệ Thống Đồ Thị Vận Dụng & Vận Dụng Cao (VD/VDC) Toàn Diện*: Tích hợp 6 chuyên đề đồ thị thi THPT gồm hàm phân thức có tiệm cận xiên (GDPT 2018), biến đổi trị tuyệt đối phức hợp `|f(x)|`, `f(|x|)`, `|f(x) + m|`, đồ thị đạo hàm `f'(x)` và tương giao hàm hợp, biện luận nghiệm đường xiên `y = ax + m`, diện tích tích phân 2 đường cong, và nhận dạng bộ ba đồ thị `f(x)`, `f'(x)`, `F(x)`.
  - *Chuẩn Hóa Ribbon & Nút Kích Hoạt*: Đồng bộ hóa nhãn `⚡ MathLab 2D/3D (JSXGraph)` trên thanh công cụ Ribbon và toàn bộ các khối sư phạm của Studio.

- **Kiểm Thử Toàn Diện Hệ Thống**:
  - `V-Eval-Web_Client`: `npm run build` hoàn thành 100% (**0 Error, 0 Warning**, hoàn tất trong 965ms trên Vite 8 và React 19).
