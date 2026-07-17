# 🚀 AGROSMART — TÀI LIỆU ĐẶC TẢ KIẾN TRÚC & KẾ HOẠCH TRIỂN KHAI CHI TIẾT (BẢN ĐẦY ĐỦ NÂNG CAO)
> **Tài liệu đặc tả toàn diện từ phần cứng, hạ tầng mạng, cơ sở dữ liệu động đến thuật toán AI lai và giao diện đồ họa không gian xấp xỉ.**

---

## 🛠️ PHẦN 1: TỔNG QUAN KIẾN TRÚC HỆ THỐNG PHÂN TÁN (SYSTEM ARCHITECTURE)

Hệ thống được thiết kế theo mô hình **Distributed Event-Driven Hybrid IoT-AI** (Kiến trúc hướng sự kiện lai phân tán) để đảm bảo dữ liệu truyền nhận hai chiều tức thời đạt độ trễ dưới $50\text{ms}$, triệt tiêu hoàn toàn cơ chế Polling (hỏi - đáp định kỳ) gây lãng phí tài nguyên.

### 1. Sơ đồ hạ tầng kết nối 2 nhánh chuyên biệt

```
┌───────────────────────┐             ┌─────────────────────────┐             ┌───────────────────────┐
│     EDGE HARDWARE     │ ◄──(MQTT)──►│   MQTT BROKER (EMQX)    │ ◄──(MQTT)──►│     BACKEND API       │
│  (ESP32 tại nhà kính)  │             │   (Dựng trên Docker)    │             │   (.NET hoặc FastAPI) │
└───────────────────────┘             └─────────────────────────┘             └───────────────────────┘
                                                                                          ▲
                                                                                          │ (WebSockets /
                                                                                          │  SignalR)
                                                                                          ▼
                                                                                ┌───────────────────────┐
                                                                                │      CLIENT APP       │
                                                                                │  (Flutter Mobile/Web) │
                                                                                └───────────────────────┘
```

* **Nhánh 1: Thiết bị biên (ESP32 ↔ Server) qua MQTT:** ESP32 duy trì duy nhất một kết nối TCP siêu nhẹ tới EMQX Broker. Dữ liệu cảm biến đóng gói thành JSON và `Publish` lên topic `greenhouse/sensor`. Lệnh điều khiển từ server được đẩy thẳng xuống ESP32 thông qua topic `greenhouse/pump/control` mà nó đã `Subscribe`.
* **Nhánh 2: Ứng dụng (Server ↔ App) qua WebSockets / SignalR:** App di động kết nối trực tiếp với Backend API để đảm bảo bảo mật kết nối. Khi có dữ liệu mới từ Broker, Backend đẩy ngay qua kết nối WebSockets mở sẵn xuống màn hình App để cập nhật UI theo thời gian thực.

### 2. Phân rã tải trọng phần cứng (Hardware Node Allocation)

* **Edge Hardware (ESP32 NodeMCU):** Đọc raw data từ cảm biến (SHT31, BH1750, độ ẩm đất, YF-S201). Chạy bộ lọc Kalman 1D để làm mịn nhiễu và chạy mô hình TinyML cực nhẹ để tự động ngắt bơm khẩn cấp khi phát hiện chập mạch/tuột cảm biến.
* **Master Node (Server Ubuntu - Ryzen 3 3250U):** Làm trạm trung chuyển trung tâm, chạy Docker gồm: EMQX Broker (giữ kết nối MQTT liên tục), TimescaleDB (ghi dữ liệu chuỗi thời gian liên tục không phình RAM), và Backend API (.NET/FastAPI) duy trì kết nối WebSockets với Client. Node này xử lý I/O mạng là chính, không tính toán AI nặng để tránh sập hệ thống.
* **AI Worker Node (PC Trạm - Ryzen 5 + GPU AMD RX 6600):** Gánh toàn bộ tác vụ nặng tính bằng TFLOPS. Nhận ảnh lá cây từ Master Node qua gRPC/HTTP để chạy mô hình `EfficientNet-B3` và sinh ảnh nhiệt `Grad-CAM`. Chạy mô hình `GRU-Attention` để dự báo lịch tưới 24h tiếp theo. Tốc độ inference chỉ mất ~15-30ms.

