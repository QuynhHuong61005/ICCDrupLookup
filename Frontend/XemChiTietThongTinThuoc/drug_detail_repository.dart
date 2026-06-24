import 'dart:convert';
import 'package:http/http.dart' as http;
import 'drug_detail_model.dart';

class DrugDetailRepository {
  final String baseUrl = 'http://10.0.2.2:3000/drugs'; // Default Android emulator URL

  Future<DrugDetail> getDrugDetail(String id, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return DrugDetail.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load Drug details: ${response.body}');
    }
  }
}
