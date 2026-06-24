# Hướng dẫn Triển khai MedPrescribe lên VPS (Ubuntu/Debian)

Tài liệu này hướng dẫn các bước cơ bản để đưa ứng dụng DrugLookup (MedPrescribe) lên một máy chủ ảo (VPS) thật.

## Yêu cầu chuẩn bị
- Một VPS chạy hệ điều hành Ubuntu 20.04 hoặc 22.04.
- Đã cài đặt sẵn **Git**, **Docker**, và **Docker Compose**.
- Đã trỏ tên miền (Domain) về IP của VPS (nếu có sử dụng tên miền).

## Các bước triển khai

### Bước 1: SSH vào VPS
Sử dụng terminal hoặc PuTTY để kết nối vào VPS của bạn:
```bash
ssh root@<IP_VPS_CUA_BAN>
```

### Bước 2: Clone mã nguồn
Clone dự án từ GitHub về VPS (đảm bảo bạn đã cấp quyền truy cập repository nếu đây là private repo):
```bash
git clone https://github.com/QuynhHuong61005/ICCDrupLookup.git
cd ICCDrupLookup
```

### Bước 3: Cấp quyền thực thi cho file script
Cấp quyền để script triển khai tự động có thể chạy được:
```bash
chmod +x deploy.sh
```

### Bước 4: Chạy Script Triển Khai
Chỉ cần chạy file script, hệ thống sẽ tự động kéo code mới nhất, build Docker images và khởi động toàn bộ dịch vụ (Database, Redis, Backend, Frontend, Nginx):
```bash
./deploy.sh
```

### Bước 5: Kiểm tra
Mở trình duyệt và truy cập vào IP của VPS (hoặc tên miền nếu đã trỏ):
- Giao diện web: `http://<IP_VPS_CUA_BAN>/`
- API Backend (Swagger/JSON): `http://<IP_VPS_CUA_BAN>/api/`

---
*Lưu ý: Nếu có chỉnh sửa mã nguồn ở Local, bạn chỉ cần push lên GitHub nhánh main, sau đó SSH vào VPS và chạy lại lệnh `./deploy.sh` là hệ thống sẽ tự cập nhật.*
