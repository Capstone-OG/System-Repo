# V-Eval Centralized Configuration Management

Thư mục này chứa các file cấu hình môi trường **chuẩn (working environment configs)** cho toàn bộ hệ thống Microservices của dự án V-Eval.

## Cấu trúc thư mục

* `V-Eval-Gateway/appsettings.json`: Cấu hình YARP Reverse Proxy, JWT secret, và các route/cluster trỏ tới các microservices.
* `V-Eval-Identity_Service/appsettings.json`: Cấu hình Supabase PostgreSQL connection string, JWT token settings, và Kestrel HTTP/gRPC.
* `V-Eval-Content_Service/appsettings.json`: Cấu hình Supabase PostgreSQL, Kestrel HTTP/gRPC endpoint.
* `V-Eval-Practice_Service/appsettings.json`: Cấu hình Supabase PostgreSQL, gRPC client trỏ sang Identity (5156) và Content (5250), URL AI Subsystem.
* `V-Eval-Ai_Engine/appsettings.json`: Cấu hình .NET API của AI Engine, OpenAI/Gemini models, timeout, và DB connection string.
* `V-Eval-Ai_Engine/rag-service/.env`: Cấu hình Python FastAPI RAG service, Gemini API Key và PostgreSQL pgvector Supabase URL.
* `V-Eval-Web_Client/.env`: Cấu hình Web Client React 19 Vite trỏ tới API Gateway (Port 5212).

## Cách sử dụng

1. **Nạp cấu hình vào các service:** Chạy `Scripts/sync_config/sync_config.bat` và chọn `[1]` để áp dụng toàn bộ cấu hình chuẩn cho máy local.
2. **Cập nhật chia sẻ cho cả nhóm:** Khi bạn sửa đổi cấu hình và muốn cập nhật bản mẫu cho cả team, chạy `Scripts/sync_config/sync_config.bat` chọn `[2]`, sau đó commit `System-Repo`.
