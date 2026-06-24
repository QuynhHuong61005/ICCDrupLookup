-- ==========================================
-- MEDPRESCRIBE POSTGRESQL SEED DATA
-- ==========================================

-- 1. Insert Roles (Fixed UUIDs)
INSERT INTO "roles" ("role_id", "role_name", "description") VALUES
('11111111-1111-1111-1111-111111111111', 'ADMIN', 'System Administrator with full access'),
('22222222-2222-2222-2222-222222222222', 'DOCTOR', 'Medical Doctor - can write prescriptions'),
('33333333-3333-3333-3333-333333333333', 'PHARMACIST', 'Pharmacist - can view prescriptions and release drugs')
ON CONFLICT ("role_id") DO NOTHING;

-- 2. Insert Permissions (Fixed UUIDs)
INSERT INTO "permissions" ("permission_id", "permission_name", "description") VALUES
('11111111-0000-0000-0000-000000000000', 'MANAGE_SYSTEM', 'Access to system configs and admin features'),
('22222222-0000-0000-0000-000000000000', 'WRITE_USERS', 'Create, update, disable users'),
('33333333-0000-0000-0000-000000000000', 'READ_USERS', 'View user profiles and list users'),
('44444444-0000-0000-0000-000000000000', 'WRITE_PRESCRIPTION', 'Create and modify prescriptions'),
('55555555-0000-0000-0000-000000000000', 'READ_PRESCRIPTION', 'View prescriptions and status history'),
('66666666-0000-0000-0000-000000000000', 'READ_DRUGS', 'View drugs and drug interaction database'),
('77777777-0000-0000-0000-000000000000', 'WRITE_DRUGS', 'Modify drug index and interactions mappings')
ON CONFLICT ("permission_id") DO NOTHING;

-- 3. Map Permissions to Roles (RolePermissions)
-- ADMIN: All permissions
INSERT INTO "role_permissions" ("role_id", "permission_id") VALUES
('11111111-1111-1111-1111-111111111111', '11111111-0000-0000-0000-000000000000'),
('11111111-1111-1111-1111-111111111111', '22222222-0000-0000-0000-000000000000'),
('11111111-1111-1111-1111-111111111111', '33333333-0000-0000-0000-000000000000'),
('11111111-1111-1111-1111-111111111111', '44444444-0000-0000-0000-000000000000'),
('11111111-1111-1111-1111-111111111111', '55555555-0000-0000-0000-000000000000'),
('11111111-1111-1111-1111-111111111111', '66666666-0000-0000-0000-000000000000'),
('11111111-1111-1111-1111-111111111111', '77777777-0000-0000-0000-000000000000')
ON CONFLICT DO NOTHING;

-- DOCTOR: Read/Write Prescriptions, Read/Write Drugs (mappings), Read Users
INSERT INTO "role_permissions" ("role_id", "permission_id") VALUES
('22222222-2222-2222-2222-222222222222', '33333333-0000-0000-0000-000000000000'),
('22222222-2222-2222-2222-222222222222', '44444444-0000-0000-0000-000000000000'),
('22222222-2222-2222-2222-222222222222', '55555555-0000-0000-0000-000000000000'),
('22222222-2222-2222-2222-222222222222', '66666666-0000-0000-0000-000000000000'),
('22222222-2222-2222-2222-222222222222', '77777777-0000-0000-0000-000000000000')
ON CONFLICT DO NOTHING;

-- PHARMACIST: Read Prescriptions, Read Drugs, Read Users
INSERT INTO "role_permissions" ("role_id", "permission_id") VALUES
('33333333-3333-3333-3333-333333333333', '33333333-0000-0000-0000-000000000000'),
('33333333-3333-3333-3333-333333333333', '55555555-0000-0000-0000-000000000000'),
('33333333-3333-3333-3333-333333333333', '66666666-0000-0000-0000-000000000000')
ON CONFLICT DO NOTHING;

