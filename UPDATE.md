# UPDATE - V-Eval System Repo

## [17/11/2026]
- **Tái thiết kế toàn diện Kiến trúc Studio Sách Giáo Khoa (SGK) & Khắc phục triệt để hiện tượng Sector 1 trống lý thuyết**:
  - **V-Eval-Web_Client**:
    - **Tự động Hydrate Chunks vào React State (`filledChunks`)**: Tự động lấy 122 trang lý thuyết từ Supabase CSDL khi khởi động, khi người dùng chọn sách từ Kho SGK, hoặc khi Bước 2 hoàn thành.
    - **Thuật toán Khớp Lý Thuyết Đa Tầng Cực Kỳ Chuẩn Xác (`currentLessonChunks`)**: Ưu tiên đối chiếu theo khoảng trang bài học (`pageStart`–`pageEnd`), đảm bảo Bài 1 (Trang 15–20) khớp chuẩn xác 6 trang lý thuyết đầy đủ định nghĩa, công thức KaTeX và thí nghiệm thực hành đo tốc độ. Fallback an toàn hiển thị 12 chunks gần nhất, không bao giờ để trống.
    - **Nâng Cấp Giao Diện Sector 1 Tiện Ích**: Bổ sung bộ lọc xem "Bài này" vs "Toàn bộ SGK (122 trang)", thanh tìm kiếm tức thì theo từ khóa/công thức KaTeX, nút nạp trực tiếp từ CSDL và nút mở Studio biên soạn sư phạm.
    - **Tách riêng 2 phân hệ rõ ràng**: Phân hệ 1 (Parse & Nạp SGK Mới - 2-Stage Pipeline) không hiển thị nội dung sách cũ kế bên; Phân hệ 2 (Kho & Studio SGK 5 Sector) chuyên sâu cho việc tra cứu, biên soạn và sinh bài tập theo 6 cấp độ Bloom.
    - **Đồng bộ hóa Điều hướng Sidebar**: Cung cấp đầy đủ 3 phân hệ độc lập trên Sidebar: Khung Chương trình (`roadmap`), Sách Giáo Khoa (`textbook-studio`), và Parse Đề thi (`exam-studio`), mỗi phân hệ đều có Studio đi kèm được tối ưu đồng bộ.
    - `npm run build` (`vite build`) đạt `✓ built in 1.26s` với 0 lỗi biên dịch.
  - **V-Eval-Ai_Engine**:
    - Nâng cấp `renderPages`: Render 10 trang đầu và 6 trang cuối bằng SkiaSharp gửi trực tiếp đến Gemini Vision AI, đảm bảo nhận diện chính xác mục lục của mọi bộ SGK.
    - Cập nhật `ResolveGeminiModels`: Bổ sung toàn diện các model chính thức chuẩn của Google AI Studio (`gemini-2.5-flash`, `gemini-2.0-flash`, `gemini-1.5-pro`, `gemini-1.5-flash`).
    - Cập nhật `InMemoryTextbookJobManager.cs` và `TextbookEndpoints.cs`: Tự động gán `SourceId` khi job hoàn tất hoặc khi nhận diện Checkpoint từ Supabase.
    - `dotnet build` đạt 0 Warnings, 0 Errors; Dịch vụ API đang chạy ổn định ở background trên cổng 5104.
