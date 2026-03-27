# GIAI ĐOẠN 1: BUILD
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# 1. Copy các file .csproj và giữ nguyên cấu trúc folder để restore không bị lỗi path 
COPY ["Ecom.Cms.Web/Ecom.Cms.Web/Ecom.Cms.Web.csproj", "Ecom.Cms.Web/Ecom.Cms.Web/"]
COPY ["Ecom.Cms.Web/Ecom.Cms.Web.Shared/Ecom.Cms.Web.Shared.csproj", "Ecom.Cms.Web/Ecom.Cms.Web.Shared/"]
COPY ["Ecom.Cms.Web/Ecom.Cms.Application.Authentication/Ecom.Cms.Application.Authentication.csproj", "Ecom.Cms.Web/Ecom.Cms.Application.Authentication/"]
COPY ["Ecom.Cms.Web/Ecom.Cms.Application.Order/Ecom.Cms.Application.Order.csproj", "Ecom.Cms.Web/Ecom.Cms.Application.Order/"]
COPY ["Ecom.Cms.Web/Ecom.Cms.Application.Product/Ecom.Cms.Application.Product.csproj", "Ecom.Cms.Web/Ecom.Cms.Application.Product/"]
COPY ["Ecom.Cms.Web/Ecom.Cms.Application.User/Ecom.Cms.Application.User.csproj", "Ecom.Cms.Web/Ecom.Cms.Application.User/"]

# 2. Restore dựa trên đường dẫn chính xác đã copy ở trên 
RUN dotnet restore "Ecom.Cms.Web/Ecom.Cms.Web/Ecom.Cms.Web.csproj"

# 3. Copy toàn bộ mã nguồn vào container
COPY . .

# 4. Chuyển vào đúng thư mục chứa project chính để thực hiện Publish 
WORKDIR "/src/Ecom.Cms.Web/Ecom.Cms.Web"
RUN dotnet publish "Ecom.Cms.Web.csproj" -c Release -o /app/publish /p:UseAppHost=false

# GIAI ĐOẠN 2: RUNTIME
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app

# Chỉ comment những dòng lệnh quan trọng
# Copy kết quả build từ giai đoạn 1 sang môi trường runtime
COPY --from=build /app/publish .

# Cấu hình Port chạy mặc định 
ENV ASPNETCORE_URLS=http://+:80
EXPOSE 80
EXPOSE 443

ENTRYPOINT ["dotnet", "Ecom.Cms.Web.dll"]