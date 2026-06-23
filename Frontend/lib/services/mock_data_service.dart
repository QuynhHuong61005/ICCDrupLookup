// --- Domain Models ---

class UserMock {
  final String userId;
  final String fullName;
  final String email;
  final String role;
  final bool isActive;

  UserMock({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
    this.isActive = true,
  });
}

class PatientMock {
  final String patientId;
  final String fullName;
  final String dob;
  final String gender;
  final String phone;
  final String address;

  PatientMock({
    required this.patientId,
    required this.fullName,
    required this.dob,
    required this.gender,
    required this.phone,
    required this.address,
  });
}

class ICDCodeMock {
  final String icdId;
  final String icdCode;
  final String diseaseName;
  final String diseaseGroup;
  final List<String> symptoms;

  ICDCodeMock({
    required this.icdId,
    required this.icdCode,
    required this.diseaseName,
    required this.diseaseGroup,
    required this.symptoms,
  });
}

class DrugMock {
  final String drugId;
  final String brandName;
  final String activeIngredient;
  final String concentration;
  final String dosageForm;
  final String manufacturer;
  final String indications;
  final String contraindications;
  final String sideEffects;
  final String warnings;

  DrugMock({
    required this.drugId,
    required this.brandName,
    required this.activeIngredient,
    required this.concentration,
    required this.dosageForm,
    required this.manufacturer,
    required this.indications,
    required this.contraindications,
    required this.sideEffects,
    required this.warnings,
  });
}

class DrugInteractionMock {
  final String interactionId;
  final String drug1Id;
  final String drug2Id;
  final String severity; // MINOR, MODERATE, SEVERE, CONTRAINDICATED
  final String description;

  DrugInteractionMock({
    required this.interactionId,
    required this.drug1Id,
    required this.drug2Id,
    required this.severity,
    required this.description,
  });
}

class ICDDrugMappingMock {
  final String mappingId;
  final String icdId;
  final String drugId;
  final String standardDosage;
  final bool bhytStatus;

  ICDDrugMappingMock({
    required this.mappingId,
    required this.icdId,
    required this.drugId,
    required this.standardDosage,
    required this.bhytStatus,
  });
}

// --- Data Service ---

class MockDataService {
  // 1. Roles & Users Mock
  static final List<UserMock> users = [
    UserMock(
      userId: 'ad888888-8888-8888-8888-888888888888',
      fullName: 'System Administrator',
      email: 'admin@medprescribe.com',
      role: 'ADMIN',
    ),
    UserMock(
      userId: 'dc888888-8888-8888-8888-888888888888',
      fullName: 'Dr. Nguyen Van A',
      email: 'doctor@medprescribe.com',
      role: 'DOCTOR',
    ),
    UserMock(
      userId: 'pc888888-8888-8888-8888-888888888888',
      fullName: 'Pharm. Tran Thi B',
      email: 'pharmacist@medprescribe.com',
      role: 'PHARMACIST',
    ),
  ];

  // 2. Patients Mock
  static final List<PatientMock> patients = [
    PatientMock(
      patientId: '99999999-1111-1111-1111-111111111111',
      fullName: 'Le Van Nam',
      dob: '1985-05-15',
      gender: 'MALE',
      phone: '0901234567',
      address: '123 Nguyen Hue, Quan 1, TP. HCM',
    ),
    PatientMock(
      patientId: '99999999-2222-2222-2222-222222222222',
      fullName: 'Pham Minh Thu',
      dob: '1992-09-20',
      gender: 'FEMALE',
      phone: '0918765432',
      address: '456 Tran Hung Dao, Quan 5, TP. HCM',
    ),
    PatientMock(
      patientId: '99999999-3333-3333-3333-333333333333',
      fullName: 'Hoang Quoc Bao',
      dob: '2015-11-02',
      gender: 'MALE',
      phone: '0982233445',
      address: '789 Le Loi, Quan Go Vap, TP. HCM',
    ),
  ];

