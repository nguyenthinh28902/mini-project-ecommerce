# GIAI ĐOẠN 1: BUILD
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# 1. Copy các file .csproj và giữ đúng cấu trúc folder cha để các project reference không bị lỗi
COPY ["EcommerceIdentityCMS/EcommerceIdentityCMS.Api/EcommerceIdentityCMS.Api.csproj", "EcommerceIdentityCMS/EcommerceIdentityCMS.Api/"]
COPY ["EcommerceIdentityCMS/EcommerceIdentityCMS.Application/EcommerceIdentityCMS.Application.csproj", "EcommerceIdentityCMS/EcommerceIdentityCMS.Application/"]
COPY ["EcommerceIdentityCMS/EcommerceIdentityCMS.Core/EcommerceIdentityCMS.Core.csproj", "EcommerceIdentityCMS/EcommerceIdentityCMS.Core/"]
COPY ["EcommerceIdentityCMS/EcommerceIdentityCMS.Infrastructure/EcommerceIdentityCMS.Infrastructure.csproj", "EcommerceIdentityCMS/EcommerceIdentityCMS.Infrastructure/"]

# 2. Restore dự án API chính dựa trên đường dẫn folder mới
RUN dotnet restore "EcommerceIdentityCMS/EcommerceIdentityCMS.Api/EcommerceIdentityCMS.Api.csproj"

# 3. Copy toàn bộ mã nguồn từ thư mục gốc vào container
COPY . .

# 4. Build ứng dụng
# Chuyển vào đúng thư mục chứa file .csproj chính để thực hiện build
WORKDIR "/src/EcommerceIdentityCMS/EcommerceIdentityCMS.Api"
RUN dotnet build "EcommerceIdentityCMS.Api.csproj" -c Release -o /app/build

# GIAI ĐOẠN 2: PUBLISH
FROM build AS publish
RUN dotnet publish "EcommerceIdentityCMS.Api.csproj" -c Release -o /app/publish /p:UseAppHost=false

# GIAI ĐOẠN 3: RUNTIME (Sử dụng ASP.NET 8.0)
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Chỉ comment những dòng lệnh quan trọng
# Copy kết quả publish vào môi trường chạy sạch
COPY --from=publish /app/publish .

# Cấu hình Port chạy mặc định cho .NET 8
ENV ASPNETCORE_URLS=http://+:80
EXPOSE 80
EXPOSE 443

ENTRYPOINT ["dotnet", "EcommerceIdentityCMS.Api.dll"]