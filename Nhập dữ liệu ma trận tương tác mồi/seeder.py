# seeder_pipeline.py
import pandas as pd
import uuid
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from models import Base, Drug, DrugInteraction

# Kết nối trực tiếp vào database bạn vừa khởi tạo trên Postgres local
DATABASE_URL = "postgresql+psycopg2://postgres:kookmin1108@127.0.0.1:5432/medprescribe_db"
engine = create_engine(DATABASE_URL, echo=False)
Session = sessionmaker(bind=engine)
session = Session()

def clean_str(val):
    if pd.isna(val):
        return "N/A"
    return str(val).strip()

def run_etl_pipeline():
    print("⏳ Bước 1: Khởi động đường ống đọc các file CSV tương tác quốc tế...")
    intl_files = [
        'ddinter_downloads_code_A.csv',
        'ddinter_downloads_code_R.csv',
        'ddinter_downloads_code_V_dulieutuongtacthuocQuocTe.csv'
    ]
    
    intl_dfs = []
    for f in intl_files:
        try:
            intl_dfs.append(pd.read_csv(f))
            print(f"  -> Đã đọc tệp: {f}")
        except FileNotFoundError:
            print(f"  ⚠️ Không thấy file {f}, tự động bỏ qua.")
            
    if not intl_dfs:
        print("❌ Không tìm thấy tệp dữ liệu quốc tế nào!")
        return

    df_intl_all = pd.concat(intl_dfs).drop_duplicates()
    print(f"  => Tổng số bản ghi tương tác quốc tế thô: {len(df_intl_all)}")

    # 1. Trích xuất danh mục thuốc độc nhất từ nguồn quốc tế
    print("⏳ Bước 2: Chuẩn hóa và chèn danh mục thuốc Master...")
    drugs_a = df_intl_all[['DDInterID_A', 'Drug_A']].rename(columns={'DDInterID_A': 'id', 'Drug_A': 'name'})
    drugs_b = df_intl_all[['DDInterID_B', 'Drug_B']].rename(columns={'DDInterID_B': 'id', 'Drug_B': 'name'})
    unique_drugs = pd.concat([drugs_a, drugs_b]).drop_duplicates(subset=['id'])
    
    drug_uuid_map = {} # Từ điển ghi nhớ để phục vụ gán khóa ngoại ở bước sau
    
    for _, row in unique_drugs.iterrows():
        drug_name = clean_str(row['name'])
        # Đảm bảo tính Idempotent: kiểm tra trùng lặp trước khi chèn
        exists = session.query(Drug).filter_by(ddinter_id=row['id']).first()
        if not exists:
            generated_uuid = uuid.uuid4()
            new_drug = Drug(
                drug_id=generated_uuid,
                ddinter_id=row['id'],
                brand_name=drug_name,
                active_ingredient=drug_name
            )
            session.add(new_drug)
            drug_uuid_map[row['id']] = generated_uuid
        else:
            drug_uuid_map[row['id']] = exists.drug_id
            
    session.commit()
    print(f"  ✔ Hoàn tất nạp {len(drug_uuid_map)} hoạt chất vào bảng 'drugs'.")

    # 2. Nạp quy tắc tương tác thuốc quốc tế
    print("⏳ Bước 3: Nạp ma trận tương tác thuốc quốc tế (Triệt tiêu hoán vị)...")
    intl_count = 0
    for _, row in df_intl_all.iterrows():
        u1 = drug_uuid_map.get(row['DDInterID_A'])
        u2 = drug_uuid_map.get(row['DDInterID_B'])
        
        if not u1 or not u2:
            continue
            
        # Thuật toán ép quy tắc toán học: u1 luôn phải nhỏ hơn u2 để tránh trùng đối xứng (A,B) và (B,A)
        id_first, id_second = (u1, u2) if u1 < u2 else (u2, u1)
        
        severity_clean = str(row['Level']).upper()
        if severity_clean not in ['MINOR', 'MODERATE', 'SEVERE', 'CONTRAINDICATED']:
            severity_clean = 'UNKNOWN'
            
        exists = session.query(DrugInteraction).filter_by(drug1_id=id_first, drug2_id=id_second).first()
        if not exists:
            new_inter = DrugInteraction(
                interaction_id=uuid.uuid4(),
                drug1_id=id_first,
                drug2_id=id_second,
                severity=severity_clean,
                description=f"Cảnh báo tương tác đối kháng quốc tế giữa {row['Drug_A']} và {row['Drug_B']}."
            )
            session.add(new_inter)
            intl_count += 1
            
        if intl_count % 1000 == 0 and intl_count > 0:
            session.commit()
            
    session.commit()
    print(f"  ✔ Hoàn tất nạp {intl_count} luật tương tác thuốc quốc tế.")

    print("⏳ Bước 4: Đọc và tích hợp đồng bộ dữ liệu tương tác thuốc Việt Nam...")
    try:
        df_vn = pd.read_csv('Dữ liệu tương tác thuốc VN.csv')
        vn_count = 0
        for _, row in df_vn.iterrows():
            name_a = clean_str(row.iloc[0]) # Tên thuốc A
            name_b = clean_str(row.iloc[1]) # Tên thuốc B
            mechanism = clean_str(row.iloc[2]) # Cơ chế tương tác
            consequence = clean_str(row.iloc[3]) # Hậu quả lâm sàng
            
            # Khởi tạo thực thể thuốc mới nếu hoạt chất Việt Nam chưa có trong danh mục master quốc tế
            drug_a = session.query(Drug).filter_by(active_ingredient=name_a).first()
            if not drug_a:
                drug_a = Drug(drug_id=uuid.uuid4(), brand_name=name_a, active_ingredient=name_a)
                session.add(drug_a)
                session.commit()
                
            drug_b = session.query(Drug).filter_by(active_ingredient=name_b).first()
            if not drug_b:
                drug_b = Drug(drug_id=uuid.uuid4(), brand_name=name_b, active_ingredient=name_b)
                session.add(drug_b)
                session.commit()
                
            id_first, id_second = (drug_a.drug_id, drug_b.drug_id) if drug_a.drug_id < drug_b.drug_id else (drug_b.drug_id, drug_a.drug_id)
            
            exists = session.query(DrugInteraction).filter_by(drug1_id=id_first, drug2_id=id_second).first()
            if not exists:
                new_vn_inter = DrugInteraction(
                    interaction_id=uuid.uuid4(),
                    drug1_id=id_first,
                    drug2_id=id_second,
                    severity='CONTRAINDICATED', # Bộ Y tế Việt Nam ban hành mặc định là chống chỉ định
                    description=f"Cơ chế: {mechanism}. Hậu quả lâm sàng: {consequence}"
                )
                session.add(new_vn_inter)
                vn_count += 1
                
        session.commit()
        print(f"  ✔ Hoàn tất tích hợp {vn_count} luật tương tác chuẩn Bộ Y Tế Việt Nam.")
    except FileNotFoundError:
        print("  ⚠️ Không tìm thấy file 'Dữ liệu tương tác thuốc VN.csv', bỏ qua.")

    print("=== 🎉 TOÀN BỘ PIPELINE SEEDER ĐÃ HOÀN THÀNH XỬ LÝ AN TOÀN ===")

if __name__ == "__main__":
    try:
        run_etl_pipeline()
    except Exception as e:
        session.rollback()
        print(f"❌ Tiến trình thất bại. Lỗi biên dịch: {str(e)}")
    finally:
        session.close()