-- 4. Insert Test Users (Password: MedPrescribe2026@)
-- Bcrypt Hash: $2b$10$LgXb38eHn7gWv/9gQe.2IeW9/l6n8B3c3vV9C/0F1U91P0r7.u3iS
INSERT INTO "users" ("user_id", "full_name", "email", "password_hash", "role_id", "is_active", "otp_enabled") VALUES
('11888888-8888-8888-8888-888888888888', 'System Admin', 'admin@medprescribe.com', '$2b$10$LgXb38eHn7gWv/9gQe.2IeW9/l6n8B3c3vV9C/0F1U91P0r7.u3iS', '11111111-1111-1111-1111-111111111111', TRUE, FALSE),
('22888888-8888-8888-8888-888888888888', 'Dr. Nguyen Van A', 'doctor@medprescribe.com', '$2b$10$LgXb38eHn7gWv/9gQe.2IeW9/l6n8B3c3vV9C/0F1U91P0r7.u3iS', '22222222-2222-2222-2222-222222222222', TRUE, FALSE),
('33888888-8888-8888-8888-888888888888', 'Pharm. Tran Thi B', 'pharmacist@medprescribe.com', '$2b$10$LgXb38eHn7gWv/9gQe.2IeW9/l6n8B3c3vV9C/0F1U91P0r7.u3iS', '33333333-3333-3333-3333-333333333333', TRUE, FALSE)
ON CONFLICT ("user_id") DO NOTHING;

-- 5. Insert Patients
INSERT INTO "patients" ("patient_id", "full_name", "dob", "gender", "phone", "address") VALUES
('99999999-1111-1111-1111-111111111111', 'Le Van Nam', '1985-05-15', 'MALE', '0901234567', '123 Nguyen Hue, Quan 1, TP. HCM'),
('99999999-2222-2222-2222-222222222222', 'Pham Minh Thu', '1992-09-20', 'FEMALE', '0918765432', '456 Tran Hung Dao, Quan 5, TP. HCM'),
('99999999-3333-3333-3333-333333333333', 'Hoang Quoc Bao', '2015-11-02', 'MALE', '0982233445', '789 Le Loi, Quan Go Vap, TP. HCM')
ON CONFLICT ("patient_id") DO NOTHING;

-- 6. Insert ICD Codes
INSERT INTO "icd_codes" ("icd_id", "icd_code", "disease_name", "disease_group") VALUES
('77777777-1111-1111-1111-111111111111', 'A09', 'Gastroenteritis and colitis of infectious origin', 'Infectious and parasitic diseases'),
('77777777-2222-2222-2222-222222222222', 'I10', 'Essential (primary) hypertension', 'Diseases of the circulatory system'),
('77777777-3333-3333-3333-333333333333', 'E11', 'Type 2 diabetes mellitus', 'Endocrine, nutritional and metabolic diseases'),
('77777777-4444-4444-4444-444411111111', 'J06', 'Acute upper respiratory infections of multiple and unspecified sites', 'Diseases of the respiratory system'),
('77777777-5555-5555-5555-555511111111', 'M54.5', 'Low back pain', 'Diseases of the musculoskeletal system and connective tissue')
ON CONFLICT ("icd_id") DO NOTHING;

-- 7. Insert Drugs (Fixed UUIDs chosen such that drug1_id < drug2_id checks hold for interactions)
-- Drug 1: Paracetamol (88888888-1111-1111-1111-111111111111)
-- Drug 2: Aspirin     (88888888-2222-2222-2222-222222222222)
-- Drug 3: Warfarin    (88888888-3333-3333-3333-333333333333)
-- Drug 4: Ibuprofen   (88888888-4444-4444-4444-444411111111)
-- Drug 5: Metformin   (88888888-5555-5555-5555-555511111111)
INSERT INTO "drugs" ("drug_id", "brand_name", "active_ingredient", "concentration", "dosage_form", "manufacturer") VALUES
('88888888-1111-1111-1111-111111111111', 'Panadol Extra', 'Paracetamol', '500mg', 'Tablet', 'GSK'),
('88888888-2222-2222-2222-222222222222', 'Aspirin PH8', 'Aspirin', '81mg', 'Enteric-coated Tablet', 'Mekophar'),
('88888888-3333-3333-3333-333333333333', 'Coumadin', 'Warfarin', '5mg', 'Tablet', 'Bristol-Myers Squibb'),
('88888888-4444-4444-4444-444411111111', 'Gofen 400', 'Ibuprofen', '400mg', 'Soft Capsule', 'Mega We Care'),
('88888888-5555-5555-5555-555511111111', 'Glucophage', 'Metformin', '850mg', 'Film-coated Tablet', 'Merck')
ON CONFLICT ("drug_id") DO NOTHING;

