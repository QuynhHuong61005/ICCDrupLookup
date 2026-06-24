/// Drug domain model representing a medication entry.
class DrugModel {
  final String drugId;
  final String brandName;
  final String activeIngredient;
  final String concentration;
  final String dosageForm;
  final String manufacturer;
  final String? ddinterId;
  final List<DrugInteractionSummary> interactions;

  const DrugModel({
    required this.drugId,
    required this.brandName,
    required this.activeIngredient,
    required this.concentration,
    required this.dosageForm,
    required this.manufacturer,
    this.ddinterId,
    this.interactions = const [],
  });

  factory DrugModel.fromJson(Map<String, dynamic> json) {
    return DrugModel(
      drugId: json['drugId'] ?? json['drug_id'] ?? '',
      brandName: json['brandName'] ?? json['brand_name'] ?? '',
      activeIngredient: json['activeIngredient'] ?? json['active_ingredient'] ?? '',
      concentration: json['concentration'] ?? '',
      dosageForm: json['dosageForm'] ?? json['dosage_form'] ?? '',
      manufacturer: json['manufacturer'] ?? '',
      ddinterId: json['ddinterId'] ?? json['ddinter_id'],
      interactions: (json['interactions1'] as List<dynamic>? ?? [])
          .map((e) => DrugInteractionSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'drugId': drugId,
        'brandName': brandName,
        'activeIngredient': activeIngredient,
        'concentration': concentration,
        'dosageForm': dosageForm,
        'manufacturer': manufacturer,
      };
}

/// Lightweight interaction summary attached to a drug model.
class DrugInteractionSummary {
  final String interactionId;
  final String otherDrugId;
  final String otherDrugName;
  final String severity;
  final String description;

  const DrugInteractionSummary({
    required this.interactionId,
    required this.otherDrugId,
    required this.otherDrugName,
    required this.severity,
    required this.description,
  });

  factory DrugInteractionSummary.fromJson(Map<String, dynamic> json) {
    final drug2 = json['drug2'] as Map<String, dynamic>? ?? {};
    return DrugInteractionSummary(
      interactionId: json['interactionId'] ?? json['interaction_id'] ?? '',
      otherDrugId: json['drug2Id'] ?? json['drug2_id'] ?? '',
      otherDrugName: drug2['brandName'] ?? drug2['brand_name'] ?? '',
      severity: json['severity'] ?? 'MINOR',
      description: json['description'] ?? '',
    );
  }
}

/// Paginated drug list response.
class DrugListResponse {
  final List<DrugModel> items;
  final int page;
  final bool hasMore;

  const DrugListResponse({
    required this.items,
    required this.page,
    required this.hasMore,
  });

  factory DrugListResponse.fromJson(Map<String, dynamic> json) {
    // Backend returns: { items: [...], page: 1, hasMore: false }
    final rawItems = json['items'] as List<dynamic>?
        ?? json['data'] as List<dynamic>?
        ?? [];
    return DrugListResponse(
      items: rawItems
          .map((e) => DrugModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: (json['page'] as num?)?.toInt() ?? 1,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }
}
