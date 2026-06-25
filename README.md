# ICCDrupLookup
# MedPrescribe - Hệ thống Hỗ trợ Kê đơn Thuốc Thông minh

## 1. Giới thiệu dự án

MedPrescribe là hệ thống hỗ trợ bác sĩ và dược sĩ trong việc:

* Tra cứu mã bệnh ICD-10
* Tra cứu thông tin thuốc
* Kiểm tra tương tác thuốc
* Kê đơn thuốc điện tử
* Quản lý phân quyền người dùng (RBAC)
* Quản lý hồ sơ cá nhân
* Xác thực 2 lớp (2FA OTP)

Hệ thống được xây dựng nhằm hỗ trợ quá trình kê đơn an toàn, giảm sai sót trong điều trị và nâng cao hiệu quả quản lý dữ liệu y tế.

---

# 2. Công nghệ sử dụng

## Frontend

* Flutter 3.x
* Riverpod
* Go Router
* Dio
* Material 3

## Backend

* NestJS
* TypeScript
* Prisma ORM
* JWT Authentication
* OTP Verification

## Database

* PostgreSQL

---

# 3. Chức năng chính

## Authentication

* Đăng ký tài khoản
* Đăng nhập
* Xác thực OTP (2FA)
* Đăng xuất

## Dashboard

* Thống kê số lượng đơn thuốc
* Thống kê thuốc
* Thống kê bệnh nhân
* Thống kê kiểm tra tương tác thuốc

## ICD-10

* Tìm kiếm ICD
* Xem chi tiết ICD
* Xem hướng dẫn điều trị
* Xem chống chỉ định

## Drug Lookup

* Tìm kiếm thuốc
* Xem chi tiết thuốc
* Thành phần hoạt chất
* Tác dụng phụ
* Chống chỉ định

## Interaction Checker

* Chọn nhiều thuốc
* Kiểm tra tương tác thuốc
* Phân loại mức độ tương tác:

  * Minor
  * Moderate
  * Severe
  * Contraindicated

## Prescription Builder

* Chọn bệnh nhân
* Nhập chẩn đoán ICD
* Thêm thuốc
* Kiểm tra tương tác tự động
* Lưu đơn thuốc

## Role Management

* Quản lý Role
* Quản lý Permission
* RBAC Matrix

---

# 4. Cấu trúc thư mục

```text
Frontend/
│
├── lib/
│   ├── core/
│   ├── features/
│   │   ├── auth/
│   │   ├── dashboard/
│   │   ├── icd/
│   │   ├── drugs/
│   │   ├── interactions/
│   │   ├── prescriptions/
│   │   ├── admin/
│   │   └── profile/
│   │
│   ├── routes/
│   ├── services/
│   └── shared/
│
└── pubspec.yaml
```

---

# 5. Yêu cầu môi trường

## Software

* Flutter SDK 3.x
* Dart SDK
* NodeJS 20+
* PostgreSQL 15+
* Git

## Kiểm tra phiên bản

```bash
flutter --version
dart --version
node -v
npm -v
psql --version
```

---

# 6. Hướng dẫn cài đặt Backend

## Clone source

```bash
git clone <LINK_GITHUB>
cd api-backend-service
```

## Cài đặt package

```bash
npm install
```

## Tạo file môi trường

Tạo file:

```text
.env
```

Ví dụ:

```env
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/medprescribe

JWT_SECRET=medprescribe_secret

PORT=3000
```

## Generate Prisma

```bash
npx prisma generate
```

## Migrate Database

```bash
npx prisma migrate deploy
```

## Seed dữ liệu

```bash
npm run seed
```

## Khởi động Backend

```bash
npm run start:dev
```

Backend chạy tại:

```text
http://localhost:3000
```

---

# 7. Hướng dẫn cài đặt Frontend

Di chuyển vào thư mục frontend:

```bash
cd Frontend
```

## Cài package

```bash
flutter pub get
```

## Chạy ứng dụng

```bash
flutter run -d chrome
```

Hoặc:

```bash
flutter run -d web-server --web-port 8080
```

Frontend chạy tại:

```text
http://localhost:8080
```

---

# 8. Tài khoản Demo

## Tài khoản Bác sĩ

```text
Email:
doctor.demo@test.com

Mật khẩu:
Password123!
```

## OTP Demo

```text
123456
```

---

# 9. Kiểm tra hệ thống

## Flutter Analyze

```bash
flutter analyze
```

## Flutter Test

```bash
flutter test
```

## Prisma Studio

```bash
npx prisma studio
```

---

# 10. Triển khai Production

## Frontend

Build Web:

```bash
flutter build web --release
```

Output:

```text
build/web
```

Deploy lên:

* Vercel
* Netlify
* Firebase Hosting

## Backend

Deploy lên:

* Railway
* Render
* VPS Ubuntu

Build:

```bash
npm run build
```

Run:

```bash
npm run start: prod
```

---

```



---

