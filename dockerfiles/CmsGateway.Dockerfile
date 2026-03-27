# GIAI ĐOẠN 1: BUILD & PUBLISH
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS publish
WORKDIR /src

# Copy file .csproj chuẩn theo cấu trúc folder từ context ecommerce-system
# Lưu ý: Lệnh này giả định bạn đang build từ thư mục gốc của Solution
COPY ["Ecommerce.ApiGateway.Cms/Ecommerce.ApiGateway.Cms/Ecommerce.ApiGateway.Cms.csproj", "Ecommerce.ApiGateway.Cms/Ecommerce.ApiGateway.Cms/"]

# Restore các dependencies
RUN dotnet restore "Ecommerce.ApiGateway.Cms/Ecommerce.ApiGateway.Cms/Ecommerce.ApiGateway.Cms.csproj"

# Copy toàn bộ mã nguồn vào Docker
COPY . .

# Publish ứng dụng ra thư mục /app/publish
# Sử dụng đường dẫn trực tiếp từ WORKDIR /src để tránh nhầm lẫn folder
RUN dotnet publish "Ecommerce.ApiGateway.Cms/Ecommerce.ApiGateway.Cms/Ecommerce.ApiGateway.Cms.csproj" \
    -c Release \
    -o /app/publish \
    /p:UseAppHost=false

# GIAI ĐOẠN 2: RUNTIME (FINAL)
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app

# Copy kết quả đã publish vào môi trường chạy sạch
COPY --from=publish /app/publish .

# Cấu hình Port chạy cho Container
ENV ASPNETCORE_URLS=http://+:80
EXPOSE 80
EXPOSE 443

ENTRYPOINT ["dotnet", "Ecommerce.ApiGateway.Cms.dll"]