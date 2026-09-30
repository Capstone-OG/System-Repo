# Nhật Ký Cập Nhật (Update Log) - System Repo

## [01/10/2026] - Nâng Cấp Core Flow 2 (Bước 1 & 2): Mở Rộng Entity Class, Migration CSDL & Đồng Bộ DomainCode Qua gRPC / DTOs

- **Triển Khai Bước 1 Kế Hoạch Nâng Cấp Core Flow 2 Trong Practice Service**:
  - **Mở Rộng Mô Hình Thực Thể [`Class.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Domain/Entities/Class.cs)**: Bổ sung 4 trường dữ liệu mới: `ClassType`, `DomainId`, `DomainCode`, `ClusterIndex`.
  - **Ánh Xạ Fluent API Trong [`PracticeDbContext.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Infrastructure/Persistence/PracticeDbContext.cs)**: Cấu hình ánh xạ cột `class_type`, `domain_id`, `domain_code`, `cluster_index`.
  - **Di Trú Database Migration & Xác Thực Schema PostgreSQL**: Áp dụng migration `20260930184119_AddThematicCohortFields` vào CSDL PostgreSQL trên Supabase.
- **Triển Khai Bước 2 Kế Hoạch Nâng Cấp Core Flow 2 (Đồng Bộ DomainCode Qua gRPC & DTOs)**:
  - **Content Service**:
    - Cập nhật hợp đồng [`content.proto`](./All%20Services/V-Eval-Content_Service/V-Eval-Content_Service.API/Protos/content.proto) bổ sung `string domain_code = 8;` trong message `SkillNode`.
    - Hiện thực RPC `GetSkillsTree` trong [`ContentGrpcService.cs`](./All%20Services/V-Eval-Content_Service/V-Eval-Content_Service.API/Services/ContentGrpcService.cs) tự động ánh xạ mã miền chuẩn (`DOM_LANG`, `DOM_MATH`, `DOM_NAT_SCI`, `DOM_SOC_SCI`).
  - **Practice Service**:
    - Đồng bộ [`content.proto`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Infrastructure/Protos/content.proto) và trích xuất `DomainCode` qua [`IContentGrpcClient.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Application/Common/Interfaces/IContentGrpcClient.cs) & [`ContentGrpcClient.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Infrastructure/GrpcClients/ContentGrpcClient.cs).
    - Bổ sung `DomainCode` vào [`RoadmapNodeSummaryDto.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Application/Features/Roadmaps/DTOs/RoadmapNodeSummaryDto.cs), [`RoadmapStageDto.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Application/Features/Roadmaps/DTOs/RoadmapStageDto.cs), [`RoadmapNodeDetailDto.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Application/Features/Roadmaps/DTOs/RoadmapNodeDetailDto.cs).
    - Bổ sung `PlacementClass` vào [`GenerateRoadmapResponseDto.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Application/Features/Roadmaps/DTOs/GenerateRoadmapResponseDto.cs).
    - Cập nhật các Command/Query Handler ([`GenerateRoadmapCommandHandler.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Application/Features/Roadmaps/Commands/GenerateRoadmap/GenerateRoadmapCommandHandler.cs), [`GetMyRoadmapQueryHandler.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Application/Features/Roadmaps/Queries/GetMyRoadmap/GetMyRoadmapQueryHandler.cs), [`GetRoadmapNodeDetailQueryHandler.cs`](./All%20Services/V-Eval-Practice_Service/V-Eval-Practice_Service.Application/Features/Roadmaps/Queries/GetRoadmapNodeDetail/GetRoadmapNodeDetailQueryHandler.cs)) map trọn vẹn `DomainCode` và `PlacementClass`.
- **Kiểm Thử Toàn Diện & Biên Dịch Solution**:
  - Cả 2 service `V-Eval-Content_Service` và `V-Eval-Practice_Service` đều biên dịch sạch 100% (**0 Warning, 0 Error**).
