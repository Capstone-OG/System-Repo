# AGENT RULES - V-EVAL CAPSTONE SYSTEM REPO

> [!IMPORTANT]
> Đây là file quy tắc hệ thống dành cho AI Assistant (Antigravity). Tất cả công việc phát triển trong dự án V-Eval phải tuân thủ nghiêm ngặt các quy tắc dưới đây.

---

## 📝 QUY TẮC CẬP NHẬT TÀI LIỆU VÀ TIẾN ĐỘ BẮT BUỘC (DOCUMENTATION FIRST RULE)

### 1. THỨ TỰ THỰC HIỆN BẮT BUỘC (STRICT ORDER OF OPERATIONS)
Khi thực hiện bất kỳ công việc nào (tạo mới, sửa lỗi, nâng cấp kiến trúc, refactor):

1. **Bước 1: Code & Kiểm thử vần hành**
   - Viết code và chạy lệnh kiểm thử (`dotnet build`, `docker compose config`...) đảm bảo code sạch 100%.
2. **Bước 2: Cập nhật Tài liệu & UPDATE.md TRƯỚC TIÊN (MANDATORY)**
   - Cập nhật nhật ký tiến độ vào bộ 3 file tài liệu chuẩn trong thư mục `docs/` của các service liên quan:
     - **`docs/daily.md`**: Nhật ký cập nhật tiến độ hằng ngày (`[DD/MM/YYYY]`).
     - **`docs/process.md`**:
       - *Phần trên*: Kiến trúc dịch vụ & danh sách các thành phần cần triển khai.
       - *Phần dưới*: Bảng theo dõi tiến độ cho từng mục (mô tả rõ từng hạng mục đang ở đâu, trạng thái và tiến độ chi tiết ra sao).
     - **`docs/architecture_acceptance.md`**: Báo cáo nghiệm thu & thấu hiểu kiến trúc (Tiếng Anh).
   - Làm mới và cập nhật file `UPDATE.md` của từng service vừa đụng tới và `UPDATE.md` của `System-Repo`:
     - Ghi chép tiến độ của **ngày hiện tại `[DD/MM/YYYY]` lên ĐẦU file**.
     - Xóa bớt/làm sạch nội dung `UPDATE.md` cũ không còn phù hợp để tài liệu luôn gọn gàng, chuẩn xác.
3. **Bước 3: Mới được phép hỏi hoặc thực hiện Git Add / Commit / Push**
   - Chỉ khi Bước 2 hoàn thành 100%, AI mới được phép đề xuất hoặc thực hiện `git add`, `git commit` và `git push` (hoặc hướng dẫn dùng `Scripts/push.bat`).

---

## 🛡️ QUY TẮC AN TOÀN BỘ SCRIPT HỆ THỐNG
- Tất cả các script trong thư mục `Scripts/` (`pull.bat`, `push.bat`, `setup.bat`, `run_docker.bat`, `run_local.bat`) phải luôn duy trì cú pháp chuẩn Windows Batch (tránh escape quote `\"` ở `pushd`, không dùng ngoặc `()` gây lỗi trong chuỗi `echo`).
