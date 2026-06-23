import 'package:medprescribe_frontend/features/dashboard/data/models/dashboard_stats_model.dart';
import 'package:medprescribe_frontend/services/api_service.dart';

/// Handles dashboard statistics API calls backed by real PostgreSQL database.
class DashboardRepository {
  final ApiService _api;

  DashboardRepository({ApiService? apiService}) : _api = apiService ?? api;

  Future<DashboardStatsModel> getStats() async {
    final response =
        await _api.get<Map<String, dynamic>>('/dashboard/stats');
    return DashboardStatsModel.fromJson(response);
  }
}