---

## 💡 PHẦN 2: CƠ CHẾ NỘI SUY KHÔNG GIAN BÙ TRỪ SAI SỐ THỰC TẾ

Hệ thống được **cô đặc bối cảnh vào mô hình Nhà kính khép kín (Greenhouse)** nhằm triệt tiêu các tác nhân gây nhiễu tự nhiên (gió, mưa, bức xạ mặt trời trực tiếp). Dữ liệu bản đồ nhiệt được tính toán thông qua **Thuật toán nội suy hình học phẳng IDW (Inverse Distance Weighting)** kết hợp **Tham số vật lý**.

### 1. Thuật toán hình học phẳng IDW

Backend tính toán giá trị độ ẩm ước tính $Z$ tại một ô đất bất kỳ tọa độ $(x, y)$ dựa vào khoảng cách đến $n$ cảm biến thực tế:

$$Z(x,y) = \frac{\sum_{i=1}^{n} \frac{Z_i}{d_i^2}}{\sum_{i=1}^{n} \frac{1}{d_i^2}}$$

Trong đó, $d_i$ là khoảng cách Euclid phẳng: $d_i = \sqrt{(x - x_i)^2 + (y - y_i)^2}$.

### 2. Các tham số vật lý bù trừ sai số thực tế

* **Tích hợp Trạng thái Bơm (Actuator State):** Nếu ô đất đang được tưới bởi vòi phun phụ trách, giá trị nội suy cộng thêm trọng số tích lũy: $Z_{\text{nội suy}} = Z_{\text{IDW}} + W_{\text{water}} \times t_{\text{tưới}}$.
* **Ranh giới phân khu vật lý (Obstacles):** Nếu đoạn thẳng nối từ ô đất đến cảm biến bị cắt ngang bởi ô vật cản (lối đi bê tông, vách ngăn), khoảng cách hiệu dụng $d$ gán bằng $\infty$ để ngắt hoàn toàn sức ảnh hưởng của cảm biến phân khu khác.
* **Sai số cắm cảm biến lệch (10-30cm):** Khoảng cách thực tế tính toán bằng mét (1m-5m). Độ lệch 0.1m-0.3m khi đưa vào công thức bình phương khoảng cách chỉ gây ra độ lệch kết quả < 2%, hoàn toàn an toàn và nằm trong phạm vi sai số nông nghiệp chấp nhận được.

---

## 🎨 PHẦN 3: BẢN THIẾT KẾ UI CẤU HÌNH ĐỘNG 2D & BIỂU DIỄN 2.5D ISOMETRIC

Hệ thống loại bỏ hoàn toàn việc hardcode sơ đồ nhà kính. Tách biệt rõ ràng: **Backend lo tính toán thực tế trên mặt phẳng — Frontend lo biểu diễn thẩm mỹ 2.5D.**

### 1. Trình cấu hình sơ đồ phẳng 2D (Admin Grid Setup UI)

Frontend biểu diễn nhà kính dưới dạng một ma trận 2 chiều số nguyên (**2D Matrix Array**) trên một hệ lưới ô vuông phẳng. Người dùng có thể chỉnh slider tăng giảm tỷ lệ scale (độ phân giải lưới, ví dụ lưới 20×20, ô lưới 1 ô = 0.5m) để khớp với hình dạng đất phức tạp, méo xéo ngoài thực tế.

**Mã hóa 4 trạng thái ô lưới:**

