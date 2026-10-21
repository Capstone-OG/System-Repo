# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [21/10/2026] - Khắc Phục Triệt Để Lỗi 400 Validation (TheoryRecap & System.Char), Tái Cấu Trúc Tài Liệu docs/ & Ban Hành Master Database Schema V3 Chuẩn 4 Schema

- **Khắc Phục Toàn Diện Lỗi 400 Validation Error Khi Nạp Tri Thức CSDL (`The TheoryRecap field is required` & `System.Char`)**:
  - *Tầng Content Service*: Tái cấu trúc các DTOs trong `CurriculumDtos.cs` sang kiểu nullable (`string?`) kết hợp chuỗi fallback an toàn; bổ sung phòng thủ đa tầng tại `ImportCurriculumCommandHandler.cs` tự động điền nhãn mặc định khi tài liệu OCR khuyết thiếu lý thuyết/phương pháp. Xử lý triệt để lỗi chuyển đổi `System.Char` qua bộ converter toàn cục `FlexibleCharJsonConverter`.
  - *Tầng AI Engine*: Hỗ trợ song song cả camelCase (`theoryRecap`, `solutionMethod`) lẫn snake_case (`theory_recap`, `solution_method`) trong `CurriculumAiService.cs` (`TryParseCurriculumFromLooseJson` và `ExtractCurriculumViaRegex`); khởi tạo mặc định chuỗi rỗng `string.Empty` trong `CurriculumAiDtos.cs` để không bao giờ xuất hiện `null`.
  - *Tầng Web Client*: Nâng cấp `sanitizeCurriculumPayload` trong `contentService.js` bảo vệ toàn diện các cấp Chương (`chapterName`), Bài học (`lessonName`), Dạng bài (`patternName`), Lý thuyết (`theoryRecap`), Phương pháp (`solutionMethod`), Video (`videoUrl`) và các trường câu hỏi trước khi gửi request tới API.
- **Tái Cấu Trúc Toàn Diện Thư Mục Tài Liệu Hệ Thống (`docs/`)**:
  - *Thư mục `docs/core_flow/`*: Gom cụm toàn bộ 6 tài liệu đặc tả luồng nghiệp vụ cốt lõi và kế hoạch triển khai (`core_flow_1_chan_doan_nang_luc.md`, `core_flow_1_step_by_step_logic.md`, `core_flow_2_quy_hoach_lo_trinh_hoc_tap.md`, `ke_hoach_trien_khai_core_flow_2_path_planning.md`, `ke_hoach_trien_khai_core_flow_3_adaptive_practice.md`, `luong_phan_tich_va_hien_thi_de_thi.md`).
  - *Thư mục `docs/lich_hop_va_cau_hoi/`*: Gom cụm lịch họp, câu hỏi định hướng và hướng giải quyết (`lich_hop_tuan_3_va_cau_hoi_huong_dan.md`).
  - *Thư mục gốc `docs/`*: Giữ lại toàn bộ usecase chuẩn hóa (`usecase_chuan_hoa_capnhat.md`, `usecase_chuan_hoa_capnhat - Copy.xlsx`) và các tài liệu kiến trúc vĩ mô.
  - *Chuẩn Hóa Đường Dẫn Tương Đối*: Cập nhật 100% liên kết nội bộ theo chuẩn `./` và `../`, tương thích hoàn hảo với MD Editor Plus.
- **Ban Hành Master Enterprise Database Schema V3 (`docs/SQL/SQL.sql`)**:
  - Phân tách chuẩn 4 Schemas PostgreSQL độc lập: `v_eval_identity`, `v_eval_content`, `v_eval_practice`, `v_eval_ai`.
  - Bổ sung đầy đủ 100% các bảng hiện đại: Đồ thị DAG tiên quyết (`SkillPrerequisites`), Tiến độ 4 giai đoạn (`StageProgress`), Lịch sử làm bài thích ứng (`AdaptiveQuizAttempts`), Sổ tay lỗi sai Leitner (`MistakeNotebooks`), Nhóm phân hóa năng lực trong lớp (`ClassGroups`, `ClassGroupMembers`), và Vector chunks 768 chiều (`KnowledgeVectorChunks`) kèm chỉ mục HNSW Cosine Similarity (<5ms).
  - Đồng bộ bảng đối chiếu vật lý tại Mục 3.1 trong `docs/kien_truc_chuan_tong_the_he_thong_v_eval.md`.
- **Kiểm Thử Toàn Diện Hệ Thống**:
  - `V-Eval-Content_Service.Application.csproj`: Biên dịch .NET 9 SDK thành công 100% (**0 Error, 0 Warning**).
  - `V-Eval-Ai_Engine.Application` & `Infrastructure`: Biên dịch .NET 9 SDK thành công 100% (**0 Error, 0 Warning**).
  - `V-Eval-Web_Client`: `npm run build` hoàn thành 100% (**0 Error, 0 Warning** trên Vite 8 và React 19).
