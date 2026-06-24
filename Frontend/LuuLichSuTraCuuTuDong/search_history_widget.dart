import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'search_history_provider.dart';

class SearchHistoryWidget extends ConsumerWidget {
  final String type;
  final Function(String query) onHistoryItemSelected;

  const SearchHistoryWidget({
    super.key,
    required this.type,
    required this.onHistoryItemSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(searchHistoryProvider);

    return historyAsync.when(
      data: (history) {
        final filteredHistory = history.where((item) => item.type == type).toList();
        
        if (filteredHistory.isEmpty) {
          return const SizedBox.shrink();
        }

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Lịch sử tìm kiếm',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        ref.read(searchHistoryProvider.notifier).clearHistory();
                      },
                      child: Text(
                        'Xóa lịch sử',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredHistory.length > 5 ? 5 : filteredHistory.length, // Show top 5
                itemBuilder: (context, index) {
                  final item = filteredHistory[index];
                  return ListTile(
                    leading: const Icon(Icons.history, color: Colors.grey, size: 20),
                    title: Text(item.query, style: const TextStyle(fontSize: 14)),
                    trailing: Text(
                      DateFormat('dd/MM HH:mm').format(item.timestamp),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    onTap: () => onHistoryItemSelected(item.query),
                  );
                },
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}
