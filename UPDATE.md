# Nhật Ký Cập Nhật (Update Log) - System Repo

## [27/09/2026] - Phát Hành Giao Diện Làm Thử Đề Thi Chẩn Đoán, AI Exam Studio (Custom Prompt, Bloom 6 Cấp, Lưu DB Chờ Duyệt) & Radar Chart

- **Phát Hành Giao Diện Khảo Sát Năng Lực Đầu Vào (`view-diagnostic.html`)**:
  - Xây dựng giao diện web độc lập phong cách Glassmorphism hiện đại (Inter, Plus Jakarta Sans, KaTeX, Chart.js) hỗ trợ kiểm thử thực tế và mô phỏng luồng Core Flow 1.
  - Tích hợp 3 Tab hoàn chỉnh:
    1. **Tab 1: AI Exam Studio**: Giáo viên nhập prompt tùy biến, chọn 5 môn học hoặc tự động nhận diện môn, chọn cấp độ Bloom (1-6) và số câu (10, 20, 30 câu).
    2. **Tab 2: Phòng Thi Học Sinh**: Làm bài thi, điều hướng 30 câu, nộp bài hoặc dùng Demo Solver tự động điền theo các kịch bản học sinh.
    3. **Tab 3: Báo Cáo Năng Lực & Radar Chart**: Điểm IRT 2PL, xếp lớp, radar chart, phân tích Bloom và bảng BKT.
  - Phục vụ đồng thời tại `http://localhost:5261/view-diagnostic.html` (Practice Service) và `http://localhost:5104/api/ai-engine/view-diagnostic` (AI Engine).
- **Phát Hành Nút Lưu CSDL Chờ Duyệt & Cơ Chế Phê Duyệt Xuất Bản**:
  - Bổ sung nút **`💾 Lưu Vào Database (Chờ Duyệt)`**: Lưu đề thi vào Supabase PostgreSQL qua `POST /api/v1/content/exams/import` với trạng thái mặc định **`IsPublished = false` (Chờ duyệt / Pending Approval)**.
  - Nút **`✅ ACCEPT: Phê Duyệt & Chuyển Sang Phòng Thi Học Sinh ➔`**: Tự động gọi `PATCH /api/v1/content/exams/{id}/publish` cập nhật trạng thái thành **`IsPublished = true` (Đã duyệt / Published)** và chuyển đề thi sang phòng thi học sinh.
