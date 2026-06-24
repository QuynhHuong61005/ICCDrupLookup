#!/bin/bash
# Script triển khai MedPrescribe lên VPS tự động

echo "====================================="
echo "   🚀 MEDPRESCRIBE DEPLOYMENT SCRIPT"
echo "====================================="

# 1. Cập nhật source code mới nhất từ GitHub
echo "[1/4] Kéo mã nguồn mới nhất từ nhánh main..."
git checkout main
git pull origin main

# 2. Xây dựng lại các image Docker và bỏ qua cache
echo "[2/4] Build lại Docker Images..."
docker-compose build --no-cache

# 3. Chạy các container ở chế độ background (detached)
echo "[3/4] Khởi động các dịch vụ qua Docker Compose..."
docker-compose up -d

# 4. Kiểm tra trạng thái
echo "[4/4] Kiểm tra trạng thái các container đang chạy..."
docker-compose ps

echo "====================================="
echo "✅ Triển khai hoàn tất! Hệ thống đã sẵn sàng."
echo "Truy cập Frontend: http://<IP_VPS_CUA_BAN>/"
echo "Truy cập Backend API: http://<IP_VPS_CUA_BAN>/api/"
echo "====================================="
