import 'package:medprescribe_frontend/features/drugs/data/models/drug_model.dart';
import 'package:medprescribe_frontend/services/api_service.dart';

/// Handles drug catalog API calls backed by real PostgreSQL database.
class DrugRepository {
  final ApiService _api;

  DrugRepository({ApiService? apiService}) : _api = apiService ?? api;

  /// Search drugs by name or active ingredient.
  Future<DrugListResponse> search({
    String query = '',
    String ingredient = '',
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _api.get<Map<String, dynamic>>(
      '/drugs',
      queryParams: {
        if (query.isNotEmpty) 'q': query,
        if (ingredient.isNotEmpty) 'ingredient': ingredient,
        'page': page,
        'limit': limit,
      },
    );
    return DrugListResponse.fromJson(response);
  }

  /// Fetch single drug with its interactions.
  Future<DrugModel> getById(String drugId) async {
    final response =
        await _api.get<Map<String, dynamic>>('/drugs/$drugId');
    return DrugModel.fromJson(response);
  }

  /// Get list of active ingredients
  Future<List<String>> getIngredients() async {
    final response = await _api.get<List<dynamic>>('/drugs/ingredients');
    return response.map((e) => e.toString()).toList();
  }
}
