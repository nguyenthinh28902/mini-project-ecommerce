# 🛒 Ecommerce Microservices System

Hệ thống thương mại điện tử kiến trúc Microservices, tập trung vào giải pháp bảo mật và tối ưu hóa hiệu năng giao tiếp nội bộ.

![Sơ đồ hệ thống](system-design-core-backend-services.png)

### 🏗️ Kiến trúc & Công nghệ (Tech Stack)

* **Core Framework:** .NET 10, Entity Framework Core.
* **Infrastructure:** YARP API Gateway, Duende.IdentityServer.
* **Databases:** SQL Server (Mô hình **Database per Service** - 8 DB riêng biệt).
* **Giao tiếp:** gRPC (Đồng bộ), RabbitMQ (Bất đồng bộ - Event-driven).
* **Caching & Security:** Redis, JWT, Secure Cookies, OIDC.

---

### 🛡️ Giải pháp Bảo mật & Xác thực

![System Workflows](system-workflow-authentication.png)

* **Identity Server (IdP):** Xác thực tập trung OIDC/OAuth2, tách biệt luồng Web và CMS.
* **Two-tier Authorization:** Phân quyền qua **Scopes** (ứng dụng) và **Claims/Roles** (người dùng).
* **Token Exchange:** Gateway hoán đổi Public Token thành **Internal JWT** trước khi vào nội bộ.
* **Header Enrichment:** Tự động gán `X-User-Id`, `X-User-Email` vào Header để định danh ngữ cảnh.

---

### 📡 Giao tiếp & Hiệu năng

* **Inter-service:** Sử dụng **gRPC** truy vấn tồn kho thời gian thực và **RabbitMQ** xử lý sự kiện đơn hàng.
* **Caching:** Triển khai **Cache-Aside** với Redis (`IUserCacheService`) tối ưu truy vấn định danh.
* **Background Worker:** `Notification Service` tiêu thụ sự kiện từ hàng đợi để xử lý thông báo ngầm.

---

### 🔗 Chi tiết Triển khai (Technical Links)

* **Client Security:** OIDC Middleware & Cookie bảo mật tại [Web CMS](https://github.com/nguyenthinh28902/ecommerce-cms-web).
* **Identity Provider:** Định nghĩa Resources/Scopes và Custom Profile Service tại [Identity Server](https://github.com/nguyenthinh28902/ecommerce-identity-server-cms).
* **Gateway Routing:** Reverse Proxy và Auth Policy tại [YARP Gateway](https://github.com/nguyenthinh28902/ecommerce-api-gateway-cms).
* **Service Auth:** JWT Bearer & Policy-based Authorization tại [Product Service](https://github.com/nguyenthinh28902/Ecom.ProductService).
