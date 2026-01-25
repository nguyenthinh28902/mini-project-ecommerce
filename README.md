# Ecommerce Microservices System

Hệ thống thương mại điện tử kiến trúc Microservices hiện đại, xây dựng trên nền tảng **.NET Core**, sử dụng **YARP** làm API Gateway và cơ chế xác thực bảo mật đa lớp.



## 📌 Kiến trúc hệ thống (Architecture)

Dự án được thiết kế theo mô hình Microservices phân tách biệt lập giữa tầng giao diện (Frontend), tầng điều hướng (Gateway) và tầng nghiệp vụ (Backend Services).

### Luồng xác thực & Bảo mật (Security Flow)
Hệ thống sử dụng cơ chế chuyển đổi định danh (Token Exchange) để tối ưu bảo mật:
* **Client ↔ Gateway**: Sử dụng **Auth Cookie** (HttpOnly, Secure) để bảo mật phía trình duyệt, chống các cuộc tấn công XSS và hỗ trợ tốt cho cơ chế SSR của Nuxt.js.
* **Gateway ↔ Services**: API Gateway đóng vai trò là **Identity Server**, xác thực Cookie và chuyển đổi thành **Internal JWT (JWT 1)** để gửi đến các service backend.
* **Service ↔ Service**: Khi các service giao tiếp nội bộ với nhau, hệ thống sử dụng mã xác thực riêng biệt **(JWT 2)** để đảm bảo tính toàn vẹn và phân quyền giữa các dịch vụ.

---

## 🏗️ Cấu trúc các Repository

### 1. Frontend Layer (Nuxt.js)
| Project | Mô tả | Link Repository |
| :--- | :--- | :--- |
| **ecommerce-web-vue** | Giao diện dành cho khách hàng (Storefront) | [github.com/ecommerce-web-vue](https://github.com/ecommerce-web-vue) |
| **ecommerce-cms-vue** | Hệ thống quản trị nội bộ (Admin Dashboard) | [github.com/ecommerce-cms-vue](https://github.com/ecommerce-cms-vue) |

### 2. API Gateway Layer (YARP)
| Project | Mô tả | Link Repository |
| :--- | :--- | :--- |
| **EcommerceApiGateway** | Gateway điều hướng cho Web & Quản lý Auth Cookie | [github.com/EcommerceApiGateway](https://github.com/EcommerceApiGateway) |
| **EcommerceApiGatewayCMS** | Gateway điều hướng cho CMS & Quản lý Auth Cookie | [github.com/EcommerceApiGatewayCMS](https://github.com/EcommerceApiGatewayCMS) |

### 3. Backend Microservices (.NET Core)
| Service | Database | Link Repository |
| :--- | :--- | :--- |
| **Customer Service** | **Oracle** | [github.com/customer-service](https://github.com/customer-service) |
| **User Service** | SQL Server | [github.com/user-service](https://github.com/user-service) |
| **Product Service** | SQL Server | [github.com/product-service](https://github.com/product-service) |
| **Cart Service** | SQL Server | [github.com/cart-service](https://github.com/cart-service) |
| **Payment Service** | SQL Server | [github.com/payment-service](https://github.com/payment-service) |

---

## 🛠️ Công nghệ sử dụng
* **Backend:** .NET 8, YARP (Yet Another Reverse Proxy), Entity Framework Core.
* **Frontend:** Nuxt 3 (Vue 3), Pinia, Tailwind CSS.
* **Databases:** SQL Server, Oracle (dành riêng cho Customer Service).
* **Security:** Identity Server, JWT (JSON Web Token), Secure Cookies.

---

## ⚙️ Hướng dẫn cài đặt nhanh (Local)

### 1. Yêu cầu hệ thống
* .NET SDK 8.0+
* Node.js 18+ & PNPM/NPM
* SQL Server & Oracle Database instance

### 2. Khởi chạy Backend
1. Cấu hình ConnectionString trong file `appsettings.json` của từng service.
2. Khởi động các Microservices:
   ```bash
   cd [Service-Directory]
   dotnet run