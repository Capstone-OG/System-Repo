# HƯỚNG DẪN KIẾN TRÚC & HẠ TẦNG KIỂM THỬ NỀN TẢNG (UNIT TEST & CODE COVERAGE)

> **Tham chiếu chuẩn hóa**: Kiến trúc kiểm thử được thiết kế dựa trên mô hình chuẩn hóa từ dự án `G:\OJT\Deploy` (OJT Laboratory Project), nâng cấp tương thích hoàn toàn với nền tảng **.NET 9** của **V-Eval Capstone System**.

---

## 1. TECH STACK KIỂM THỬ CHUẨN HÓA

Toàn bộ 5 Microservices C# (`V-Eval-Identity_Service`, `V-Eval-Content_Service`, `V-Eval-Practice_Service`, `V-Eval-Ai_Engine`, `V-Eval-Gateway`) đã được trang bị đồng bộ bộ công nghệ:

| Công cụ / Thư viện | Phiên bản | Vai trò & Mục đích |
| :--- | :--- | :--- |
| **xUnit** | `2.9.2` | Test runner & Framework kiểm thử đơn vị hiện đại. |
| **Microsoft.NET.Test.Sdk** | `17.12.0` | Bộ công cụ SDK chạy test chính thức của Microsoft. |
| **Moq** | `4.20.72` | Thư viện tạo Mock Objects (giả lập Repository, Service, DbContext, HttpClient, ILogger). |
| **FluentAssertions** | `7.2.0` | Cú pháp viết Assertions tự nhiên, trực quan theo chuẩn BDD (`result.Should().BeTrue()`). |
| **Coverlet Collector** | `6.0.2` | Bộ thu thập độ bao phủ mã nguồn (Code Coverage) xuất ra định dạng Cobertura XML. |
| **ReportGenerator** | `5.4.18` | .NET Local Tool tự động biên dịch Cobertura XML thành giao diện báo cáo HTML trực quan. |

### Global Usings được tích hợp sẵn trong `.csproj`:
Khi viết test trong bất kỳ file nào, bạn **không cần phải gõ lại** các dòng using sau vì đã được cấu hình toàn cục:
```csharp
global using Xunit;
global using Moq;
global using FluentAssertions;
```

---

## 2. CẤU TRÚC THƯ MỤC TEST CHUẨN HÓA

Mỗi Microservice đều sở hữu một dự án kiểm thử riêng biệt `<ServiceName>.Tests`, tổ chức đối xứng 1-1 với các use-case của tầng Application:

```
<ServiceName>.Tests/
├── Common/                  # Base fixtures, Mock helper factories, In-Memory DB setup
├── Commands/                # Unit tests cho các Command Handlers (Create, Update, Delete)
├── Queries/                 # Unit tests cho các Query Handlers (GetById, List, Search)
├── Validators/              # Unit tests cho FluentValidation rules
├── TestResults/             # Thư mục tự động sinh khi chạy test
│   ├── coverage/            # File Cobertura XML (coverage.cobertura.xml)
│   └── CoverageReport/      # Báo cáo HTML trực quan (index.html)
└── <ServiceName>.Tests.csproj
```

---

## 3. BỘ SCRIPT AUTOMATION TỰ ĐỘNG HÓA

### A. Kiểm thử toàn bộ hệ thống (Toàn bộ 5 Microservices)
Chạy script tại thư mục gốc của hệ thống:
```cmd
Scripts\test\test_all.bat
```
* **Chức năng**:
  * Tự động nhận diện môi trường .NET 9 (`%USERPROFILE%\.dotnet\dotnet.exe` hoặc `dotnet`).
  * Cung cấp menu tương tác chọn kiểm thử toàn bộ hoặc từng dịch vụ riêng lẻ.
  * Xuất bảng tổng kết số lượng dịch vụ **Passed / Failed** với màu sắc trực quan.

### B. Kiểm thử chi tiết từng Microservice (Kèm đo Coverage & Mở Báo cáo HTML)
Chạy script test độc lập bên trong từng service:
```cmd
All Services\V-Eval-Identity_Service\Scripts\test.bat
All Services\V-Eval-Content_Service\Scripts\test.bat
All Services\V-Eval-Practice_Service\Scripts\test.bat
All Services\V-Eval-Ai_Engine\Scripts\test.bat
All Services\V-Eval-Gateway\Scripts\test.bat
```
* **Quy trình 4 bước tự động**:
  1. `[1/4]`: Biên dịch dự án Test ở chế độ Debug.
  2. `[2/4]`: Thực thi các Test Cases và thu thập Cobertura Code Coverage qua Coverlet.
  3. `[3/4]`: Kiểm tra và khôi phục công cụ `dotnet tool reportgenerator`.
  4. `[4/4]`: Biên dịch báo cáo HTML trong `TestResults/CoverageReport/index.html` và **tự động mở trên trình duyệt web**.

---

## 4. TEMPLATE MẪU VIẾT UNIT TEST THEO CHUẨN AAA (ARRANGE - ACT - ASSERT)

Dưới đây là cấu trúc mẫu để dev tham khảo khi bắt tay vào viết Unit Test cho một Handler:

```csharp
namespace V_Eval_Identity_Service.Tests.Commands;

public class SampleCommandHandlerTests
{
    private readonly Mock<IUserRepository> _mockUserRepo;
    private readonly Mock<ILogger<SampleCommandHandler>> _mockLogger;

    public SampleCommandHandlerTests()
    {
        // 1. Khởi tạo Mocks
        _mockUserRepo = new Mock<IUserRepository>();
        _mockLogger = new Mock<ILogger<SampleCommandHandler>>();
    }

    private SampleCommandHandler CreateHandler()
    {
        return new SampleCommandHandler(_mockUserRepo.Object, _mockLogger.Object);
    }

    [Fact]
    public async Task Handle_ValidRequest_ShouldReturnSuccessResult()
    {
        // Arrange (Chuẩn bị dữ liệu và Mock)
        var handler = CreateHandler();
        var command = new SampleCommand { UserId = Guid.NewGuid(), Email = "test@v-eval.vn" };
        var fakeUser = new User { Id = command.UserId, Email = command.Email };

        _mockUserRepo.Setup(r => r.GetByIdAsync(command.UserId, It.IsAny<CancellationToken>()))
                     .ReturnsAsync(fakeUser);

        // Act (Thực thi hành động)
        var result = await handler.Handle(command, CancellationToken.None);

        // Assert (Kiểm chứng kết quả bằng FluentAssertions)
        result.Should().NotBeNull();
        result.IsSuccess.Should().BeTrue();
        result.Value.Email.Should().Be("test@v-eval.vn");

        // Verify tương tác
        _mockUserRepo.Verify(r => r.UpdateAsync(fakeUser, It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task Handle_UserNotFound_ShouldReturnFailureResult()
    {
        // Arrange
        var handler = CreateHandler();
        var command = new SampleCommand { UserId = Guid.NewGuid() };

        _mockUserRepo.Setup(r => r.GetByIdAsync(command.UserId, It.IsAny<CancellationToken>()))
                     .ReturnsAsync((User?)null);

        // Act
        var result = await handler.Handle(command, CancellationToken.None);

        // Assert
        result.IsSuccess.Should().BeFalse();
        result.Error.Code.Should().Be("User.NotFound");
    }
}
```

