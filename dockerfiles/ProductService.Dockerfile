#cd D:\2026\Project\ecommerce-system
#docker build -f D:\2026\Project\mini-project-ecommerce\dockerfiles\{{namefiel}}.Dockerfile -t {{nameservice}}-service:v1 .
#docker run -d ` --name product-service ` -p 8080:80 ` -e ConnectionStrings__EcommerceProduct="Data Source=host.docker.internal,1433;Persist Security Info=True;User ID=demo;Password=Thinh@zzxx9;Trust Server Certificate=True;Initial Catalog=ecom_product_db; " ` product-service:v1

# --- GIAI ĐOẠN 1: BUILD ---
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# 1. Copy các file .csproj (Giữ nguyên cấu trúc thư mục để restore không lỗi)
# Lưu ý: Bên trái là máy thật, bên phải là đường dẫn trong Docker
COPY ["Ecom.ProductService/Ecom.ProductService/Ecom.ProductService.csproj", "Ecom.ProductService/Ecom.ProductService/"]
COPY ["Ecom.ProductService/Ecom.ProductService.Application/Ecom.ProductService.Application.csproj", "Ecom.ProductService.Application/"]
COPY ["Ecom.ProductService/Ecom.ProductService.Core/Ecom.ProductService.Core.csproj", "Ecom.ProductService.Core/"]
COPY ["Ecom.ProductService/Ecom.ProductService.Infrastructure/Ecom.ProductService.Infrastructure.csproj", "Ecom.ProductService.Infrastructure/"]

# 2. Restore gói NuGet trỏ đúng vào file Startup Project
RUN dotnet restore "Ecom.ProductService/Ecom.ProductService/Ecom.ProductService.csproj"

# 3. Copy toàn bộ code (Lúc này mới copy code để tận dụng cache layer trên)
COPY . .

# 4. Di chuyển vào thư mục chứa file .csproj chính để Build
WORKDIR "/src/Ecom.ProductService/Ecom.ProductService"
RUN dotnet build "Ecom.ProductService.csproj" -c Release -o /app/build

# --- GIAI ĐOẠN 2: PUBLISH ---
FROM build AS publish
RUN dotnet publish "Ecom.ProductService.csproj" -c Release -o /app/publish /p:UseAppHost=false

# --- GIAI ĐOẠN 3: RUNTIME ---
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app

# Copy toàn bộ file cấu hình (bao gồm cả các file .yaml nếu có)
COPY --from=publish /app/publish .

# Cấu hình môi trường
ENV ASPNETCORE_URLS=http://+:80
EXPOSE 80

ENTRYPOINT ["dotnet", "Ecom.ProductService.dll"]