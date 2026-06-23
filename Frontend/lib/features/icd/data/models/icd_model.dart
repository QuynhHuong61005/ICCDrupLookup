/// ICD-10 disease code model.
class IcdModel {
  final String icdId;
  final String icdCode;
  final String diseaseName;
  final String diseaseGroup;
  final List<DrugRecommendation> recommendedDrugs;

  const IcdModel({
    required this.icdId,
    required this.icdCode,
    required this.diseaseName,
    required this.diseaseGroup,
    this.recommendedDrugs = const [],
  });

  factory IcdModel.fromJson(Map<String, dynamic> json) {
    return IcdModel(
      icdId: json['icdId'] ?? json['icd_id'] ?? '',
      icdCode: json['icdCode'] ?? json['icd_code'] ?? '',
      diseaseName: json['diseaseName'] ?? json['disease_name'] ?? '',
      diseaseGroup: json['diseaseGroup'] ?? json['disease_group'] ?? '',
      recommendedDrugs: (json['mappings'] as List<dynamic>? ?? [])
          .map((e) => DrugRecommendation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'icdId': icdId,
        'icdCode': icdCode,
        'diseaseName': diseaseName,
        'diseaseGroup': diseaseGroup,
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
      mappingId: json['mappingId'] ?? json['mapping_id'] ?? '',
      drugId: json['drugId'] ?? json['drug_id'] ?? drug['drugId'] ?? drug['drug_id'] ?? '',
      brandName: drug['brandName'] ?? drug['brand_name'] ?? '',
      activeIngredient: drug['activeIngredient'] ?? drug['active_ingredient'] ?? '',
      standardDosage: json['standardDosage'] ?? json['standard_dosage'] ?? '',
      bhytStatus: json['bhytStatus'] ?? json['bhyt_status'] ?? false,
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
    // Backend returns: { items: [...], page: 1, hasMore: false }
    final rawItems = json['items'] as List<dynamic>?
        ?? json['data'] as List<dynamic>?
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
