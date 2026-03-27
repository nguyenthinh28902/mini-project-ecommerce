# GIAI ĐOẠN 1: BUILD
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# 1. Copy file .csproj dựa trên đường dẫn tuyệt đối bạn cung cấp
# Đường dẫn nguồn từ context (ecommerce-system): EcommerceIdentityServerCMS/EcommerceIdentityServerCMS/EcommerceIdentityServerCMS/
COPY ["EcommerceIdentityServerCMS/EcommerceIdentityServerCMS/EcommerceIdentityServerCMS/EcommerceIdentityServerCMS.csproj", "EcommerceIdentityServerCMS/"]

# 2. Restore dự án
RUN dotnet restore "EcommerceIdentityServerCMS/EcommerceIdentityServerCMS.csproj"

# 3. Copy toàn bộ mã nguồn
COPY . .

# 4. Build dự án
WORKDIR "/src/EcommerceIdentityServerCMS/EcommerceIdentityServerCMS/EcommerceIdentityServerCMS"
RUN dotnet build "EcommerceIdentityServerCMS.csproj" -c Release -o /app/build

# GIAI ĐOẠN 2: PUBLISH
FROM build AS publish
RUN dotnet publish "EcommerceIdentityServerCMS.csproj" -c Release -o /app/publish /p:UseAppHost=false

# GIAI ĐOẠN 3: RUNTIME (FINAL)
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app

# Chỉ comment những dòng lệnh quan trọng 
# Copy kết quả đã publish vào môi trường chạy
COPY --from=publish /app/publish .

# Cấu hình môi trường chạy
ENV ASPNETCORE_URLS=http://+:80
EXPOSE 80
EXPOSE 443

ENTRYPOINT ["dotnet", "EcommerceIdentityServerCMS.dll"]