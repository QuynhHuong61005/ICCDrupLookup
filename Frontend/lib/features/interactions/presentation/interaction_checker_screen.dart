import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medprescribe_frontend/features/drugs/presentation/providers/drug_provider.dart';
import 'package:medprescribe_frontend/features/interactions/presentation/providers/interaction_provider.dart';
import 'package:medprescribe_frontend/shared/constants/app_constants.dart';
import 'package:medprescribe_frontend/shared/themes/app_theme.dart';
import 'package:medprescribe_frontend/shared/widgets/app_button.dart';
import 'package:medprescribe_frontend/shared/widgets/app_card.dart';
import 'package:medprescribe_frontend/shared/widgets/app_text_field.dart';

class InteractionCheckerScreen extends ConsumerStatefulWidget {
  const InteractionCheckerScreen({super.key});

  @override
  ConsumerState<InteractionCheckerScreen> createState() =>
      _InteractionCheckerScreenState();
}

class _InteractionCheckerScreenState
    extends ConsumerState<InteractionCheckerScreen> {
  final _searchController = TextEditingController();
  final _debounce = _Debouncer(milliseconds: 300);
  bool _showDrugSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce.run(() {
      ref.read(drugSearchProvider.notifier).search(query);
    });
  }

  void _toggleDrugSearch() {
    setState(() {
      _showDrugSearch = !_showDrugSearch;
      if (_showDrugSearch) {
        _searchController.clear();
        ref.read(drugSearchProvider.notifier).search('');
      }
    });
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toUpperCase()) {
      case 'SEVERE':
      case 'CONTRAINDICATED':
        return AppColors.error;
      case 'MODERATE':
        return AppColors.warning;
      case 'MINOR':
      default:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final checkerState = ref.watch(interactionCheckerProvider);
    final drugSearchState = ref.watch(drugSearchProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column: Selected Drug Checklist + Drug Search
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Selected Drugs (${checkerState.selectedDrugs.length})',
                        style: theme.textTheme.titleMedium,
                      ),
                      Row(
                        children: [
                          AppButton(
                            text: _showDrugSearch ? 'Close Search' : 'Add Drug',
                            icon: _showDrugSearch ? Icons.close : Icons.add,
                            onPressed: _toggleDrugSearch,
                            width: 150,
                          ),
                          if (checkerState.selectedDrugs.isNotEmpty) ...[
                            AppSpacing.gapW8,
                            TextButton.icon(
                              onPressed: () => ref
                                  .read(interactionCheckerProvider.notifier)
                                  .clearAll(),
                              icon: const Icon(Icons.clear_all, size: 16),
                              label: const Text('Clear'),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Inline Drug Search Panel
                if (_showDrugSearch) ...[
                  AppSpacing.gapH12,
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(
                          controller: _searchController,
                          label: 'Search Drug to Add',
                          hint: 'Type brand name or active ingredient...',
                          prefixIcon: Icons.search,
                          onChanged: _onSearchChanged,
                        ),
                        AppSpacing.gapH12,
                        if (drugSearchState.isLoading)
                          const Center(child: CircularProgressIndicator())
                        else
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: drugSearchState.items.length,
                              itemBuilder: (context, index) {
                                final drug = drugSearchState.items[index];
                                final isAdded = checkerState.selectedDrugs
                                    .any((d) => d.drugId == drug.drugId);
                                return ListTile(
                                  dense: true,
                                  title: Text(drug.brandName,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold)),
                                  subtitle: Text(
                                      '${drug.activeIngredient} • ${drug.concentration}'),
                                  trailing: isAdded
                                      ? Icon(Icons.check_circle,
                                          color: theme.colorScheme.primary)
                                      : const Icon(Icons.add_circle_outline),
                                  enabled: !isAdded,
                                  onTap: isAdded
                                      ? null
                                      : () {
                                          ref
                                              .read(interactionCheckerProvider
                                                  .notifier)
                                              .addDrug(drug);
                                          // Auto-trigger check if ≥ 2 drugs selected
                                          if (checkerState.selectedDrugs.length >=
                                              2) {
                                            Future.microtask(() => ref
                                                .read(interactionCheckerProvider
                                                    .notifier)
                                                .checkInteractions());
                                          }
                                        },
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ],

                AppSpacing.gapH16,
                Expanded(
                  child: checkerState.selectedDrugs.isEmpty
                      ? const AppCard(
                          child: Center(
                            child: Text(
                              'No drugs selected. Click "Add Drug" to begin scan.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: checkerState.selectedDrugs.length,
                          itemBuilder: (context, index) {
                            final drug = checkerState.selectedDrugs[index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                  bottom: AppSpacing.sm),
                              child: AppCard(
                                padding: EdgeInsets.zero,
                                child: ListTile(
                                  leading: const Icon(Icons.medication,
                                      color: AppColors.primary),
                                  title: Text(
                                    drug.brandName,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontSize: 16),
                                  ),
                                  subtitle: Text(
                                      '${drug.activeIngredient} (${drug.concentration})'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: AppColors.error),
                                    onPressed: () {
                                      ref
                                          .read(interactionCheckerProvider
                                              .notifier)
                                          .removeDrug(drug.drugId);
                                      // Re-check if still ≥ 2 drugs
                                      if (checkerState.selectedDrugs.length >
                                          2) {
                                        ref
                                            .read(interactionCheckerProvider
                                                .notifier)
                                            .checkInteractions();
                                      }
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),

                if (checkerState.selectedDrugs.length >= 2) ...[
                  AppSpacing.gapH12,
                  AppButton(
                    text: checkerState.isChecking
                        ? 'Checking...'
                        : 'Check Interactions',
                    icon: Icons.biotech,
                    onPressed: checkerState.isChecking
                        ? null
                        : () => ref
                            .read(interactionCheckerProvider.notifier)
                            .checkInteractions(),
                  ),
                ],
              ],
            ),
          ),
          AppSpacing.gapW16,
          // Right Column: Interaction Warnings
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppCard(
                  child: Text(
                    'Interaction Results',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                AppSpacing.gapH16,
                Expanded(
                  child: _buildResultsPanel(theme, checkerState),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsPanel(ThemeData theme, checkerState) {
    if (checkerState.isChecking) {
      return const AppCard(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Checking interactions against database...'),
            ],
          ),
        ),
      );
    }

    if (checkerState.error != null) {
      return AppCard(
        child: Center(
          child: Text(
            'Error: ${checkerState.error}',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      );
    }

    if (checkerState.selectedDrugs.length < 2) {
      return const AppCard(
        child: Center(
          child: Text(
            'Please select at least 2 drugs to verify interactions.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (checkerState.result == null) {
      return const AppCard(
        child: Center(
          child: Text(
            'Click "Check Interactions" to scan for drug interactions.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final interactingResults = checkerState.result!.results
        .where((r) => r.hasInteraction)
        .toList();

    if (interactingResults.isEmpty) {
      return AppCard(
        backgroundColor: AppColors.success.withValues(alpha: 0.08),
        hasBorder: true,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline,
                  color: AppColors.success, size: 48),
              AppSpacing.gapH16,
              Text(
                'No interactions found between selected drugs.',
                style: TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacing.gapH8,
              Text(
                'All ${checkerState.selectedDrugs.length} drugs appear to be safe to use together.',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: interactingResults.length,
      itemBuilder: (context, index) {
        final result = interactingResults[index];
        final severity = result.interaction?.severity.name.toUpperCase() ?? 'MINOR';
        final color = _getSeverityColor(severity);

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: AppCard(
            backgroundColor: color.withValues(alpha: 0.05),
            hasBorder: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: AppRadius.smBorderRadius,
                      ),
                      child: Text(
                        severity,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    AppSpacing.gapW16,
                    Expanded(
                      child: Text(
                        '${result.drug1Name} ↔ ${result.drug2Name}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapH12,
                Text(
                  result.interaction?.description ?? '',
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Simple debouncer utility
class _Debouncer {
  final int milliseconds;
  VoidCallback? _action;
  bool _disposed = false;

  _Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    if (_disposed) return;
    _action = action;
    Future.delayed(Duration(milliseconds: milliseconds), () {
      if (!_disposed && _action == action) {
        action();
      }
    });
  }

  void dispose() {
    _disposed = true;
    _action = null;
  }
}
