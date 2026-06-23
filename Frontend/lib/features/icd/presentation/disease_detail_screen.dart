import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medprescribe_frontend/features/icd/presentation/providers/icd_provider.dart';
import 'package:medprescribe_frontend/shared/constants/app_constants.dart';
import 'package:medprescribe_frontend/shared/themes/app_theme.dart';
import 'package:medprescribe_frontend/shared/widgets/app_card.dart';

class DiseaseDetailScreen extends ConsumerWidget {
  final String icdId;

  const DiseaseDetailScreen({super.key, required this.icdId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncDisease = ref.watch(icdDetailProvider(icdId));

    return asyncDisease.when(
      loading: () => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Disease Detail'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: AppCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                AppSpacing.gapH16,
                Text('Failed to load disease detail', style: theme.textTheme.titleMedium),
                AppSpacing.gapH8,
                Text(err.toString(), style: const TextStyle(color: AppColors.error)),
                AppSpacing.gapH16,
                ElevatedButton(
                  onPressed: () => ref.invalidate(icdDetailProvider(icdId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (disease) {
        return Scaffold(
          appBar: AppBar(
            title: Text('${disease.icdCode} — ${disease.diseaseName}'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Disease Header Card ─────────────────────────────
                AppCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.08),
                          borderRadius: AppRadius.smBorderRadius,
                        ),
                        child: Text(
                          disease.icdCode,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      AppSpacing.gapW16,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              disease.diseaseName,
                              style: theme.textTheme.titleLarge?.copyWith(fontSize: 22),
                            ),
                            AppSpacing.gapH4,
                            Text(
                              disease.diseaseGroup,
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(color: theme.hintColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapH24,

                // ── Suggested Drugs Grid (từ treatment_guidelines) ──
                Text('Standard Suggested Drugs', style: theme.textTheme.titleMedium),
                AppSpacing.gapH12,
                disease.recommendedDrugs.isEmpty
                    ? const AppCard(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Text(
                              'No standard drug mappings configured for this ICD code.'),
                        ),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 300,
                          mainAxisSpacing: AppSpacing.md,
                          crossAxisSpacing: AppSpacing.md,
                          childAspectRatio: 1.4,
                        ),
                        itemCount: disease.recommendedDrugs.length,
                        itemBuilder: (context, index) {
                          final rec = disease.recommendedDrugs[index];
                          return AppCard(
                            onTap: rec.drugId.isNotEmpty
                                ? () => context.push('/drugs/detail/${rec.drugId}')
                                : null,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      rec.brandName,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      rec.activeIngredient,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (rec.standardDosage.isNotEmpty)
                                      Text(
                                        rec.standardDosage,
                                        style: theme.textTheme.bodySmall,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Divider(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          rec.bhytStatus ? 'BHYT Covered' : 'Non-BHYT',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: rec.bhytStatus
                                                ? AppColors.success
                                                : AppColors.warning,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Icon(Icons.arrow_forward, size: 16),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}
