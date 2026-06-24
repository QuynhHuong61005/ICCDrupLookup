import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medprescribe_frontend/services/mock_data_service.dart';
import 'package:medprescribe_frontend/shared/constants/app_constants.dart';
import 'package:medprescribe_frontend/shared/themes/app_theme.dart';
import 'package:medprescribe_frontend/shared/widgets/app_card.dart';

class DiseaseDetailScreen extends StatelessWidget {
  final String icdId;

  const DiseaseDetailScreen({super.key, required this.icdId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Find the disease in mock database
    final disease = MockDataService.icdCodes.firstWhere(
      (element) => element.icdId == icdId,
      orElse: () => ICDCodeMock(
        icdId: '',
        icdCode: 'Unknown',
        diseaseName: 'Unknown Disease',
        diseaseGroup: 'Unknown Group',
        symptoms: [],
      ),
    );

    if (disease.icdId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Disease Not Found')),
        body: const Center(
            child: Text('The requested disease profile was not found.')),
      );
    }

    // Find suggested drugs for this ICD code
    final suggestedMappings = MockDataService.mappings
        .where((m) => m.icdId == disease.icdId)
        .toList();
    final suggestedDrugs = suggestedMappings.map((m) {
      return MockDataService.drugs.firstWhere((d) => d.drugId == m.drugId);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('${disease.icdCode} - ${disease.diseaseName}'),
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
            // Disease Header Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.08),
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
                              style: theme.textTheme.titleLarge
                                  ?.copyWith(fontSize: 22),
                            ),
                            Text(
                              disease.diseaseGroup,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AppSpacing.gapH24,

            // Symptoms Wrap Section
            Text(
              'Associated Symptoms',
              style: theme.textTheme.titleMedium,
            ),
            AppSpacing.gapH12,
            AppCard(
              child: disease.symptoms.isEmpty
                  ? const Text('No symptoms cataloged for this diagnosis.')
                  : Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: disease.symptoms.map((symptom) {
                        return Chip(
                          label: Text(symptom),
                          backgroundColor:
                              theme.colorScheme.primary.withValues(alpha: 0.05),
                          side: BorderSide(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.12)),
                        );
                      }).toList(),
                    ),
            ),
            AppSpacing.gapH24,

            // Suggested Mapped Drugs Grid
            Text(
              'Standard Suggested Drugs',
              style: theme.textTheme.titleMedium,
            ),
            AppSpacing.gapH12,
            suggestedDrugs.isEmpty
                ? const AppCard(
                    child: Text(
                        'No standard drug mappings currently configured for this ICD code.'),
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
                    itemCount: suggestedDrugs.length,
                    itemBuilder: (context, index) {
                      final drug = suggestedDrugs[index];
                      final mapping = suggestedMappings[index];
                      return AppCard(
                        onTap: () {
                          // Route to Drug Detail (Screen 6)
                          context.push('/drugs/detail/${drug.drugId}');
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  drug.brandName,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  drug.activeIngredient,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
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
                                      mapping.bhytStatus
                                          ? 'BHYT Covered'
                                          : 'Non-BHYT',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: mapping.bhytStatus
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
  }
}