  // 3. ICD Codes Mock
  static final List<ICDCodeMock> icdCodes = [
    ICDCodeMock(
      icdId: '77777777-1111-1111-1111-111111111111',
      icdCode: 'A09',
      diseaseName: 'Gastroenteritis and colitis of infectious origin',
      diseaseGroup: 'Infectious and parasitic diseases',
      symptoms: [
        'Diarrhea',
        'Nausea',
        'Vomiting',
        'Abdominal cramps',
        'Mild fever'
      ],
    ),
    ICDCodeMock(
      icdId: '77777777-2222-2222-2222-222222222222',
      icdCode: 'I10',
      diseaseName: 'Essential (primary) hypertension',
      diseaseGroup: 'Diseases of the circulatory system',
      symptoms: [
        'Headache',
        'Dizziness',
        'Shortness of breath',
        'Chest pain',
        'Fatigue'
      ],
    ),
    ICDCodeMock(
      icdId: '77777777-3333-3333-3333-333333333333',
      icdCode: 'E11',
      diseaseName: 'Type 2 diabetes mellitus',
      diseaseGroup: 'Endocrine, nutritional and metabolic diseases',
      symptoms: [
        'Increased thirst',
        'Frequent urination',
        'Hunger',
        'Weight loss',
        'Blurry vision'
      ],
    ),
    ICDCodeMock(
      icdId: '77777777-4444-4444-4444-444411111111',
      icdCode: 'J06',
      diseaseName:
          'Acute upper respiratory infections of multiple and unspecified sites',
      diseaseGroup: 'Diseases of the respiratory system',
      symptoms: [
        'Runny nose',
        'Sore throat',
        'Cough',
        'Low-grade fever',
        'Sneezing'
      ],
    ),
    ICDCodeMock(
      icdId: '77777777-5555-5555-5555-555511111111',
      icdCode: 'M54.5',
      diseaseName: 'Low back pain',
      diseaseGroup:
          'Diseases of the musculoskeletal system and connective tissue',
      symptoms: [
        'Muscle ache',
        'Shooting or stabbing pain',
        'Pain radiating down leg',
        'Limited flexibility'
      ],
    ),
  ];

