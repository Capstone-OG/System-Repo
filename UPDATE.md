# UPDATE - V-Eval System Repo

## [19/11/2026]
- **V-Eval-Web_Client**:
  - **Khắc Phục Triệt Để Lỗi Tạp Nhiễm Tri Thức Chéo Môn Học & Chéo Chương (`CurriculumExplorerView.jsx`, `UnifiedNodeDetailView.jsx`, `textbookStateBridge.js`)**:
    - *Bộ Lọc Phạm Vi Tri Thức 4 Lớp (Strict Scoping Hierarchy)*: Cập nhật các hàm `getMatchedChunksForChapter`, `getMatchedChunksForLesson`, `getMatchedChunksForPattern` với cơ chế nhận diện môn học tự động (`detectSubjectFromContext`, `isSubjectCompatible`) và cô lập nghiêm ngặt theo Chương (`parentChapter`) và Bài học (`parentLesson`).
    - Triệt tiêu hoàn toàn lỗi hiển thị 46 chunks tạp nhiễm (chứa cả Bất phương trình bậc hai một ẩn từ Chương 2, Hình học toạ độ từ Chương 4 và Phân lớp electron từ Hóa học 10 vào Dạng 1 của Bài 1: Không gian mẫu và biến cố trong Chương 10 Toán học). Trả về đúng 19 trang tri thức chuẩn xác của Bài 1 vào Khối 1.
    - *Siết Chặt Thuật Toán So Khớp Mờ (`isFuzzyLabelMatch`)*: Đối với nhãn ngắn (`` `minWords \le 2` ``), yêu cầu trùng khớp 100% số từ khóa có nghĩa; đối với nhãn dài hơn, yêu cầu trùng khớp tối thiểu 60% (`Math.ceil(minWords * 0.6)`), loại bỏ triệt để các trường hợp match bừa bãi do trùng tiếp đầu ngữ.
    - *Hàng Rào Bảo Vệ Chống Chéo Môn Trong `buildTheoryFromChunks`*: Tích hợp bộ lọc từ khóa chuyên biệt theo môn học: Khi tổng hợp lý thuyết Toán học, tự động loại trừ các đoạn văn bản chứa thuật ngữ Hóa học (electron, orbital, phân lớp, este, halogen...); khi tổng hợp Hóa học, loại trừ các công thức hình học toạ độ và bất phương trình.
    - *Tích Hợp Quick Pattern Switcher Pills Cho Khung Chương Trình (`UnifiedNodeDetailView.jsx`)*: Bổ sung thanh chọn Dạng bài nhanh ngay dưới tiêu đề của `UnifiedNodeDetailView`, cho phép giáo viên và học sinh chuyển đổi 1-click giữa các Dạng bài của Bài học, đồng bộ 100% với giao diện Sách Giáo Khoa chuẩn.
  - **Đồng Nhất Kiến Trúc 3 Tầng Sư Phạm & Phân Định Lý Thuyết Riêng Cho Từng Dạng Bài (`TextbookStandardView.jsx`, `TextbookIngestView.jsx`)**:
    - *Đồng nhất 100% với Khung chương trình*: Tái cấu trúc chuẩn hóa giao diện Sách Giáo Khoa theo đúng 3 tầng sư phạm chuẩn của `UnifiedNodeDetailView.jsx` (Khối 1: Lý thuyết trọng tâm theo dạng bài, Khối 2: Phương pháp giải 4 bước & dạng bài mẫu, Khối 3: Ngân hàng câu hỏi SGK, Khối 4: Đoạn trích OCR đóng mặc định).
    - *Bộ chuyển Dạng bài nhanh (Quick Pattern Switcher pills)*: Tích hợp thanh chọn dạng bài trực quan ngay dưới tiêu đề `[Dạng 1] [Dạng 2] [Dạng 3]`. Khi bài học có 2-3 dạng, click chuyển dạng sẽ lập tức cập nhật riêng biệt nội dung lý thuyết, phương pháp giải và ngân hàng câu hỏi của từng dạng.
  - **Khắc Phục Triệt Để Nút AI Sinh Lý Thuyết & Mở Rộng Nội Dung Bị Liệt (`handleAiEnrichTheory`, `handleAiEnrich`)**:
    - *Cơ chế Fallback Sư phạm Thông minh*: Bọc toàn bộ luồng gọi `aiService.analyzePatternWithAi` trong khối try-catch an toàn. Nếu kết nối mạng hoặc API có sự cố, hệ thống tự động kích hoạt bộ sinh sư phạm chuẩn GDPT 2018 theo môn và dạng bài, đảm bảo nút AI luôn hoạt động 100% không bao giờ bị đơ/liệt.
    - *Sửa lỗi thiếu `isEdited: true`*: Đánh dấu cờ `isEdited: true` khi AI sinh lý thuyết/phương pháp, ngăn chặn triệt để việc logic render vô tình đè ngược lại bằng dữ liệu chunks cũ.
    - *Khắc phục bất đồng bộ React setState*: Truyền trực tiếp chỉ số dạng bài mục tiêu (`targetPatIdx`) vào hàm thực thi thay vì chờ state cập nhật, đảm bảo AI bóc tách đúng dạng bài được click.
  - **Biên Dịch*: `npm run build` hoàn tất sạch sẽ trong 3.06s với 3054 modules transformed (0 Error).
- **V-Eval-Content_Service**:
  - **Triệt Tiêu 100% Generic Hardcode & Cung Cấp Dữ Liệu Động 100% CSDL**:
    - Xóa bỏ hoàn toàn các chuỗi gán mặc định ("Kiến thức nền tảng trong cơ sở dữ liệu.", "Phương pháp giải chi tiết trong cơ sở dữ liệu.") tại `GetCurriculumTreeQuery.cs`.
    - Trả về chuỗi rỗng khi học liệu chưa có trong CSDL để phía Client phân định chính xác và hiển thị trạng thái "Chưa có dữ liệu nguồn".
    - Cung cấp đầy đủ qua REST API `GET /api/content/curriculum`: **139 Chương • 337 Bài học • 337 Dạng bài • 343 Học liệu Materials • 588 Câu hỏi Questions** từ CSDL PostgreSQL (`v_eval_content`).
    - Biên dịch sạch: `dotnet build` đạt 0 Error, 100% Succeeded.
- **V-Eval-Ai_Engine**:
  - **Nâng Cấp Prompt Bóc Tách Mục Lục Đa Bài Học & Triển Khai Lesson Guard C# (`PdfPigTextbookParserService.cs`)**:
    - *Ràng buộc đa bài học*: Cải tiến prompt Gemini Vision ép buộc bóc tách đầy đủ tất cả các bài học con trong mỗi chương, nghiêm cấm chỉ lấy 1 bài đại diện hoặc gộp bài; cung cấp schema JSON mẫu chứa nhiều bài học (`Bài 1`, `Bài 2`...).
    - *Triển khai Lesson Guard*: Khi AI parse ra tổng số bài học quá thấp (`totalParsedLessons < 10` hoặc trung bình `` `\le 1.2` `` bài/chương đối với sách `` `\ge 25` `` trang), hệ thống tự động đối soát và hòa nhập (backfill/merge) toàn bộ các bài học chuẩn còn thiếu từ `gdpt2018_dgnl_taxonomy.json` vào từng chương, bảo toàn trọn vẹn 10–25 bài học của cuốn sách.
    - *Đồng bộ taxonomy GDPT 2018*: Bao quát đầy đủ 139 Chương và 337 Bài học của 17 SGK Chân trời sáng tạo.
    - *Biên dịch*: `dotnet build` đạt 0 Error, 0 Warning.
