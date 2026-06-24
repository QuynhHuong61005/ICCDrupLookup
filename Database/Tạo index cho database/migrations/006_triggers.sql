-- Gắn trigger kiểm toán an toàn (Xóa cũ tạo mới tránh lỗi lặp lại)
DROP TRIGGER IF EXISTS audit_prescriptions ON "prescriptions";
CREATE TRIGGER audit_prescriptions
AFTER INSERT OR UPDATE OR DELETE ON "prescriptions"
FOR EACH ROW EXECUTE FUNCTION log_table_audit();

DROP TRIGGER IF EXISTS audit_prescription_details ON "prescription_details";
CREATE TRIGGER audit_prescription_details
AFTER INSERT OR UPDATE OR DELETE ON "prescription_details"
FOR EACH ROW EXECUTE FUNCTION log_table_audit();

DROP TRIGGER IF EXISTS audit_users ON "users";
CREATE TRIGGER audit_users
AFTER INSERT OR UPDATE OR DELETE ON "users"
FOR EACH ROW EXECUTE FUNCTION log_table_audit();
