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

## 🛠️ Công nghệ sử dụng
* **Backend:** .NET 10, YARP (Yet Another Reverse Proxy), Duende.IdentityServer, Entity Framework Core.
* **Databases:** SQL Server.
* **Security:** Identity Server, JWT (JSON Web Token), Secure Cookies.

## 🔄 Workflow Xác thực trực tiếp (Direct Identity)

### Giai đoạn Đăng nhập (Authentication)
* **Step 1:** Người dùng nhập User/Pass trên Website(Google) hoặc CMS.
* **Step 2:** Client gửi request trực tiếp tới URL của **Identity server**
* **Step 3:** **Identity server** gọi **User Service** sử dụng **EF Core** truy vấn SQL Server để verify tài khoản.
    * Nếu khớp, Service trả về thông tin để **Identity server** tạo **JWT** (chứa Claims UserId).
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
## Hệ thống
### Xác thực

