import 'dart:convert';
import 'package:http/http.dart' as http;
import 'icd_model.dart';

class IcdRepository {
  final String baseUrl = 'http://10.0.2.2:3000/icd'; // Default Android emulator URL

  Future<IcdDetail> getIcdDetail(String id, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return IcdDetail.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load ICD details: ${response.body}');
    }
  }
}
