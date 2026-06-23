import 'package:medprescribe_frontend/features/icd/data/models/icd_model.dart';
import 'package:medprescribe_frontend/services/api_service.dart';

/// Handles ICD-10 disease code API calls backed by real PostgreSQL database.
class IcdRepository {
  final ApiService _api;

  IcdRepository({ApiService? apiService}) : _api = apiService ?? api;

  /// Search ICD codes by query string.
  Future<IcdListResponse> search({
    String query = '',
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _api.get<Map<String, dynamic>>(
      '/icd',
      queryParams: {
        if (query.isNotEmpty) 'q': query,
        'page': page,
        'limit': limit,
      },
    );
    return IcdListResponse.fromJson(response);
  }

  /// Fetch a single ICD code with its drug recommendations.
  Future<IcdModel> getById(String icdId) async {
    final response =
        await _api.get<Map<String, dynamic>>('/icd/$icdId');
    return IcdModel.fromJson(response);
  }
}
