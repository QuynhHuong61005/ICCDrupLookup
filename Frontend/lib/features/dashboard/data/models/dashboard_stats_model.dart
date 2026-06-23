/// Dashboard statistics model.
class DashboardStatsModel {
  final int totalPrescriptions;
  final int totalDrugs;
  final int totalPatients;
  final int totalInteractionsChecked;
  final int interactionsWithWarnings;
  final List<PrescriptionTrendPoint> prescriptionTrend;
  final List<TopDrugItem> topDrugs;
  final List<RecentActivity> recentActivity;

  const DashboardStatsModel({
    required this.totalPrescriptions,
    required this.totalDrugs,
    required this.totalPatients,
    required this.totalInteractionsChecked,
    required this.interactionsWithWarnings,
    required this.prescriptionTrend,
    required this.topDrugs,
    required this.recentActivity,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalPrescriptions: json['totalPrescriptions'] ?? 0,
      totalDrugs: json['totalDrugs'] ?? 0,
      totalPatients: json['totalPatients'] ?? 0,
      totalInteractionsChecked: json['totalInteractionsChecked'] ?? 0,
      interactionsWithWarnings: json['interactionsWithWarnings'] ?? 0,
      prescriptionTrend: (json['prescriptionTrend'] as List<dynamic>? ?? [])
          .map((e) =>
              PrescriptionTrendPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      topDrugs: (json['topDrugs'] as List<dynamic>? ?? [])
          .map((e) => TopDrugItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentActivity: (json['recentActivity'] as List<dynamic>? ?? [])
          .map((e) => RecentActivity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Fallback mock stats when backend is not available.
  factory DashboardStatsModel.mock() {
    return DashboardStatsModel(
      totalPrescriptions: 248,
      totalDrugs: 1858,
      totalPatients: 134,
      totalInteractionsChecked: 1024,
      interactionsWithWarnings: 87,
      prescriptionTrend: List.generate(
        7,
        (i) => PrescriptionTrendPoint(
          date: DateTime.now().subtract(Duration(days: 6 - i)),
          count: 20 + (i * 5) + (i % 3 == 0 ? 10 : 0),
        ),
      ),
      topDrugs: const [
        TopDrugItem(drugName: 'Paracetamol', count: 145),
        TopDrugItem(drugName: 'Amoxicillin', count: 112),
        TopDrugItem(drugName: 'Metformin', count: 98),
        TopDrugItem(drugName: 'Ibuprofen', count: 76),
        TopDrugItem(drugName: 'Omeprazole', count: 64),
      ],
      recentActivity: const [],
    );
  }
}

class PrescriptionTrendPoint {
  final DateTime date;
  final int count;

  const PrescriptionTrendPoint({required this.date, required this.count});

  factory PrescriptionTrendPoint.fromJson(Map<String, dynamic> json) {
    return PrescriptionTrendPoint(
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      count: json['count'] ?? 0,
    );
  }
}

class TopDrugItem {
  final String drugName;
  final int count;

  const TopDrugItem({required this.drugName, required this.count});

  factory TopDrugItem.fromJson(Map<String, dynamic> json) {
    return TopDrugItem(
      drugName: json['drugName'] ?? json['drug_name'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class RecentActivity {
  final String action;
  final String description;
  final DateTime timestamp;

  const RecentActivity({
    required this.action,
    required this.description,
    required this.timestamp,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      action: json['action'] ?? '',
      description: json['description'] ?? '',
      timestamp:
          DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}
