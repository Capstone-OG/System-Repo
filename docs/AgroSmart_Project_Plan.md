# AgroSmart — Kế hoạch triển khai chi tiết (End-to-End Project Plan)
### Bản v2 — Bổ sung đầy đủ theo Use Case / SRS gốc

> Bản kế hoạch chi tiết từ gốc đến ngọn để đạt điểm 9-10 (Xuất sắc) cho đồ án tốt nghiệp, đi từ phân rã kiến trúc phần cứng, thiết kế cơ sở dữ liệu cho đến triển khai các thuật toán AI cao cấp.
>
> **Các mục có gắn 🆕 là phần được bổ sung so với bản kế hoạch gốc, để khớp 100% với các use case trong file đăng ký/SRS.**

---

## 🛠️ Tổng quan kiến trúc hệ thống (System Architecture)

Hệ thống được thiết kế theo mô hình **Distributed Hybrid IoT-AI** (Hệ thống IoT - AI phân tán):

```
                                  [ CLIENT (Flutter Web/App) ]
                                      ▲                  │
                           (HTTPS)    │                  │ (HTTPS) Upload ảnh lá
                     Kết quả & Control│                  ▼
┌───────────────────────┐   LAN/VPN   │        ┌─────────────────────────┐
│ 1. MASTER NODE (Server)│ ◄──────────┘        │ 2. AI WORKER (PC/Laptop)│
│ (Ryzen 3 3250U - Ubuntu)│                     │ (Ryzen 5 + RX 6600)     │
│  - Docker Compose     │ ───────────────────> │  - PyTorch (ROCm/CUDA)  │
│  - EMQX (MQTT Broker) │  gRPC / HTTP POST    │  - EfficientNet-B3 + CAM│
│  - Postgres+Timescale │  Yêu cầu chẩn đoán   │  - GRU-Attention (TFT)  │
│  - FCM Push Gateway 🆕│                      │                         │
└───────────────────────┘                      └─────────────────────────┘
         ▲         │
  (MQTT) │         │ (MQTT) Control
  Sensor │         ▼
┌────────────────────────────────────────────────────────────────────────┐
│ 3. EDGE hardware (ESP32 tại vườn)                                       │
│  - Đọc SHT31, BH1750, Độ ẩm đất điện dung.                              │
│  - Tính Lưu lượng dòng chảy YF-S201 (đo lượng nước).                    │
│  - Chạy bộ lọc 1D Kalman. Bảo vệ an toàn bằng Hardware Watchdog.        │
│  - Gửi Heartbeat định kỳ báo trạng thái online/offline 🆕               │
└────────────────────────────────────────────────────────────────────────┘
```

---

## ⚠️ Ghi chú đồng bộ thuật ngữ (SRS ↔ Plan)

Kế hoạch kỹ thuật có 2 điểm khác tên gọi so với SRS gốc — cần cập nhật lại SRS để tránh mất điểm "tài liệu không khớp sản phẩm":

| SRS gốc ghi | Plan kỹ thuật thực tế dùng | Đề xuất |
|---|---|---|
| Z-score filter (anomaly detection) | Autoencoder (Reconstruction Error) | Giữ cả hai: Z-score làm lớp lọc nhanh (rule-based, chạy ngay trên Backend), Autoencoder làm lớp phát hiện sâu hơn (pattern-based). Ghi rõ trong SRS là **"Hybrid Z-score + Autoencoder"** |
| LSTM (predictive scheduling) | Bidirectional GRU + Self-Attention | Cập nhật SRS thành **"GRU-Attention time-series model"** (tên gọi kỹ thuật chính xác hơn, LSTM chỉ là category chung ban đầu) |

---

## 📅 Kế hoạch triển khai chi tiết qua 6 giai đoạn

### Giai đoạn 1: Thiết kế Hardware ở Biên & Firmware ESP32 (Tuần 1 - 2)

