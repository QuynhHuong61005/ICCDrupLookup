import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medprescribe_frontend/services/mock_data_service.dart';
import 'package:medprescribe_frontend/shared/constants/app_constants.dart';
import 'package:medprescribe_frontend/shared/themes/app_theme.dart';
import 'package:medprescribe_frontend/shared/widgets/app_card.dart';

class DrugDetailScreen extends StatelessWidget {
  final String drugId;

  const DrugDetailScreen({super.key, required this.drugId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Look up the drug inside mock service
    final drug = MockDataService.drugs.firstWhere(
      (element) => element.drugId == drugId,
      orElse: () => DrugMock(
        drugId: '',
        brandName: 'Unknown',
        activeIngredient: 'Unknown',
        concentration: 'Unknown',
        dosageForm: 'Unknown',
        manufacturer: 'Unknown',
        indications: 'Unknown',
        contraindications: 'Unknown',
        sideEffects: 'Unknown',
        warnings: 'Unknown',
      ),
    );

    if (drug.drugId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Drug Not Found')),
        body: const Center(child: Text('Requested drug profile not found.')),
      );
    }

    final mappings = MockDataService.mappings.where((m) => m.drugId == drug.drugId).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(drug.brandName),
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
            // Header card
            AppCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.medication,
                        size: 36, color: theme.colorScheme.primary),
                  ),
                  AppSpacing.gapW16,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          drug.brandName,
                          style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Active: ${drug.activeIngredient} (${drug.concentration})',
                          style: theme.textTheme.bodyLarge,
                        ),
                        Text(
                          'Form: ${drug.dosageForm} • Manufacturer: ${drug.manufacturer}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.gapH24,

            // Accordion sections (ExpansionTiles)
            _buildAccordionTile(
              theme,
              title: 'Indications & Uses',
              content: drug.indications,
              icon: Icons.check_circle_outline,
              iconColor: AppColors.success,
            ),
            AppSpacing.gapH12,
            _buildAccordionTile(
              theme,
              title: 'Contraindications',
              content: drug.contraindications,
              icon: Icons.cancel_outlined,
              iconColor: AppColors.error,
            ),
            AppSpacing.gapH12,
            _buildAccordionTile(
              theme,
              title: 'Side Effects & Adverse Reactions',
              content: drug.sideEffects,
              icon: Icons.bug_report_outlined,
              iconColor: AppColors.warning,
            ),
            AppSpacing.gapH12,
            _buildAccordionTile(
              theme,
              title: 'Warnings & Precautions',
              content: drug.warnings,
              icon: Icons.warning_amber_outlined,
              iconColor: AppColors.error,
            ),
            AppSpacing.gapH12,
            _buildBHYTStatusTile(theme, mappings),
          ],
        ),
      ),
    );
  }

  Widget _buildAccordionTile(
    ThemeData theme, {
    required String title,
    required String content,
    required IconData icon,
    required Color iconColor,
  }) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(icon, color: iconColor),
          title: Text(
            title,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl + 8, 0, AppSpacing.lg, AppSpacing.lg),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  content,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBHYTStatusTile(ThemeData theme, List<ICDDrugMappingMock> mappings) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: const Icon(Icons.health_and_safety, color: AppColors.primary),
          title: Text(
            'BHYT Coverage & Supported Indications',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          children: [
            if (mappings.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.xl + 8, 0, AppSpacing.lg, AppSpacing.lg),
                child: const Text('No specific BHYT mappings found for this drug.'),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.xl + 8, 0, AppSpacing.lg, AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: mappings.map((mapping) {
                    final icd = MockDataService.icdCodes.firstWhere(
                        (i) => i.icdId == mapping.icdId,
                        orElse: () => ICDCodeMock(
                              icdId: '',
                              icdCode: 'Unknown',
                              diseaseName: 'Unknown',
                              diseaseGroup: '',
                              symptoms: [],
                            ));
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${icd.icdCode} - ${icd.diseaseName}',
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              Text(
                                mapping.bhytStatus ? 'BHYT Covered' : 'Non-BHYT',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: mapping.bhytStatus ? AppColors.success : AppColors.warning,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(' • '),
                              Expanded(
                                child: Text(
                                  mapping.standardDosage,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
