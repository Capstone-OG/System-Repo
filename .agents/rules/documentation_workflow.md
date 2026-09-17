# AGENT RULE: DOCUMENTATION FIRST WORKFLOW (QUY TẮC CẬP NHẬT TÀI LIỆU VÀ TIẾN ĐỘ BẮT BUỘC)

> [!CRITICAL]
> **TÀI LIỆU & UPDATE.MD PHẢI ĐƯỢC CẬP NHẬT TRƯỚC KHI THỰC HIỆN BẤT KỲ LỆNH COMMMIT HOẶC PUSH NÀO.**
> AI Assistant phải tuân thủ nghiêm ngặt quy trình 3 bước dưới đây trong mọi tác vụ triển khai hoặc chỉnh sửa mã nguồn.

---

## 📋 THỨ TỰ THỰC HIỆN BẮT BUỘC (STRICT ORDER OF OPERATIONS)

### BƯỚC 1: HOÀN THÀNH CODE & KIỂM THỬ VẬN HÀNH
- Thực hiện logic lập trình, sửa bug, tạo tính năng hoặc refactor mã nguồn.
- Chạy lệnh kiểm thử biên dịch (ví dụ: `dotnet build`, `docker compose config`...) để đảm bảo code hoạt động hoàn hảo 100% trước khi chuyển bước.

### BƯỚC 2: CẬP NHẬT TÀI LIỆU TIẾN ĐỘ & UPDATE.MD (BẮT BUỘC HOÀN THÀNH TRƯỚC)
Trước khi đề xuất hoặc thực hiện Git Commit/Push, AI **BẮT BUỘC** phải rà soát và cập nhật đầy đủ các tài liệu sau:

1. **Cập Nhật Bộ Tài Liệu Chuẩn Của Service (`docs/`)**:
   - **`docs/daily.md`**: Nhật ký cập nhật tiến độ hằng ngày (log rõ công việc làm được theo mốc ngày `[DD/MM/YYYY]`).
   - **`docs/process.md`**:
     - *Phần trên*: Định nghĩa Kiến trúc tổng thể của service & các hạng mục/chức năng cần triển khai.
     - *Phần dưới*: Bảng Tiến độ Chi tiết cho từng mục (mô tả rõ từng hạng mục đang ở đâu, trạng thái Hoàn thành / Đang triển khai / Chưa làm, và tiến độ ra sao).
   - **`docs/architecture_acceptance.md`**: Báo cáo nghiệm thu & thấu hiểu kiến trúc (Tiếng Anh).

2. **Cập Nhật File `UPDATE.md` Theo Ngày Hiện Tại**:
   - Mở file `UPDATE.md` của từng Service đã chỉnh sửa và file `UPDATE.md` tổng tại root `System-Repo`.
   - **Xóa bỏ các nội dung `UPDATE.md` cũ không còn phù hợp / ghi đè log tiến độ mới nhất của ngày hôm đó**.
   - Đặt mục ngày hiện tại `[DD/MM/YYYY]` lên **ĐẦU FILE** `UPDATE.md`, ghi lại ngắn gọn, chất lượng các công việc đã làm trong ngày.

### BƯỚC 3: HỎI VÀ THỰC HIỆN GIT COMMIT / GIT PUSH
- **ĐIỀU KIỆN TIÊN QUYẾT**: Chỉ khi Bước 2 đã hoàn tất 100% (Tất cả file docs và `UPDATE.md` đã được ghi nhận), AI mới được phép:
  1. Hỏi ý kiến người dùng hoặc thực hiện `git add -A`.
  2. Tạo `git commit` với thông điệp rõ ràng, chất lượng.
  3. Thực hiện `git push` hoặc hướng dẫn người dùng chạy công cụ `Scripts/push.bat`.

---

## 🚫 CÁC HÀNH VI BỊ CẤM (PROHIBITED ACTIONS)
- **CẤM**: Thực hiện `git commit` hoặc `git push` khi chưa cập nhật `UPDATE.md` và các file `docs/`.
- **CẤM**: Hỏi người dùng về việc push/commit trước khi tài liệu đã được ghi nhận đầy đủ.
- **CẤM**: Giữ lại các thông tin lỗi thời trong `UPDATE.md` mà không dọn dẹp/làm mới theo ngày triển khai.