- **Tối Ưu Luồng Đánh Giá Bloom 6 Mức Độ (Revised Bloom's Taxonomy)**:
  - Khởi tạo hằng số `BloomTaxonomy.cs` trong cả Content Service và Practice Service định nghĩa 6 mức độ nhận thức:
    1. Nhận biết (Remembering)
    2. Thông hiểu (Understanding)
    3. Vận dụng (Applying)
    4. Phân tích (Analyzing)
    5. Đánh giá (Evaluating)
    6. Sáng tạo (Creating)
  - Ánh xạ độ khó IRT 2PL trong AI Engine (`diagnostic_engine.py`) sang 6 mức độ tương ứng: `b \in {-1.8, -1.0, -0.2, +0.6, +1.4, +2.2}`.
  - Cập nhật schema Pydantic `DiagnosticAnswerItem` mở rộng phạm vi `difficulty_level` lên `[1..6]`.
- **Phát Hành AI Exam Studio, Quy Trình Kiểm Duyệt Đề & Kiến Trúc Chế Độ Kép (Dual Engine: Gemini Cloud vs Siêu Tốc)**:
  - Bổ sung **Tab 1: AI Exam Studio**: Cho phép giáo viên nhập prompt tự do tùy biến dạng bài, kèm 5 mẫu gợi ý nhanh (Chuẩn V-ACT, Toán chuyên sâu, Logic suy diễn, KHTN ứng dụng, Ngôn ngữ đọc hiểu).
  - Tích hợp bộ lọc dropdown trực quan: Lĩnh vực / Môn học, Thang độ khó Bloom 6 cấp (Cân bằng, Cơ bản, Vận dụng, Nâng cao), Số lượng câu hỏi (10, 20, 30 câu).
  - Hỗ trợ **2 Chế độ Engine linh hoạt**:
    1. **Google Gemini Live Cloud**: Gọi mô hình Gemini (`gemini-flash-lite-latest`) với cấu trúc JSON `responseSchema`, AI trực tiếp suy nghĩ và sinh mới 100% câu hỏi bám sát prompt (~3-6s).
    2. **Siêu Tốc Calibrated Bank**: Tổ hợp các câu hỏi chuẩn hóa từ RAM siêu tốc (< 0.1s), phục vụ demo tức thì và kiểm thử nhanh.
  - **Cơ Chế Nhận Diện Ý Định & Khắc Phục Xung Đột Lĩnh Vực (Strict Domain Conflict Resolution)**: Tự động phát hiện từ khóa chuyên sâu trong câu prompt (ví dụ: `Full Ngữ Văn` chuyển thẳng sang `dom_lang`), vô hiệu hóa tình trạng rơi vào cấu hình mặc định 5 lĩnh vực (`ALL`), đảm bảo 100% câu hỏi thuộc đúng môn học được yêu cầu.
  - **Ưu Tiên Tuyệt Đối Lựa Chọn Dropdown Của Giáo Viên**: Khắc phục triệt để lỗi dropdown tự động nhảy sang Ngữ văn; chỉ kích hoạt suy luận từ prompt khi dropdown là `ALL`. Bổ sung gợi ý mẫu `🌍 Chuyên Sâu KHXH (Lịch Sử & Địa Lý)`.
  - Phân bổ đáp án chuẩn hóa đều 4 phương án A, B, C, D (25% mỗi đáp án), hiển thị KaTeX sắc nét cho toàn bộ biểu thức toán học.
  - **Cơ Chế Tự Động Lưu (Auto-Save LocalStorage & Restore)**: Tự động lưu bản nháp đề vừa tạo ngay khi AI sinh xong và tự động lưu đề thi chính thức khi giáo viên bấm `ACCEPT`. Khi F5/tải lại trang, hệ thống tự động nhận diện và khôi phục lại đề thi từ bộ nhớ trình duyệt kèm nút `📂 Khôi Phục Đề Đã Lưu`.
  - **Chuẩn Hóa Múi Giờ Việt Nam (Asia/Ho_Chi_Minh UTC+7)**: Cấu hình role PostgreSQL Supabase sang `Asia/Ho_Chi_Minh` và bổ sung trường `createdAtVn` trong API DTO tự động định dạng `dd/MM/yyyy HH:mm:ss`, hiển thị chuẩn xác ngày hôm nay `27/09/2026` trên cả CSDL và REST API.
- **Nâng Cấp Script Chạy Local Toàn Diện (`Scripts/run_local/run_local.bat`)**:
  - Hỗ trợ chạy đồng thời đầy đủ 6 service trọng yếu của hệ sinh thái V-Eval trong các cửa sổ riêng biệt:
    1. `V-Eval-Gateway`: Cổng API YARP Reverse Proxy (`http://localhost:5212`)
    2. `V-Eval-Identity_Service`: Xác thực JWT, User, Campus (`http://localhost:5155` / gRPC `:5156`)
    3. `V-Eval-Content_Service`: Ngân hàng câu hỏi, đề thi chẩn đoán (`http://localhost:5249` / gRPC `:5250`)
    4. `V-Eval-Practice_Service`: Chấm điểm thi, phân lớp, UI runner (`http://localhost:5261`)
    5. `V-Eval-Ai_Engine` (.NET API): Trích xuất OCR, ingestion đề thi (`http://localhost:5104`)
    6. `V-Eval-Ai_Engine` (Python FastAPI): Động cơ RAG, Psychometrics IRT 2PL, BKT, AI Exam Studio (`http://localhost:8000`)
  - Tự động giải phóng cổng xung đột (Kill port listening `5212, 5155, 5156, 5249, 5250, 5261, 5104, 8000, 5000, 5001, 5002...`).
  - Hỗ trợ menu 4 chế độ: Chạy Full 6 Service, Chạy riêng Microservices .NET, Chạy riêng AI Subsystem, hoặc Giải phóng Port.
- **Kiểm Thử Vận Hành & Build**:
  - Toàn bộ các solution .NET (`V-Eval-Practice_Service.sln`, `V-Eval-Content_Service.sln`, `V-Eval-Ai_Engine.sln`, `V-Eval-Gateway.sln`) biên dịch sạch 100% (**0 Error**).
  - Endpoint `/generate-exam` kiểm thử thành công HTTP 200 OK trên cả 2 chế độ: Fast Mode (`ms: 0`) và Gemini Mode (`ms: 7245`).
  - Endpoint `PATCH /api/v1/content/exams/{id}/publish` kiểm thử thành công HTTP 200 OK cập nhật `{ is_published: true }`.
  - Tối ưu luồng truy xuất biến môi trường, khắc phục triệt để lỗi thiếu `import os` trong `V-Eval-Ai_Engine/rag-service/routers/diagnostic.py`, toàn bộ 12/12 test cases của AI Engine chạy đạt 100%.

