# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - V-EVAL CAPSTONE SYSTEM REPO

## [16/11/2026] - Khắc Phục Triệt Để Hiện Tượng Lặp Từ Kép (Double Token Glitch) Khi Gia Sư AI Socratic Trả Lời & Tối Ưu Hóa Dòng Stream SSE

- **Khắc Phục Lỗi Lặp Từ Kép Khi AI Stream Phản Hồi ([`AISocraticTutorModal.jsx`](./All%20Services/V-Eval-Web_Client/src/components/modals/AISocraticTutorModal.jsx), [`AISocraticTutorWidget.jsx`](./All%20Services/V-Eval-Web_Client/src/components/dashboard/AISocraticTutorWidget.jsx))**:
  - **Xác định nguyên nhân gốc rễ**: Trong môi trường React 19 / Vite development mode, React StrictMode thực thi các hàm cập nhật trạng thái (`setSessions(prev => ...)`) 2 lần liên tiếp nhằm kiểm tra tính thuần khiết (pure function). Trước đây, code cũ thực hiện biến đổi trực tiếp thuộc tính đối tượng in-place (`last.text = (last.text || '') + token`), khiến mỗi token gửi từ SSE bị cộng dồn 2 lần (dẫn đến hiện tượng mọi từ đều bị lặp kép như *"Chào Chào em! em! Chà, Chà, em em vừa vừa mang mang đến đến một một..."*).
  - **Tách biệt luồng tích lũy với `useRef` (Decoupled Stream Ref)**: Sử dụng `streamedTextRef.current` lưu trữ nguồn dữ liệu chính xác duy nhất cho chuỗi văn bản đang stream. State updater chỉ thực hiện gán bất biến (`text: currentText`) qua `prev.map(...)`, hoàn toàn miễn nhiễm 100% trước cơ chế chạy lặp của React StrictMode.
  - **Triệt tiêu 200+ lần ghi đĩa dư thừa vào LocalStorage**: Loại bỏ lời gọi `aiSessionManager.saveSessions(...)` bên trong callback `onToken`. Việc lưu phiên chỉ thực hiện đúng 1 lần duy nhất khi kết thúc lượt stream (`onComplete`) hoặc khi gặp lỗi (`onError`), giải phóng hoàn toàn nghẽn I/O và hiện tượng giật lag giao diện.
- **Tự Động Làm Sạch & Phục Hồi Dữ Liệu Phiên Cũ ([`aiSessionManager.js`](./All%20Services/V-Eval-Web_Client/src/utils/aiSessionManager.js), [`aiSessionManager.test.js`](./All%20Services/V-Eval-Web_Client/tests/aiSessionManager.test.js))**:
  - Xây dựng hàm `cleanDoubledWords` nhận diện và tự động chữa lành các tin nhắn lịch sử từng bị dính lỗi lặp từ trước đó trong `localStorage` ngay khi nạp phiên, đồng thời giữ nguyên các từ láy tự nhiên trong tiếng Việt (như "thong thả", "chầm chậm").
- **Kiểm Thử & Biên Dịch Toàn Diện**:
  - `npm run build`: Thành công 100% trong 1.20s.
  - `node --test`: Đạt **22/22 unit tests pass 100%** (bao gồm toàn bộ suite `aiSessionManager` và `cleanVietnameseDiacritics`).
  - **Không phát sinh bất kỳ cảnh báo breaking change hay suy giảm hiệu năng nào**.
