class DrugDetail {
  final String drugId;
  final String brandName;
  final String activeIngredient;
  final String concentration;
  final String dosageForm;
  final String manufacturer;
  final List<DrugInteraction> interactions;

  DrugDetail({
    required this.drugId,
    required this.brandName,
    required this.activeIngredient,
    required this.concentration,
    required this.dosageForm,
    required this.manufacturer,
    required this.interactions,
  });

  factory DrugDetail.fromJson(Map<String, dynamic> json) {
    return DrugDetail(
      drugId: json['drugId'] ?? '',
      brandName: json['brandName'] ?? '',
      activeIngredient: json['activeIngredient'] ?? '',
      concentration: json['concentration'] ?? '',
      dosageForm: json['dosageForm'] ?? '',
      manufacturer: json['manufacturer'] ?? '',
      interactions: (json['interactions'] as List?)
              ?.map((e) => DrugInteraction.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class DrugInteraction {
  final String interactionId;
  final String otherDrugId;
  final String otherDrugName;
  final String severity;
  final String description;

  DrugInteraction({
    required this.interactionId,
    required this.otherDrugId,
    required this.otherDrugName,
    required this.severity,
    required this.description,
  });

  factory DrugInteraction.fromJson(Map<String, dynamic> json) {
    return DrugInteraction(
      interactionId: json['interactionId'] ?? '',
      otherDrugId: json['otherDrugId'] ?? '',
      otherDrugName: json['otherDrugName'] ?? '',
      severity: json['severity'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
