# Biên Bản Chuẩn Bị Họp Tuần 3: Danh Sách Câu Hỏi & Điểm Mơ Hồ Cần Thầy Cố Vấn Định Hướng

> **Dự án**: Hệ thống Đánh giá & Cá nhân hóa Lộ trình Học tập V-Eval (V-ACT ĐHQG-HCM)\
****Thời gian dự kiến**: Tuần 3 (Ngày 24/09/2026)\
****Người thực hiện**: Nhóm phát triển V-Eval\
****Tài liệu tham chiếu**: [Báo Cáo Kỹ Thuật Core Flow 1](./core_flow_1_chan_doan_nang_luc.md) | [Step-by-Step Logic](./core_flow_1_step_by_step_logic.md)

---

## 🎯 Mục Tiêu Buổi Họp Tuần 3

1. Báo cáo tiến độ hoàn thành liên thông **Core Flow 1 (Chẩn đoán năng lực, tính toán IRT/BKT, tự động xếp lớp)** qua 4 Microservices.
2. Xin ý kiến định hướng kiến trúc phân tách dịch vụ cho phân hệ AI Subsystem đa chức năng.
3. Thống nhất ma trận/phổ đề chuẩn hóa 30 câu thi đầu vào theo cấu trúc ĐGNL ĐHQG-HCM.
4. Làm rõ các "điểm mù" (blind spots) về mặt học thuật và nghiệp vụ để chuẩn bị hồ sơ bảo vệ đồ án tốt nghiệp vững chắc.

---

## ❓ NHÓM 1: CÂU HỎI TRỌNG TÂM CỦA BẠN (ĐÃ TỔNG HỢP & NÂNG CẤP HỌC THUẬT)

### 💬 Câu hỏi 1: Kiến trúc phân tách Microservices cho hệ thống AI đa chức năng

#### Bối cảnh của nhóm:

Hiện tại hệ thống AI của V-Eval có rất nhiều tính năng với đặc thù tính toán và thư viện công nghệ hoàn toàn khác nhau:

1. **Psychometrics Engine (Core Flow 1 & 3)**: Tính toán số học thuần túy (IRT 2PL, MAP Brent, BKT Sigmoid) bằng `NumPy`/`SciPy` – Yêu cầu CPU, cực nhẹ, độ trễ phản hồi siêu nhanh (&lt; 20ms).
2. **Socratic AI Tutor & RAG Chatbot (Core Flow 4)**: Xử lý ngôn ngữ tự nhiên, Vector Search (`pgvector`/`Qdrant`), LangChain và gọi API LLM (Gemini/OpenAI) qua Streaming SSE/gRPC – Phụ thuộc I/O mạng và token.
3. **Công cụ OCR / LaTeX Parser (Content Ingestion)**: Bóc tách đề thi từ PDF/Word, nhận diện công thức toán LaTeX (có thể dùng PyTorch, Nougat, Marker hoặc Multimodal LLM) – Yêu cầu RAM lớn và tính toán nặng.
4. **Mô hình Dự báo Điểm thi (Core Flow 6)**: Mô hình hồi quy/học máy dự đoán điểm số kỳ thi thật (huấn luyện offline bằng Python, sau đó xuất ra `ONNX` để nhúng vào .NET hoặc gọi API).

#### Câu hỏi trực tiếp hỏi Thầy:

> *"Thưa Thầy, đối với phân hệ AI có nhiều chức năng với đặc thù công nghệ khác nhau (RAG/LLM dùng LangChain, Tâm trắc học dùng SciPy, OCR dùng PyTorch/Model nặng, và Mô hình dự đoán ONNX):*\
 **1. Nhóm nên đóng gói **tất cả chung vào 1 Service AI duy nhất** (Modular Monolith) hay nên **tách thành 2-3 Microservices chuyên biệt** (ví dụ:* `AI-Math-Engine` *riêng biệt với* `AI-RAG-Tutor`*)?*\
 **2. Tiêu chí nào về mặt tài nguyên phần cứng (RAM/CPU/Docker container size) và bảo trì mà Hội đồng phản biện đánh giá cao hơn đối với quy mô đồ án tốt nghiệp?"*

#### Gợi ý phương án sẵn sàng trao đổi với Thầy:

- **Phương án A (Tách chuyên biệt - Khuyên dùng về kiến trúc)**:
  - `ai-psychometrics-service` (FastAPI + SciPy): Cực kỳ nhẹ (\~150MB RAM), không phụ thuộc GPU, phản hồi tức thời cho các luồng thi trắc nghiệm.
  - `ai-rag-service` (FastAPI + LangChain + Vector DB): Chuyên xử lý Chatbot Socratic, phân tách rủi ro nghẽn I/O khi người dùng chat đồng thời.
  - `ONNX Inference`: Nhúng trực tiếp thư viện `Microsoft.ML.OnnxRuntime` vào backend C# .NET để chạy mô hình dự đoán mà không cần dựng thêm service Python trung gian.
