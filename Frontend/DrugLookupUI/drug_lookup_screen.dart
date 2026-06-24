import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medprescribe_frontend/features/drugs/presentation/providers/drug_provider.dart';
import 'package:medprescribe_frontend/shared/constants/app_constants.dart';
import 'package:medprescribe_frontend/shared/widgets/app_card.dart';
import 'package:medprescribe_frontend/shared/widgets/app_text_field.dart';

class DrugLookupScreen extends ConsumerStatefulWidget {
  const DrugLookupScreen({super.key});

  @override
  ConsumerState<DrugLookupScreen> createState() => _DrugLookupScreenState();
}

class _DrugLookupScreenState extends ConsumerState<DrugLookupScreen> {
  final _searchController = TextEditingController();
  final List<bool> _viewSelection = [true, false]; // Card View vs List View
  // Debounce timer
  final _debounce = _Debouncer(milliseconds: 300);

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(drugSearchProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search & Views Filter Card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _searchController,
                        label: 'Search Drugs (Brand or Active Ingredient)',
                        hint: 'Type "Paracetamol" or "Aspirin"...',
                        prefixIcon: Icons.search,
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    AppSpacing.gapW16,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'View Style',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        AppSpacing.gapH8,
                        ToggleButtons(
                          isSelected: _viewSelection,
                          onPressed: (index) {
                            setState(() {
                              for (int i = 0; i < _viewSelection.length; i++) {
                                _viewSelection[i] = i == index;
                              }
                            });
                          },
                          borderRadius: AppRadius.mdBorderRadius,
                          constraints:
                              const BoxConstraints(minWidth: 46, minHeight: 46),
                          children: const [
                            Icon(Icons.grid_view),
                            Icon(Icons.view_list),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.gapH24,

          // Loading / Error States
          if (state.isLoading)
            const Center(child: CircularProgressIndicator()),

          if (state.error != null)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                'Error: ${state.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),

          // Grid vs List Render
          Expanded(
            child: (!state.isLoading && state.items.isEmpty)
                ? const Center(
                    child: Text('No drugs found matching criteria.'),
                  )
                : _viewSelection[0]
                    ? _buildGridView(theme, state.items, state.hasMore)
                    : _buildListView(theme, state.items, state.hasMore),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(ThemeData theme, items, bool hasMore) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 320,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.25,
      ),
      itemCount: items.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == items.length) {
          return ElevatedButton(
            onPressed: () => ref.read(drugSearchProvider.notifier).loadMore(),
            child: const Text('Load More'),
          );
        }
        final drug = items[index];
        return AppCard(
          onTap: () => context.push('/drugs/detail/${drug.drugId}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: AppRadius.smBorderRadius,
                    ),
                    child: Text(
                      drug.dosageForm ?? 'Drug',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  AppSpacing.gapH8,
                  Text(
                    drug.brandName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${drug.activeIngredient} (${drug.concentration ?? ''})',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      drug.manufacturer ?? '',
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios,
                      size: 12, color: theme.colorScheme.primary),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListView(ThemeData theme, items, bool hasMore) {
    return ListView.builder(
      itemCount: items.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == items.length) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: ElevatedButton(
              onPressed: () => ref.read(drugSearchProvider.notifier).loadMore(),
              child: const Text('Load More'),
            ),
          );
        }
        final drug = items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: AppCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: Icon(Icons.medication,
                  color: theme.colorScheme.primary, size: 36),
              title: Text(
                drug.brandName,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                  '${drug.activeIngredient} • ${drug.concentration ?? ''} • ${drug.manufacturer ?? ''}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/drugs/detail/${drug.drugId}'),
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