**Mục tiêu:** Đọc dữ liệu cảm biến chính xác, mịn nhiễu, điều khiển bơm an toàn bằng phần cứng, và báo cáo trạng thái thiết bị.

**Bước 1.1 — Thiết kế sơ đồ nguyên lý mạch (Schematic)**
- Đấu nối hai cảm biến I2C (**SHT31** và **BH1750**) chung đường bus SDA/SCL (địa chỉ riêng biệt: SHT31: `0x44`, BH1750: `0x23`).
- Đấu nối cảm biến độ ẩm đất điện dung vào cổng Analog (ví dụ: `GPIO34`).
- Đấu chân tín hiệu (xung Hall) của cảm biến lưu lượng nước **YF-S201** vào chân ngắt ngoài (Interrupt GPIO, ví dụ: `GPIO18`).
- Sử dụng module **Relay 5V Opto cách ly** điều khiển bơm, chế độ **Active Low**.

**Bước 1.2 — Lập trình Firmware (C++/PlatformIO)**
- **Lọc nhiễu cảm biến đất:** Cài `SimpleKalmanFilter`, chạy lọc trực tiếp trên ESP32 trước khi đóng gói dữ liệu.
- **Đo lưu lượng nước:** Viết hàm ISR đếm xung từ YF-S201, quy đổi `Q = F / 7.5` (Lít/Phút), cộng dồn tổng lượng nước tiêu thụ (V).
- **Hardware Watchdog:** Dùng `esp_task_wdt.h`, khởi tạo bộ đếm 5 giây, gọi `esp_task_wdt_reset()` trong mỗi chu kỳ `loop()`.
- **Kết nối MQTT:** Dùng `PubSubClient`, gửi JSON định kỳ mỗi 5 giây/lần tới Master Server.

**Bước 1.3 🆕 — Cơ chế Heartbeat & báo trạng thái online/offline**
- ESP32 publish một topic MQTT riêng `device/{id}/heartbeat` mỗi 10-15 giây (retain message + Last Will and Testament (LWT) của MQTT).
- Cấu hình **LWT** khi connect broker: nếu ESP32 mất kết nối đột ngột, EMQX tự động publish "offline" thay cho thiết bị — không cần chờ timeout thủ công.
- Backend subscribe topic này, cập nhật trạng thái thiết bị trong bảng `devices` (Postgres) và bắn realtime lên dashboard qua SignalR/WebSocket.

---

### Giai đoạn 2: Thiết lập hạ tầng Master Server (Ubuntu) (Tuần 3)

**Mục tiêu:** Dựng môi trường Docker ổn định chạy 24/7, quản lý CSDL, phân quyền, và cấu hình theo từng loại cây trồng.

**Bước 2.1 — Phân tách phân vùng SSD & Cài đặt Ubuntu (Dual Boot cho máy AI PC)**
- Shrink phân vùng ổ cứng Windows ra khoảng 60GB trống, cài Ubuntu LTS trên PC (Ryzen 5 + RX 6600).

**Bước 2.2 — Dựng Docker-Compose trên Master Server (Ryzen 3)**
- **EMQX Broker**: cổng `1883` (ESP32 đẩy dữ liệu), cổng `18083` (trang quản trị), bật LWT cho heartbeat.
- **TimescaleDB** (PostgreSQL extension): schema tối ưu cho dữ liệu chuỗi thời gian.

**Bước 2.3 — Thiết kế Database Schema chuẩn chỉ**
- Bảng phi thời gian: `Users` (Owner/Field Technician), `Pumps`, `Costs`, `Devices` (trạng thái online/offline).
- Bảng chuỗi thời gian (Hypertable): `sensor_data` (`time`, `device_id`, `soil_moisture`, `temperature`, `humidity`, `lux`, `water_flow`, `total_water`).
- Nén dữ liệu tự động (Compression Policy) cho dữ liệu cũ hơn 14 ngày.
- **🆕 Bảng `crop_profiles` (Crop Dictionary):** `crop_id`, `crop_name`, `soil_moisture_min/max`, `temp_min/max`, `light_min/max`, `default_watering_volume`. Đây là bảng còn thiếu ở bản kế hoạch gốc — cần có để đáp ứng use case "Configure threshold theo crop type".
- **🆕 Bảng `farm_zones` / `beds`:** `zone_id`, `zone_name`, `bed_id`, `crop_id` (FK), `position_x/y` (toạ độ để vẽ layout 2D/3D), `device_id` (FK tới ESP32 gán cho bed đó).