-- 8. Insert Drug Interactions
-- Condition: drug1_id must be lexically smaller than drug2_id.
-- Let's check IDs:
-- Aspirin (88888888-2222-...) < Warfarin (88888888-3333-...) -> TRUE
-- Aspirin (88888888-2222-...) < Ibuprofen (88888888-4444-...) -> TRUE
-- Warfarin (88888888-3333-...) < Ibuprofen (88888888-4444-...) -> TRUE
-- Metformin (88888888-5555-...) -- No interaction defined or Metformin + Contrast Media (not in drugs table). Let's define:
-- Paracetamol (88888888-1111-...) < Warfarin (88888888-3333-...) -> TRUE (Moderate interaction on prolonged paracetamol use)

INSERT INTO "drug_interactions" ("interaction_id", "drug1_id", "drug2_id", "severity", "description") VALUES
('11111111-aaaa-bbbb-cccc-dddddddddddd', '88888888-2222-2222-2222-222222222222', '88888888-3333-3333-3333-333333333333', 'SEVERE', 'Concomitant use of Aspirin and Warfarin significantly increases the risk of serious gastrointestinal bleeding. Close INR monitoring is required.'),
('22222222-aaaa-bbbb-cccc-dddddddddddd', '88888888-2222-2222-2222-222222222222', '88888888-4444-4444-4444-444411111111', 'MODERATE', 'Ibuprofen may decrease the cardioprotective antiplatelet effect of low-dose aspirin. Risk of gastric irritation is also increased.'),
('33333333-aaaa-bbbb-cccc-dddddddddddd', '88888888-3333-3333-3333-333333333333', '88888888-4444-4444-4444-444411111111', 'SEVERE', 'NSAIDs like Ibuprofen increase the risk of bleeding in patients receiving anticoagulant therapy with Warfarin.'),
('44444444-aaaa-bbbb-cccc-dddddddddddd', '88888888-1111-1111-1111-111111111111', '88888888-3333-3333-3333-333333333333', 'MINOR', 'Chronic or high-dose Paracetamol use may enhance the anticoagulant effect of Warfarin. Occasional use has minimal risk.')
ON CONFLICT ("interaction_id") DO NOTHING;

-- 9. Insert ICD-Drug Mappings (Standard recommendations for diseases)
INSERT INTO "icd_drug_mappings" ("mapping_id", "icd_id", "drug_id", "standard_dosage", "bhyt_status") VALUES
('99999999-aaaa-bbbb-cccc-111111111111', '77777777-2222-2222-2222-222222222222', '88888888-2222-2222-2222-222222222222', 'Take 1 tablet (81mg) daily after breakfast for antiplatelet therapy.', TRUE),
('99999999-aaaa-bbbb-cccc-222222222222', '77777777-3333-3333-3333-333333333333', '88888888-5555-5555-5555-555511111111', 'Take 1 tablet (850mg) twice daily with meals.', TRUE),
('99999999-aaaa-bbbb-cccc-333333333333', '77777777-4444-4444-4444-444411111111', '88888888-1111-1111-1111-111111111111', 'Take 1 tablet (500mg) every 4-6 hours as needed for fever or pain. Max 4g/day.', TRUE),
('99999999-aaaa-bbbb-cccc-444444444444', '77777777-5555-5555-5555-555511111111', '88888888-4444-4444-4444-444411111111', 'Take 1 capsule (400mg) three times daily after meals as needed for severe pain.', FALSE)
ON CONFLICT ("mapping_id") DO NOTHING;
