import 'package:medprescribe_frontend/features/drugs/data/models/drug_model.dart';

/// Severity levels for drug interactions (matches backend enum).
enum InteractionSeverity {
  minor,
  moderate,
  severe,
  contraindicated;

  static InteractionSeverity fromString(String value) {
    switch (value.toUpperCase()) {
      case 'MINOR':
        return InteractionSeverity.minor;
      case 'MODERATE':
        return InteractionSeverity.moderate;
      case 'SEVERE':
        return InteractionSeverity.severe;
      case 'CONTRAINDICATED':
        return InteractionSeverity.contraindicated;
      default:
        return InteractionSeverity.minor;
    }
  }

  String get label {
    switch (this) {
      case InteractionSeverity.minor:
        return 'Minor';
      case InteractionSeverity.moderate:
        return 'Moderate';
      case InteractionSeverity.severe:
        return 'Severe';
      case InteractionSeverity.contraindicated:
        return 'Contraindicated';
    }
  }
}

/// Full drug interaction model.
class InteractionModel {
  final String interactionId;
  final String drug1Id;
  final String drug2Id;
  final DrugModel? drug1;
  final DrugModel? drug2;
  final InteractionSeverity severity;
  final String description;

  const InteractionModel({
    required this.interactionId,
    required this.drug1Id,
    required this.drug2Id,
    this.drug1,
    this.drug2,
    required this.severity,
    required this.description,
  });

  factory InteractionModel.fromJson(Map<String, dynamic> json) {
    return InteractionModel(
      interactionId: json['interactionId'] ?? json['interaction_id'] ?? '',
      drug1Id: json['drug1Id'] ?? json['drug1_id'] ?? '',
      drug2Id: json['drug2Id'] ?? json['drug2_id'] ?? '',
      drug1: json['drug1'] != null
          ? DrugModel.fromJson(json['drug1'] as Map<String, dynamic>)
          : null,
      drug2: json['drug2'] != null
          ? DrugModel.fromJson(json['drug2'] as Map<String, dynamic>)
          : null,
      severity: InteractionSeverity.fromString(json['severity'] ?? 'MINOR'),
      description: json['description'] ?? '',
    );
  }
}

/// Result of a drug-pair interaction check.
class InteractionCheckResult {
  final String drug1Id;
  final String drug2Id;
  final String drug1Name;
  final String drug2Name;
  final bool hasInteraction;
  final InteractionModel? interaction;

  const InteractionCheckResult({
    required this.drug1Id,
    required this.drug2Id,
    required this.drug1Name,
    required this.drug2Name,
    required this.hasInteraction,
    this.interaction,
  });

  factory InteractionCheckResult.fromJson(Map<String, dynamic> json) {
    return InteractionCheckResult(
      drug1Id: json['drug1Id'] ?? '',
      drug2Id: json['drug2Id'] ?? '',
      drug1Name: json['drug1Name'] ?? '',
      drug2Name: json['drug2Name'] ?? '',
      hasInteraction: json['hasInteraction'] ?? false,
      interaction: json['interaction'] != null
          ? InteractionModel.fromJson(
              json['interaction'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Batch check request containing all drug pairs to validate.
class BatchInteractionCheckRequest {
  final List<String> drugIds;

  const BatchInteractionCheckRequest({required this.drugIds});

  Map<String, dynamic> toJson() => {'drugIds': drugIds};
}

/// Batch interaction check result.
class BatchInteractionResult {
  final List<InteractionCheckResult> results;
  final bool hasAnyInteraction;
  final int severeCount;
  final int moderateCount;
  final int minorCount;

  const BatchInteractionResult({
    required this.results,
    required this.hasAnyInteraction,
    required this.severeCount,
    required this.moderateCount,
    required this.minorCount,
  });

  factory BatchInteractionResult.fromJson(Map<String, dynamic> json) {
    final results = (json['results'] as List<dynamic>? ?? [])
        .map((e) =>
            InteractionCheckResult.fromJson(e as Map<String, dynamic>))
        .toList();

    int severe = 0, moderate = 0, minor = 0;
    for (final r in results) {
      if (r.interaction != null) {
        switch (r.interaction!.severity) {
          case InteractionSeverity.severe:
          case InteractionSeverity.contraindicated:
            severe++;
            break;
          case InteractionSeverity.moderate:
            moderate++;
            break;
          case InteractionSeverity.minor:
            minor++;
            break;
        }
      }
    }

    return BatchInteractionResult(
      results: results,
      hasAnyInteraction: results.any((r) => r.hasInteraction),
      severeCount: severe,
      moderateCount: moderate,
      minorCount: minor,
    );
  }
}