  // 4. Drugs Mock
  static final List<DrugMock> drugs = [
    DrugMock(
      drugId: '88888888-1111-1111-1111-111111111111',
      brandName: 'Panadol Extra',
      activeIngredient: 'Paracetamol',
      concentration: '500mg',
      dosageForm: 'Tablet',
      manufacturer: 'GSK',
      indications:
          'Relief of mild to moderate pain (headache, migraine, sore throat, muscle pain, toothache) and reduction of fever.',
      contraindications:
          'Hypersensitivity to paracetamol. Severe hepatic impairment.',
      sideEffects:
          'Rare occurrences of skin rash or other allergic reactions. Thrombocytopenia is extremely rare.',
      warnings:
          'Do not exceed the recommended dose. Do not take other paracetamol-containing products concurrently.',
    ),
    DrugMock(
      drugId: '88888888-2222-2222-2222-222222222222',
      brandName: 'Aspirin PH8',
      activeIngredient: 'Aspirin',
      concentration: '81mg',
      dosageForm: 'Enteric-coated Tablet',
      manufacturer: 'Mekophar',
      indications:
          'Prophylaxis of thromboembolic diseases, secondary prevention of myocardial infarction and stroke.',
      contraindications:
          'Active peptic ulcer disease. Bleeding disorders. Hypersensitivity to NSAIDs.',
      sideEffects:
          'Dyspepsia, gastrointestinal bleeding, increased bleeding tendency, urticaria.',
      warnings:
          'Use caution in patients with renal or hepatic impairment. Avoid use in children (risk of Reye syndrome).',
    ),
    DrugMock(
      drugId: '88888888-3333-3333-3333-333333333333',
      brandName: 'Coumadin',
      activeIngredient: 'Warfarin',
      concentration: '5mg',
      dosageForm: 'Tablet',
      manufacturer: 'Bristol-Myers Squibb',
      indications:
          'Prophylaxis and treatment of venous thrombosis, pulmonary embolism, and thromboembolic complications associated with atrial fibrillation.',
      contraindications:
          'Pregnancy. Hemorrhagic tendencies. Recent surgery of CNS or eye. Uncontrolled hypertension.',
      sideEffects:
          'Hemorrhage (bleeding from any tissue or organ), tissue necrosis, dermatitis.',
      warnings:
          'Requires strict monitoring of Prothrombin Time (PT) / International Normalized Ratio (INR). Strict compliance with dosage is mandatory.',
    ),
    DrugMock(
      drugId: '88888888-4444-4444-4444-444411111111',
      brandName: 'Gofen 400',
      activeIngredient: 'Ibuprofen',
      concentration: '400mg',
      dosageForm: 'Soft Capsule',
      manufacturer: 'Mega We Care',
      indications:
          'Relief of mild to moderate pain (dental pain, headache, primary dysmenorrhea, musculoskeletal pain) and reduction of swelling/fever.',
      contraindications:
          'Active peptic ulcer, severe heart failure, severe renal or hepatic failure.',
      sideEffects:
          'Nausea, heartburn, stomach pain, dizziness, rash, fluid retention.',
      warnings:
          'May increase the risk of serious cardiovascular thrombotic events. Monitor renal function in elderly patients.',
    ),
    DrugMock(
      drugId: '88888888-5555-5555-5555-555511111111',
      brandName: 'Glucophage',
      activeIngredient: 'Metformin',
      concentration: '850mg',
      dosageForm: 'Film-coated Tablet',
      manufacturer: 'Merck',
      indications:
          'Treatment of type 2 diabetes mellitus, particularly in overweight patients, when dietary management and exercise alone result in inadequate glycemic control.',
      contraindications:
          'Diabetic ketoacidosis. Renal failure or dysfunction (GFR < 30 mL/min). Acute conditions predisposing to lactic acidosis.',
      sideEffects:
          'Gastrointestinal disorders (nausea, vomiting, diarrhea, abdominal pain), loss of appetite, metallic taste.',
      warnings:
          'Discontinue prior to contrast media imaging procedures. Risk of lactic acidosis is extremely low but fatal if it occurs.',
    ),
  ];

  // 5. Drug Interactions Mock
  static final List<DrugInteractionMock> interactions = [
    DrugInteractionMock(
      interactionId: '11111111-aaaa-bbbb-cccc-dddddddddddd',
      drug1Id: '88888888-2222-2222-2222-222222222222', // Aspirin
      drug2Id: '88888888-3333-3333-3333-333333333333', // Warfarin
      severity: 'SEVERE',
      description:
          'Concomitant use of Aspirin and Warfarin significantly increases the risk of serious gastrointestinal bleeding. Low-dose aspirin combined with anticoagulants requires careful clinical monitoring and regular INR checks.',
    ),
    DrugInteractionMock(
      interactionId: '22222222-aaaa-bbbb-cccc-dddddddddddd',
      drug1Id: '88888888-2222-2222-2222-222222222222', // Aspirin
      drug2Id: '88888888-4444-4444-4444-444411111111', // Ibuprofen
      severity: 'MODERATE',
      description:
          'Ibuprofen may decrease the cardioprotective antiplatelet effect of low-dose aspirin. Patients taking low-dose aspirin for cardiovascular protection should take ibuprofen at least 8 hours before or 30 minutes after aspirin.',
    ),
    DrugInteractionMock(
      interactionId: '33333333-aaaa-bbbb-cccc-dddddddddddd',
      drug1Id: '88888888-3333-3333-3333-333333333333', // Warfarin
      drug2Id: '88888888-4444-4444-4444-444411111111', // Ibuprofen
      severity: 'SEVERE',
      description:
          'NSAIDs like Ibuprofen increase the risk of bleeding in patients receiving anticoagulant therapy with Warfarin due to antiplatelet activity and gastric mucosal injury.',
    ),
    DrugInteractionMock(
      interactionId: '44444444-aaaa-bbbb-cccc-dddddddddddd',
      drug1Id: '88888888-1111-1111-1111-111111111111', // Paracetamol
      drug2Id: '88888888-3333-3333-3333-333333333333', // Warfarin
      severity: 'MINOR',
      description:
          'Chronic or high-dose Paracetamol use (exceeding 2g/day for several days) may enhance the anticoagulant effect of Warfarin, increasing bleeding risk. Occasional single-dose use is safe.',
    ),
  ];

