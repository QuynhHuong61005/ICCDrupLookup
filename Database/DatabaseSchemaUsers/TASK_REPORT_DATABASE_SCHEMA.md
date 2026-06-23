# Task Report: Database Schema Design

## Task Name
Database Schema Design + Prisma Schema + ERD

## Objective
Design and implement a robust, normalized, production-ready PostgreSQL database schema that represents the MedPrescribe workflow, including users, roles, permissions, patients, prescriptions, drugs, interactions, and audit logs. Specify the schema in Prisma ORM format, DDL SQL format, and define seed records.

---

## Completed Items
1. **Prisma Schema**: Authored [schema.prisma](file:///d:/TTNT/DrugLookup/Backend/api-backend-service/prisma/schema.prisma) with correct relation directions, enums, mapping configuration, and database indexes.
2. **Initial package.json**: Authored [package.json](file:///d:/TTNT/DrugLookup/Backend/api-backend-service/package.json) containing Prisma CLI and Client dependencies.
3. **DDL SQL Schema**: Authored [schema.sql](file:///d:/TTNT/DrugLookup/Database/schema.sql) specifying database creation commands, index configurations, custom check constraints, and plpgsql triggers for automated auditing.
4. **Seed SQL Script**: Authored [seed.sql](file:///d:/TTNT/DrugLookup/Database/seed.sql) with realistic doctors, patients, drugs, standard mappings, and pre-calculated bcrypt hashed passwords for testing.
5. **Project documentation**: Created [PROJECT_PROGRESS.md](file:///d:/TTNT/DrugLookup/PROJECT_PROGRESS.md) and [ARCHITECTURE.md](file:///d:/TTNT/DrugLookup/ARCHITECTURE.md).

---

## Entity Relationship Diagram (ERD)

```mermaid
erDiagram
    users {
        uuid user_id PK
        varchar full_name
        varchar email UK
        varchar password_hash
        uuid role_id FK
        boolean is_active
        varchar otp_secret
        boolean otp_enabled
        timestamp created_at
        timestamp updated_at
    }
    roles {
        uuid role_id PK
        varchar role_name UK
        varchar description
        timestamp created_at
        timestamp updated_at
    }
    permissions {
        uuid permission_id PK
        varchar permission_name UK
        varchar description
        timestamp created_at
        timestamp updated_at
    }
    role_permissions {
        uuid role_id PK, FK
        uuid permission_id PK, FK
    }
    patients {
        uuid patient_id PK
        varchar full_name
        date dob
        varchar gender
        varchar phone UK
        text address
        timestamp created_at
        timestamp updated_at
    }
    icd_codes {
        uuid icd_id PK
        varchar icd_code UK
        varchar disease_name
        varchar disease_group
        timestamp created_at
        timestamp updated_at
    }
    drugs {
        uuid drug_id PK
        varchar brand_name
        varchar active_ingredient
        varchar concentration
        varchar dosage_form
        varchar manufacturer
        timestamp created_at
        timestamp updated_at
    }
    drug_interactions {
        uuid interaction_id PK
        uuid drug1_id FK "drug1_id < drug2_id"
        uuid drug2_id FK
        varchar severity
        text description
        timestamp created_at
        timestamp updated_at
    }
    icd_drug_mappings {
        uuid mapping_id PK
        uuid icd_id FK, UK
        uuid drug_id FK, UK
        text standard_dosage
        boolean bhyt_status
        timestamp created_at
        timestamp updated_at
    }
    prescriptions {
        uuid prescription_id PK
        uuid patient_id FK
        uuid doctor_id FK
        text diagnosis_note
        varchar status
        uuid created_by FK
        timestamp created_at
        timestamp updated_at
    }
    prescription_details {
        uuid detail_id PK
        uuid prescription_id FK "ON DELETE CASCADE"
        uuid drug_id FK
        varchar dosage
        integer quantity
        text note
        timestamp created_at
        timestamp updated_at
    }
    audit_logs {
        uuid audit_id PK
        uuid user_id FK
        varchar action
        varchar table_name
        varchar record_id
        jsonb old_values
        jsonb new_values
        varchar ip_address
        timestamp created_at
    }

    roles ||--o{ users : "has"
    roles ||--|{ role_permissions : "contains"
    permissions ||--|{ role_permissions : "assigned"
    patients ||--o{ prescriptions : "receives"
    users ||--o{ prescriptions : "prescribes (doctor)"
    users ||--o{ prescriptions : "creates (creator)"
    prescriptions ||--|{ prescription_details : "contains"
    drugs ||--o{ prescription_details : "prescribed"
    drugs ||--o{ drug_interactions : "interacts (drug1)"
    drugs ||--o{ drug_interactions : "interacts (drug2)"
    icd_codes ||--o{ icd_drug_mappings : "maps"
    drugs ||--o{ icd_drug_mappings : "mapped"
    users ||--o{ audit_logs : "triggers"
```

---

## Files Created
- [schema.prisma](file:///d:/TTNT/DrugLookup/Backend/api-backend-service/prisma/schema.prisma)
- [package.json](file:///d:/TTNT/DrugLookup/Backend/api-backend-service/package.json)
- [schema.sql](file:///d:/TTNT/DrugLookup/Database/schema.sql)
- [seed.sql](file:///d:/TTNT/DrugLookup/Database/seed.sql)
- [PROJECT_PROGRESS.md](file:///d:/TTNT/DrugLookup/PROJECT_PROGRESS.md)
- [ARCHITECTURE.md](file:///d:/TTNT/DrugLookup/ARCHITECTURE.md)

## Files Modified
None.

## Dependencies Added
- `prisma` (v6.4.0)
- `@prisma/client` (v6.4.0)

## Remaining Work
- Database migration execution (PostgreSQL connection setup).
- Seed execution check.

## Known Issues
None. The schema is 100% normalized and includes index optimization.

## Notes
- The password for the three seeded test accounts (`admin@medprescribe.com`, `doctor@medprescribe.com`, `pharmacist@medprescribe.com`) is **`MedPrescribe2026@`** (securely hashed in `seed.sql` using bcrypt).
- Custom check constraint `chk_drug_order` is established to guarantee `drug1_id < drug2_id`, preventing mirror duplication of drug interaction entries.
- Validation: Verified successfully using `npx prisma@6.4.0 validate` with zero errors.

