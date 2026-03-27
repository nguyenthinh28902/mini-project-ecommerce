# GIAI ĐOẠN 1: BUILD
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# 1. Copy các file .csproj (Giữ đúng cấu trúc folder cha để các project reference tìm thấy nhau)
# Chú ý: Cấu trúc folder trong container phải khớp với cấu trúc folder vật lý của bạn
COPY ["Ecom.OrderService.Api/Ecom.OrderService.Api/Ecom.OrderService.Api.csproj", "Ecom.OrderService.Api/Ecom.OrderService.Api/"]
COPY ["Ecom.OrderService.Api/Ecom.OrderService.Application/Ecom.OrderService.Application.csproj", "Ecom.OrderService.Api/Ecom.OrderService.Application/"]
COPY ["Ecom.OrderService.Api/Ecom.OrderService.Core/Ecom.OrderService.Core.csproj", "Ecom.OrderService.Api/Ecom.OrderService.Core/"]
COPY ["Ecom.OrderService.Api/Ecom.OrderService.Infrastructure/Ecom.OrderService.Infrastructure.csproj", "Ecom.OrderService.Api/Ecom.OrderService.Infrastructure/"]

# 2. Restore gói NuGet dựa trên đường dẫn folder mới
RUN dotnet restore "Ecom.OrderService.Api/Ecom.OrderService.Api/Ecom.OrderService.Api.csproj"

# 3. Copy toàn bộ mã nguồn vào Docker
COPY . .

# 4. Build dự án
# Chuyển vào đúng thư mục chứa file .csproj để thực hiện build
WORKDIR "/src/Ecom.OrderService.Api/Ecom.OrderService.Api"
RUN dotnet build "Ecom.OrderService.Api.csproj" -c Release -o /app/build

# GIAI ĐOẠN 2: PUBLISH
FROM build AS publish
RUN dotnet publish "Ecom.OrderService.Api.csproj" -c Release -o /app/publish /p:UseAppHost=false

# GIAI ĐOẠN 3: RUNTIME (FINAL)
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app

# Chỉ comment những dòng lệnh quan trọng
# Copy kết quả đã publish vào môi trường chạy
COPY --from=publish /app/publish .

# Cấu hình môi trường chạy mặc định trên port 80 
ENV ASPNETCORE_URLS=http://+:80
EXPOSE 80

ENTRYPOINT ["dotnet", "Ecom.OrderService.Api.dll"]