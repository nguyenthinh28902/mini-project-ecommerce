# Ecommerce System
Dự án hệ thống thương mại điện tử
#### Dự án còn đang phát triển chưa hoàn thành nhiều tính năng nghiệp vụ (tạo dữ liệu mẫu để test).
## Cấu trúc dự án
### 1. Website  (Mvc)
| Project | Mô tả | Link Repository |
| :--- | :--- | :--- |
| **ecommerce-web** | Giao diện dành cho khách hàng | [github.com/Ecom.Web](https://github.com/nguyenthinh28902/ecommerce-web) |
| **ecommerce-cms-web** | Hệ thống quản trị nội bộ (Admin Dashboard) | [github.com/Ecom.Cms](https://github.com/nguyenthinh28902/ecommerce-cms-web)|

### 2. Identity server (Duende.IdentityServer)
| Project | Mô tả | Link Repository |
| :--- | :--- | :--- |
| **Web IdentityServer** | Xác thực thông tin khách hàng | [github.com/Ecom.Web.Identityserver](https://github.com/nguyenthinh28902/ecommerce-web-identityserver) |
| **CMS IdentityServer** | Xác thực thông tin quản trị | [github.com/Ecom.Cms.Identityserver](https://github.com/nguyenthinh28902/ecommerce-identity-server-cms) |

### 3. API Gateway Layer (YARP)
| Project | Mô tả | Link Repository |
| :--- | :--- | :--- |
| **ApiGateway** | Gateway điều hướng cho Website khách hàng | [github.com/ecommerce-api-gateway](https://github.com/nguyenthinh28902/ecommerce-api-gateway) |
| **ApiGateway CMS** | Gateway điều hướng cho CMS | [github.com/ecommerce-api-gateway-cms](https://github.com/nguyenthinh28902/ecommerce-api-gateway-cms) |

### 4. Backend Microservices (.NET Api Core)
| Service | Mô tả | Link Repository |
| :--- | :--- | :--- |
| **Customer Service** | Thông tin khách hàng | [github.com/ecommerce-customer-service](https://github.com/nguyenthinh28902/ecommerce-customer-service) |
| **User Service** | Thông tin quản trị | [github.com/ecommerce-identity-cms](https://github.com/nguyenthinh28902/ecommerce-identity-cms) |
| **Product Service** | Quản lý thông tin sản phẩm | [github.com/Ecom.ProductService](https://github.com/nguyenthinh28902/Ecom.ProductService) |
| **Order Service** | Quản lý thông tin đặt hàng, thông tin giỏ hàng | [github.com/Ecom.OrderService](https://github.com/nguyenthinh28902/ecom-order-service) |
| **Payment Service** | Quản lý thông tin giao dịch | [github.com/Ecom.PaymentService](https://github.com/nguyenthinh28902/ecom-payment) |
| **Notification Service** | Quản lý thông báo | [github.com/Ecom.Notification](https://github.com/nguyenthinh28902/ecom-notification-service) |
### 5. Sơ đồ hệ thống
![Sơ đồ hệ thống](system-design-core-backend-services.png)
---
### 6.Mô tả
---
#### 1. Tầng Giao diện & Người dùng (Client Layer)
Hệ thống cung cấp hai giao diện người dùng tách biệt để đảm bảo tính bảo mật và trải nghiệm chuyên biệt:
* **Web MVC (Khách hàng):** Cổng tương tác trực tiếp dành cho người dùng cuối (mua sắm, xem sản phẩm, thanh toán).
* **CMS MVC (Quản trị):** Công cụ quản trị nội bộ dành cho nhân viên vận hành quản lý hệ thống.

---

#### 2. Tầng Bảo mật & Điều hướng (Entry Points)

###### **Identity Server (Duende)**
* Đóng vai trò là trung tâm xác thực (Identity Provider), nằm ngang hàng với Gateway.
* Tiếp nhận và xử lý yêu cầu xác thực trực tiếp từ cả hai ứng dụng Web MVC.
* **Cơ chế truy vấn:** Khi cần lấy dữ liệu để xác thực (từ User hoặc Customer Service), Identity Server sẽ gửi request thông qua **API Gateway** thay vì gọi trực tiếp vào database của service đó.

###### **API Gateway (YARP)**
Hệ thống sử dụng **YARP (Yet Another Reverse Proxy)** để điều hướng luồng yêu cầu với hai cổng riêng biệt:
* **ApiGateway (Web):** Điều hướng tới các dịch vụ: `Customer`, `Product`, `Order`, `Payment`, `Notification`. *Lưu ý: Chặn hoàn toàn quyền truy cập tới User Service.*
* **ApiGateway CMS:** Cho phép điều hướng tới toàn bộ 6 dịch vụ Backend.

---

#### 3. Tầng Dịch vụ lõi (Backend Microservices)
Các dịch vụ được phát triển độc lập bằng **.NET Core API**, bao gồm:
* **Customer Service:** Quản lý thông tin và hồ sơ khách hàng.
* **User Service:** Quản lý thông tin tài khoản nhân sự quản trị hệ thống.
* **Product Service:** Quản lý danh mục, thông tin và tồn kho sản phẩm.
* **Order Service:** Xử lý quy trình đặt hàng và quản lý giỏ hàng.
* **Payment Service:** Xử lý các giao dịch thanh toán.
* **Notification Service:** Chịu trách nhiệm gửi thông báo (Email, SMS, Push Notification).

---

#### 4. Luồng giao tiếp (Communication Patterns)

###### **Giao tiếp giữa các tầng (Inter-layer)**
Sử dụng tiêu chuẩn **REST API (HTTP)** cho tất cả các yêu cầu từ Client tới Identity/Gateway và từ Gateway tới các Service.

###### **Giao tiếp giữa các dịch vụ (Inter-service)**
Để tối ưu hóa hiệu suất và đảm bảo tính nhất quán dữ liệu, hệ thống sử dụng kết hợp hai phương thức:
* **Đồng bộ (Synchronous):** Sử dụng **gRPC** cho các tác vụ cần phản hồi tức thì (Ví dụ: `Order Service` gọi `Product Service` để kiểm tra giá và tồn kho).
* **Bất đồng bộ (Asynchronous):** Sử dụng **RabbitMQ** làm Message Broker. Các dịch vụ nghiệp vụ đẩy sự kiện (Events) vào hàng đợi.
* **Tiêu thụ dữ liệu:** `Notification Service` lắng nghe các sự kiện từ RabbitMQ để thực hiện nhiệm vụ, đảm bảo không làm nghẽn luồng xử lý chính (không sử dụng gRPC cho dịch vụ này).

---

#### 5. Tầng Dữ liệu (Persistence Layer)
* **Chiến lược:** Áp dụng mô hình **Database per Service** để đảm bảo tính độc lập và khả năng mở rộng riêng lẻ.
* **Công nghệ:** Sử dụng **SQL Server**.
* **Quy mô:** Tổng cộng 8 Database riêng biệt (6 cho các Microservices và 2 cho các Identity Servers).

---

> **Ghi chú:** Đây là tài liệu thiết kế mức cao (High-level Design). Vui lòng tham khảo mã nguồn chi tiết trong từng Repository tương ứng để biết thêm về cấu hình triển khai.
## 🛠️ Công nghệ sử dụng
* **Backend:** .NET 10, YARP (Yet Another Reverse Proxy), Duende.IdentityServer, Entity Framework Core.
* **Databases:** SQL Server.
* **Security:** Identity Server, JWT (JSON Web Token), Secure Cookies.

## 🔄 Workflow hệ thống

### Workflow áp dụng cho toàn hệ thống (Authentication)
* **Step 1:** Người dùng nhập User/Pass trên Website(Google) hoặc CMS.
* **Step 2:** Client gửi request trực tiếp tới URL của **Identity server**
* **Step 3:** **Identity server** gọi **User Service** sử dụng **EF Core** truy vấn SQL Server để verify tài khoản.
    * Nếu khớp, Service trả về thông tin để **Identity server** tạo **JWT** (chứa Claims UserId).
    * Khi truy vấn identity vẫn dùng token nội bộ.
* **Step 4:** Token được trả trực tiếp về Client.
* **Step 5:** Client call api khi đi qua gateway, gateway sẻ gọi để đổi token nội bộ để đi tiếp (Token Service-to-Service).
### 🔑 Chi tiết Access Token (Ví dụ)

**Token nội bộ**

Dưới đây là cấu trúc JWT được cấp cho `APIGatewayCMS` sau khi giải mã:

```json
{
  "header": {
    "alg": "RS256",
    "kid": "2BF45F2C062C3F7CFD022EC23707CA44",
    "typ": "at+jwt"
  },
  "payload": {
    "iss": "https://localhost:7133",
    "nbf": 1772364222,
    "iat": 1772364222,
    "exp": 1772364522,
    "aud": [
      "product.api",
      "user.api"
    ],
    "scope": [
      "order.internal",
      "payment.internal",
      "product.internal",
      "stock.internal",
      "user.internal"
    ],
    "client_id": "APIGatewayCMS",
    "jti": "BFD5E2A71BAA5E154829B250C01D6202"
  }
}
```

**Token client**

Dưới đây là cấu trúc JWT được cấp cho `cms_admin_client` sau khi giải mã:

```json
{
  "header": {
    "alg": "RS256",
    "kid": "2BF45F2C062C3F7CFD022EC23707CA44",
    "typ": "at+jwt"
  },
  "payload": {
    "iss": "https://localhost:7133",
    "exp": 1772367854,
    "aud": [
      "user.api",
      "product.api"
    ],
    "scope": [
      "openid",
      "profile",
      "email",
      "user.read",
      "user.write",
      "product.read",
      "order.write"
    ],
    "client_id": "cms_admin_client",
    "sub": "4",
    "jti": "61A2B07D501D7467092830BFFB4F661C"
  }
}
```

### Workflow chi tiết


