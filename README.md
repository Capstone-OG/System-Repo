# V-EVAL: Hệ Thống Cá Nhân Hóa Lộ Trình Học & Luyện Thi Đánh Giá Năng Lực Tích Hợp AI (V-ACT 2026)

> **Dự án CapStone 2026** - Kiến trúc Microservices linh hoạt dựa trên nền tảng .NET 9 Web API, YARP API Gateway, Supabase PostgreSQL, Qdrant Vector DB và Gemini AI OCR / Socratic Tutor.

---

## 🏛️ KIẾN TRÚC HỆ THỐNG (MICROSERVICES ARCHITECTURE)

Hệ thống được chia thành **5 Microservices chính** hoạt động độc lập và liên thông thông qua **V-Eval API Gateway**:

```text
[ Web Client / SPA / Mobile ]
              │
              ▼
    ┌───────────────────┐
    │  V-Eval Gateway   │ (Port 5212 - YARP Reverse Proxy & Edge Security)
    └─────────┬─────────┘
              │
     ┌────────┼──────────────┬──────────────┬──────────────┐
     │        │              │              │              │
     ▼        ▼              ▼              ▼              ▼
┌─────────┐ ┌──────────┐ ┌───────────┐ ┌──────────┐ ┌────────────┐
│Identity │ │ Content  │ │ Practice  │ │AI Engine │ │ (Supabase/ │
│ Service │ │ Service  │ │ Service   │ │ (Gemini/ │ │ Qdrant Cloud)
│ (:5001) │ │ (:5249)  │ │ (:5002)   │ │  :5104)  │ └────────────┘
└─────────┘ └──────────┘ └───────────┘ └──────────┘
```

---

## 📊 BẢNG MA TRẬN DỊCH VỤ & PORT MAPPING

| Tên Dịch Vụ | Tên Thư Mục Service | Cổng (Port) | Công Nghệ Chính | Trách Nhiệm Chính |
| :--- | :--- | :---: | :--- | :--- |
| **V-Eval Gateway** | `All Services/V-Eval-Gateway` | **5212** | .NET 9, YARP v2.3.0 | Single Entry Point, Anti-Header Spoofing, Token Warning, Rate Limiting, CORS |
| **Identity Service** | `All Services/V-Eval-Identity_Service` | **5001** | .NET 9, JWT Auth, EF Core | Đăng ký, Đăng nhập, Quản lý Người dùng & Sinh JWT Token |
| **Content Service** | `All Services/V-Eval-Content_Service` | **5249** | .NET 9, CQRS MediatR, Supabase | Ngân hàng câu hỏi, Chùm bài đọc, Import đề thi từ AI |
| **Practice Service** | `All Services/V-Eval-Practice_Service` | **5002** | .NET 9, EF Core | Làm bài thi trực tuyến, Chấm điểm tự động, Thống kê kỹ năng |
| **AI Engine** | `All Services/V-Eval-Ai_Engine` | **5104** | .NET 9, Gemini OCR, Qdrant | Ingestion đề thi PDF, Socratic AI Tutor Chatbot, RAG Vector Search |

---

## 🚀 HƯỚNG DẪN CHẠY BẰNG DOCKER COMPOSE

### 1. Yêu cầu môi trường:
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Hỗ trợ Docker Compose v2)
- [.NET 9 SDK](https://dotnet.microsoft.com/download/dotnet/9.0) (Nếu muốn chạy local không qua Docker)

### 2. Chạy tự động bằng Script:
Mở Terminal hoặc click đúp chuột chạy file script:
```cmd
Scripts\run_docker\run_docker.bat
```

### 3. Chạy thủ công bằng Docker Compose Lệnh CLI:
```bash
# Khởi chạy và build lại toàn bộ 5 Microservices
docker-compose up --build -d

# Kiểm tra trạng thái các container đang chạy
docker compose ps

# Kiểm tra Health Check của Gateway
curl http://localhost:5212/healthz
```

---

## 🛡️ BẢO MẬT MÃ NGUỒN & CẤU HÌNH PRODUCTION

1. **Tệp cấu hình mẫu (`appsettings.example.json`)**: Mỗi microservice đều có 1 file mẫu chứa các label tham số cho Production.
2. **Loại bỏ Secret khỏi Git (`.gitignore`)**: Mọi file `appsettings.json` cá nhân chứa password / API Key thật trên máy local đều được tự động ẩn khỏi Git tracking.

---

## 📑 HỆ THỐNG TÀI LIỆU (DOCUMENTATION)

- 📘 **Triển khai Gateway**: [`All Services/V-Eval-Gateway/docs/trien_khai_gateway.md`](file:///e:/CapStone/All%20Services/V-Eval-Gateway/docs/trien_khai_gateway.md)
- 📕 **Nghiệm thu Kiến trúc Gateway**: [`All Services/V-Eval-Gateway/docs/nghiem_thu_va_thau_hieu_kien_truc.md`](file:///e:/CapStone/All%20Services/V-Eval-Gateway/docs/nghiem_thu_va_thau_hieu_kien_truc.md)
- 🟢 **Nhật ký Cập nhật Hệ thống**: [`UPDATE.md`](file:///e:/CapStone/UPDATE.md)
