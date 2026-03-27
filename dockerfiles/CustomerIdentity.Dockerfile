# GIAI ĐOẠN 1: BUILD
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# 1. Copy các file .csproj và giữ đúng cấu trúc folder cha để các project reference không bị lỗi
COPY ["CustomerIdentityService/CustomerIdentityService.API/CustomerIdentityService.API.csproj", "CustomerIdentityService/CustomerIdentityService.API/"]
COPY ["CustomerIdentityService/CustomerIdentityService.Application/CustomerIdentityService.Application.csproj", "CustomerIdentityService/CustomerIdentityService.Application/"]
COPY ["CustomerIdentityService/CustomerIdentityService.Infrastructure/CustomerIdentityService.Infrastructure.csproj", "CustomerIdentityService/CustomerIdentityService.Infrastructure/"]
COPY ["CustomerIdentityService/CustomerIdentityService.Core/CustomerIdentityService.Core.csproj", "CustomerIdentityService/CustomerIdentityService.Core/"]

# 2. Restore dựa trên đường dẫn folder mới đã copy
RUN dotnet restore "CustomerIdentityService/CustomerIdentityService.API/CustomerIdentityService.API.csproj"

# 3. Copy toàn bộ mã nguồn vào container
COPY . .

# 4. Build ứng dụng
# Chuyển vào đúng thư mục chứa file .csproj chính
WORKDIR "/src/CustomerIdentityService/CustomerIdentityService.API"
RUN dotnet build "CustomerIdentityService.API.csproj" -c Release -o /app/build

# GIAI ĐOẠN 2: PUBLISH
FROM build AS publish
RUN dotnet publish "CustomerIdentityService.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

# GIAI ĐOẠN 3: RUNTIME (FINAL)
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app

# Chỉ comment những dòng lệnh quan trọng 
# Copy toàn bộ file đã publish vào môi trường chạy 
COPY --from=publish /app/publish .

# Cấu hình Port chạy (Khớp với các service khác trong hệ thống) 
ENV ASPNETCORE_URLS=http://+:80
EXPOSE 80

ENTRYPOINT ["dotnet", "CustomerIdentityService.API.dll"]