import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'search_history_model.dart';
import 'search_history_service.dart';

final searchHistoryServiceProvider = Provider<SearchHistoryService>((ref) {
  return SearchHistoryService();
});

final searchHistoryProvider = StateNotifierProvider<SearchHistoryNotifier, AsyncValue<List<SearchHistoryItem>>>((ref) {
  return SearchHistoryNotifier(ref.watch(searchHistoryServiceProvider));
});

class SearchHistoryNotifier extends StateNotifier<AsyncValue<List<SearchHistoryItem>>> {
  final SearchHistoryService _service;

  SearchHistoryNotifier(this._service) : super(const AsyncValue.loading()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    state = const AsyncValue.loading();
    try {
      final history = await _service.getHistory();
      state = AsyncValue.data(history);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addSearch(String query, String type) async {
    try {
      await _service.addSearch(query, type);
      await loadHistory();
    } catch (e, st) {
      // In case of error, just log it, don't break the UI
      print('Error saving history: $e');
    }
  }

  Future<void> clearHistory() async {
    try {
      await _service.clearHistory();
      state = const AsyncValue.data([]);
    } catch (e, st) {
      print('Error clearing history: $e');
    }
  }
}
