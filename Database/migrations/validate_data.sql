-- 1. Kiểm tra bản ghi mồ côi (Orphan Records) do lỗi tắt FK hoặc xử lý dữ liệu từ nguồn khác
SELECT 'Orphan Prescription Details' AS issue, COUNT(*) FROM "prescription_details" pd
LEFT JOIN "prescriptions" p ON pd.prescription_id = p.prescription_id WHERE p.prescription_id IS NULL
UNION ALL
SELECT 'Orphan Users (Invalid Role)' AS issue, COUNT(*) FROM "users" u
LEFT JOIN "roles" r ON u.role_id = r.role_id WHERE r.role_id IS NULL;

-- 2. Kiểm tra lỗi trùng lặp mã danh mục y tế gốc
SELECT 'Duplicate ICD Code' AS issue, COUNT(*) FROM (
    SELECT "icd_code" FROM "icd_codes" GROUP BY "icd_code" HAVING COUNT(*) > 1
) AS dup;

-- 3. Kiểm tra logic cặp thuốc tương tác bị đảo ngược hoặc trùng lặp
SELECT 'Invalid Drug Interaction Logic' AS issue, COUNT(*) FROM "drug_interactions" 
WHERE "drug1_id" >= "drug2_id";
