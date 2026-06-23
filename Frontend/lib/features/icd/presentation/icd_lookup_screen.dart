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
  final _debounce = _Debouncer(milliseconds: 400);

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
          // ── Search Bar ──────────────────────────────────────────
          AppCard(
            child: AppTextField(
              controller: _searchController,
              label: 'Tra cứu mã bệnh lý ICD-10',
              hint: 'Nhập "Hypertension", "A09", "Typhoid"...',
              prefixIcon: Icons.search,
              onChanged: _onSearchChanged,
            ),
          ),
          AppSpacing.gapH16,

          // ── Count row ──────────────────────────────────────────
          if (!state.isLoading && state.items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Hiển thị ${state.items.length} kết quả${state.query.isNotEmpty ? ' cho "${state.query}"' : ''}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.hintColor),
              ),
            ),

          if (!state.isLoading && state.items.isNotEmpty)
            AppSpacing.gapH8,

          // ── Loading ────────────────────────────────────────────
          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(child: CircularProgressIndicator()),
            ),

          // ── Error ──────────────────────────────────────────────
          if (state.error != null)
            AppCard(
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  AppSpacing.gapW8,
                  Expanded(
                    child: Text(
                      state.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),

          // ── Empty ──────────────────────────────────────────────
          if (!state.isLoading && state.error == null && state.items.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off,
                        size: 64,
                        color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                    AppSpacing.gapH16,
                    Text(
                      state.query.isEmpty
                          ? 'Nhập từ khoá để tìm kiếm bệnh lý'
                          : 'Không tìm thấy kết quả cho "${state.query}"',
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(color: theme.hintColor),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

          // ── Results ───────────────────────────────────────────
          if (!state.isLoading && state.items.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: state.items.length + (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  // Load more button
                  if (index == state.items.length) {
                    return Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            ref.read(icdSearchProvider.notifier).loadMore(),
                        icon: const Icon(Icons.expand_more),
                        label: const Text('Tải thêm'),
                      ),
                    );
                  }

                  final item = state.items[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: AppCard(
                      padding: EdgeInsets.zero,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                        leading: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs),
                          constraints: const BoxConstraints(minWidth: 56),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.08),
                            borderRadius: AppRadius.smBorderRadius,
                          ),
                          child: Text(
                            item.icdCode,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        title: Text(
                          item.diseaseName,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontSize: 15),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.diseaseNameVi.isNotEmpty)
                              Text(
                                item.diseaseNameVi,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.8),
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            if (item.diseaseGroup.isNotEmpty)
                              Text(
                                item.diseaseGroup,
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: theme.hintColor),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        // Navigate using icdCode (e.g. "A01") as route param
                        onTap: () {
                          final id = Uri.encodeComponent(item.icdCode);
                          context.push('/icd/detail/$id');
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
