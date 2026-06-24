-- Viết lại hàm Audit Log: Sửa triệt để lỗi mất dữ liệu record_id khi hành động DELETE xảy ra
CREATE OR REPLACE FUNCTION log_table_audit()
RETURNS TRIGGER AS $$
DECLARE
    v_user_id UUID;
    v_old_data JSONB := NULL;
    v_new_data JSONB := NULL;
    v_record_id VARCHAR(100) := NULL;
BEGIN
    IF (TG_OP = 'UPDATE') THEN
        v_old_data := to_jsonb(OLD);
        v_new_data := to_jsonb(NEW);
    ELSIF (TG_OP = 'DELETE') THEN
        v_old_data := to_jsonb(OLD);
    ELSIF (TG_OP = 'INSERT') THEN
        v_new_data := to_jsonb(NEW);
    END IF;

    -- Lấy ID khóa chính động một cách chính xác dựa trên cấu trúc schema
    CASE TG_TABLE_NAME
        WHEN 'prescription_details' THEN
            v_record_id := COALESCE(v_new_data->>'detail_id', v_old_data->>'detail_id');
        ELSE
            v_record_id := COALESCE(
                v_new_data->>(TG_TABLE_NAME || '_id'), 
                v_old_data->>(TG_TABLE_NAME || '_id')
            );
    END CASE;

    BEGIN
        v_user_id := COALESCE(
            current_setting('app.current_user_id', true)::UUID,
            (v_new_data->>'created_by')::UUID,
            (v_new_data->>'doctor_id')::UUID
        );
    EXCEPTION WHEN OTHERS THEN
        v_user_id := NULL;
    END;

    INSERT INTO "audit_logs" (
        "user_id", "action", "table_name", "record_id", "old_values", "new_values", "ip_address"
    ) VALUES (
        v_user_id, TG_OP, TG_TABLE_NAME, v_record_id, v_old_data, v_new_data, inet_client_addr()::VARCHAR
    );

    IF (TG_OP = 'DELETE') THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;
