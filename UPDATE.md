# NHẬT KÝ CẬP NHẬT (UPDATE LOG) - SYSTEM REPO

## [02/11/2026] - Thiết Lập Kiến Trúc Test Nền Tảng & Script Test Tương Tác (`test.bat`)

- **Thiết lập nền tảng kiểm thử Microservices (.NET 9 SDK Host)**:
  - Đồng bộ và hoàn thiện cấu trúc dự án kiểm thử `.Tests.csproj` cho cả 5 service (`Identity_Service`, `Content_Service`, `Practice_Service`, `Ai_Engine`, `Gateway`) dựa trên chuẩn kiến trúc tham chiếu `G:\OJT\Deploy\OJT_Laboratory_Project\IAM_Service`.
  - Tích hợp bộ công cụ chuẩn: `xUnit 2.9.2`, `Moq 4.20.72`, `FluentAssertions 7.2.0`, `coverlet.collector 6.0.2` kèm `Global Usings`.
  - Khởi tạo `.config/dotnet-tools.json` và khôi phục thành công công cụ báo cáo độ bao phủ mã nguồn `dotnet-reportgenerator-globaltool 5.4.18`.
  - Thiết lập sẵn cấu trúc thư mục kiểm thử khung (`Commands/`, `Queries/`, `Validators/`, `Common/`) sẵn sàng cho việc viết test nghiệp vụ.
- **Tạo Script kiểm thử thủ công tương tác (`Scripts/test/test.bat`)**:
  - Xóa bỏ script tự động `test_all.bat` cũ theo yêu cầu người dùng.
  - Xây dựng `Scripts/test/test.bat` với menu tương tác số `[1-7]` cho phép lựa chọn chạy toàn bộ 5 dịch vụ hoặc từng dịch vụ đơn lẻ.
  - Tự động nhận diện đường dẫn SDK .NET 9 trên máy Host (`%USERPROFILE%\.dotnet\dotnet.exe`), tương thích 100% chuẩn Windows Batch CRLF, xuất báo cáo Coverage HTML và dừng màn hình (`pause`) để người dùng tự chạy và kiểm tra kết quả trực quan.
- **Tài liệu hướng dẫn nội bộ**:
  - Khởi tạo tài liệu [`docs_noi_bo/testing_architecture_guide.md`](./docs_noi_bo/testing_architecture_guide.md) mô tả chi tiết kiến trúc test, cấu trúc thư mục, quy tắc viết Unit Test AAA và hướng dẫn sử dụng script.
