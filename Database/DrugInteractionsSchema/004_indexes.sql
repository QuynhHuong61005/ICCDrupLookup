-- Tối ưu hóa tìm kiếm danh mục (Không dùng B-Tree bừa bãi, chuẩn hóa trường dữ liệu thường query)
CREATE INDEX IF NOT EXISTS "idx_icd_code_search" ON "icd_codes" USING btree ("icd_code");
CREATE INDEX IF NOT EXISTS "idx_icd_name_search" ON "icd_codes" USING btree ("disease_name");
CREATE INDEX IF NOT EXISTS "idx_drug_brand_name" ON "drugs" USING btree ("brand_name");
CREATE INDEX IF NOT EXISTS "idx_drug_active_ingredient" ON "drugs" USING btree ("active_ingredient");

-- Sửa lỗi thiếu Index nghiêm trọng trên Foreign Keys để tăng tốc độ JOIN và tránh Lock bảng
CREATE INDEX IF NOT EXISTS "idx_users_role" ON "users" ("role_id");
CREATE INDEX IF NOT EXISTS "idx_users_rank" ON "users" ("rank_id");
CREATE INDEX IF NOT EXISTS "idx_role_permissions_perm" ON "role_permissions" ("permission_id");
CREATE INDEX IF NOT EXISTS "idx_prescriptions_patient" ON "prescriptions" ("patient_id");
CREATE INDEX IF NOT EXISTS "idx_prescriptions_doctor" ON "prescriptions" ("doctor_id");
CREATE INDEX IF NOT EXISTS "idx_prescriptions_icd" ON "prescriptions" ("icd_id");
CREATE INDEX IF NOT EXISTS "idx_details_prescription" ON "prescription_details" ("prescription_id");
CREATE INDEX IF NOT EXISTS "idx_details_drug" ON "prescription_details" ("drug_id");