---

### Giai đoạn 3: Huấn luyện các mô hình AI trên máy GPU (Tuần 4 - 5)

**Mục tiêu:** Xây dựng các mô hình AI mạnh mẽ trên máy trạm GPU PC (RX 6600).

**Bước 3.1 — Train model chẩn đoán bệnh lá cây (CNN)**
- **Dataset:** PlantVillage (Kaggle) — lá khỏe & các loại bệnh đốm lá, nấm, trĩ...
- **Model:** EfficientNet-B3 (PyTorch), Transfer Learning.
- **XAI:** Module Grad-CAM tạo heatmap vùng bất thường trên lá.

**Bước 3.2 — Train model dự báo lịch tưới (Bidirectional GRU + Self-Attention)**
- **Feature Engineering:** chuỗi thời gian 7 ngày (cảm biến) + dự báo thời tiết (nhiệt độ, độ ẩm, khả năng mưa) từ OpenWeather API.
- **Model:** Bidirectional GRU + Self-Attention dự báo độ ẩm đất 24h tiếp theo.
- *(Tên gọi kỹ thuật thay cho "LSTM" ghi trong SRS gốc — xem bảng đồng bộ thuật ngữ ở trên.)*

**Bước 3.3 — Train model phát hiện bất thường cảm biến (Hybrid Z-score + Autoencoder)**
- **Lớp 1 (nhanh, rule-based):** Z-score filter chạy trực tiếp trên Backend — phát hiện outlier tức thời (VD: giá trị nhảy về 0 đột ngột), phản ứng ngay lập tức để bảo vệ bơm.
- **Lớp 2 (sâu, pattern-based):** Autoencoder (MLP/CNN 1D) huấn luyện trên dữ liệu bình thường, phát hiện các pattern bất thường tinh vi hơn mà Z-score đơn thuần bỏ sót (VD: cảm biến "kẹt" ở một giá trị hợp lý nhưng sai thực tế).

**Bước 3.4 🆕 — Rule "Adaptive Irrigation Delay" theo dự báo mưa**
- Đây là pain-point chính nêu trong phần Context của SRS nhưng chưa có bước triển khai cụ thể — bổ sung ngay tại Backend (không cần model riêng):
  - Gọi OpenWeather API lấy xác suất mưa (`pop` — probability of precipitation) trong 3-6h tới.
  - Rule đơn giản: nếu `pop > ngưỡng cấu hình (VD: 70%)` → hoãn lệnh tưới tự động, gửi thông báo "Đã hoãn tưới do dự báo mưa" lên app.
  - Kết hợp với output của GRU-Attention (Bước 3.2): nếu model dự báo độ ẩm đất vẫn đủ trong 24h tới VÀ xác suất mưa cao → ưu tiên hoãn tưới, tiết kiệm nước.

---

### Giai đoạn 4: Phát triển Backend API & Tích hợp AI (Tuần 6 - 7)

**Mục tiêu:** Viết API điều phối tác vụ, kết nối cơ sở dữ liệu, xử lý nghiệp vụ, và phủ đầy đủ các luồng xác thực/thông báo còn thiếu.

**Bước 4.1 — Viết API Gateway (FastAPI Python)**
- API quản lý người dùng với **RBAC** (JWT authentication).
- Thuật toán tính hóa đơn: tổng lượng nước tưới trong tháng × biểu giá nước + điện năng tiêu thụ bơm (thời gian bật × công suất định mức × biểu giá EVN).

