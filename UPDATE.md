# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [16/10/2026] - Nâng Cấp Cây Tri Thức Đa Tầng 16 Dạng Bài, Làm Sâu Sắc Lý Thuyết Khối 1, Ngân Hàng 4-5 Câu Vận Dụng (L3/L4) Mỗi Dạng Bài & Bộ Lọc Bloom Panoramic Workspace

- **Làm Sâu Sắc Lý Thuyết Nền Tảng Khối 1 (`CurriculumAiService.cs` - AI Engine)**:
  - Tự động làm giàu Khối 1 với lý thuyết chuẩn SGK GDPT 2018 đa đoạn văn, 4 quy tắc vàng xác định số oxi hóa, bảng các trường hợp ngoại lệ đặc biệt ($H_2O_2$, $KO_2$, $OF_2$, $NaH$, hợp chất hữu cơ), lưu ý thi cử ĐGNL và ví dụ minh họa SGK có lời giải KaTeX chi tiết.
- **Mở Rộng Cây Tri Thức 16 Dạng Bài & 5 Bài Học Chi Tiết (`GenerateHeuristicCurriculum`)**:
  - Mở rộng toàn diện cấu trúc chương học lên 16 dạng bài chuyên sâu trải dài 5 bài học (Hóa học) và 11 dạng bài qua 4 bài học (Toán học), bao phủ từ xác định số oxi hóa, cân bằng ion-electron, bảo toàn electron nâng cao đến bài toán thực tế điện hóa và ăn mòn kim loại.
- **Ngân Hàng Câu Hỏi Sư Phạm 14 Câu/Dạng Bài (224 Câu) Với 5 Câu L3 & 5 Câu L4 (`EnrichPatternPedagogyAndQuestions`)**:
  - Thiết lập chuẩn tối thiểu 14 câu hỏi trắc nghiệm/dạng bài: 2 câu L1 (Nhận biết), 2 câu L2 (Thông hiểu), 5 câu L3 (Vận dụng) và 5 câu L4 (Vận dụng cao), đáp ứng triệt để yêu cầu ngân hàng câu hỏi vận dụng chuyên sâu của giáo viên.
  - Tự động sinh đầy đủ đề bài KaTeX, 4 phương án A-B-C-D, đáp án đúng và lời giải chi tiết KaTeX từng bước cho toàn bộ 16 dạng bài (tổng 224 câu hỏi).
- **Bộ Lọc Phân Cấp Bloom & Duyệt Câu Hỏi Thông Minh (`CurriculumExplorerView.jsx` - Web Client)**:
  - Tích hợp thanh tab lọc Bloom trực quan trên Khối 4: `[Tất cả (14)]`, `[L1: Nhận biết (2)]`, `[L2: Thông hiểu (2)]`, `[L3: Vận dụng (5 câu)]`, `[L4: Vận dụng cao (5 câu)]`.
  - Hiển thị huy hiệu mật độ câu hỏi ở Pane 1: `(L1: 2 • L2: 2 • L3: 5 • L4: 5)` và `Chuẩn ĐGNL: L3 (5 câu) • L4 (5 câu)`.
- **Kiểm Thử Vận Hành & Biên Dịch Hệ Thống**:
  - `V-Eval-Ai_Engine`: Biên dịch .NET 9 thành công 100% (**0 Error, 2 Warning**), service đang chạy ngầm trên cổng HTTP `5104`.
  - `V-Eval-Web_Client`: `npm run build` hoàn thành 100% (**0 Error, 0 Warning**, hoàn thành trong 732ms).
  - Kiểm thử `python test_ai_extract.py`: Trích xuất thành công 16 dạng bài với **224 câu hỏi mẫu**, mỗi dạng bài chứa đúng 2 L1, 2 L2, 5 L3 và 5 L4 câu hỏi.
