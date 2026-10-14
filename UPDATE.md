# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [15/10/2026] - Khắc Phục Triệt Để Lỗi Màn Trắng (White Screen Fix), Hoàn Thiện Studio Sư Phạm Chuyên Sâu & Nạp Tri Thức Động Kép

- **Khắc Phục Triệt Để Lỗi Màn Trắng & Nâng Cao Tính Bền Vững Frontend**:
  - *Sửa lỗi biến chưa khai báo*: Khắc phục `ReferenceError: weakPrerequisites is not defined` tại `CurriculumExplorerView.jsx:1303` bằng cách bổ sung bộ lọc dạng bài tiên quyết vùng trũng `<10%` đồng bộ từ `skillMasteryMap`.
  - *Bọc Error Boundary Toàn Cục (`RootErrorBoundary` trong `src/main.jsx`)*: Ngăn ngừa toàn bộ sự cố màn hình trắng; cung cấp giao diện báo lỗi trực quan kèm stack trace và nút Tải lại trang/Xóa cache.
  - *Bổ Sung Type Safety Cho `MathText.jsx`*: Thêm kiểm tra nghiêm ngặt `typeof text !== 'string'` tránh crash render.
  - *Mở Rộng Điều Hướng Tab Lộ Trình Cho Mọi Vai Trò (`App.jsx`)*: Học sinh, Giáo viên và Quản lý học thuật đều có thể truy cập phân hệ Dàn kiến thức & Lộ trình phân cấp.
- **Xóa Bỏ 100% Hardcode Dữ Liệu Tĩnh Trong Toàn Bộ Hệ Thống**:
  - Loại bỏ hoàn toàn `CurriculumHierarchySeeder.cs` và các khối switch-case hardcode LaTeX/câu hỏi giả trong `GetCurriculumTreeQuery.cs`.
  - Loại bỏ các GUID hardcode mẫu và các câu hỏi giả fabricated trong `CurriculumExplorerView.jsx`.
  - Toàn bộ dữ liệu tri thức và câu hỏi được quản lý và truy vấn 100% động từ cơ sở dữ liệu PostgreSQL (`v_eval_content`).
- **Triển Khai Môi Trường Studio Sư Phạm Chuyên Sâu Toàn Diện (`CurriculumStudioEditor.jsx`)**:
  - Nâng cấp trải nghiệm hiệu đính của giảng viên từ modal thu nhỏ thành không gian Studio toàn màn hình tải nặng:
    - *3 Chế Độ Xem*: `Biên soạn (Editor)`, `Chia đôi (Split 50-50 Live KaTeX Preview)`, và `Review Học sinh (Live Preview)` mô phỏng chính xác 100% góc nhìn của người học.
    - *Bảng Ký Tự KaTeX 3 Nhóm Chuyên Sâu*: Đại số & Giải tích, Hình học & Không gian Oxyz, Logic & Tập hợp.
    - *Thư Viện Đồ Thị & Chèn Hình Ảnh Sư Phạm*: Modal chèn ảnh đồ thị minh họa (Đồ thị hàm bậc ba, Bảng biến thiên, Hình chóp S.ABC, Hệ trục Oxyz) và hỗ trợ chèn ảnh Markdown `![Mô tả](url)`.
    - *Động Cơ Render Toán Học Kèm Ảnh (`MathText.jsx`)*: Phân tích và render tự động hình ảnh Markdown với bo góc và bóng đổ chuẩn sách giáo khoa.
    - *Bảng Phân Đoạn Video Timestamps*: Thêm/sửa/xóa các mốc thời gian bài giảng và nhúng trực tiếp trình phát video YouTube.
    - *Studio Quản Trị Ngân Hàng Câu Hỏi Thích Ứng (API 16-18)*: Xem danh sách câu hỏi trong PostgreSQL, xóa câu hỏi và tạo câu hỏi mới theo chuẩn Bloom L1-L4.
- **Triển Khai REST API Nhập Liệu Tri Thức Động (`POST /api/content/curriculum/import`)**:
  - Hỗ trợ kiến trúc 2 kênh bổ trợ: Giảng viên/Ban Chuyên Môn chủ động quản lý nhập liệu và AI Engine tự động nạp phân tích từ file PDF Sách Giáo Khoa.
  - Triển khai `ImportCurriculumCommand` và `ImportCurriculumCommandHandler`: Tự động upsert toàn bộ cây phân cấp đa môn: `Miền Năng Lực` -> `Chương` -> `Bài học` -> `Dạng bài` -> `Materials` -> `Questions` -> `SkillPrerequisites`.
- **Trọn Bộ REST APIs Quản Trị Cây Tri Thức Của Content Service**:
  - `PUT /api/content/curriculum/patterns/{id}` (`UpdatePatternCommand`): Hiệu đính 4 khối nội dung dạng bài.
  - `PUT /api/content/curriculum/nodes/{id}` (`UpdateNodeCommand`): Cập nhật thông tin node Chương/Bài học.
  - `POST /api/content/curriculum/nodes` (`CreateNodeCommand`): Thêm mới Chương, Bài học hoặc Dạng bài.
  - `DELETE /api/content/curriculum/nodes/{id}` (`DeleteNodeCommand`): Xóa node an toàn và dọn dẹp quan hệ DAG.
- **Cấu Trúc Cây 3 Tầng Chuẩn Sư Phạm SGK & 4 Khối Sư Phạm Thích Ứng**:
  - Cột trái: Accordion 3 tầng linh hoạt (Chương -> Bài học -> Dạng bài) kèm huy hiệu năng lực cá nhân (`🚨 Hổng <10%`, `⚠️ Vùng trũng <60%`, `✅ Đã vững ≥60%`).
  - Cột phải: 4 khối nội dung sư phạm và tự động gom dạng bài lân cận/tiên quyết hổng (&lt;10%) vào đề luyện tập thích ứng vi mô (API 19).
- **Trạng Thái Kiểm Thử Vận Hành Toàn Hệ Thống**:
  - `V-Eval-Content_Service.sln`: Biên dịch sạch 100% (**0 Warning, 0 Error** trên .NET 9 SDK).
  - `V-Eval-Web_Client`: `npm run build` thành công 100% (**0 Error, 0 Warning**, hoàn thành trong 781ms).
  - Nhánh duy nhất đồng bộ: `ThinhTT/feature-question-bank-adaptive-quiz`.
