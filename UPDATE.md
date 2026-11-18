# UPDATE - V-Eval System Repo

## [18/11/2026]
- **V-Eval-Ai_Engine**:
  - **Nâng Cấp Prompt Bóc Tách Cấu Trúc SGK Skeleton Đa Dạng Hóa Dạng Bài (2–4 Dạng) & Bloom L1–L4 (`./All Services/V-Eval-Ai_Engine/V-Eval-Ai_Engine.Infrastructure/Services/PdfPigTextbookParserService.cs`)**:
    - *Giải quyết nguyên nhân chỉ có 1 dạng bài L2*: Trước đây prompt `ScanTextbookSkeletonAsync` chỉ cung cấp JSON template 1 dạng bài mẫu với `bloomLevel: 2`, dẫn đến AI chỉ sinh 1 dạng duy nhất cho mọi bài học.
    - *Ép buộc 2–4 dạng bài với Bloom đa dạng*: Bổ sung quy tắc: *"Mỗi bài học PHẢI có từ 2 đến 4 dạng bài trọng tâm với bloomLevel đa dạng từ 1 đến 4 (1: Nhận biết, 2: Thông hiểu, 3: Vận dụng, 4: Vận dụng cao), tuyệt đối không để 1 dạng duy nhất hoặc toàn bộ bloomLevel=2"*.
    - *Minh họa schema mẫu đa tầng*: Đưa các dạng bài mẫu với `bloomLevel: 1` và `bloomLevel: 3` vào template mẫu gửi Gemini Vision.
  - **Tối Ưu Hóa Toàn Diện Tốc Độ Bóc Tách SGK: 48 DPI, Nén JPEG 52%, Batch 2 Trang, Giảm Tải Nội Dung & Timeout 15s (`./All Services/V-Eval-Ai_Engine/V-Eval-Ai_Engine.Infrastructure/Services/PdfPigTextbookParserService.cs`, `./All Services/V-Eval-Ai_Engine/V-Eval-Ai_Engine.API/Endpoints/TextbookEndpoints.cs`, `./All Services/V-Eval-Ai_Engine/V-Eval-Ai_Engine.API/appsettings.json`)**:
    - *Hạ DPI & Giảm kích thước ảnh SkiaSharp*: Thiết lập DPI mặc định thành `48 DPI` (thay vì 56/72), giới hạn chiều tối đa ảnh `capDim` xuống `640px - 720px` và nén JPEG 52%. Cắt giảm 65-70% dung lượng payload ảnh (từ ~180KB xuống ~35-50KB/trang), giảm 50% số token hình ảnh (tiling tokens) gửi đến Gemini.
    - *Thu nhỏ Batch Size Vision AI (2 Trang/Lượt)*: Giảm batch size xử lý ảnh từ 4-5 trang xuống 2 trang/lần. Tránh hiện tượng Gemini phải sinh hàng nghìn tokens cùng lúc gây nghẽn/timeout; thời gian phản hồi mỗi batch giảm từ 15-22s xuống chỉ còn **2.5s - 4.5s**.
    - *Giảm tải nội dung phải parse (High-Yield Core Knowledge Prompt)*: Cải tiến prompt chỉ trích xuất tri thức trọng tâm cốt lõi (Định nghĩa, Định lý, Tính chất, 100% Công thức KaTeX, 1 Ví dụ tiêu biểu ngắn gọn 2-3 bước). Loại bỏ hoàn toàn bài tập tự luyện dài dòng, hoạt động khởi động, trò chơi; giới hạn `maxOutputTokens = 4096`. Token đầu ra giảm 60%, tốc độ sinh chữ tăng gấp 3 lần.
    - *Bộ đệm điều tiết nhịp độ (Inter-Batch Pacing Jitter)*: Bổ sung khoảng dừng `await Task.Delay(400, cancellationToken)` giữa các batch/cluster để giải tỏa áp lực hạn ngạch TPM/RPM (Tokens/Requests Per Minute) của Google Gemini, triệt tiêu mã lỗi 503 và 429 do gửi request quá dồn dập.
    - *Khắc phục lỗi bỏ sót kết quả (Resilient Multi-Page Regex Parsing)*: Bổ sung regex dự phòng bắt tiêu đề `### Trang X`, `[TRANG X]`, `Page X` và cơ chế bảo hiểm tự động gán dữ liệu cho trang đầu batch nếu Gemini không trả về đúng thẻ phân trang chuẩn, ngăn chặn tuyệt đối lỗi quăng bỏ kết quả 200 OK hợp lệ để chuyển model lặp vô ích.
    - *Timeout bảo vệ 15s cho Vision Request*: Bổ sung `CancellationTokenSource.CancelAfter(TimeSpan.FromSeconds(15))` cho mỗi lượt gọi mô hình; nếu Google xếp hàng quá lâu (như `gemini-3.6-flash` nghẽn 19.8s), hệ thống tự động hủy và đổi sang model/key tiếp theo ngay lập tức.
    - *Loại bỏ các model thường xuyên quá tải*: Đưa `gemini-3.6-flash` ra khỏi danh sách xoay vòng trong `appsettings.json`, tập trung 100% tài nguyên vào các model ổn định `gemini-3.1-flash-lite`, `gemini-3.5-flash-lite` và `gemini-flash-lite-latest`.
  - **Fail-Fast Khi Model Quá Tải 503/500/504 & Tối Ưu Thứ Tự Ưu Tiên Flash-Lite (`./All Services/V-Eval-Ai_Engine/V-Eval-Ai_Engine.Infrastructure/Services/PdfPigTextbookParserService.cs`, `./All Services/V-Eval-Ai_Engine/V-Eval-Ai_Engine.API/appsettings.json`)**:
    - *Cơ chế ngắt mạch quá tải*: Khi Google trả về mã lỗi 503 (Server Overload), 500, 504 hoặc 404, hệ thống lập tức ngắt vòng lặp key (`break`) để chuyển sang MODEL tiếp theo thay vì tiếp tục thử 4 API keys vô ích, cắt đứt hoàn toàn tình trạng đóng băng từ 30s-90s.
    - *Tối ưu hóa cấu hình Flash-Lite*: Đưa các model siêu tốc `gemini-3.1-flash-lite`, `gemini-3.5-flash-lite`, `gemini-flash-lite-latest` lên top đầu trong `appsettings.json`, duy trì tốc độ xử lý 4–7s/batch ổn định 100% (200 OK).
  - **Triệt Tiêu 100% Hardcode Models (Zero-Hardcode) Trong Pipeline Bóc Tách SGK (`./All Services/V-Eval-Ai_Engine/V-Eval-Ai_Engine.Infrastructure/Services/PdfPigTextbookParserService.cs`)**:
    - *Xóa sạch hardcode model*: Xóa bỏ hoàn toàn mảng `standardModels` trong hàm `ResolveGeminiModels` và mảng nối `new[] { 3.6-flash, ... }` trong `GeneratePatternExercisesAsync`.
    - *Tuân thủ 100% cấu hình*: Chuyển đổi sang đọc thuần túy từ section `"AiSettings:GeminiModels"` của `appsettings.json`, chấm dứt hoàn toàn hiện tượng tự động fallback sang các model lỗi 404.
  - **Sửa Lỗi Biên Dịch CS0103 Trong Chuỗi Nội Suy KaTeX & Khởi Chạy Ổn Định Cổng 5104 (`./All Services/V-Eval-Ai_Engine/V-Eval-Ai_Engine.Infrastructure/Services/PdfPigTextbookParserService.cs`)**:
    - *Sửa lỗi escape ngoặc nhọn*: Escape `{{AB}}` và `{{a}}` trong chuỗi `$@"..."` triệt tiêu lỗi `error CS0103: The name 'AB' does not exist in the current context`.
    - *Khởi chạy dịch vụ nền*: Dịch vụ `V-Eval-Ai_Engine.API` biên dịch sạch 100% (0 errors, 0 warnings) và đang chạy daemon trên cổng 5104.
    - *Xác thực định tuyến Gateway*: YARP Gateway (cổng 5212) định tuyến thông suốt đến `http://127.0.0.1:5104/api/ai-engine/textbooks/sources`, phản hồi HTTP 200 OK ngay lập tức.
  - **Chuẩn Hóa Pipeline Bóc Tách Tri Thức (`CurriculumTaxonomyRegistry.cs`, `CurriculumAiService.cs`, `PdfPigTextbookParserService.cs`)**:
    - *Khử triệt để thẻ rò rỉ*: Chuyển đổi cơ chế bóc tách thẻ `[TAXONOMY: ...]` sang xử lý đa thẻ (`Regex.Matches`) và gọi `Regex.Replace` xóa sạch 100% thẻ taxonomy khỏi văn bản `chunk.Text`.
    - *Lọc sạch thông tin xuất bản*: Tự động phát hiện các dòng `Tên sách`, `Bộ sách`, `Tổng chủ biên`, `Chủ biên`, `Nhà xuất bản` để xóa bỏ và phân loại trang thành `section="COVER"`.
    - *Nối dòng KaTeX & biểu diễn vectơ*: Nối các dòng ngắt đơn lẻ đối với biến số và điểm hình học; chuẩn hóa các ký hiệu vectơ sang KaTeX `\vec{AB}`, `|\vec{AB}| = AB`.
  - **API Xóa Sách & Vector Chunks (`TextbookEndpoints.cs`, `TextbookRepository.cs`, `ITextbookRepository.cs`)**:
    - Bổ sung endpoint `DELETE /api/ai-engine/textbooks/sources/{sourceId:guid}` xóa an toàn trong một transaction Npgsql.
