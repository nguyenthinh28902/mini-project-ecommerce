# GIAI ĐOẠN 1: BUILD
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# 1. Copy các file .csproj và giữ đúng cấu trúc folder cha để các project reference không bị lỗi
COPY ["Ecom.Notification/Ecom.Notification/Ecom.Notification.csproj", "Ecom.Notification/Ecom.Notification/"]
COPY ["Ecom.Notification/Ecom.Notification.Application/Ecom.Notification.Application.csproj", "Ecom.Notification/Ecom.Notification.Application/"]
COPY ["Ecom.Notification/Ecom.Notification.Core/Ecom.Notification.Core.csproj", "Ecom.Notification/Ecom.Notification.Core/"]
COPY ["Ecom.Notification/Ecom.Notification.Infrastructure/Ecom.Notification.Infrastructure.csproj", "Ecom.Notification/Ecom.Notification.Infrastructure/"]

# 2. Restore dự án chính dựa trên đường dẫn folder đã copy
RUN dotnet restore "Ecom.Notification/Ecom.Notification/Ecom.Notification.csproj"

# 3. Copy toàn bộ mã nguồn từ thư mục gốc vào container
COPY . .

# 4. Build ứng dụng
# Chuyển vào đúng thư mục chứa file .csproj chính
WORKDIR "/src/Ecom.Notification/Ecom.Notification"
RUN dotnet build "Ecom.Notification.csproj" -c Release -o /app/build

# GIAI ĐOẠN 2: PUBLISH
FROM build AS publish
RUN dotnet publish "Ecom.Notification.csproj" -c Release -o /app/publish /p:UseAppHost=false

# GIAI ĐOẠN 3: RUNTIME (FINAL)
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app

# Chỉ comment những dòng lệnh quan trọng
# Copy kết quả đã publish vào môi trường runtime
COPY --from=publish /app/publish .

# Cấu hình Port chạy mặc định
ENV ASPNETCORE_URLS=http://+:80
EXPOSE 80

ENTRYPOINT ["dotnet", "Ecom.Notification.dll"]