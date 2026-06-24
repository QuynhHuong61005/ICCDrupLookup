import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'search_history_model.dart';

class SearchHistoryService {
  static const String _storageKey = 'medprescribe_search_history';
  final int _maxItems = 50;

  Future<List<SearchHistoryItem>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStringList = prefs.getStringList(_storageKey) ?? [];
    
    return jsonStringList.map((jsonString) {
      return SearchHistoryItem.fromJson(jsonDecode(jsonString));
    }).toList();
  }

  Future<void> addSearch(String query, String type) async {
    if (query.trim().isEmpty) return;
    
    final prefs = await SharedPreferences.getInstance();
    final currentHistory = await getHistory();

    // Remove if exists to move it to the top
    currentHistory.removeWhere((item) => 
        item.query.toLowerCase() == query.toLowerCase() && item.type == type);

    final newItem = SearchHistoryItem(
      query: query,
      timestamp: DateTime.now(),
      type: type,
    );

    currentHistory.insert(0, newItem);

    // Keep only the most recent items
    if (currentHistory.length > _maxItems) {
      currentHistory.removeLast();
    }

    final jsonStringList = currentHistory.map((item) {
      return jsonEncode(item.toJson());
    }).toList();

    await prefs.setStringList(_storageKey, jsonStringList);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
