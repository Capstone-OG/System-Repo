# KẾ HOẠCH DỌN DẸP & CHUẨN HÓA DEAD CODE (BACKEND)

> **Người thực hiện**: Trần Thái Thịnh (`ThinhTT` / `Thinhtran2412`)  
> **Ngày lập kế hoạch**: `27/11/2026`  
> **Nhánh gốc đồng bộ**: `origin/develop` (đã pull mới nhất trên `V-Eval-Ai_Engine` và `V-Eval-Gateway`)  
> **Nhánh làm việc đề xuất**: `ThinhTT/chore-cleanup-unused-code` (tách từ `develop`)

---

## 1. Chiến lược nhánh Git (Branching Strategy)
- **`V-Eval-Ai_Engine`**: Tạo nhánh `ThinhTT/chore-cleanup-unused-code` từ `develop`.
- **`V-Eval-Gateway`**: Tạo nhánh `ThinhTT/chore-cleanup-unused-code` từ `develop`.
- **`System-Repo`**: Giữ nhánh `ThinhTT/personal-acceptance-audit` để cập nhật `docs_noi_bo/personal/ThinhTT_aceptance.md`.

---

## 2. Danh sách chi tiết 7 file Dead Code / Stub cần xóa

### A. Repo `V-Eval-Ai_Engine` (5 file code + 1 file test)
| # | File | Lý do xóa |
| :-: | :--- | :--- |
| 1 | `V-Eval-Ai_Engine.Infrastructure/Services/QdrantVectorDbService.cs` | Đã bị thay thế 100% bởi `PgVectorDbService.cs` trong `DependencyInjection.cs` trên `develop` (0 tham chiếu runtime). |
| 2 | `V-Eval-Ai_Engine.Domain/Entities/TutorSession.cs` | Scaffold từ đợt refactor `01/09/2026`, không có service runtime nào gọi. |
| 3 | `V-Eval-Ai_Engine.Domain/ValueObjects/DialogueMessage.cs` | Chỉ duy nhất `TutorSession.cs` dùng; mồ côi khi xóa `TutorSession.cs`. |
| 4 | `V-Eval-Ai_Engine.Domain/Entities/TheoreticalDocument.cs` | 0 tham chiếu trên toàn bộ codebase (kể cả unit tests). |
| 5 | `V-Eval-Ai_Engine.Domain/ValueObjects/KnowledgeChunk.cs` | 0 tham chiếu (luồng gRPC đang dùng `KnowledgeChunkDto` ở tầng Application). |
| 6 | `V-Eval-Ai_Engine.Tests/Domain/TutorSessionTests.cs` | Chỉ test `TutorSession.cs`, xóa đồng bộ để `dotnet test` không lỗi biên dịch. |

> **Lưu ý**: Giữ nguyên project `V-Eval-Ai_Engine.Domain.csproj` để bảo toàn cấu trúc solution 4 tầng Clean Architecture và không phá vỡ project references.

### B. Repo `V-Eval-Gateway` (1 file code)
| # | File | Lý do xóa |
| :-: | :--- | :--- |
| 7 | `V-Eval-Gateway.API/Health/DownstreamHealthCheck.cs` | File stub còn `// TODO`, không được đăng ký trong `ServiceCollectionExtensions.cs`. |

---

## 3. Các nhóm file ĐANG DÙNG THẬT (Tuyệt đối KHÔNG xóa)
- **24 file `*Validator.cs`** (`V-Eval-Content_Service`, `V-Eval-Practice_Service`): Tự động nạp qua FluentValidation Assembly Scanning.
- **`AuthConfigurations.cs`** (`V-Eval-Identity_Service`): Tự động nạp qua EF Core `ApplyConfigurationsFromAssembly`.
- **5 file Extension của `V-Eval-Gateway`** (`ServiceCollectionExtensions.cs`, `MiddlewarePipelineExtensions.cs`, `RateLimiterExtensions.cs`, `GatewayAuthExtensions.cs`, `ClaimsHeaderTransform.cs`): Được gọi trực tiếp trong `Program.cs` và `GatewayTransformProvider.cs`.

---

## 4. Trình tự thực hiện chuẩn (Tuân thủ `AGENTS.md`)
1. **Bước 1 — Tách nhánh & Xóa file**:
   - Tạo nhánh `ThinhTT/chore-cleanup-unused-code` từ `develop` trên `V-Eval-Ai_Engine` và `V-Eval-Gateway`.
   - Xóa 7 file trên và dọn các `using` thừa nếu có.
2. **Bước 2 — Kiểm thử vận hành**:
   - Chạy `dotnet build` và `dotnet test` trên `V-Eval-Ai_Engine`.
   - Chạy `dotnet build` trên `V-Eval-Gateway`.
   - Đảm bảo **0 errors, 0 broken tests**.
3. **Bước 3 — Cập nhật Tài liệu & `UPDATE.md` (Documentation First)**:
   - Cập nhật `docs/daily.md`, `docs/process.md`, `docs/architecture_acceptance.md` và làm mới `UPDATE.md` (chỉ giữ mục ngày hiện tại) trên từng repo liên quan.
   - Đồng bộ `docs_noi_bo/personal/ThinhTT_aceptance.md` (gỡ mục `TutorSession.cs`).
4. **Bước 4 — Review & Push**:
   - Kiểm tra `git status`, `git diff`, sau đó commit và push lên `origin/ThinhTT/chore-cleanup-unused-code`.
