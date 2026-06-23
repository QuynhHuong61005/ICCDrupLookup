import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medprescribe_frontend/features/icd/presentation/providers/icd_provider.dart';
import 'package:medprescribe_frontend/shared/constants/app_constants.dart';
import 'package:medprescribe_frontend/shared/widgets/app_card.dart';
import 'package:medprescribe_frontend/shared/widgets/app_text_field.dart';

class IcdLookupScreen extends ConsumerStatefulWidget {
  const IcdLookupScreen({super.key});

  @override
  ConsumerState<IcdLookupScreen> createState() => _IcdLookupScreenState();
}

class _IcdLookupScreenState extends ConsumerState<IcdLookupScreen> {
  final _searchController = TextEditingController();
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
      ref.read(icdSearchProvider.notifier).search(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(icdSearchProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search header card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  controller: _searchController,
                  label: 'Search ICD-10 Disease Codes or Names',
                  hint: 'Type "Hypertension" or "A09"...',
                  prefixIcon: Icons.search,
                  onChanged: _onSearchChanged,
                ),
              ],
            ),
          ),
          AppSpacing.gapH24,

          // Status row
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

          // Result list
          Expanded(
            child: (!state.isLoading && state.items.isEmpty)
                ? const Center(
                    child: Text('No disease codes match your search criteria.'),
                  )
                : ListView.builder(
                    itemCount: state.items.length + (state.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.items.length) {
                        // Load more button
                        return Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: ElevatedButton(
                            onPressed: () => ref.read(icdSearchProvider.notifier).loadMore(),
                            child: const Text('Load More'),
                          ),
                        );
                      }
                      final item = state.items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: AppCard(
                          padding: EdgeInsets.zero,
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.08),
                                borderRadius: AppRadius.smBorderRadius,
                              ),
                              child: Text(
                                item.icdCode,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            title: Text(
                              item.diseaseName,
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontSize: 16),
                            ),
                            subtitle: Text(item.diseaseGroup),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              context.push('/icd/detail/${item.icdId}');
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
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
