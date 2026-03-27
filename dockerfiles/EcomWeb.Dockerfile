# GIAI ĐOẠN 1: BUILD
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# 1. Copy các file .csproj và giữ đúng cấu trúc folder để các project reference không bị lỗi
COPY ["Ecom.Web/Ecom.Web/Ecom.Web.csproj", "Ecom.Web/Ecom.Web/"]
COPY ["Ecom.Web/Ecom.Web.Shared/Ecom.Web.Shared.csproj", "Ecom.Web/Ecom.Web.Shared/"]
COPY ["Ecom.Web/Ecom.Application.Authentication/Ecom.Application.Authentication.csproj", "Ecom.Web/Ecom.Application.Authentication/"]
COPY ["Ecom.Web/Ecom.Application.Customer/Ecom.Application.Customer.csproj", "Ecom.Web/Ecom.Application.Customer/"]
COPY ["Ecom.Web/Ecom.Application.Order/Ecom.Application.Order.csproj", "Ecom.Web/Ecom.Application.Order/"]
COPY ["Ecom.Web/Ecom.Application.Payment/Ecom.Application.Payment.csproj", "Ecom.Web/Ecom.Application.Payment/"]
COPY ["Ecom.Web/Ecom.Application.Product/Ecom.Application.Product.csproj", "Ecom.Web/Ecom.Application.Product/"]
COPY ["Ecom.Web/Ecom.Application.User/Ecom.Application.User.csproj", "Ecom.Web/Ecom.Application.User/"]

# 2. Restore các dependencies dựa trên đường dẫn folder chính xác
RUN dotnet restore "Ecom.Web/Ecom.Web/Ecom.Web.csproj"

# 3. Copy toàn bộ mã nguồn vào container
COPY . .

# 4. Publish ứng dụng
# Chuyển vào đúng thư mục chứa file .csproj chính
WORKDIR "/src/Ecom.Web/Ecom.Web"
RUN dotnet publish "Ecom.Web.csproj" -c Release -o /app/publish /p:UseAppHost=false

# GIAI ĐOẠN 2: RUNTIME
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app

# Chỉ comment những dòng lệnh quan trọng
# Copy kết quả đã publish từ giai đoạn build vào thư mục chạy
COPY --from=build /app/publish .

# Cấu hình Port chạy mặc định
ENV ASPNETCORE_URLS=http://+:80
EXPOSE 80
EXPOSE 443

ENTRYPOINT ["dotnet", "Ecom.Web.dll"]