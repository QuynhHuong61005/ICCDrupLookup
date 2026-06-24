-- 1. Hạng chức danh / Y tế
CREATE TABLE IF NOT EXISTS "medical_ranks" (
    "rank_id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "rank_name" VARCHAR(100) UNIQUE NOT NULL,
    "description" VARCHAR(255),
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 2. Quyền
CREATE TABLE IF NOT EXISTS "permissions" (
    "permission_id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "permission_name" VARCHAR(100) UNIQUE NOT NULL,
    "description" VARCHAR(255),
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 3. Vai trò
CREATE TABLE IF NOT EXISTS "roles" (
    "role_id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "role_name" VARCHAR(50) UNIQUE NOT NULL,
    "description" VARCHAR(255),
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 4. Bảng trung gian Vai trò - Quyền
CREATE TABLE IF NOT EXISTS "role_permissions" (
    "role_id" UUID NOT NULL REFERENCES "roles"("role_id") ON DELETE CASCADE,
    "permission_id" UUID NOT NULL REFERENCES "permissions"("permission_id") ON DELETE CASCADE,
    PRIMARY KEY ("role_id", "permission_id")
);

-- 5. Người dùng (Bác sĩ, Nhân viên)
CREATE TABLE IF NOT EXISTS "users" (
    "user_id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "full_name" VARCHAR(255) NOT NULL,
    "email" VARCHAR(255) UNIQUE NOT NULL,
    "password_hash" VARCHAR(255) NOT NULL,
    "role_id" UUID NOT NULL REFERENCES "roles"("role_id"),
    "rank_id" UUID REFERENCES "medical_ranks"("rank_id") ON DELETE SET NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT TRUE,
    "otp_secret" VARCHAR(255),
    "otp_enabled" BOOLEAN NOT NULL DEFAULT FALSE,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 6. Bệnh nhân
CREATE TABLE IF NOT EXISTS "patients" (
    "patient_id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "full_name" VARCHAR(255) NOT NULL,
    "dob" DATE NOT NULL,
    "gender" "Gender" NOT NULL,
    "phone" VARCHAR(20) UNIQUE NOT NULL,
    "address" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 7. Danh mục mã ICD-10
CREATE TABLE IF NOT EXISTS "icd_codes" (
    "icd_id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "icd_code" VARCHAR(20) UNIQUE NOT NULL,
    "disease_name" VARCHAR(255) NOT NULL,
    "disease_group" VARCHAR(255) NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 8. Danh mục thuốc
CREATE TABLE IF NOT EXISTS "drugs" (
    "drug_id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "brand_name" VARCHAR(255) NOT NULL,
    "active_ingredient" VARCHAR(255) NOT NULL,
    "concentration" VARCHAR(100) NOT NULL,
    "dosage_form" VARCHAR(100) NOT NULL,
    "manufacturer" VARCHAR(255) NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 9. Tương tác thuốc
CREATE TABLE IF NOT EXISTS "drug_interactions" (
    "interaction_id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "drug1_id" UUID NOT NULL REFERENCES "drugs"("drug_id") ON DELETE CASCADE,
    "drug2_id" UUID NOT NULL REFERENCES "drugs"("drug_id") ON DELETE CASCADE,
    "severity" "Severity" NOT NULL,
    "description" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "unique_drug_pair" UNIQUE ("drug1_id", "drug2_id"),
    CONSTRAINT "chk_drug_order" CHECK ("drug1_id" < "drug2_id")
);

-- 10. Phác đồ / Ánh xạ ICD - Thuốc
CREATE TABLE IF NOT EXISTS "icd_drug_mappings" (
    "mapping_id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "icd_id" UUID NOT NULL REFERENCES "icd_codes"("icd_id") ON DELETE CASCADE,
    "drug_id" UUID NOT NULL REFERENCES "drugs"("drug_id") ON DELETE CASCADE,
    "standard_dosage" TEXT NOT NULL,
    "bhyt_status" BOOLEAN NOT NULL DEFAULT TRUE,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "unique_icd_drug" UNIQUE ("icd_id", "drug_id")
);

-- 11. Đơn thuốc
CREATE TABLE IF NOT EXISTS "prescriptions" (
    "prescription_id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "patient_id" UUID NOT NULL REFERENCES "patients"("patient_id"),
    "doctor_id" UUID NOT NULL REFERENCES "users"("user_id"),
    "icd_id" UUID REFERENCES "icd_codes"("icd_id"), -- Thêm liên kết trực tiếp mã bệnh chính
    "diagnosis_note" TEXT NOT NULL,
    "status" "PrescriptionStatus" NOT NULL DEFAULT 'DRAFT',
    "created_by" UUID NOT NULL REFERENCES "users"("user_id"),
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 12. Chi tiết đơn thuốc
CREATE TABLE IF NOT EXISTS "prescription_details" (
    "detail_id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "prescription_id" UUID NOT NULL REFERENCES "prescriptions"("prescription_id") ON DELETE CASCADE,
    "drug_id" UUID NOT NULL REFERENCES "drugs"("drug_id"),
    "dosage" VARCHAR(255) NOT NULL,
    "quantity" INTEGER NOT NULL CONSTRAINT "chk_quantity_positive" CHECK ("quantity" > 0),
    "note" TEXT,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 13. Hệ thống kiểm toán (Audit Logs)
CREATE TABLE IF NOT EXISTS "audit_logs" (
    "audit_id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "user_id" UUID REFERENCES "users"("user_id") ON DELETE SET NULL,
    "action" VARCHAR(100) NOT NULL,
    "table_name" VARCHAR(100) NOT NULL,
    "record_id" VARCHAR(100),
    "old_values" JSONB,
    "new_values" JSONB,
    "ip_address" VARCHAR(45),
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);