  // 6. ICD-Drug Mapping recommendations
  static final List<ICDDrugMappingMock> mappings = [
    ICDDrugMappingMock(
      mappingId: '99999999-aaaa-bbbb-cccc-111111111111',
      icdId: '77777777-2222-2222-2222-222222222222', // Hypertension (I10)
      drugId:
          '88888888-2222-2222-2222-222222222222', // Aspirin (as prophylaxis)
      standardDosage:
          'Take 1 tablet (81mg) daily after breakfast for antiplatelet therapy.',
      bhytStatus: true,
    ),
    ICDDrugMappingMock(
      mappingId: '99999999-aaaa-bbbb-cccc-222222222222',
      icdId: '77777777-3333-3333-3333-333333333333', // Type 2 Diabetes (E11)
      drugId: '88888888-5555-5555-5555-555511111111', // Metformin
      standardDosage: 'Take 1 tablet (850mg) twice daily with meals.',
      bhytStatus: true,
    ),
    ICDDrugMappingMock(
      mappingId: '99999999-aaaa-bbbb-cccc-333333333333',
      icdId: '77777777-4444-4444-4444-444411111111', // Acute URI (J06)
      drugId: '88888888-1111-1111-1111-111111111111', // Paracetamol
      standardDosage:
          'Take 1 tablet (500mg) every 4-6 hours as needed for fever or pain. Max 4g/day.',
      bhytStatus: true,
    ),
    ICDDrugMappingMock(
      mappingId: '99999999-aaaa-bbbb-cccc-444444444444',
      icdId: '77777777-5555-5555-5555-555511111111', // Low Back Pain (M54.5)
      drugId: '88888888-4444-4444-4444-444411111111', // Ibuprofen
      standardDosage:
          'Take 1 capsule (400mg) three times daily after meals as needed for severe pain.',
      bhytStatus: false,
    ),
  ];

  // Helper function to search ICD codes
  static List<ICDCodeMock> searchICD(String query) {
    if (query.isEmpty) return icdCodes;
    final lower = query.toLowerCase();
    return icdCodes.where((icd) {
      return icd.icdCode.toLowerCase().contains(lower) ||
          icd.diseaseName.toLowerCase().contains(lower) ||
          icd.diseaseGroup.toLowerCase().contains(lower);
    }).toList();
  }

  // Helper function to search Drugs
  static List<DrugMock> searchDrugs(String query) {
    if (query.isEmpty) return drugs;
    final lower = query.toLowerCase();
    return drugs.where((drug) {
      return drug.brandName.toLowerCase().contains(lower) ||
          drug.activeIngredient.toLowerCase().contains(lower) ||
          drug.manufacturer.toLowerCase().contains(lower);
    }).toList();
  }

  // Helper function to check interactions between a list of selected drugs
  static List<DrugInteractionMock> checkInteractions(
      List<String> selectedDrugIds) {
    List<DrugInteractionMock> results = [];
    if (selectedDrugIds.length < 2) return results;

    for (int i = 0; i < selectedDrugIds.length; i++) {
      for (int j = i + 1; j < selectedDrugIds.length; j++) {
        final id1 = selectedDrugIds[i];
        final id2 = selectedDrugIds[j];

        // Remember our rule: drug1_id must be lexically smaller than drug2_id
        final sortedIds = [id1, id2]..sort();
        final d1 = sortedIds[0];
        final d2 = sortedIds[1];

        // Find matches in interactions list
        final match = interactions.firstWhere(
          (inter) => inter.drug1Id == d1 && inter.drug2Id == d2,
          orElse: () => DrugInteractionMock(
            interactionId: '',
            drug1Id: '',
            drug2Id: '',
            severity: '',
            description: '',
          ),
        );

        if (match.interactionId.isNotEmpty) {
          results.add(match);
        }
      }
    }
    return results;
  }
}
