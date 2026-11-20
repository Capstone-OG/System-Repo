# UPDATE - SYSTEM REPO

## [21/11/2026]
- **Tối Ưu Hóa Trình Bày Câu Hỏi Tìm Lỗi Sai Tiếng Anh, Tự Động Phục Hồi Chùm Đọc Hiểu 118–120 & Nâng Cấp Bộ Parser Đề Thi PDF (Chạy Local, Không Deploy Docker)**:
  - **Web Client (`examParserUtils.js`, `examTextRepair.js`, `ExamPaperView.jsx`, `MathText.jsx`, `examStateBridge.js`, `examStateBridge.test.js`)**:
    + Bổ sung cơ chế tự động chữa lành chùm đọc hiểu (`normalizeExamData`): giải cứu các câu hỏi bị nuốt vào bên trong thân đoạn văn do dữ liệu cũ, tách riêng thành 3 câu hỏi con 118, 119, 120 với đầy đủ phương án A/B/C/D (chuyển trạng thái từ "0 câu" thành "3 câu"); phục hồi nguyên bản đoạn văn Lịch sử 11 trang 155 không còn ký tự rác.
    + Xóa bỏ các nhãn `(A)`, `(B)`, `(C)`, `(D)` lơ lửng trên câu hỏi; định dạng từ cần tìm lỗi sai thành **in đậm + gạch chân** (`font-bold underline`).
    + Nâng cấp `STORAGE_KEY` lên `v3` để trình duyệt tự động xóa cache cũ và kích hoạt logic phục hồi.
  - **AI Engine (`PdfPigLocalExamParser.cs`, `PdfPigLocalExamParserTests.cs`)**:
    + Chuyển sang thuật toán **Line-Following (Nearest-Neighbor Horizontal Chain)** trong `ExtractOrderedPageText`: loại bỏ 100% tình trạng xé lẻ chữ cái đơn (`o`, `g`, `n`, `u`, `V`, `i`, `đ`) và chống trộn dòng khi trang scan bị nghiêng.
    + Mở rộng nhận diện câu hỏi số trần (`91.`, `92.`, `118.`, `119.`, `120.`), chống chùm đọc hiểu nuốt câu hỏi con.
- **Kiểm Thử Toàn Hệ Thống**:
  - `V-Eval-Ai_Engine`: `dotnet build --no-restore` 0 Error, `dotnet test --no-build` `65/65` passed.
  - `V-Eval-Web_Client`: `examStateBridge.test.js` `6/6` passed, `tests/*.test.js` `22/22` passed, `npm run build` thành công `6.40s`.
