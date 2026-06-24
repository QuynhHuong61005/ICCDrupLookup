import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medprescribe_frontend/features/drugs/data/models/drug_model.dart';
import 'package:medprescribe_frontend/features/drugs/data/repositories/drug_repository.dart';

// ─── Drug Search State ───────────────────────────────────────────

class DrugSearchState {
  final List<DrugModel> items;
  final bool isLoading;
  final String? error;
  final String query;
  final String ingredient;
  final bool hasMore;
  final int currentPage;

  const DrugSearchState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.query = '',
    this.ingredient = '',
    this.hasMore = false,
    this.currentPage = 1,
  });

  DrugSearchState copyWith({
    List<DrugModel>? items,
    bool? isLoading,
    String? error,
    String? query,
    String? ingredient,
    bool? hasMore,
    int? currentPage,
  }) {
    return DrugSearchState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      query: query ?? this.query,
      ingredient: ingredient ?? this.ingredient,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class DrugSearchNotifier extends StateNotifier<DrugSearchState> {
  final DrugRepository _repo;

  DrugSearchNotifier(this._repo) : super(const DrugSearchState()) {
    search('');
  }

  Future<void> search(String query, {String? ingredient, bool reset = true}) async {
    final searchIngredient = ingredient ?? state.ingredient;
    if (reset) {
      state = DrugSearchState(query: query, ingredient: searchIngredient, isLoading: true);
    } else {
      state = state.copyWith(isLoading: true);
    }

    try {
      final page = reset ? 1 : state.currentPage + 1;
      final response = await _repo.search(query: query, ingredient: searchIngredient, page: page);
      final newItems = reset ? response.items : [...state.items, ...response.items];
      state = DrugSearchState(
        items: newItems,
        query: query,
        ingredient: searchIngredient,
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

// ─── Drug Detail Notifier ────────────────────────────────────────

class DrugDetailNotifier extends StateNotifier<AsyncValue<DrugModel>> {
  final DrugRepository _repo;

  DrugDetailNotifier(this._repo) : super(const AsyncValue.loading());

  Future<void> load(String drugId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.getById(drugId));
  }
}

// ─── Providers ───────────────────────────────────────────────────

final drugRepositoryProvider =
    Provider<DrugRepository>((ref) => DrugRepository());

final drugSearchProvider =
    StateNotifierProvider<DrugSearchNotifier, DrugSearchState>((ref) {
  return DrugSearchNotifier(ref.watch(drugRepositoryProvider));
});

final drugDetailProvider = StateNotifierProvider.family<DrugDetailNotifier,
    AsyncValue<DrugModel>, String>((ref, drugId) {
  final notifier = DrugDetailNotifier(ref.watch(drugRepositoryProvider));
  notifier.load(drugId);
  return notifier;
});

final drugIngredientsProvider = FutureProvider<List<String>>((ref) async {
  return ref.watch(drugRepositoryProvider).getIngredients();
});