* `0`: Empty / Path (Lối đi, hành lang kỹ thuật - Màu xám nhạt).
* `1`: Active Bed (Luống đất trồng trọt cần tính toán nội suy - Màu xanh lá).
* `2`: Obstacle / Wall (Ô vách ngăn phân khu, khối bê tông cách ẩm - Màu đen).
* `3`: Sensor Node (Vị trí cắm đầu cảm biến thực tế - Hiển thị Icon cảm biến).

*Tương tác:* Bắt sự kiện `onMouseDown` và `onMouseEnter` (Web) hoặc `onPanUpdate` (Flutter) để quét cọ vẽ luống đất nhanh chóng. Bấm "Lưu" để xuất chuỗi JSON Metadata cấu hình gửi lên Backend.

### 2. Trình biểu diễn giao diện vận hành 2.5D Isometric (Client Presentation Layer)

Frontend nhận mảng JSON sạch từ Backend, tự động bẻ nghiêng ma trận phẳng sang phối cảnh 2.5D bằng đồ họa **Dynamic SVG (Scalable Vector Graphics)**.

**Ma trận chuyển đổi tọa độ phẳng sang Isometric:**

$$isoX = (x - y) \times \frac{\text{width}}{2}$$

$$isoY = (x + y) \times \frac{\text{height}}{2}$$

* **Thuật toán khử che khuất (Z-Ordering / Occlusion):** Mảng dữ liệu được Frontend sắp xếp (`Sort`) theo chiều sâu tăng dần của tổng giá trị tọa độ $(x + y)$ trước khi render. Ô nào xa hơn (tổng x+y nhỏ) sẽ được vẽ trước, ô gần hơn vẽ đè lên sau để tránh lỗi vật thể đè khuất nhau phi lý.
* **Color Mapping:** Đổ màu động (`fill`) cho các thẻ `<polygon>` hình thoi SVG theo dải màu HSL chạy từ Đỏ (0%, khô hạn) sang Xanh dương (100%, đủ nước) thời gian thực.

### 3. Mã nguồn SVG Isometric Mẫu (Dành cho Frontend hiện thực hóa)

```html
<svg width="500" height="300" style="background-color: #f0f0f0;">
  <defs>
    <radialGradient id="wetSoil" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#3498db" /> <!-- Tâm luống tưới màu xanh dương -->
      <stop offset="100%" stop-color="#2ecc71" /> <!-- Rìa ngoài màu xanh lá -->
    </radialGradient>
  </defs>

  <!-- Luống đất 1 (Tương ứng ô 0,0 phẳng) - Đang đủ nước -->
  <polygon points="250,50 350,100 250,150 150,100" fill="url(#wetSoil)" stroke="#27ae60" stroke-width="2" />
  <text x="235" y="105" fill="white" font-weight="bold">Luống 1 (80%)</text>

  <!-- Luống đất 2 (Tương ứng ô 1,0 phẳng) - Nằm kế bên hạ về phía dưới phải - Bị khô hạn -->
  <polygon points="350,100 450,150 350,200 250,150" fill="#e74c3c" stroke="#c0392b" stroke-width="2" />
  <text x="335" y="155" fill="white" font-weight="bold">Luống 2 (20%)</text>
</svg>
```

---

## 💾 PHẦN 4: THIẾT KẾ CƠ SỞ DỮ LIỆU ĐỘNG (DATABASE SCHEMA)

Toàn bộ sơ đồ số hóa (Digital Twin) được lưu trữ dưới dạng cấu hình thưa (Metadata) trong database để hệ thống tự động tải động khi khởi chạy.

