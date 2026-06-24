import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medprescribe_frontend/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:medprescribe_frontend/shared/constants/app_constants.dart';
import 'package:medprescribe_frontend/shared/themes/app_theme.dart';
import 'package:medprescribe_frontend/shared/widgets/app_card.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: AppCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    color: AppColors.error, size: 48),
                AppSpacing.gapH16,
                Text('Failed to load dashboard',
                    style: theme.textTheme.titleMedium),
                AppSpacing.gapH8,
                Text(error.toString(), style: const TextStyle(color: AppColors.error)),
                AppSpacing.gapH16,
                ElevatedButton(
                  onPressed: () => ref.invalidate(dashboardStatsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (stats) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'System Overview',
                      style: theme.textTheme.headlineSmall,
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => ref.invalidate(dashboardStatsProvider),
                      tooltip: 'Refresh Dashboard',
                    ),
                  ],
                ),
                AppSpacing.gapH16,
                // Analytics grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 900
                        ? 4
                        : (constraints.maxWidth > 600 ? 2 : 1);
                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      childAspectRatio: 1.5,
                      children: [
                        _buildStatCard(
                          context,
                          title: 'Total Prescriptions',
                          value: stats.totalPrescriptions.toString(),
                          icon: Icons.note_alt,
                          iconColor: theme.colorScheme.primary,
                        ),
                        _buildStatCard(
                          context,
                          title: 'Total Drugs',
                          value: stats.totalDrugs.toString(),
                          icon: Icons.medical_services,
                          iconColor: Colors.teal,
                        ),
                        _buildStatCard(
                          context,
                          title: 'Total Patients',
                          value: stats.totalPatients.toString(),
                          icon: Icons.people,
                          iconColor: Colors.orange,
                        ),
                        _buildStatCard(
                          context,
                          title: 'Interactions Checked',
                          value: stats.totalInteractionsChecked.toString(),
                          icon: Icons.check_circle_outline,
                          iconColor: AppColors.success,
                        ),
                      ],
                    );
                  },
                ),
                AppSpacing.gapH24,

                // Charts Section
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 800) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildPrescriptionVolumeChart(theme, stats),
                          ),
                          AppSpacing.gapW16,
                          Expanded(
                            flex: 2,
                            child: _buildRecentActivityList(theme, stats),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          _buildPrescriptionVolumeChart(theme, stats),
                          AppSpacing.gapH16,
                          _buildRecentActivityList(theme, stats),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: AppRadius.smBorderRadius,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ],
          ),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionVolumeChart(ThemeData theme, stats) {
    if (stats.prescriptionTrend.isEmpty) {
      return AppCard(
        child: SizedBox(
          height: 250,
          child: const Center(child: Text('No trend data available')),
        ),
      );
    }

    // Convert API dates to chart spots
    final spots = <FlSpot>[];
    final dates = <String>[];
    
    // Sort by date just in case
    final trendData = List.from(stats.prescriptionTrend)
      ..sort((a, b) => a.date.compareTo(b.date));

    for (int i = 0; i < trendData.length; i++) {
      spots.add(FlSpot(i.toDouble(), trendData[i].count.toDouble()));
      dates.add(DateFormat('MM/dd').format(trendData[i].date));
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prescription Trend (Last 7 Days)',
            style: theme.textTheme.titleMedium,
          ),
          AppSpacing.gapH24,
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: theme.brightness == Brightness.light
                        ? Colors.grey.withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.05),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < dates.length) {
                          return Text(dates[index],
                              style: const TextStyle(fontSize: 10));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: theme.colorScheme.primary,
                    barWidth: 4,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityList(ThemeData theme, stats) {
    if (stats.recentActivity.isEmpty) {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Activity', style: theme.textTheme.titleMedium),
            const SizedBox(height: 100, child: Center(child: Text('No recent activity'))),
          ],
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent System Actions',
            style: theme.textTheme.titleMedium,
          ),
          AppSpacing.gapH16,
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stats.recentActivity.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final act = stats.recentActivity[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  child: Icon(Icons.history, color: theme.colorScheme.primary, size: 20),
                ),
                title: Text(
                  act.action,
                  style: theme.textTheme.bodyLarge?.copyWith(fontSize: 14),
                ),
                subtitle: Text(act.description),
                contentPadding: EdgeInsets.zero,
              );
            },
          ),
        ],
      ),
    );
  }
}
