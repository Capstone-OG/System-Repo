# THUẬT TOÁN ĐO LƯỜNG NĂNG LỰC IRT 2PL (ITEM RESPONSE THEORY 2-PARAMETER LOGISTIC)

> **Tài liệu lý thuyết & Bản chất toán học chuyên sâu dành cho Dự án V-Eval**  
> **Áp dụng:** Core Flow 1 – Đánh giá năng lực chẩn đoán đầu vào (Diagnostic Assessment)  
> **Module thực thi:** AI Engine (`rag-service/diagnostic_engine.py`) kết hợp Practice Service

---

## 📑 MỤC LỤC
1. [Khái Niệm Nền Tảng: Tại Sao IRT Thay Thế Hoàn Toàn Lý Thuyết Cổ Điển CTT?](#1-khái-niệm-nền-tảng-tại-sao-irt-thay-thế-hoàn-toàn-lý-thuyết-cổ-điển-ctt)
2. [Họ Mô Hình IRT Logistic (1PL, 2PL, 3PL Là Gì?)](#2-họ-mô-hình-irt-logistic-1pl-2pl-3pl-là-gì)
3. [Công Thức Toán Học Chi Tiết Của IRT 2PL Trong V-Eval](#3-công-thức-toán-học-chi-tiết-của-irt-2pl-trong-v-eval)
4. [Mổ Xẻ Ý Nghĩa Của 4 Tham Số Cốt Lõi: θ, b, a, c](#4-mổ-xẻ-ý-nghĩa-của-4-tham-số-cốt-lõi-θ-b-a-c)
5. [Hình Thái Học: Đường Cong Đặc Trưng Câu Hỏi (ICC - Item Characteristic Curve)](#5-hình-thái-học-đường-cong-đặc-trưng-câu-hỏi-icc---item-characteristic-curve)
6. [Hàm Thông Tin Fisher & Sai Số Chuẩn Đo Lường (SEM)](#6-hàm-thông-tin-fisher--sai-số-chuẩn-đo-lường-sem)
7. [Cơ Chế Phạt Đoán Mò Siêu Tốc (Anti-Guessing Penalty Của V-Eval)](#7-cơ-chế-phạt-đoán-mò-siêu-tốc-anti-guessing-penalty-của-v-eval)
8. [Đối Chiếu Trực Tiếp Với Code Python Trong `diagnostic_engine.py`](#8-đối-chiếu-trực-tiếp-với-code-python-trong-diagnostic_enginepy)
9. [Bước Chuyển Sang Flow 2: Năng Lực θ Hóa Thành Xác Suất Thành Thạo P(L0)](#9-bước-chuyển-sang-flow-2-năng-lực-θ-hóa-thành-xác-suất-thành-thạo-pl0)
10. [Bảng So Sánh Tổng Kết Toàn Diện](#10-bảng-so-sánh-tổng-kết-toàn-diện)

---

## 1. KHÁI NIỆM NỀN TẢNG: TẠI SAO IRT THAY THẾ HOÀN TOÀN LÝ THUYẾT CỔ ĐIỂN CTT?

### 1.1. Nghịch lý của Lý thuyết trắc nghiệm cổ điển (CTT - Classical Test Theory)
Trong hàng chục năm qua, các kỳ thi truyền thống thường chấm điểm bằng cách **đếm số câu đúng**:
```text
Điểm số = (Số câu đúng / Tổng số câu) × 100%
```

> [!WARNING]
> **Điểm mù chí mạng của CTT**: CTT hoàn toàn không quan tâm đến **độ khó** và **chất lượng** của từng câu hỏi:
> * **Học sinh A**: Làm đúng 15 câu ở mức **Nhận biết (Rất dễ)**.
> * **Học sinh B**: Làm đúng 15 câu ở mức **Vận dụng cao (Rất khó)**.
> * **Hệ thống CTT kết luận**: Hai học sinh này có trình độ **ngang nhau** (đều đúng 15/30 câu = 50%).
> 
> Đây là một sự đánh giá cào bằng và sai lệch nghiêm trọng về mặt sư phạm!

### 1.2. Giải pháp của Lý thuyết ứng đáp câu hỏi (IRT - Item Response Theory)
IRT được phát triển bởi các nhà khoa học đo lường giáo dục (Lord, Novick, Rasch) dựa trên một nguyên lý cốt lõi:
* Mỗi học sinh có một **Năng lực tiềm ẩn (Latent Trait)** chưa thấy ngay được, ký hiệu là `` `\theta` `` (Theta).
* Mỗi câu hỏi có các thuộc tính toán học riêng: **Độ khó (b)**, **Độ phân biệt (a)** và **Xác suất đoán mò (c)**.
* IRT xây dựng một hàm toán học liên kết trực tiếp: **Nếu học sinh có năng lực `` `\theta` ``, xác suất để em đó làm đúng câu hỏi có độ khó `` `b` `` là bao nhiêu phần trăm?**

---

## 2. HỌ MÔ HÌNH IRT LOGISTIC (1PL, 2PL, 3PL LÀ GÌ?)

Tùy vào số lượng tham số của câu hỏi được đưa vào bài toán, IRT được chia thành các cấp độ:

```
                                    HỌ MÔ HÌNH IRT LOGISTIC
                                               │
       ┌───────────────────────────────────────┼───────────────────────────────────────┐
       ▼                                       ▼                                       ▼
  Mô hình 1PL (Rasch)                     Mô hình 2PL                             Mô hình 3PL
 (1-Parameter Logistic)                  (2-Parameter Logistic)                  (3-Parameter Logistic)
 ──────────────────────                  ──────────────────────                  ──────────────────────
 Chỉ xét:                                Xét:                                    Xét:
 • Độ khó câu hỏi (b)                    • Độ khó câu hỏi (b)                    • Độ khó câu hỏi (b)
                                         • Độ phân biệt (a)                      • Độ phân biệt (a)
 Mọi câu hỏi đều có độ phân loại                                                 • Tham số đoán mò tự do (c)
 ngang nhau (a = 1).                     Độ dốc mỗi câu khác nhau.
                                                                                 Ước lượng cả 3 tham số trên dữ liệu lớn.
```

### Tại sao dự án V-Eval lại chọn mô hình IRT 2PL có mở rộng tham số đoán mò?
* Đề thi Đánh giá Năng lực ĐHQG-HCM sử dụng hoàn toàn **trắc nghiệm 4 lựa chọn (A, B, C, D)**, vì vậy xác suất một người chọn bừa trúng đáp án đúng là cố định: `` `c = 1/4 = 0.25` ``.
* Thay vì phải tốn hàng chục ngàn mẫu thi thử để học tham số `c` tự do (như 3PL), hệ thống **khóa cứng `` `c = 0.25` ``**, tập trung ước lượng năng lực `` `\theta` `` dựa trên 2 thông số phản ánh chất lượng đề thi thực tế là **Độ khó `b`** và **Độ phân biệt `a`**.

---

## 3. CÔNG THỨC TOÁN HỌC CHUẨN XÁC CỦA IRT TRONG DỰ ÁN V-EVAL

### 3.1. Công thức triển khai thực tế trong hệ thống V-Eval
Xác suất một học sinh có năng lực `` `\theta` `` trả lời **đúng** câu hỏi thứ `i` (với xác suất đoán mò cố định `` `c = 0.25` ``):

```text
                               1 - c
P(X_i = 1 | θ)  =  c  +  ─────────────────────────────────
                          1 + exp( -a_i × (θ - b_i) )
```

Hoặc viết dưới dạng phân số rời để không bị nhầm lẫn:
```text
P(X_i = 1 | θ)  =  c  +  (1 - c) × ────────────── 1 ──────────────
                                    1 + exp( -a_i × (θ - b_i) )
```

> [!IMPORTANT]
> **Lưu ý học thuật để bảo vệ đồ án:**
> * **Mô hình 2PL nguyên bản trong sách giáo khoa:** 
>   `` `P(X_i = 1 | \theta) = \frac{1}{1 + \exp(-a_i(\theta - b_i))}` `` (Hoàn toàn **không có tham số c**).
> * **Mô hình 3PL trong sách giáo khoa:** Có thêm tham số đoán mò tự do `` `c_i` `` cần ước lượng từ dữ liệu lớn.
> * **Mô hình trong V-Eval:** Bản chất là **Mô hình 3PL nhưng KHÓA CỨNG hằng số `` `c = 0.25` ``** (do đề thi ĐGNL ĐHQG-HCM sử dụng trắc nghiệm 4 lựa chọn A, B, C, D). Vì `` `c` `` là một hằng số cố định không cần ước lượng, hệ thống chỉ cần tập trung xử lý 2 tham số thực sự của câu hỏi là **Độ khó `b`** và **Độ phân biệt `a`**.

Trong đó:
* `` `X_i = 1` `` biểu thị sự kiện học sinh trả lời **đúng** câu hỏi $i$.
* `` `X_i = 0` `` biểu thị sự kiện học sinh trả lời **sai** câu hỏi $i$.
* Xác suất trả lời **sai** là: `` `P(X_i = 0 | \theta) = 1 - P(X_i = 1 | \theta)` ``.

---

## 4. MỔ XẺ Ý NGHĨA CỦA 4 THAM SỐ CỐT LÕI: θ, b, a, c

### 4.1. Tham số `` `\theta` `` (Theta) – Năng lực tiềm ẩn của học sinh
* **Miền giá trị**: Chuẩn hóa trong khoảng liên tục `[-3.0, +3.0]`.
* **Ý nghĩa thống kê**:
  * `` `\theta = 0.0` ``: Học sinh có học lực **Trung bình** của toàn bộ kỳ thi.
  * `` `\theta = -3.0` ``: Học sinh bị hổng kiến thức nặng (mất gốc).
  * `` `\theta = +3.0` ``: Học sinh có học lực xuất sắc, thủ khoa.
  * Khoảng `[-1.0, +1.0]` bao trọn khoảng 68.2% số lượng học sinh trong tự nhiên.

---

### 4.2. Tham số `` `b_i` `` (Item Difficulty) – Độ khó của câu hỏi
* **Ý nghĩa hình học**: Là tọa độ trên trục năng lực mà tại đó câu hỏi có khả năng phân loại tốt nhất (điểm uốn của đường cong).
* **Quy chuẩn trong đề thi V-ACT (Quy đổi từ 4 cấp độ nhận thức Bloom)**:
  * **Mức 1 (Nhận biết)**: `` `b = -1.0` `` (Câu hỏi định nghĩa, công thức cơ bản).
  * **Mức 2 (Thông hiểu)**: `` `b = 0.0` `` (Câu hỏi hiểu bản chất, tính toán 1 bước).
  * **Mức 3 (Vận dụng)**: `` `b = +1.0` `` (Câu hỏi phối hợp kiến thức, suy luận 2–3 bước).
  * **Mức 4 (Vận dụng cao)**: `` `b = +2.0` `` (Câu hỏi phân hóa đỉnh cao, tích hợp liên môn).

---

### 4.3. Tham số `` `a_i` `` (Item Discrimination) – Độ phân biệt của câu hỏi
* **Ý nghĩa hình học**: Là **độ dốc (Slope)** của đường cong tại điểm uốn.
* **Ý nghĩa sư phạm**: Đại diện cho khả năng "tách" học sinh giỏi ra khỏi học sinh yếu:
  * Nếu `` `a_i` `` cao (ví dụ `a = 1.5 - 2.0`): Đường cong dựng đứng. Học sinh chỉ cần có năng lực nhỉnh hơn độ khó câu hỏi một chút là làm đúng ngay; kém hơn một chút là làm sai ngay. Đây là một câu hỏi phân hóa rất tốt.
  * Nếu `` `a_i` `` thấp (ví dụ `a = 0.2 - 0.3`): Đường cong phẳng lì. Học sinh giỏi hay học sinh yếu đều có cơ hội làm đúng ngang ngửa nhau $\implies$ Câu hỏi phân loại kém.
  * Trong điều kiện tiêu chuẩn của V-Eval, câu hỏi chuẩn được gán: `` `a_i = 1.0` ``.

---

### 4.4. Tham số `` `c` `` (Pseudo-Guessing) – Xác suất đoán mò ngẫu nhiên
* Do đề thi V-ACT dùng 4 phương án (A, B, C, D), một học sinh dù hoàn toàn không biết gì (năng lực cực thấp `` `\theta \to -\infty` ``) khi bấm bừa một đáp án vẫn có xác suất trúng là:
  ```text
  c = 1 / 4 = 0.25 (25%)
  ```
* Nếu không có tham số `c`, mô hình sẽ ép xác suất của học sinh yếu về 0%, dẫn đến việc chấm sai lệch năng lực khi học sinh gặp may.

---

## 5. HÌNH THÁI HỌC: ĐƯỜNG CONG ĐẶC TRƯNG CÂU HỎI (ICC - ITEM CHARACTERISTIC CURVE)

Mỗi câu hỏi trong ngân hàng đề thi được đặc trưng bởi một đường cong hình chữ S:

```text
  Xác suất làm đúng P(θ)
    1.0 ┤                                                    ...-''
        │                                              ..-''
    0.625 ┼                                       .---' (Điểm uốn: θ = b_i)
        │                                   .---'
        │                             .---'
    0.25 ┼┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈..-'''' (Tiệm cận dưới: c = 0.25)
    0.0 ┴──────────┬──────────────┬──────────────┬──────────────┬────────> Năng lực θ
                  -3.0           0.0            b_i           +3.0
```

### Các đặc điểm hình học then chốt của đường cong ICC:
1. **Tiệm cận dưới bằng 0.25**:
   Khi năng lực học sinh cực thấp (`` `\theta \to -\infty` ``), số mũ `` `-a_i(\theta - b_i) \to +\infty` `` $\implies$ Mẫu số tiến về vô cùng $\implies$ Phân số bằng 0. Khi đó:
   `` `P(-\infty) = c = 0.25` ``.
2. **Điểm uốn tại `` `\theta = b_i` ``**:
   Khi năng lực của học sinh bằng đúng độ khó của câu hỏi (`` `\theta = b_i` ``):
   `` `-a_i(b_i - b_i) = 0 \implies \exp(0) = 1` ``
   Xác suất làm đúng tại điểm này là:
   `` `P(b_i) = c + \frac{1 - c}{1 + 1} = 0.25 + \frac{0.75}{2} = \mathbf{0.625 \ (62.5\%)}` ``
3. **Tiệm cận trên bằng 1.0**:
   Khi học sinh có năng lực cực cao (`` `\theta \to +\infty` ``), số mũ âm rất lớn $\implies$ `` `\exp(-\infty) = 0` ``:
   `` `P(+\infty) = c + \frac{1 - c}{1 + 0} = c + 1 - c = \mathbf{1.0 \ (100\%)}` ``.

---

## 6. HÀM THÔNG TIN FISHER & SAI SỐ CHUẨN ĐO LƯỜNG (SEM)

Làm sao để biết một bài thi 30 câu có đo chính xác năng lực học sinh hay không? IRT sử dụng khái niệm **Hàm thông tin Fisher (Fisher Information)**.

### 6.1. Công thức Lượng thông tin Fisher của một câu hỏi
Lượng thông tin mà câu hỏi $i$ đóng góp để xác định năng lực `` `\theta` `` được tính bằng:

```text
            ( P'_i(θ) )²
I_i(θ) = ──────────────────────
          P_i(θ) × (1 - P_i(θ))
```

Trong đó `` `P'_i(\theta)` `` là đạo hàm cấp 1 của hàm xác suất IRT 2PL:
```text
P'_i(θ) = (1 - c) × a_i × [ exp(-a_i*(θ - b_i)) / (1 + exp(-a_i*(θ - b_i)))² ]
```

### 6.2. Lượng thông tin đạt cực đại khi nào?
* Lượng thông tin `` `I_i(\theta)` `` đạt giá trị lớn nhất khi: **Độ khó của câu hỏi xấp xỉ năng lực của học sinh (`` `b_i \approx \theta` ``)**.
* **Ý nghĩa sư phạm**: 
  * Nếu đưa một câu Vận dụng cao (`b = 2.0`) cho một học sinh mất gốc (`θ = -2.0`), học sinh chỉ đánh lụi 25% $\implies$ Câu hỏi đó mang lại **lượng thông tin gần như bằng 0**.
  * Muốn đo chính xác năng lực học sinh, bài thi phải có sự phân bổ độ khó trải đều từ Dễ đến Khó.

### 6.3. Sai số chuẩn đo lường (SEM - Standard Error of Measurement)
Tổng lượng thông tin của cả bài thi 30 câu: `` `I(\theta) = \sum_{i=1}^{30} I_i(\theta)` ``.  
Sai số đo lường của điểm năng lực ước lượng `` `\hat{\theta}` `` là:

```text
SE(θ̂) = 1 / √( I(θ̂) + 0.25 )
```

Khoảng tin cậy 95% của năng lực học sinh là:
```text
[ θ̂ - 1.96 × SE(θ̂) ,  θ̂ + 1.96 × SE(θ̂) ]
```

---

## 7. CƠ CHẾ PHẠT ĐOÁN MÒ SIÊU TỐC (ANTI-GUESSING PENALTY CỦA V-EVAL)

Trong thi trắc nghiệm trực tuyến, một vấn đề nhức nhối là học sinh "đánh lụi" (click ngẫu nhiên) khi gặp câu hỏi dài hoặc sắp hết giờ:

```
                            TÌNH HUỐNG THỰC TẾ
                            
       Học sinh gặp câu Vận dụng cao (b = 2.0 - cần giải trong 90s)
                                    │
                                    ▼
       Học sinh click bừa đáp án trong vòng 2 GIÂY
                                    │
                                    ▼
       Ăn may: Trúng đáp án ĐÚNG!
                                    │
            ┌───────────────────────┴───────────────────────┐
            ▼                                               ▼
   [ Nếu dùng IRT thông thường ]                  [ Cơ chế Anti-Guessing của V-Eval ]
   Hệ thống lầm tưởng học sinh này                Hệ thống phát hiện: TimeSpent < 5s
   có năng lực xuất sắc và đẩy vọt                Lập tức ép: a_i = 0.1 (thay vì 1.0)
   điểm θ lên sai lệch thực tế!                   Lượng thông tin Fisher I(θ) ≈ 0!
                                                  Câu trả lời bị vô hiệu hóa điểm ảo!
```

### Bản chất toán học của việc ép `` `a_i = 0.1` ``:
* Khi độ phân biệt bị ép xuống `` `a_i = 0.1` ``, đường cong ICC trở nên **gần như một đường thẳng nằm ngang**.
* Đạo hàm `` `P'_i(\theta) \to 0` `` dẫn đến tử số của hàm thông tin Fisher:
  `` `(P'_i(\theta))^2 \approx 0 \implies I_i(\theta) \approx 0` ``.
* Nhờ vậy, câu trả lời ăn may hoàn toàn **không đóng góp thông tin vào hàm ước lượng MAP**, bảo vệ độ "sạch" và chính xác tuyệt đối của tham số năng lực `` `\theta_0` ``.

---

## 8. ĐỐI CHIẾU TRỰC TIẾP VỚI CODE PYTHON TRONG `diagnostic_engine.py`

Toàn bộ lý thuyết trên được hiện thực hóa trong file [`diagnostic_engine.py`](./All%20Services/V-Eval-Ai_Engine/rag-service/diagnostic_engine.py) như sau:

### 1. Hàm tính xác suất IRT 2PL:
```python
def _irt_probability(theta: float, b: float, a: float = DEFAULT_DISCRIMINATION,
                     c: float = GUESSING_PARAM) -> float:
    # Tính số mũ: -a * (θ - b)
    exponent = -a * (theta - b)
    
    # Kẹp biên an toàn [-500, 500] để chống tràn số exp() trong máy tính
    exponent = max(-500.0, min(500.0, exponent))
    
    # Công thức: c + (1 - c) / (1 + exp(-a*(θ - b)))
    return c + (1.0 - c) / (1.0 + math.exp(exponent))
```

### 2. Hàm phạt đoán mò dưới 5 giây:
```python
# Nếu học sinh làm dưới 5s, hạ độ phân biệt a xuống 0.1
a = 0.1 if ans.time_spent_seconds < RAPID_GUESS_THRESHOLD_SECONDS else DEFAULT_DISCRIMINATION

# Tính xác suất làm đúng với độ phân biệt đã điều chỉnh
p = _irt_probability(theta, b, a=a, c=GUESSING_PARAM)
```

---

## 9. BƯỚC CHUYỂN SANG FLOW 2: NĂNG LỰC θ HÓA THÀNH XÁC SUẤT THÀNH THẠO P(L0)

Sau khi giải thuật MAP tìm ra điểm năng lực tổng quát `` `\theta_0` `` (ví dụ: `` `\theta_0 = +1.2` ``), làm sao để chuyển điểm này thành dữ liệu đầu vào cho **Core Flow 2 (Topological Sorter & Path Pruner)**?

Hệ thống sử dụng **Hàm Logistic Sigmoid chuẩn hóa**:

```text
               1
P(L_0) = ──────────────
         1 + exp(-θ)
```

Kèm cơ chế chặn biên an toàn (Boundary Clamping):
```text
P(L_0)_safe = max( 0.05, min( 0.95, P(L_0) ) )
```

```
                     ÁNH XẠ NĂNG LỰC SANG XÁC SUẤT BKT
                     
    Thang Năng Lực IRT θ                      Xác Suất Thành Thạo P(L0)
   (Dùng để xếp lớp Flow 1)                  (Dùng để sinh lộ trình Flow 2)
   ────────────────────────                  ──────────────────────────────
         θ = +2.5        ────────Sigmoid───────>      P(L0) = 0.92 (92%)
         θ =  0.0        ────────Sigmoid───────>      P(L0) = 0.50 (50%)
         θ = -2.5        ────────Sigmoid───────>      P(L0) = 0.08  (8%)
```

> [!NOTE]
> **Ý nghĩa của kẹp biên `[0.05, 0.95]`**: 
> Trong sư phạm, không có học sinh nào biết 100% (luôn có thể có sai sót bất cẩn) và cũng không có ai mất gốc 100% (luôn có xác suất học hiểu). Kẹp biên này bảo vệ mô hình BKT ở các luồng sau không bị rơi vào trạng thái bão hòa xác suất.

---

## 10. BẢNG SO SÁNH TỔNG KẾT TOÀN DIỆN

| Tiêu chí | Đo lường cổ điển (CTT) | Đo lường hiện đại (IRT 2PL của V-Eval) |
| :--- | :--- | :--- |
| **Bản chất tính điểm** | Đếm số câu đúng / Tổng số câu | Ước lượng năng lực ẩn `` `\theta` `` dựa trên độ khó câu hỏi |
| **Xử lý câu Dễ vs câu Khó** | Cào bằng như nhau | Phân biệt rõ rệt (đúng câu khó ghi nhận năng lực cao hơn) |
| **Xử lý đoán mò (Click bừa)** | Không thể phát hiện, tính đủ điểm | Kích hoạt luật phạt `< 5s`, triệt tiêu lượng thông tin câu ăn may |
| **Thang đo năng lực** | Phụ thuộc vào độ dễ/khó của đề thi | Thang đo chuẩn hóa `` `[-3.0, +3.0]` ``, không phụ thuộc đề |
| **Độ tin cậy kết quả** | Không định lượng được sai số từng người | Đo lường chính xác sai số chuẩn `SEM` qua hàm thông tin Fisher |
| **Ứng dụng tiếp theo** | Chỉ để trả kết quả điểm số | Khởi tạo vector `` `P(L_0)` `` để nuôi sống thuật toán định tuyến lộ trình học |
