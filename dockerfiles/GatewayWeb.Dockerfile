# GIAI ĐOẠN 1: BUILD & PUBLISH
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS publish
WORKDIR /src

# 1. Copy file .csproj đúng cấu trúc từ ecommerce-system
COPY ["Ecom.ApiGateway/Ecom.ApiGateway/Ecom.ApiGateway.csproj", "Ecom.ApiGateway/Ecom.ApiGateway/"]
RUN dotnet restore "Ecom.ApiGateway/Ecom.ApiGateway/Ecom.ApiGateway.csproj"

# 2. Copy toàn bộ mã nguồn
COPY . . 

# 3. Publish trực tiếp ra thư mục /app/publish
WORKDIR "/src/Ecom.ApiGateway/Ecom.ApiGateway"
RUN dotnet publish "Ecom.ApiGateway.csproj" -c Release -o /app/publish /p:UseAppHost=false

# GIAI ĐOẠN 2: RUNTIME (FINAL)
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
EXPOSE 80
EXPOSE 443

# 4. Copy kết quả đã publish vào thư mục /app hiện tại 
COPY --from=publish /app/publish .

# 5. Copy các file YAML cấu hình vào cùng cấp với file .dll 
# Lưu ý: Lệnh này lấy file từ context build (ecommerce-system)
COPY Ecom.ApiGateway/Ecom.ApiGateway/proxy-config-*.yaml ./ 

ENTRYPOINT ["dotnet", "Ecom.ApiGateway.dll"]