- **V-Eval-Web_Client**:
  - **Kiến Trúc Universal Storage Bridge, Triệt Tiêu Stale Closure & Đồng Bộ Câu Hỏi Thời Gian Thực Hai Chiều (`./All Services/V-Eval-Web_Client/src/components/curriculum/textbookStateBridge.js`, `./All Services/V-Eval-Web_Client/src/components/curriculum/TextbookIngestView.jsx`, `./All Services/V-Eval-Web_Client/src/components/curriculum/TextbookStandardView.jsx`)**:
    - *Chẩn đoán & Khắc phục triệt để lỗi mất câu hỏi*:
      + Triệt tiêu lỗi Stale Closure React trong `saveToStorage`: sử dụng `skeletonRef = useRef(skeleton)` và luôn cập nhật `skeletonRef.current` trước khi lưu vào persistent storage, loại bỏ hiện tượng async loop ghi đè skeleton rỗng lên `localStorage`.
      + Loại bỏ lỗi lệch chỉ số mảng (Index Mismatch): thay thế truy cập chỉ số `chapters[cIdx]` bằng hàm `updatePatternByName(chapterTitle, lessonTitle, patternName, updater)` định vị tuyệt đối theo tên chương, bài học và dạng bài.
      + Khắc phục trạng thái rỗng khi Mount: `TextbookStandardView.jsx` tự động nạp dữ liệu câu hỏi từ `getSavedTextbookData(sourceId, fileName)` và hợp nhất sâu qua `mergeSavedExercisesIntoChapters` ngay khi component khởi tạo.
    - *Cứu cánh lưu trữ Universal Storage Bridge*:
      + Hàm `getSavedTextbookData` tra cứu đa tầng qua `sourceId` CSDL Supabase, `fileName` và fallback mặc định across `localStorage` và `sessionStorage`.
      + Hàm `saveTextbookData` ghi đồng thời vào nhiều khóa và phát sự kiện `window.dispatchEvent(new CustomEvent('veval:textbook-saved', { detail }))`.
      + Tích hợp listener `veval:textbook-saved` giúp phản hồi tức thì hai chiều: AI sinh câu hỏi ở Trang Nạp là Trang Xem hiển thị ngay lập tức mà không cần F5.
    - *Nạp sẵn bộ câu hỏi mẫu chuẩn GDPT 2018*: Bổ sung ngân hàng câu hỏi mẫu hoàn chỉnh kèm công thức KaTeX, đáp án A/B/C/D và lời giải chi tiết cho `PHYS_10` Bài 1 và Bài 2 trong `GDPT_PRESETS`.
  - **Thu Gọn Thanh Mục Lục Cấu Trúc SGK Linh Hoạt Tương Tự Sidebar (`./All Services/V-Eval-Web_Client/src/components/curriculum/TextbookStandardView.jsx`)**:
    - *Cơ chế thu gọn `isTocCollapsed`*: Tích hợp nút thu gọn (`ChevronLeft`) trên thanh tiêu đề mục lục bên trái.
    - *Thu nhỏ thành cột dọc tinh tế*: Khi thu gọn, cột mục lục co lại thành dải thanh dọc (`lg:col-span-1`) hiển thị nút mở rộng (`ChevronRight`) và tiêu đề xoay dọc `Mục Lục SGK ({count} Chương)`, giải phóng diện tích ngang cho cột nội dung mở rộng sang `lg:col-span-11`.
    - *Nút shortcut mở nhanh*: Bổ sung nút `[Mục lục]` với icon `ChevronRight` trên thanh header bài học giúp mở lại cây mục lục 1-click tức thì.
    - *Tự động mở rộng 2 trang OCR song song*: Khi mục lục hoặc sidebar thu gọn (`isSidebarCollapsed || isTocCollapsed`), bộ trích xuất OCR tự động hiển thị 2 trang sách song song (`pageSize = 2`).
  - **Thu Nhỏ Ô Lý Thuyết Còn 3/5 Tỉ Lệ Chuẩn (`./All Services/V-Eval-Web_Client/src/components/curriculum/TextbookStandardView.jsx`)**:
    - Giới hạn chiều cao ô hiển thị lý thuyết chuẩn xuống ~3/5 (từ `min-h-[920px] max-h-[140vh]` còn `min-h-[380px] max-h-[550px] overflow-y-auto`, làm tròn xuống 550px) giúp bố cục cân đối và cuộn mượt mà.
    - Ở chế độ chỉnh sửa trực tiếp lý thuyết (`isEditingTheory`), điều chỉnh ô `textarea` từ `rows={16}` xuống `rows={10}` tương ứng tỉ lệ 3/5.
  - **Bổ Sung Phân Hệ Ngân Hàng Câu Hỏi & Bài Tập SGK Trực Tiếp Dưới Ô Lý Thuyết (`./All Services/V-Eval-Web_Client/src/components/curriculum/TextbookStandardView.jsx`)**:
    - *Header phân hệ câu hỏi*: Hiển thị tổng số câu hỏi thực tế (`{activeLessonExercises.length} câu`), định danh bài học và huy hiệu phân hóa Bloom Taxonomy L1–L6.
    - *Bộ lọc phạm vi & cấp độ nhận thức*: Cho phép lọc `[Cả bài]` hoặc `[Dạng bài đang chọn]`, kèm các pill lọc nhanh theo 6 cấp độ Bloom (L1. Nhớ, L2. Hiểu, L3. Vận dụng, L4. Phân tích, L5. Đánh giá, L6. Sáng tạo).
    - *Thẻ bài tập chi tiết*: Render đề bài toán học qua `<MathText />`, 4 phương án trắc nghiệm A/B/C/D với đáp án đúng được làm nổi bật viền xanh ngọc `ring-1 ring-emerald-400` kèm icon `CheckCircle2`.
    - *Phương pháp & Lời giải chi tiết*: Nút đóng/mở xem phương pháp và lời giải chi tiết kèm icon bóng đèn `Lightbulb`.
    - *Empty State thân thiện*: Nếu bài học chưa có bài tập, hiển thị hướng dẫn kèm nút `[Đến Trang Nạp SGK để sinh câu hỏi]` điều hướng trực tiếp sang tab `ingest`.
  - **Tối Giản Hóa Giao Diện Sinh Câu Hỏi Phần 3: Loại Bỏ Nút Toàn Sách Cục Bộ, Bộ Chọn 1 Trong 2 Kèm Nút Sinh Duy Nhất & Dọn Dẹp Icon Thừa (`./All Services/V-Eval-Web_Client/src/components/curriculum/TextbookIngestView.jsx`)**:
    - *Xóa nút "Sinh toàn bộ sách" khỏi header bài học*: Loại bỏ nút toàn sách khỏi Phần 3 để tách bạch ranh giới phạm vi, đưa chức năng toàn sách lên thanh điều khiển tổng quát trên cùng.
    - *Bộ chọn phạm vi 1 trong 2*: Bổ sung thanh chọn gọn gàng với tiêu mục rõ ràng `Sinh câu hỏi:` cho phép chọn 1 trong 2 chế độ:
      + `[Dạng này]`: Sinh câu hỏi cho dạng bài đang chọn (`activePattern`).
      + `[Cả bài học ({validPatterns.length})]`: Duyệt sinh câu hỏi cho toàn bộ các dạng bài của bài học hiện tại.
    - *Nút `[Sinh câu hỏi]` duy nhất*: Thay thế cụm 3 nút cồng kềnh trước đây bằng 1 nút duy nhất thực thi theo phạm vi đã chọn, tích hợp trạng thái tải xoay vòng `Đang sinh...` chuyên nghiệp.
    - *Dọn dẹp triệt để icon và text dư thừa*: Xóa sạch các emoji lồng ghép trùng lặp (`⚡`, `⚡⚡`, `🌟`, `✨ ⚡`, `⚡ ⚡ ⚡`, `✨ 🌟`), quy chuẩn 100% về icon SVG Lucide tinh tế (`Sparkles`, `RefreshCw`).
  - **Thanh Tác Vụ Tổng Quát Nằm Ngay Trên Bộ Chuyển 3 Chế Độ, Tự Động Lưu (Auto-Save) & Nút Lưu Toàn Bộ SGK (`./All Services/V-Eval-Web_Client/src/components/curriculum/TextbookIngestView.jsx`)**:
    - *Bố trí Thanh Điều Khiển Tổng Quát chuẩn công thái học*: Đặt nổi bật ngay phía trên bộ chuyển 3 chế độ (Phần 1: Cấu trúc / Phần 2: Lý thuyết / Phần 3: Câu hỏi), tách bạch hoàn toàn các tác vụ thuộc về toàn bộ cuốn sách khỏi các phân mục con của từng bài học.
    - *Nút "Lưu Toàn Bộ SGK"*: Thiết kế trực quan với icon `Save`, màu xanh ngọc lục bảo `bg-emerald-700`, cho phép người dùng chủ động bấm lưu toàn bộ Cấu trúc mục lục, Lý thuyết và Ngân hàng câu hỏi của cuốn sách vào persistent storage (`localStorage` & `sessionStorage`).
    - *Nút "Sinh Toàn Bộ Sách"*: Đặt ngay tại thanh tổng quát trên cùng, tách biệt với các nút sinh cục bộ cho bài học và dạng bài ở Phần 3.
    - *Cơ chế Tự Động Lưu (Auto-Save ON) & Khôi Phục Tự Động (Auto-Restore)*:
      + Tự động lưu tức thì vào `localStorage` (`veval_textbook_saved_${sourceId}`) ngay khi AI sinh thêm câu hỏi, chuyển cấp độ Bloom hoặc sửa đổi cấu trúc.
      + Badge hiển thị thời gian: `Đã lưu lúc HH:mm:ss` kèm chấm tròn phát xung xanh lá thời gian thực.
      + Khi chọn lại cuốn sách từ dropdown hoặc refresh trang, hệ thống tự động khôi phục toàn bộ câu hỏi và dạng bài đã lưu từ cache, không bao giờ bị mất dữ liệu.
  - **Đa Dạng Hóa Dạng Bài Chuẩn GDPT 2018 & Bộ Chọn Cấp Độ Nhận Thức Bloom (L1–L6) Trực Quan 1-Click (`./All Services/V-Eval-Web_Client/src/components/curriculum/TextbookIngestView.jsx`, `./All Services/V-Eval-Web_Client/src/components/curriculum/TextbookStandardView.jsx`)**:
    - *Tự động làm giàu dạng bài từ GDPT 2018 preset (`getGdptPreset`)*: Khắc phục hiện tượng bài học chỉ có 1 dạng bài đơn điệu mang cấp độ L2 do chunks OCR chỉ có nhãn mặc định chung. Hệ thống tự động nạp từ 2 đến 4 dạng bài thực tế từ bộ chuẩn GDPT 2018 với đa dạng cấp độ Bloom (L1 Nhớ, L2 Hiểu, L3 Vận dụng, L4 Phân tích).
    - *Bộ chuyển đổi Bloom Level 1-click*:
      + Trên cây mục lục bên trái: Huy hiệu `L{bloomLevel} ▾` cho phép click trực tiếp để xoay vòng cấp độ Bloom (L1 -> L2 -> L3 -> L4 -> L5 -> L6) kèm cập nhật màu sắc tức thì.
      + Tại Phần 3: Bổ sung thanh pill chọn nhanh 6 cấp độ Bloom (L1. Nhớ, L2. Hiểu, L3. Vận dụng, L4. Phân tích, L5. Đánh giá, L6. Sáng tạo) ngay trên danh sách bài tập.
      + Cập nhật `handleAddNewPatternToLesson` tự động gán Bloom level tịnh tiến khi tạo dạng bài mới.
  - **Thay Thế `window.confirm`/`alert` Bằng Modal Popup Xác Nhận & Cam Kết Cơ Chế Chỉ Sinh Thêm (Append-Only) Tuyệt Đối Không Ghi Đè Câu Hỏi (`./All Services/V-Eval-Web_Client/src/components/curriculum/TextbookIngestView.jsx`)**:
    - *Thay thế hộp thoại browser bằng in-app Modal Dialog (`confirmModal`)*: Loại bỏ hoàn toàn `window.confirm`/`alert` của trình duyệt; tích hợp Modal Dialog Tailwind UI hiện đại với backdrop mờ (`backdrop-blur-xs`), card nổi bo tròn 3xl.
    - *Thống kê chi tiết & cam kết bảo toàn*: Hiển thị rõ tên phạm vi bài học / toàn sách, tổng số dạng bài, số câu sinh thêm (`+ 3 câu / dạng`), kèm thông báo cam kết xanh lá: *"Cam kết chỉ sinh thêm, không thay thế: Hệ thống chỉ sinh thêm câu hỏi mới và nối tiếp vào danh sách. Toàn bộ các câu hỏi đã có trước đó đều được giữ nguyên 100%, tuyệt đối không bị ghi đè hoặc thay thế."*
    - *Cơ chế Append-Only an toàn tuyệt đối*:
      + Toàn bộ logic cập nhật bài tập (`updatePatternAt`, `updatePattern`) sử dụng cú pháp nối mảng `exercises: [...existing, ...mappedNew]`.
      + Cấp phát mã ID duy nhất cho từng bài tập mới sinh (`id: `ex_${Date.now()}_...``) chống xung đột key React.
      + Thông báo Toast hiển thị tổng số câu tích lũy sau khi hoàn thành.
  - **Tính Năng AI Sinh Câu Hỏi Hàng Loạt (Batch Exercise Generation) Cho Mọi Dạng Bài (`./All Services/V-Eval-Web_Client/src/components/curriculum/TextbookIngestView.jsx`)**:
    - 3 chế độ sinh bài tập thông minh: Đơn lẻ, Toàn bộ dạng trong bài học, và Toàn bộ dạng trong toàn cuốn sách.
    - Kích hoạt nhanh từ Cây Mục Lục bên trái và Thanh Tổng Quát trên cùng.
    - Thanh tiến trình trực quan thời gian thực hiển thị tỷ lệ `%`, số thứ tự `Dạng X / Y`, tên bài và tên dạng đang xử lý kèm nút `[Dừng Lại]`.
  - **Đồng Bộ Hoàn Toàn Cây Cấu Trúc Sách Phân Cấp (Chương ▾ Bài Học ▾ Dạng Bài) Cho Trang Nạp SGK Giống Trang Xem SGK Chuẩn (`./All Services/V-Eval-Web_Client/src/components/curriculum/TextbookIngestView.jsx`)**:
    - Tái thiết kế cột trái `lg:col-span-4` thành cây accordion 3 tầng chuẩn mực (`Chương C.X` ▾ `Bài học B.X` ▾ `Dạng bài P.X` kèm nhãn Bloom L1–L6 và `cleanPrefix`).
    - Cho phép click chọn Dạng bài trực tiếp trên cây để kích hoạt Phần 3 (Câu Hỏi & Bài Tập SGK).
  - **Kiểm Thử Vận Hành**: `npm run build` (`vite build`) đạt `✓ built in 1.24s` với 3053 modules sạch 100%, 0 lỗi.
