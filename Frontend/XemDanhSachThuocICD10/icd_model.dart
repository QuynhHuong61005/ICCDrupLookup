class IcdDetail {
  final String icdId;
  final String icdCode;
  final String diseaseName;
  final String diseaseGroup;
  final List<RecommendedDrug> recommendedDrugs;

  IcdDetail({
    required this.icdId,
    required this.icdCode,
    required this.diseaseName,
    required this.diseaseGroup,
    required this.recommendedDrugs,
  });

  factory IcdDetail.fromJson(Map<String, dynamic> json) {
    return IcdDetail(
      icdId: json['icdId'] ?? '',
      icdCode: json['icdCode'] ?? '',
      diseaseName: json['diseaseName'] ?? '',
      diseaseGroup: json['diseaseGroup'] ?? '',
      recommendedDrugs: (json['recommendedDrugs'] as List?)
              ?.map((e) => RecommendedDrug.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class RecommendedDrug {
  final String drugId;
  final String brandName;
  final String activeIngredient;
  final String standardDosage;
  final String bhytStatus;

  RecommendedDrug({
    required this.drugId,
    required this.brandName,
    required this.activeIngredient,
    required this.standardDosage,
    required this.bhytStatus,
  });

  factory RecommendedDrug.fromJson(Map<String, dynamic> json) {
    return RecommendedDrug(
      drugId: json['drugId'] ?? '',
      brandName: json['brandName'] ?? '',
      activeIngredient: json['activeIngredient'] ?? '',
      standardDosage: json['standardDosage'] ?? '',
      bhytStatus: json['bhytStatus'] ?? '',
    );
  }
}