**Bước 4.2 — Tích hợp hệ thống phân tán nội bộ (Task Delegation)**
- FastAPI trên Server Ryzen 3 định tuyến yêu cầu chẩn đoán bệnh:
  - Máy AI PC đang mở → chuyển ảnh sang PC chạy EfficientNet trên GPU RX 6600 (~15ms).
  - Máy AI PC tắt → fallback chạy EfficientNet-Lite trên CPU Server (~150ms), đảm bảo dịch vụ không gián đoạn.

**Bước 4.3 🆕 — Đăng ký/Đăng nhập đầy đủ (OAuth2 + Biometric)**
- **OAuth2:** Tích hợp `Authlib`/`FastAPI-Users` cho đăng ký qua Google/Facebook OAuth2, song song với đăng ký bằng số điện thoại/email (OTP qua SMS Gateway hoặc email service).
- **Biometric login (Fingerprint/FaceID):** Xử lý hoàn toàn phía client (Flutter/React Native dùng `local_auth` hoặc `expo-local-authentication`) — thiết bị xác thực sinh trắc học cục bộ, sau đó dùng secure token (refresh token lưu trong Keychain/Keystore) để gọi API mà không cần nhập lại mật khẩu. Backend chỉ cần cấp API refresh-token endpoint chuẩn.

**Bước 4.4 🆕 — Push Notification Service (FCM)**
- Tích hợp Firebase Admin SDK vào Backend.
- Trigger gửi push khi: thiết bị chuyển trạng thái offline (heartbeat mất), độ ẩm đất xuống dưới ngưỡng khẩn cấp, hoặc anomaly detection (Bước 3.3) phát hiện lỗi cảm biến.
- Thiết kế bảng `notifications` lưu lịch sử để hiển thị lại trong app.

**Bước 4.5 🆕 — API cho Offline Sync Mode**
- Thiết kế endpoint dạng **batch upsert** (`POST /sync/operations`) nhận một mảng các thao tác thủ công (bật/tắt bơm, ghi chú) mà mobile đã lưu local (SQLite/Hive) trong lúc mất mạng.
- Mỗi thao tác có `client_timestamp` + `idempotency_key` để Backend xử lý đúng thứ tự và tránh trùng lặp khi đồng bộ lại.
- Trả về kết quả từng item (thành công/lỗi/conflict) để mobile cập nhật lại local queue.

---

### Giai đoạn 5: Viết Frontend Dashboard (Web hoặc Mobile App) (Tuần 8 - 9)

**Mục tiêu:** Trực quan hóa dữ liệu sinh động, cung cấp tương tác thông minh, và phủ đầy đủ các use case còn thiếu ở client.

**Bước 5.1 — Màn hình Giám sát thời gian thực (Real-time Dashboard)**
- Flutter/React, kết nối WebSockets/MQTT-over-WebSockets tới Server Master, hiển thị biểu đồ nhiệt độ, độ ẩm, ánh sáng cập nhật theo giây.

**Bước 5.2 🆕 — 3D/Isometric Grid Layout của Greenhouse**
- Chọn phương án **Isometric 2.5D bằng CSS/SVG** (đủ đáp ứng yêu cầu SRS, chi phí công sức thấp, không cần học React Three Fiber):
  - Vẽ lưới ô (bed) theo toạ độ `position_x/y` từ bảng `farm_zones` (Bước 2.3), dùng `transform: rotateX() skew()` hoặc SVG phối cảnh.
  - Tô màu từng ô real-time theo dữ liệu độ ẩm/nhiệt độ (gradient xanh → đỏ).
  - *(Tuỳ chọn nâng cao nếu còn thời gian: dựng bằng `react-three-fiber` với OrbitControls để xoay/zoom tự do — nên tách thành task riêng, buffer thêm ~1 tuần.)*

**Bước 5.3 — Màn hình AI Chẩn đoán & Giải thích**
- Chụp ảnh lá cây từ camera điện thoại, hiển thị song song ảnh gốc và ảnh nhiệt Grad-CAM.