```sql
-- 1. Bảng lưu trữ phân khu / nhà kính
CREATE TABLE farm_zones (
    zone_id SERIAL PRIMARY KEY,
    zone_name VARCHAR(100),
    grid_width INT,   -- Độ phân giải lưới ngang (Ví dụ: 20)
    grid_height INT   -- Độ phân giải lưới dọc (Ví dụ: 20)
);

-- 2. Bảng lưu cấu hình luống đất động (Bao gồm tham số vật lý cao độ)
CREATE TABLE crop_beds (
    bed_id SERIAL PRIMARY KEY,
    zone_id INT REFERENCES farm_zones(zone_id),
    pos_x INT,        -- Tọa độ X phẳng trên lưới
    pos_y INT,        -- Tọa độ Y phẳng trên lưới
    status_value INT, -- Trạng thái ô đất (1: Active Bed, 2: Obstacle)
    elevation FLOAT DEFAULT 1.0, -- Tham số cao độ vật lý phục vụ bù trừ IDW
    pump_id INT       -- Liên kết ID vòi tưới phụ trách khu vực này
);

-- 3. Bảng cấu hình ánh xạ cảm biến phần cứng ra thực địa
CREATE TABLE sensor_metadata (
    sensor_id VARCHAR(50) PRIMARY KEY, -- Mã Hardware ID cứng của ESP32 (Ví dụ: MAC Address)
    zone_id INT REFERENCES farm_zones(zone_id),
    pos_x INT,        -- Tọa độ X phẳng thực tế cắm trên vườn
    pos_y INT,        -- Tọa độ Y phẳng thực tế cắm trên vườn
    calibration_offset FLOAT DEFAULT 0.0 -- Hệ số hiệu chuẩn sai số nén đất cục bộ (+/- %)
);
```

---

## 🧠 PHẦN 5: ĐẶC TẢ TÍNH NĂNG CHẨN ĐOÁN BỆNH LÁ CÂY VÀ TRÍ TUỆ NHÂN TẠO GIẢI THÍCH ĐƯỢC (XAI)

Luồng chẩn đoán bệnh lá cây được thiết kế nâng cao nhằm giải quyết bài toán hiệu năng mạng và tính minh bạch của AI:

1. **Nén ảnh tại biên (Client-side Compression):** Ứng dụng di động (Flutter) tự động nén ảnh chụp gốc từ camera (hạ dung lượng từ 3-10MB xuống còn ~100KB, giữ độ phân giải khoảng 512×512 pixel) trước khi tải lên, giúp tiết kiệm băng thông mạng 4G ngoài thực địa và tăng tốc độ truyền nhận.

2. **Ủy quyền tác vụ (Task Delegation) & Hệ thống chịu lỗi (Fallback):** Master Server (Ryzen 3) nhận ảnh bất đồng bộ, lập tức ủy quyền tính toán sang máy AI PC (GPU RX 6600) qua gRPC để thực hiện inference mô hình `EfficientNet-B3` nhằm tránh làm nghẽn luồng chính. Nếu máy trạm GPU ngoại tuyến, Master Node tự động kích hoạt cơ chế Fallback, chạy bản mô hình tối ưu `EfficientNet-Lite` trực tiếp trên CPU Server thông qua ONNX Runtime.

3. **Mô hình AI có thể giải thích (Explainable AI - Grad-CAM):** Sau khi phân loại bệnh lá, hệ thống sử dụng thuật toán **Grad-CAM (Gradient-weighted Class Activation Mapping)** để bóc tách các lớp gradient từ convolutional layer cuối cùng, sinh ra một **Bản đồ nhiệt (Heatmap) vùng tổn thương** đè lên ảnh gốc. Vùng pixel quyết định bệnh sẽ đỏ rực, giúp chứng minh rõ ràng cơ sở khoa học của quyết định chẩn đoán trước hội đồng chấm thi.

---

## 📦 PHẦN 6: DANH MỤC THƯ VIỆN & NGUỒN THAM KHẢO CHÍNH XÁC

Để đảm bảo tính khả thi cao nhất trong thời gian thực nghiệm 3 tuần, dự án ứng dụng các thư viện chuẩn open-source sau:

### 1. Phía Thiết bị biên & Firmware (ESP32)

