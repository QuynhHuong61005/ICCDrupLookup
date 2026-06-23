-- ==========================================
-- MEDPRESCRIBE POSTGRESQL SCHEMA DDL
-- ==========================================

-- 1. Create ENUM Types
CREATE TYPE "Gender" AS ENUM ('MALE', 'FEMALE', 'OTHER');
CREATE TYPE "Severity" AS ENUM ('MINOR', 'MODERATE', 'SEVERE', 'CONTRAINDICATED');
CREATE TYPE "PrescriptionStatus" AS ENUM ('DRAFT', 'ACTIVE', 'COMPLETED', 'CANCELLED');

-- 2. Create Tables

-- roles table
CREATE TABLE "roles" (
    "role_id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "role_name" VARCHAR(50) UNIQUE NOT NULL,
    "description" VARCHAR(255),
    "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- permissions table
CREATE TABLE "permissions" (
    "permission_id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "permission_name" VARCHAR(100) UNIQUE NOT NULL,
    "description" VARCHAR(255),
    "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- role_permissions join table
CREATE TABLE "role_permissions" (
    "role_id" UUID NOT NULL REFERENCES "roles"("role_id") ON DELETE CASCADE,
    "permission_id" UUID NOT NULL REFERENCES "permissions"("permission_id") ON DELETE CASCADE,
    PRIMARY KEY ("role_id", "permission_id")
);

-- users table
CREATE TABLE "users" (
    "user_id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "full_name" VARCHAR(255) NOT NULL,
    "email" VARCHAR(255) UNIQUE NOT NULL,
    "password_hash" VARCHAR(255) NOT NULL,
    "role_id" UUID NOT NULL REFERENCES "roles"("role_id"),
    "is_active" BOOLEAN NOT NULL DEFAULT TRUE,
    "otp_secret" VARCHAR(255),
    "otp_enabled" BOOLEAN NOT NULL DEFAULT FALSE,
    "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- patients table
CREATE TABLE "patients" (
    "patient_id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "full_name" VARCHAR(255) NOT NULL,
    "dob" DATE NOT NULL,
    "gender" "Gender" NOT NULL,
    "phone" VARCHAR(20) UNIQUE NOT NULL,
    "address" TEXT NOT NULL,
    "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- icd_codes table
CREATE TABLE "icd_codes" (
    "icd_id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "icd_code" VARCHAR(20) UNIQUE NOT NULL,
    "disease_name" VARCHAR(255) NOT NULL,
    "disease_group" VARCHAR(255) NOT NULL,
    "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- drugs table
CREATE TABLE "drugs" (
    "drug_id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "brand_name" VARCHAR(255) NOT NULL,
    "active_ingredient" VARCHAR(255) NOT NULL,
    "concentration" VARCHAR(100) NOT NULL,
    "dosage_form" VARCHAR(100) NOT NULL,
    "manufacturer" VARCHAR(255) NOT NULL,
    "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- drug_interactions table
CREATE TABLE "drug_interactions" (
    "interaction_id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "drug1_id" UUID NOT NULL REFERENCES "drugs"("drug_id") ON DELETE CASCADE,
    "drug2_id" UUID NOT NULL REFERENCES "drugs"("drug_id") ON DELETE CASCADE,
    "severity" "Severity" NOT NULL,
    "description" TEXT NOT NULL,
    "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "unique_drug_pair" UNIQUE ("drug1_id", "drug2_id"),
    -- Rule: drug1_id must always be smaller than drug2_id to prevent duplicates/mirror entries
    CONSTRAINT "chk_drug_order" CHECK ("drug1_id" < "drug2_id")
);

-- icd_drug_mappings table
CREATE TABLE "icd_drug_mappings" (
    "mapping_id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "icd_id" UUID NOT NULL REFERENCES "icd_codes"("icd_id") ON DELETE CASCADE,
    "drug_id" UUID NOT NULL REFERENCES "drugs"("drug_id") ON DELETE CASCADE,
    "standard_dosage" TEXT NOT NULL,
    "bhyt_status" BOOLEAN NOT NULL DEFAULT TRUE,
    "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "unique_icd_drug" UNIQUE ("icd_id", "drug_id")
);

-- prescriptions table
CREATE TABLE "prescriptions" (
    "prescription_id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "patient_id" UUID NOT NULL REFERENCES "patients"("patient_id"),
    "doctor_id" UUID NOT NULL REFERENCES "users"("user_id"),
    "diagnosis_note" TEXT NOT NULL,
    "status" "PrescriptionStatus" NOT NULL DEFAULT 'DRAFT',
    "created_by" UUID NOT NULL REFERENCES "users"("user_id"),
    "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- prescription_details table
CREATE TABLE "prescription_details" (
    "detail_id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "prescription_id" UUID NOT NULL REFERENCES "prescriptions"("prescription_id") ON DELETE CASCADE,
    "drug_id" UUID NOT NULL REFERENCES "drugs"("drug_id"),
    "dosage" VARCHAR(255) NOT NULL,
    "quantity" INTEGER NOT NULL CHECK ("quantity" > 0),
    "note" TEXT,
    "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- audit_logs table
CREATE TABLE "audit_logs" (
    "audit_id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "user_id" UUID REFERENCES "users"("user_id") ON DELETE SET NULL,
    "action" VARCHAR(100) NOT NULL,
    "table_name" VARCHAR(100) NOT NULL,
    "record_id" VARCHAR(100),
    "old_values" JSONB,
    "new_values" JSONB,
    "ip_address" VARCHAR(45),
    "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 3. Create Performance & Search Indexes

-- Users and Patients unique indexes are implicit from constraints.
-- ICD Code searching by name/code
CREATE INDEX "idx_icd_code_search" ON "icd_codes"("icd_code");
CREATE INDEX "idx_icd_name_search" ON "icd_codes"("disease_name");

-- Drug search indexes
CREATE INDEX "idx_drug_brand_name" ON "drugs"("brand_name");
CREATE INDEX "idx_drug_active_ingredient" ON "drugs"("active_ingredient");

-- Prescription relationships lookup
CREATE INDEX "idx_prescriptions_patient" ON "prescriptions"("patient_id");
CREATE INDEX "idx_prescriptions_doctor" ON "prescriptions"("doctor_id");
CREATE INDEX "idx_prescriptions_created_by" ON "prescriptions"("created_by");

-- Prescription details mapping
CREATE INDEX "idx_details_prescription" ON "prescription_details"("prescription_id");

-- Drug interaction pairs
CREATE INDEX "idx_interactions_pair" ON "drug_interactions"("drug1_id", "drug2_id");

-- ICD-Drug mapping pairs
CREATE INDEX "idx_icd_drug_mapping" ON "icd_drug_mappings"("icd_id", "drug_id");

-- 4. Audit Log Helper Functions & Triggers (Trigger Normalization)

CREATE OR REPLACE FUNCTION log_table_audit()
RETURNS TRIGGER AS $$
DECLARE
    v_user_id UUID;
    v_old_data JSONB := NULL;
    v_new_data JSONB := NULL;
BEGIN
    -- Determine the values based on operational context
    IF (TG_OP = 'UPDATE') THEN
        v_old_data := to_jsonb(OLD);
        v_new_data := to_jsonb(NEW);
    ELSIF (TG_OP = 'DELETE') THEN
        v_old_data := to_jsonb(OLD);
    ELSIF (TG_OP = 'INSERT') THEN
        v_new_data := to_jsonb(NEW);
    END IF;

    -- In real app, the user context is set via session variable or config
    -- For trigger purposes, try to fetch user_id if present in row, otherwise default null
    BEGIN
        v_user_id := COALESCE(
            current_setting('app.current_user_id', true)::UUID,
            CASE
                WHEN TG_OP = 'DELETE' THEN NULL
                ELSE (v_new_data->>'created_by')::UUID
            END
        );
    EXCEPTION WHEN OTHERS THEN
        v_user_id := NULL;
    END;

    INSERT INTO "audit_logs" (
        "user_id",
        "action",
        "table_name",
        "record_id",
        "old_values",
        "new_values",
        "ip_address"
    ) VALUES (
        v_user_id,
        TG_OP,
        TG_TABLE_NAME,
        CASE
            WHEN TG_OP = 'DELETE' THEN (v_old_data->>'id')
            ELSE (v_new_data->> (TG_TABLE_NAME || '_id'))
        END,
        v_old_data,
        v_new_data,
        inet_client_addr()::VARCHAR
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply Audit Log trigger to core transactional tables
CREATE TRIGGER audit_prescriptions
AFTER INSERT OR UPDATE OR DELETE ON "prescriptions"
FOR EACH ROW EXECUTE FUNCTION log_table_audit();

CREATE TRIGGER audit_prescription_details
AFTER INSERT OR UPDATE OR DELETE ON "prescription_details"
FOR EACH ROW EXECUTE FUNCTION log_table_audit();

CREATE TRIGGER audit_users
AFTER INSERT OR UPDATE OR DELETE ON "users"
FOR EACH ROW EXECUTE FUNCTION log_table_audit();
