import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medprescribe_frontend/features/icd/data/models/icd_model.dart';
import 'package:medprescribe_frontend/features/icd/data/repositories/icd_repository.dart';

// ─── ICD Search State ────────────────────────────────────────────

class IcdSearchState {
  final List<IcdModel> items;
  final bool isLoading;
  final String? error;
  final String query;
  final bool hasMore;
  final int currentPage;

  const IcdSearchState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.query = '',
    this.hasMore = false,
    this.currentPage = 1,
  });

  IcdSearchState copyWith({
    List<IcdModel>? items,
    bool? isLoading,
    String? error,
    String? query,
    bool? hasMore,
    int? currentPage,
  }) {
    return IcdSearchState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      query: query ?? this.query,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

// ─── ICD Search Notifier ─────────────────────────────────────────

class IcdSearchNotifier extends StateNotifier<IcdSearchState> {
  final IcdRepository _repo;

  IcdSearchNotifier(this._repo) : super(const IcdSearchState()) {
    search('');
  }

  Future<void> search(String query, {bool reset = true}) async {
    if (reset) {
      state = IcdSearchState(query: query, isLoading: true);
    } else {
      state = state.copyWith(isLoading: true);
    }

    try {
      final page = reset ? 1 : state.currentPage + 1;
      final response = await _repo.search(query: query, page: page);
      final newItems = reset ? response.items : [...state.items, ...response.items];
      state = IcdSearchState(
        items: newItems,
        query: query,
        hasMore: response.hasMore,
        currentPage: page,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;
    await search(state.query, reset: false);
  }

  void clearError() => state = state.copyWith(error: null);
}

// ─── ICD Detail State ────────────────────────────────────────────

class IcdDetailNotifier extends StateNotifier<AsyncValue<IcdModel>> {
  final IcdRepository _repo;

  IcdDetailNotifier(this._repo) : super(const AsyncValue.loading());

  Future<void> load(String icdId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.getById(icdId));
  }
}

// ─── Providers ───────────────────────────────────────────────────

final icdRepositoryProvider = Provider<IcdRepository>((ref) => IcdRepository());

final icdSearchProvider =
    StateNotifierProvider<IcdSearchNotifier, IcdSearchState>((ref) {
  return IcdSearchNotifier(ref.watch(icdRepositoryProvider));
});

final icdDetailProvider = StateNotifierProvider.family<IcdDetailNotifier,
    AsyncValue<IcdModel>, String>((ref, icdId) {
  final notifier = IcdDetailNotifier(ref.watch(icdRepositoryProvider));
  notifier.load(icdId);
  return notifier;
});
