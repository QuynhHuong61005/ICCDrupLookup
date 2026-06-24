# test_connection.py
from sqlalchemy import create_engine, text

# URL kết nối cục bộ hoàn toàn thông suốt của bạn
DATABASE_URL = "postgresql+psycopg2://postgres:kookmin1108@127.0.0.1:5432/medprescribe_db"

def check_database_connection():
    print("⏳ Đang gửi tín hiệu kết nối đến PostgreSQL...")
    try:
        # 1. Khởi tạo engine kết nối với cấu hình chặn timeout sau 5 giây
        engine = create_engine(DATABASE_URL, connect_args={'connect_timeout': 5})
        
        # 2. Sử dụng connection context để thực thi các câu lệnh an toàn
        with engine.connect() as connection:
            result = connection.execute(text("SELECT 1"))
            response = result.scalar()
            
            if response == 1:
                print("==================================================")
                print("🎉 KẾT NỐI THÀNH CÔNG! Backend Python đã làm chủ Database.")
                print("==================================================")
                
                # SỬA LỖI: Dùng connection.execute và text() theo chuẩn SQLAlchemy
                # Kiểm tra số lượng bản ghi của bảng mã bệnh ICD-10
                res_icd = connection.execute(text('SELECT COUNT(*) FROM "icd10_v2"'))
                print("Mã bệnh ICD-10 hiện có:", res_icd.scalar())

                # Kiểm tra số lượng thuốc master
                res_drugs = connection.execute(text('SELECT COUNT(*) FROM "drugs"'))
                print("Danh mục thuốc Master hiện có:", res_drugs.scalar())

                # Kiểm tra số lượng quy tắc tương tác đối kháng thuốc (84804 bản ghi)
                res_inter = connection.execute(text('SELECT COUNT(*) FROM "drug_interactions"'))
                print("Quy tắc tương tác đối kháng thuốc:", res_inter.scalar())

                print("==================================================")
                
    except Exception as e:
        print("==================================================")
        print("❌ KẾT NỐI THẤT BẠI! Không thể thông sang Database.")
        print(f"🔍 Chi tiết lỗi hệ thống: {str(e)}")
        print("==================================================")
        print("💡 Gợi ý khắc phục:")
        print("  1. Hãy chắc chắn dịch vụ PostgreSQL trên máy đang ở trạng thái RUNNING.")
        print("  2. Kiểm tra xem mật khẩu 'kookmin1108' và tên DB 'medprescribe_db' gõ đúng chưa.")

if __name__ == "__main__":
    check_database_connection()