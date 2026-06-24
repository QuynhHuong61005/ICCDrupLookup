#!/bin/bash
# Script sao lưu (backup) cơ sở dữ liệu PostgreSQL từ Docker Container

# Cấu hình
CONTAINER_NAME="medprescribe_db"
DB_USER="postgres"
DB_NAME="medprescribe_db"
BACKUP_DIR="./backups"
DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/db_backup_${DATE}.sql"

# Tạo thư mục backups nếu chưa tồn tại
mkdir -p ${BACKUP_DIR}

echo "=========================================="
echo " Bắt đầu sao lưu Database: ${DB_NAME}"
echo " Thời gian: $(date)"
echo "=========================================="

# Thực hiện lệnh pg_dump trong container
docker exec -t ${CONTAINER_NAME} pg_dump -U ${DB_USER} -d ${DB_NAME} -c > ${BACKUP_FILE}

# Kiểm tra kết quả
if [ $? -eq 0 ]; then
    echo "✅ Sao lưu thành công!"
    echo "📂 File backup được lưu tại: ${BACKUP_FILE}"
    
    # Xoá các file backup cũ hơn 7 ngày để tiết kiệm dung lượng
    echo "🗑️  Đang dọn dẹp các file backup cũ hơn 7 ngày..."
    find ${BACKUP_DIR} -name "db_backup_*.sql" -type f -mtime +7 -exec rm {} \;
    echo "✅ Dọn dẹp hoàn tất."
else
    echo "❌ Sao lưu thất bại! Vui lòng kiểm tra lại container ${CONTAINER_NAME}."
    # Xoá file rỗng nếu lỗi
    rm -f ${BACKUP_FILE}
fi

echo "=========================================="
