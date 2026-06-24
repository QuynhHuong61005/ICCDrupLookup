import 'package:medprescribe_frontend/features/interactions/data/models/interaction_model.dart';
import 'package:medprescribe_frontend/services/api_service.dart';

/// Handles drug interaction API calls backed by real PostgreSQL database.
class InteractionRepository {
  final ApiService _api;

  InteractionRepository({ApiService? apiService}) : _api = apiService ?? api;

  /// Check all interactions within a set of drugs (batch).
  Future<BatchInteractionResult> checkBatch(List<String> drugIds) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/interactions/check-batch',
      data: BatchInteractionCheckRequest(drugIds: drugIds).toJson(),
    );
    return BatchInteractionResult.fromJson(response);
  }
}
