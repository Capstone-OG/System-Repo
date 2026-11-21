# UPDATE - SYSTEM REPO

## [22/11/2026]
- **Bóc Tách Chuyên Sâu Trực Tiếp Bộ 24 Cuốn SGK Thật (8 Môn Cốt Lõi × 3 Khối Lớp 10–12), Sinh Ngân Hàng Câu Hỏi & Đồng Bộ 1 Nguồn Chân Lý**:
  - Chạy pipeline bóc tách chuyên sâu trực tiếp từ bộ PDF SGK Chân trời sáng tạo (`docs/Document_Train/SGK`, kết hợp text gốc + Gemini Vision OCR): cập nhật **673/708 dạng bài** với toàn văn lý thuyết riêng từng dạng, công thức KaTeX, ví dụ mẫu kèm lời giải từng bước và bẫy đề ĐGNL V-ACT vào đồng thời **`v_eval_content."Materials"`** và **`v_eval_ai."KnowledgeVectorChunks"`** (thuộc **24 đầu sách** trong `v_eval_ai."KnowledgeSources"`).
  - Sinh bổ sung **3,189 câu hỏi trắc nghiệm chi tiết** (đủ 4 mức: Nhận biết, Thông hiểu, Vận dụng cơ bản, Vận dụng cao kèm lời giải từng bước) vào `v_eval_content."Questions"` (**tổng toàn DB đạt 4,068 câu hỏi / 954 kỹ năng**) và nâng cấp **553 dạng bài** thêm **Ví dụ 2 (Vận dụng ĐGNL)** đồng bộ 2 chiều sang `Materials` & `KnowledgeVectorChunks`.
- **V-Eval-Ai_Engine & CSDL `v_eval_content."Skills"`**:
  - Nâng cấp **339 bài học Lớp 10–12** thành **750 dạng bài thực tế không đánh số cứng `Dạng X:`** trong `gdpt2018_dgnl_taxonomy.json`; gỡ hardcode số dạng & tiền tố trong `PdfPigTextbookParserService.cs`; đồng bộ FK-safe vào `v_eval_content."Skills"` (`65/65` tests Passed).
- **V-Eval-Content_Service & V-Eval-Practice_Service**:
  - Thêm `IsContentLanguageMismatch` chặn câu Tiếng Anh gán nhầm môn; siết biên giới chương bước `1d`; kế thừa `Materials` theo anh em cùng bài (`18/18` tests Passed).
  - Gỡ lọc cứng `QuestionCount > 0 || MaterialId.HasValue` trong `GenerateRoadmapCommandHandler.cs` để nạp đủ 750+ dạng bài vào lộ trình (`20/20` tests Passed).
- **V-Eval-Web_Client**:
  - Bổ sung `StructuredTheoryRenderer` trong Pha Learn PLAR; sửa vỡ cột `MathText.jsx` (`headingStyles[3]` từ `flex` ➔ `block`) & bỏ tiền tố `#### Dạng` lồng nhau trong `textbookStateBridge.js`; tái thiết kế Learn-First UX 4 tab toàn màn hình & Studio 3 tab cho `TextbookStandardView.jsx`.
  - Chuẩn hóa `TextbookStandardView.jsx`, `AccountNavbar.jsx`, `contentService.js`: đổi `Bloom L1–L6` sang Tiếng Việt, bỏ dấu `✓ ✓` & thanh `Dạng bài:` trùng lặp; map trực tiếp `Môn học + Khối lớp` sang `Phiên bản SGK`; mở khóa nút điều hướng; khôi phục 1 nút đóng/mở Sidebar toàn hệ thống; nối Tab 3 tới ngân hàng câu hỏi CSDL thật và triệt tiêu `404 /api/content/skills-tree`.
  - Nâng cấp toàn diện **Luyện tập Thích ứng ZPD** (`AdaptiveQuizModal.jsx`), xây mới **Phòng Thi Thử V-ACT** có **Khóa toàn màn hình + Giám thị chống gian lận** (`StudentMockExamPage.jsx`) nối 4 bộ đề chính thức ĐHQG-HCM & kho 4,181 câu hỏi thật; bổ sung tính năng **Gắn cờ Báo lỗi & Tự động đổi câu hỏi** cho học sinh + **Hàng đợi Xét duyệt Chuyển miền/Xóa câu hỏi** cho Giảng viên & Ban quản lý (`FlaggedQuestionsReviewPanel.jsx`); gỡ bỏ **Lớp học & Live Q&A** (`npm run build` 0 Error).
