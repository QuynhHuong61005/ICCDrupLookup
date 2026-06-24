import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medprescribe_frontend/features/drugs/data/models/drug_model.dart';
import 'package:medprescribe_frontend/features/interactions/data/models/interaction_model.dart';
import 'package:medprescribe_frontend/features/interactions/data/repositories/interaction_repository.dart';

// ─── Interaction Checker State ───────────────────────────────────

class InteractionCheckerState {
  final List<DrugModel> selectedDrugs;
  final BatchInteractionResult? result;
  final bool isChecking;
  final String? error;

  const InteractionCheckerState({
    this.selectedDrugs = const [],
    this.result,
    this.isChecking = false,
    this.error,
  });

  InteractionCheckerState copyWith({
    List<DrugModel>? selectedDrugs,
    BatchInteractionResult? result,
    bool? isChecking,
    String? error,
    bool clearResult = false,
  }) {
    return InteractionCheckerState(
      selectedDrugs: selectedDrugs ?? this.selectedDrugs,
      result: clearResult ? null : (result ?? this.result),
      isChecking: isChecking ?? this.isChecking,
      error: error,
    );
  }

  bool get canCheck => selectedDrugs.length >= 2;
}

// ─── Interaction Checker Notifier ────────────────────────────────

class InteractionCheckerNotifier
    extends StateNotifier<InteractionCheckerState> {
  final InteractionRepository _repo;

  InteractionCheckerNotifier(this._repo)
      : super(const InteractionCheckerState());

  void addDrug(DrugModel drug) {
    final already = state.selectedDrugs.any((d) => d.drugId == drug.drugId);
    if (already) return;
    state = state.copyWith(
      selectedDrugs: [...state.selectedDrugs, drug],
      clearResult: true,
    );
  }

  void removeDrug(String drugId) {
    state = state.copyWith(
      selectedDrugs: state.selectedDrugs.where((d) => d.drugId != drugId).toList(),
      clearResult: true,
    );
  }

  void clearAll() {
    state = const InteractionCheckerState();
  }

  Future<void> checkInteractions() async {
    if (!state.canCheck) return;
    state = state.copyWith(isChecking: true, error: null);

    try {
      final ids = state.selectedDrugs.map((d) => d.drugId).toList();
      final result = await _repo.checkBatch(ids);
      state = state.copyWith(isChecking: false, result: result);
    } catch (e) {
      state = state.copyWith(
        isChecking: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}

// ─── Providers ───────────────────────────────────────────────────

final interactionRepositoryProvider =
    Provider<InteractionRepository>((ref) => InteractionRepository());

final interactionCheckerProvider = StateNotifierProvider<
    InteractionCheckerNotifier, InteractionCheckerState>((ref) {
  return InteractionCheckerNotifier(ref.watch(interactionRepositoryProvider));
});