- **Phương án B (Gộp 1 service AI lớn)**:
  - Dễ quản lý deploy trong 1 Docker compose, nhưng file image nặng (hàng GB), nếu chức năng OCR bị tràn bộ nhớ thì toàn bộ luồng chấm điểm thi chẩn đoán cũng bị ảnh hưởng.

---

### 💬 Câu hỏi 2: Ma trận & Phổ đề thi 30 câu chẩn đoán năng lực chuẩn ĐHQG-HCM

#### Bối cảnh của nhóm:

Đề thi Đánh giá năng lực ĐHQG-HCM chuẩn gồm **120 câu hỏi** (thời gian làm bài 150 phút, thang điểm 1200). Đề chẩn đoán đầu vào của V-Eval rút gọn xuống **30 câu** (thời gian 35-40 phút) để học sinh kiểm tra nhanh trình độ mà không gây nản chí.

#### Câu hỏi trực tiếp hỏi Thầy:

> *"Thưa Thầy, cấu trúc đề thi ĐGNL ĐHQG-HCM có 120 câu chia thành 3 phần lớn. Khi nhóm rút gọn thành đề chẩn đoán nhanh 30 câu đầu vào:*\
 **1. Tỷ lệ phân bổ 30 câu theo các phần thi nên chia thế nào để bảo đảm tính đại diện năng lực chuẩn xác nhất?*\
 **2. Với các câu hỏi phần Giải quyết vấn đề (Khoa học tự nhiên & Khoa học xã hội), nhóm nên chọn các câu tổng hợp bao quát hay học sinh được chọn tổ hợp môn thế mạnh của mình?*\
 **3. Phổ độ khó của 30 câu này có nên trải đều theo 4 mức độ nhận thức (Nhận biết, Thông hiểu, Vận dụng, Vận dụng cao) theo tỷ lệ nào?"*

#### Bảng ma trận đề thi 30 câu đề xuất để xin Thầy duyệt:

| Phần thi chuẩn ĐHQG-HCM | Số câu chuẩn (120 câu) | Đề xuất rút gọn (30 câu) | Kỹ năng đại diện kiểm tra | Tỷ lệ đề xuất |
| --- | --- | --- | --- | --- |
| **Phần 1: Sử dụng ngôn ngữ** | **40 câu** | **10 câu** | 5 câu Tiếng Việt (chính tả, ngữ pháp, đọc hiểu) + 5 câu Tiếng Anh (từ vựng, đọc hiểu logic). | **33.3%** |
| **Phần 2: Toán học, Logic & Phân tích số liệu** | **30 câu** | **10 câu** | 4 câu Toán phổ thông + 3 câu Suy luận Logic + 3 câu Đọc biểu đồ/Phân tích số liệu. | **33.3%** |
| **Phần 3: Giải quyết vấn đề (Khoa học)** | **50 câu** | **10 câu** | 5 câu Khoa học tự nhiên (Lý, Hóa, Sinh) + 5 câu Khoa học xã hội (Sử, Địa, Đọc dữ liệu thực tế). | **33.3%** |

- **Phân bổ theo mức độ nhận thức Bloom**:
  - Mức 1 (Nhận biết): 6 câu (20%) — `b \approx -1.2`
  - Mức 2 (Thông hiểu): 12 câu (40%) — `b \approx -0.2`
  - Mức 3 (Vận dụng): 8 câu (27%) — `b \approx 0.8`
  - Mức 4 (Vận dụng cao): 4 câu (13%) — `b \approx 1.6`

---

## 💡 NHÓM 2: CÁC "ĐIỂM MÙ" NGHIỆP VỤ & HỌC THUẬT QUAN TRỌNG NÊN HỎI THẦY

Dưới đây là những câu hỏi mang tính chất "chuyên gia" giúp nhóm ghi điểm rất lớn trước Thầy hướng dẫn và giải quyết triệt để các góc khuất khi làm đồ án:

---

### ❓ Điểm mù 1: Vấn đề hiệu chuẩn tham số câu hỏi IRT (Item Calibration Cold-Start)

- **Vấn đề thực tế**:

  - Mô hình IRT chuẩn quốc tế đòi hỏi mỗi câu hỏi phải có tham số độ khó `b` và độ phân biệt `a` được hiệu chuẩn từ hàng ngàn lượt làm bài thật của học sinh trước đó (thông qua thuật toán Marginal Maximum Likelihood / EM).
  - Hiện tại, nhóm đang gán cố định tham số `b` dựa trên mức độ chuyên gia biên soạn (1 đến 4) và `a = 1.2`.

- **Câu hỏi hỏi Thầy**:

  > *"Thưa Thầy, trong giai đoạn đầu dự án khi chưa có tập dữ liệu kiểm thử thực nghiệm lớn từ học sinh để chạy hiệu chuẩn tham số câu hỏi (Item Calibration):*\
   **Nhóm gán giá trị* `b` *ánh xạ từ mức độ khó 1-4 của giáo viên và* `a` *mặc định như hiện tại có được Hội đồng nghiệm thu chấp nhận không? Nhóm có cần xây dựng thêm một background job tự động cập nhật lại tham số* `a, b` *của câu hỏi sau mỗi 100 lượt học sinh làm bài không ạ?"*