**Bước 5.4 🆕 — UI Điều khiển thủ công (Manual Override) & Đăng nhập sinh trắc học**
- Nút bật/tắt bơm thủ công cho từng bed, có xác nhận (confirm dialog) để tránh bấm nhầm ngoài đồng.
- Màn hình đăng nhập tích hợp `local_auth`/biometric prompt, fallback về mật khẩu nếu thiết bị không hỗ trợ.

**Bước 5.5 — Trang phân tích Tài chính & Vận hành**
- Biểu đồ cột chi phí điện/nước theo tuần, tháng.
- Lịch tưới dự báo 48h tới từ model GRU-Attention.

**Bước 5.6 🆕 — Offline Local Queue trên Mobile**
- Dùng SQLite (Flutter) hoặc WatermelonDB/Hive (React Native) lưu queue thao tác khi mất mạng.
- Background sync job tự động gọi API `/sync/operations` (Bước 4.5) khi có mạng trở lại, hiển thị badge "Đang đồng bộ N thao tác" trên UI.

---

### Giai đoạn 6: Kiểm thử độ an toàn (Chaos Engineering) & Viết báo cáo (Tuần 10)

**Mục tiêu:** Đảm bảo khả năng chịu lỗi tối đa và hoàn thiện slide báo cáo đồ án.

**Bước 6.1 — Kịch bản kiểm thử "Chống phá hệ thống"**
- **Kịch bản 1 (Mất mạng đột ngột):** Đang bật bơm, rút Wifi — kiểm tra sau 5 giây Watchdog ESP32 có tự ngắt bơm không.
- **Kịch bản 2 (Tuột cảm biến):** Rút cáp Analog cảm biến đất — kiểm tra Z-score/Autoencoder có phát hiện, bỏ qua điểm dữ liệu lỗi, và gửi cảnh báo đỏ (qua FCM) không.
- **🆕 Kịch bản 3 (Mất mạng phía mobile):** Bật chế độ máy bay trên điện thoại, thực hiện vài thao tác bật/tắt bơm — tắt airplane mode, kiểm tra Offline Sync (Bước 4.5/5.6) đồng bộ đúng thứ tự, không trùng lặp.
- **🆕 Kịch bản 4 (Dự báo mưa cao):** Giả lập response OpenWeather trả về `pop` cao — kiểm tra hệ thống có hoãn lệnh tưới tự động và bắn push notification giải thích lý do không.

**Bước 6.2 — Tổng hợp dữ liệu và hoàn thiện báo cáo**
- Ảnh kết quả Grad-CAM làm dẫn chứng trực quan trong báo cáo.
- Biểu đồ so sánh độ chính xác model đề xuất (EfficientNet-B3 + GRU-Attention) với model truyền thống (ResNet50, LSTM thuần).
- **🆕 Cập nhật lại phần SRS/Functional Requirement** để khớp đúng thuật ngữ kỹ thuật (xem bảng đồng bộ ở đầu file) và bổ sung các use case mới (OAuth2, Biometric, FCM, Offline Sync, 3D Grid, Adaptive Rain Delay) vào tài liệu chính thức trước khi nộp báo cáo.

---

## 📊 Kế hoạch hành động nhanh (Action Items) cho tuần này

1. **Về phần cứng:** Đặt mua ngay bộ cảm biến và phụ kiện (SHT31, BH1750, cảm biến đất điện dung, lưu lượng nước YF-S201, Relay Opto) — tổng chi phí khoảng ~440.000 ₫.
2. **Về phân vùng:** Shrink ổ cứng trên máy PC, tạo phân vùng trống 60GB để cài song song Ubuntu.
3. **🆕 Về tài liệu:** Cập nhật lại SRS/Functional Requirement với các use case và thuật ngữ kỹ thuật đã đồng bộ ở trên, tránh lệch giữa tài liệu nộp và sản phẩm demo.
