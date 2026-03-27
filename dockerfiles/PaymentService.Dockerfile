# GIAI ĐOẠN 1: BUILD
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# 1. Copy các file .csproj (Giữ đúng cấu trúc folder để restore không lỗi) 
# Chú ý: Phải giữ folder cha Ecom.PaymentService để các project reference tìm thấy nhau
COPY ["Ecom.PaymentService/Ecom.PaymentService.Api/Ecom.PaymentService.Api.csproj", "Ecom.PaymentService/Ecom.PaymentService.Api/"]
COPY ["Ecom.PaymentService/Ecom.PaymentService.Application/Ecom.PaymentService.Application.csproj", "Ecom.PaymentService/Ecom.PaymentService.Application/"]
COPY ["Ecom.PaymentService/Ecom.PaymentService.Core/Ecom.PaymentService.Core.csproj", "Ecom.PaymentService/Ecom.PaymentService.Core/"]
COPY ["Ecom.PaymentService/Ecom.PaymentService.Infrastructure/Ecom.PaymentService.Infrastructure.csproj", "Ecom.PaymentService/Ecom.PaymentService.Infrastructure/"]

# 2. Restore các dependencies dựa trên file project chính 
RUN dotnet restore "Ecom.PaymentService/Ecom.PaymentService.Api/Ecom.PaymentService.Api.csproj"

# 3. Copy toàn bộ mã nguồn vào Docker
COPY . .

# 4. Build ứng dụng
WORKDIR "/src/Ecom.PaymentService/Ecom.PaymentService.Api"
RUN dotnet build "Ecom.PaymentService.Api.csproj" -c Release -o /app/build

# GIAI ĐOẠN 2: PUBLISH
FROM build AS publish
RUN dotnet publish "Ecom.PaymentService.Api.csproj" -c Release -o /app/publish /p:UseAppHost=false

# GIAI ĐOẠN 3: RUNTIME (FINAL)
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app

# Chỉ comment những dòng lệnh quan trọng
# Copy kết quả đã publish vào thư mục chạy
COPY --from=publish /app/publish .

# Mặc định .NET 10 dùng port 8080, cấu hình lại port 80 theo chuẩn hệ thống
ENV ASPNETCORE_URLS=http://+:80
EXPOSE 80

ENTRYPOINT ["dotnet", "Ecom.PaymentService.Api.dll"]