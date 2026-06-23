/// ICD-10 disease code model — mapped to real API response fields.
/// API returns: { code, name_en, name_vi, diseaseGroup, description, is_active }
class IcdModel {
  final String icdId;      // uses 'code' as identifier (e.g. "A01")
  final String icdCode;    // same as icdId
  final String diseaseName;
  final String diseaseNameVi;
  final String diseaseGroup;
  final String description;
  final List<DrugRecommendation> recommendedDrugs;

  const IcdModel({
    required this.icdId,
    required this.icdCode,
    required this.diseaseName,
    this.diseaseNameVi = '',
    this.diseaseGroup = '',
    this.description = '',
    this.recommendedDrugs = const [],
  });

  factory IcdModel.fromJson(Map<String, dynamic> json) {
    // API uses 'code' as the primary key (no UUID)
    final code = json['code']?.toString()
        ?? json['icdCode']?.toString()
        ?? json['icd_code']?.toString()
        ?? json['icdId']?.toString()
        ?? json['icd_id']?.toString()
        ?? json['id']?.toString()
        ?? '';

    final name = json['name_en']?.toString()
        ?? json['diseaseName']?.toString()
        ?? json['disease_name']?.toString()
        ?? json['name']?.toString()
        ?? '';

    return IcdModel(
      icdId: code,
      icdCode: code,
      diseaseName: name,
      diseaseNameVi: json['name_vi']?.toString() ?? '',
      diseaseGroup: json['diseaseGroup']?.toString()
          ?? json['disease_group']?.toString()
          ?? json['category']?.toString()
          ?? '',
      description: json['description']?.toString() ?? '',
      recommendedDrugs: (json['mappings'] as List<dynamic>?
              ?? json['treatmentGuidelines'] as List<dynamic>?
              ?? json['treatment_guidelines'] as List<dynamic>?
              ?? [])
          .map((e) => DrugRecommendation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'code': icdCode,
        'name_en': diseaseName,
        'name_vi': diseaseNameVi,
        'diseaseGroup': diseaseGroup,
        'description': description,
      };
}

/// Represents a drug recommendation linked to an ICD code.
class DrugRecommendation {
  final String mappingId;
  final String drugId;
  final String brandName;
  final String activeIngredient;
  final String standardDosage;
  final bool bhytStatus;

  const DrugRecommendation({
    required this.mappingId,
    required this.drugId,
    required this.brandName,
    required this.activeIngredient,
    required this.standardDosage,
    required this.bhytStatus,
  });

  factory DrugRecommendation.fromJson(Map<String, dynamic> json) {
    final drug = json['drug'] as Map<String, dynamic>? ?? {};
    return DrugRecommendation(
      mappingId: json['mappingId']?.toString()
          ?? json['mapping_id']?.toString()
          ?? '',
      drugId: json['drugId']?.toString()
          ?? json['drug_id']?.toString()
          ?? drug['drugId']?.toString()
          ?? drug['drug_id']?.toString()
          ?? drug['id']?.toString()
          ?? '',
      brandName: drug['brandName']?.toString()
          ?? drug['brand_name']?.toString()
          ?? drug['name']?.toString()
          ?? '',
      activeIngredient: drug['activeIngredient']?.toString()
          ?? drug['active_ingredient']?.toString()
          ?? '',
      standardDosage: json['standardDosage']?.toString()
          ?? json['standard_dosage']?.toString()
          ?? '',
      bhytStatus: json['bhytStatus'] as bool?
          ?? json['bhyt_status'] as bool?
          ?? false,
    );
  }
}

/// Paginated list of ICD codes.
class IcdListResponse {
  final List<IcdModel> items;
  final int page;
  final bool hasMore;

  const IcdListResponse({
    required this.items,
    required this.page,
    required this.hasMore,
  });

  factory IcdListResponse.fromJson(Map<String, dynamic> json) {
    // API returns: { data: [...], page: 1, hasMore: true }
    // (also check 'items' key for flexibility)
    final rawItems = json['data'] as List<dynamic>?
        ?? json['items'] as List<dynamic>?
        ?? [];
    return IcdListResponse(
      items: rawItems
          .map((e) => IcdModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: (json['page'] as num?)?.toInt() ?? 1,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }
}