* **SimpleKalmanFilter (Tác giả: Denys Sene):** Bộ lọc Kalman 1D chạy trực tiếp trên chip nhúng để làm mịn tín hiệu cảm biến đất.
  * *Nguồn:* `github.com/denyssene/SimpleKalmanFilter`
* **m2cgen (Model to Code Generator):** Thư viện Python giúp dịch mô hình học máy phân loại outlier thành mã nguồn C++ if-else thuần túy để nhúng vào ESP32, đảm bảo TinyML chạy cực nhẹ dưới 1ms không rủi ro treo chip.
  * *Nguồn:* `github.com/BayesWitnesses/m2cgen`

### 2. Phía Backend & Hạ tầng Broker

* **EMQX Broker (Docker Image):** Hạ tầng MQTT Broker công nghiệp chịu tải, dùng để duy trì kết nối bền bỉ với thiết bị và quản lý trạng thái thiết bị thời gian thực.
  * *Nguồn:* `github.com/emqx/emqx`

### 3. Phía Frontend & Đồ họa 2.5D Isometric

* **SVG Isometric Grid Template:** Mẫu tổ chức thẻ `<svg>` và ma trận đa giác `<polygon>` phối cảnh để render lưới 2.5D.
  * *Nguồn mẫu thiết kế sẵn tham khảo:* Tra cứu các boilerplate trên Codepen.io với từ khóa cấu trúc "SVG Isometric Grid".
* **Obelisk.js:** Thư viện JavaScript mã nguồn mở chuyên dụng để hỗ trợ dựng Isometric pixel siêu nhẹ nếu cần mở rộng tính năng đồ họa trên Web.
  * *Nguồn:* `github.com/nosir/obelisk.js`

---

## 📅 PHẦN 7: KẾ HOẠCH HÀNH ĐỘNG THỰC NGHIỆM CUỐN CHIẾU (3 TUẦN)

* **Tuần 1 (Kiểm thử cấu hình & DB):** Tập trung dựng UI lưới phẳng 2D, test luồng: Click vẽ sơ đồ → Xuất JSON → Lưu DB Schema → Đọc ngược từ DB vẽ lại sơ đồ phẳng. Đạt chuẩn mới qua tuần sau.

* **Tuần 2 (Kiểm thử toán học nội suy):** Nạp dữ liệu cảm biến giả lập vào DB. Cho Backend chạy thuật toán IDW có kết hợp tham số vật lý (vách ngăn, trạng thái bơm). Thực hiện kiểm thử biên nghiêm ngặt để bắt lỗi chia cho 0 (nếu ô đất trùng khít tọa độ cảm biến, `if (d == 0) return sensor.moisture;`) và tối ưu hóa thời gian xử lý của hàm.

* **Tuần 3 (Kiểm thử đồ họa & Tích hợp):** Viết hàm nhân ma trận bẻ xéo tọa độ từ phẳng sang 2.5D trên SVG. Mở kết nối WebSockets để kiểm tra dải màu nhiệt hình thoi tự động loang mờ real-time khi data thay đổi, đồng thời kết nối luồng ảnh nén từ điện thoại gửi về để xuất ảnh nhiệt Grad-CAM.

---

## 🏛️ PHẦN 8: KỊCH BẢN PHẢN BIỆN TRƯỚC HỘI ĐỒNG (BÍ QUYẾT LẤY ĐIỂM XUẤT SẮC)

Khi hội đồng đưa ra các câu hỏi hóc búa để thử thách tư duy hệ thống của bạn, hãy sử dụng chính xác các câu trả lời thực chiến dưới đây:

### 1. Phản biện về tính linh hoạt của sơ đồ nhà kính

**Câu hỏi hội đồng:** *"Nếu chủ vườn thay đổi thiết kế nhà kính, dịch chuyển một luống rau hay cắm lại con cảm biến, hệ thống của em có phải viết lại code không?"*

