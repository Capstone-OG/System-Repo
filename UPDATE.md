# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [01/11/2026] - Khởi Tạo & Chuẩn Hóa Báo Cáo Nghiệm Thu Mã Nguồn Cá Nhân (`ThinhTT_aceptance.md`)

- **Báo cáo nghiệm thu cá nhân ThinhTT (`docs_noi_bo/personal/ThinhTT_aceptance.md`)**:
  - Khởi tạo tài liệu nghiệm thu kỹ thuật chi tiết cho 34 file thành phần cốt lõi trong toàn bộ hệ thống V-Eval thuộc phạm vi thiết kế và commit của ThinhTT (loại trừ hoàn toàn `rag-service`).
  - Chuẩn hóa 100% cấu trúc toggle: tên file thuần túy (`<summary>Filename.ext</summary>`), liên kết điều hướng tương đối, mục tiêu nghiệp vụ, phân tích lỗi LLM, mã nguồn đáp ứng và cơ chế phòng thủ chiều sâu.
  - Hoàn thiện ghi nhận chi tiết cho `CurriculumAiService.cs` (Task đọc hiểu tài liệu với Gemini Vision, cơ chế sửa lỗi JSON RFC8259 qua `JsonSanitizer.RepairJson`) và `GeminiExamParserService.cs` (Bóc tách trực tiếp đề thi trắc nghiệm 120–150 câu, chuẩn hóa ảnh `DPI = 96`, `Quality = 70` kết hợp Fallback Model đa tầng).
