# Nhật Ký Cập Nhật (Update Log) - System Repo

## [08/10/2026] - Chuyển Đổi Mô Hình Giảng Dạy Offline: Gỡ Bỏ Toàn Bộ 7/7 APIs Phân Hệ Live Streaming (LiveSessions)

- **Gỡ Bỏ Hoàn Toàn Tầng API Controller LiveSessions (`Practice Service`)**:
  - Xóa bỏ `LiveSessionsController.cs` và toàn bộ 7/7 endpoints phục vụ live streaming giảng dạy trực tuyến (`POST /live-sessions`, `GET /my-schedule`, `POST /{sessionId}/join`, `POST /{sessionId}/attendance`, `GET /teacher-schedule`, `PUT /{sessionId}/recording`, `PUT /{sessionId}/cancel`).
  - Chuyển đổi định hướng sản phẩm sang giảng dạy trực tiếp tại cơ sở (offline), không còn duy trì phân hệ live stream trực tuyến.
- **Dọn Sạch Toàn Bộ Tầng Application & Repository LiveSessions**:
  - Xóa sạch 100% thư mục `Features/LiveSessions` (bao gồm toàn bộ Commands, Queries, Handlers, Validators, DTOs).
  - Tái cấu trúc `AssignTeacherCommandHandler` sang inject `IClassEnrollmentRepository`, giải phóng phụ thuộc vào `ILiveSessionRepository`.
  - Gỡ bỏ hoàn toàn `ILiveSessionRepository.cs`, `LiveSessionRepository.cs` và đăng ký Scoped tại `DependencyInjection.cs`.
- **Đồng Bộ Tầng Dịch Vụ Phía Frontend (`Web Client`)**:
  - Gỡ bỏ 7 phương thức gọi API livestream đã decommission khỏi `src/services/practiceService.js`, giữ nguyên nghiệp vụ phân công giáo viên `assignTeacher`.
- **Đồng Bộ Kiến Trúc & Kiểm Thử Vận Hành Toàn Hệ Thống**:
  - Cập nhật bộ 3 tài liệu chuẩn trong `All Services/V-Eval-Practice_Service/docs/` (`daily.md`, `process.md`, `architecture_acceptance.md`) và `All Services/V-Eval-Web_Client/docs/daily.md`.
  - Toàn bộ 5 Microservices .NET (`Gateway`, `Identity`, `Content`, `Practice`, `AI Engine`) biên dịch sạch 100% (**0 Warning, 0 Error**).
  - Frontend `Web Client` build Vite thành công (**0 Error, 0 Warning**).
  - Cấu hình `docker compose config` hợp lệ 100%.