**Trả lời thuyết phục:** "Dạ thưa thầy/cô, hệ thống của em được thiết kế theo tư duy sản phẩm thương mại hoàn chỉnh. Em không hề hardcode sơ đồ nhà kính. Em cung cấp một Giao diện cấu hình động (Dynamic Setup UI) dựa trên ma trận ô lưới phẳng 2D. Người dùng có thể tự vẽ lại sơ đồ, định vị lại vị trí cắm cảm biến và luống đất ngay trên màn hình. Toàn bộ sơ đồ này được lưu trữ dưới dạng Metadata trong Database. Khi thuật toán nội suy chạy trên Backend hoặc khi Client render Isometric 2.5D, hệ thống sẽ đọc động dữ liệu Metadata này để xử lý. Nhờ đó, phần mềm có thể tương thích 100% với bất kỳ nhà kính thực tế nào mà không cần phải can thiệp hay sửa đổi một dòng code nào."

### 2. Phản biện về sai số thuật toán nội suy khi diện tích lớn (Scale-up)

**Câu hỏi hội đồng:** *"Thuật toán nội suy không gian thông thường sẽ có sai số rất lớn khi scale diện tích rộng, làm sao hệ thống của em đảm bảo độ tin cậy?"*

**Trả lời thuyết phục:** "Dạ thưa thầy/cô, thuật toán nội suy không gian thông thường đúng là sẽ có sai số lớn ngoài thực địa tự nhiên do các yếu tố ngẫu nhiên như gió, mưa, nắng gắt. Vì vậy, để kiểm soát sai số ở mức thấp nhất, đề tài của em đã giới hạn và cô đặc bối cảnh ứng dụng vào mô hình Nhà kính khép kín (Greenhouse). Tại đây, các tác nhân ngẫu nhiên từ môi trường hở đã được triệt tiêu. Đồng thời, thuật toán nội suy trên Backend của em không chỉ tính theo khoảng cách hình học đơn thuần, mà đã được tích hợp các tham số vật lý thực tế bao gồm: Trạng thái đóng/mở và thời gian phun tích lũy của từng vòi tưới cụ thể tại luống, kết hợp với Ranh giới vách ngăn phân khu vật lý. Hơn nữa, sự chênh lệch độ ẩm đất giữa vị trí cảm biến lệch 10-30cm là cực kỳ nhỏ trong môi trường kín và chỉ lệch kết quả IDW dưới 2%. Do đó hệ thống hoàn toàn đủ độ tin cậy thực tế để vận hành tự động."

### 3. Phản biện về tính "Hộp đen" (Black box) của mô hình AI nhận diện bệnh lá

**Câu hỏi hội đồng:** *"Làm sao em chứng minh được mô hình AI nhận diện đúng vết bệnh của chiếc lá chứ không học vẹt phông nền hay bàn tay phía sau?"*

**Trả lời thuyết phục:** "Dạ thưa thầy/cô, mô hình AI chẩn đoán bệnh lá của em không phải là một chiếc hộp đen bí ẩn. Em đã tích hợp công nghệ Giải thích mô hình học máy (Explainable AI) bằng thuật toán Grad-CAM. Thuật toán này bóc tách các lớp gradient ở tầng convolutional layer cuối cùng để tính toán xem những vùng pixel nào trên chiếc lá đóng góp điểm số cao nhất vào quyết định phân loại. Từ đó, hệ thống tự động sinh ra một bản đồ nhiệt (Heatmap) đè lên ảnh gốc để hiển thị trực tiếp lên App. Nhìn vào ảnh nhiệt này, cả người vận hành và hội đồng đều có thể thấy rõ ràng AI đang tập trung vào đúng các vết đốm nấm hay đốm sâu (vùng đỏ rực) chứ không hề bị nhiễu bởi phông nền phía sau. Điều này chứng minh tính minh bạch và độ chính xác khoa học của mô hình."
