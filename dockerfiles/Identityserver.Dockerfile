#cd D:\2026\Project\ecommerce-system
#docker build -f D:\2026\Project\mini-project-ecommerce\dockerfiles\Identityserver.Dockerfile -t identityserver-service:v1 .
# --- GIAI ĐOẠN 1: BUILD ---
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# 1. Copy file .csproj (Bắt đầu từ thư mục gốc ecommerce-system)
COPY ["Ecom.IdentityServer/Ecom.IdentityServer/Ecom.IdentityServer.csproj", "Ecom.IdentityServer/Ecom.IdentityServer/"]

# 2. Restore trỏ đúng vào file đã copy
RUN dotnet restore "Ecom.IdentityServer/Ecom.IdentityServer/Ecom.IdentityServer.csproj"

# 3. Copy toàn bộ mã nguồn từ máy thật vào
COPY . .

# 4. Di chuyển vào thư mục dự án để Build
WORKDIR "/src/Ecom.IdentityServer/Ecom.IdentityServer"
RUN dotnet build "Ecom.IdentityServer.csproj" -c Release -o /app/build

# --- GIAI ĐOẠN 2: PUBLISH ---
FROM build AS publish
RUN dotnet publish "Ecom.IdentityServer.csproj" -c Release -o /app/publish /p:UseAppHost=false

# --- GIAI ĐOẠN 3: RUNTIME ---
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app

# Copy kết quả build
COPY --from=publish /app/publish .

# Cấu hình môi trường chạy
ENV ASPNETCORE_URLS=http://+:80
EXPOSE 80
EXPOSE 443

ENTRYPOINT ["dotnet", "Ecom.IdentityServer.dll"]