import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medprescribe_frontend/features/dashboard/data/models/dashboard_stats_model.dart';
import 'package:medprescribe_frontend/features/dashboard/data/repositories/dashboard_repository.dart';

final dashboardRepositoryProvider =
    Provider<DashboardRepository>((ref) => DashboardRepository());

/// Async provider for dashboard statistics.
final dashboardStatsProvider =
    FutureProvider<DashboardStatsModel>((ref) async {
  return ref.watch(dashboardRepositoryProvider).getStats();
});

/// Provider for refreshing dashboard.
final dashboardRefreshProvider = StateProvider<int>((ref) => 0);
