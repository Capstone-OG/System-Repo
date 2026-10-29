# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [29/10/2026] - Khắc Phục Lỗi Nguồn NuGet Practice Service, Bảng Biến Thiên Lưới `2N - 1` Cột Không Nhảy Layout, Tái Thiết Kế Thư Viện Công Thức/Hợp Chất & Nâng Cấp Hình Học Phẳng 2D (`JSXGraph`)

- **Cấu Hình NuGet Chuẩn Hóa Cho Toàn Hệ Thống (`nuget.config`)**:
  - Khởi tạo file [`nuget.config`](./nuget.config) tại thư mục gốc với chỉ thị `<clear />` và nguồn chính thức `https://api.nuget.org/v3/index.json`, khắc phục triệt để lỗi `NU1301: The local source 'C:\Program Files (x86)\Microsoft SDKs\NuGetPackages\' doesn't exist` khi build `V-Eval-Practice_Service` và các microservice .NET trên máy chưa cài Visual Studio Offline SDK.

- **Chuẩn Hóa Canvas Công Thức Trực Quan WYSIWYG, Bảng Biến Thiên Lưới `2N - 1` Cột Không Nhảy Layout & Tái Thiết Kế Thư Viện Công Thức/Hợp Chất (`V-Eval-Web_Client`)**:
  - Nâng cấp `VariationTable.jsx` và `InteractiveFormulaBuilderModal.jsx` sang **Kiến trúc Lưới Cột Chuẩn SGK (`2N - 1` cột)**: Căn thẳng hàng dọc tuyệt đối giữa mốc `x_i`, đạo hàm tại điểm (`0` hoặc `||`) và giá trị cực trị `y_i`; cố định chiều cao dòng và đặt thanh Kéo - Thả ở phía dưới bảng để triệt tiêu hoàn toàn hiện tượng nhảy bảng khi click; hỗ trợ 1-click đổi dấu `+`/`-` (đồng bộ mũi tên chéo SVG `↗`/`↘`), 1-click đổi cực trị `0` và tiệm cận đứng `||`, cùng thao tác kéo thả hoặc gõ số trực tiếp.
  - Tái thiết kế `HierarchicalMathPalette.jsx` (**Thư Viện Công Thức & Hợp Chất**) với hệ thống thẻ Studio Tile phân màu 7 môn học, hiển thị trực tiếp ký pháp KaTeX / công thức hóa học trên mặt thẻ và hỗ trợ kéo - thả (`draggable`) thẳng vào mọi khung soạn thảo hoặc vào ô Bảng biến thiên.
  - Thay thế toàn bộ các ô `<textarea>` và `<input>` hiển thị mã LaTeX thô ở Khối 2 (Bẫy đề thi, Mẹo tư duy) và Khối 4 (Đề bài mẫu, 4 phương án A-D, Lời giải chi tiết) trong `CurriculumStudioEditor.jsx` bằng `<WordStyleFormulaCanvas />` (`compact` & `singleLine`), tự động khử dấu nháy đơn thừa `'...'`, dấu `\` cuối dòng và đồng bộ trạng thái 4 nút mức độ nhận thức chuẩn Bloom (`L1` - `L4`).

- **Nâng Cấp Toàn Diện Phòng Thí Nghiệm Hình Học Phẳng 2D Tương Tác (`InteractiveMathWorkbenchModal.jsx`, `InteractiveMathRenderer.jsx`, `mathGraphUtils.js`)**:
  - Khắc phục lỗi chữ tiếng Việt bị nghiêng dính liền trên huy hiệu `Mô hình:` và lỗi đè nhãn giữa chân đường cao `H` với tâm đường tròn ngoại tiếp `M`.
  - Bổ sung 6 mô hình hình học phẳng chuẩn SGK (Tam giác vuông, Tam giác nhọn & đường tròn Euler, Đường tròn & tiếp tuyến `MA, MB`, Tứ giác nội tiếp, Hình bình hành, Hình thang vuông), bảng điều khiển sửa tọa độ `(X, Y)` đỉnh, thêm điểm phụ, kẻ đường phụ nét đứt/liền và bộ parser thẻ `[MATH_GEOMETRY_2D]`.
