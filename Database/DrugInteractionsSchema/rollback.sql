DROP TRIGGER IF EXISTS audit_users ON "users";
DROP TRIGGER IF EXISTS audit_prescription_details ON "prescription_details";
DROP TRIGGER IF EXISTS audit_prescriptions ON "prescriptions";

DROP FUNCTION IF EXISTS log_table_audit();

DROP TABLE IF EXISTS "audit_logs" CASCADE;
DROP TABLE IF EXISTS "prescription_details" CASCADE;
DROP TABLE IF EXISTS "prescriptions" CASCADE;
DROP TABLE IF EXISTS "icd_drug_mappings" CASCADE;
DROP TABLE IF EXISTS "drug_interactions" CASCADE;
DROP TABLE IF EXISTS "drugs" CASCADE;
DROP TABLE IF EXISTS "icd_codes" CASCADE;
DROP TABLE IF EXISTS "patients" CASCADE;
DROP TABLE IF EXISTS "users" CASCADE;
DROP TABLE IF EXISTS "role_permissions" CASCADE;
DROP TABLE IF EXISTS "roles" CASCADE;
DROP TABLE IF EXISTS "permissions" CASCADE;
DROP TABLE IF EXISTS "medical_ranks" CASCADE;

DROP TYPE IF EXISTS "PrescriptionStatus";
DROP TYPE IF EXISTS "Severity";
DROP TYPE IF EXISTS "Gender";
