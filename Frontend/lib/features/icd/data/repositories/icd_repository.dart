import 'package:medprescribe_frontend/features/icd/data/models/icd_model.dart';
import 'package:medprescribe_frontend/services/api_service.dart';

/// Handles ICD-10 disease code API calls backed by real PostgreSQL database.
/// Backend controller: GET /api/icd?q=&page=
/// Backend detail:     GET /api/icd/:code
class IcdRepository {
  final ApiService _api;

  IcdRepository({ApiService? apiService}) : _api = apiService ?? api;

  /// Search ICD codes.
  /// Backend accepts: q (query string), page (1-based)
  /// Backend returns: { items: [...], page: N, hasMore: bool }
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
      },
    );
    return IcdListResponse.fromJson(response);
  }

  /// Fetch single ICD code detail by code (e.g. "A01").
  /// Backend uses iCDCode.code as unique lookup key.
  /// Route param must be URL-encoded before calling this.
  Future<IcdModel> getById(String icdCode) async {
    final response =
        await _api.get<Map<String, dynamic>>('/icd/$icdCode');
    return IcdModel.fromJson(response);
  }
}