---

### ❓ Điểm mù 2: Quy tắc làm lại bài thi chẩn đoán (Diagnostic Retake Policy)

- **Vấn đề thực tế**:

  - Sau một thời gian học tập, nếu học sinh muốn làm lại bài chẩn đoán thì hệ thống xử lý ra sao?
  - Có được phép thi lại không? Nếu thi lại thì điểm số mới có ghi đè giá trị `P(L_0)` và lớp học hiện tại (`ClassEnrollment`) tại Campus không?

- **Câu hỏi hỏi Thầy**:

  > *"Thưa Thầy, về mặt sư phạm của cơ sở luyện thi:*\
   **Học sinh có được làm lại bài chẩn đoán năng lực không, hay bài kiểm tra này chỉ được làm DUY NHẤT một lần đầu khi tạo tài khoản? Nếu làm lại, hệ thống nên cập nhật đè hay tạo một version hồ sơ năng lực mới (Snapshot/History) để so sánh sự tiến bộ?"*

---

### ❓ Điểm mù 3: Cơ chế xếp lớp tại cơ sở (Fixed Thresholds vs Dynamic Percentile)

- **Vấn đề thực tế**:

  - Hiện tại nhóm đang chia lớp cứng theo ngưỡng cố định: `\theta_0 < -0.5` ( Foundation), `[-0.5, 0.5]` (Acceleration), `> 0.5` (Breakthrough).
  - Giả sử tại một Campus nhỏ, nếu 90% học sinh thi xong đều rơi vào nhóm Acceleration thì lớp đó sẽ bị quá tải, còn lớp khác không có người học.

- **Câu hỏi hỏi Thầy**:

  > *"Thưa Thầy, việc xếp lớp vào 3 phân khúc (Foundation / Acceleration / Breakthrough) tại cơ sở đào tạo nên dựa trên **ngưỡng điểm số cố định** hay nên dựa trên **hạn ngạch/sĩ số tối đa của từng lớp** (ví dụ mỗi lớp tối đa 30 học sinh, nếu đầy thì tự động mở lớp mới hoặc đẩy sang lớp cận kề)?"*

---

### ❓ Điểm mù 4: Chỉ số đánh giá và nghiệm thu mô hình AI (Evaluation Metrics)

- **Vấn đề thực tế**:

  - Khi ra Hội đồng chấm Capstone, giảng viên phản biện chắc chắn sẽ hỏi: *"Mô hình AI Psychometrics của nhóm tốt ở chỗ nào? Độ chính xác bao nhiêu %? So sánh với phương pháp truyền thống thế nào?"*

- **Câu hỏi hỏi Thầy**:

  > *"Thưa Thầy, để phục vụ cho báo cáo nghiệm thu đồ án tốt nghiệp, nhóm nên thu thập chỉ số đánh giá (Evaluation Metric) nào cho phần AI:*\
   **- So sánh độ lệch chuẩn đo lường (Standard Error of Measurement - SEM) giữa IRT 2PL với phương pháp tính điểm trung bình cổ điển (CTT)?*\
   **- Hay đo lường độ chính xác dự đoán đúng/sai ở các câu hỏi tiếp theo (Prediction Accuracy / AUC)?"*

---

### ❓ Điểm mù 5: Giải pháp tối ưu chi phí & Quản lý Token LLM (Gemini / OpenAI API)

- **Vấn đề thực tế**:

  - Nếu có 100 học sinh cùng nộp bài chẩn đoán cùng lúc, việc gọi LLM liên tục sẽ dễ dính lỗi nghẽn Rate Limit (RPM / TPM) và tiêu tốn chi phí API.

- **Câu hỏi hỏi Thầy**:

  > *"Thưa Thầy, đối với lời nhận xét sư phạm ở bài chẩn đoán, nhóm đang kết hợp song song giữa Prompt Socratic qua Gemini và Rule-based Templates dự phòng. Nhóm có nên áp dụng cơ chế Caching kết quả nhận xét theo cụm nhóm điểm để tiết kiệm chi phí gọi LLM không ạ?"*

---

## 📝 BẢNG CHECKLIST CHUẨN BỊ CHO BUỔI HỌP

- [ ] **Demo trực tiếp**: Mở sẵn terminal chạy `./Scripts/run_local/run_core_flow1_services.bat` và file kiểm thử `./Scripts/test_core_flow1.ps1`.

- [ ] **Trình chiếu sơ đồ tuần tự**: Mở file `docs/core_flow_1_step_by_step_logic.md` để thuyết minh cách 4 service liên thông.

- [ ] **Mở tài liệu công thức toán**: Mở `docs/ai_architecture/cong_thuc_psychometrics_irt_bkt.md` nếu Thầy hỏi sâu về thuật toán MAP Brent hay kẹp Sigmoid.

- [ ] **Ghi chú phản hồi**: Chuẩn bị sẵn sổ tay hoặc file ghi chú để lưu lại toàn bộ chỉ dẫn của Thầy sau buổi họp.