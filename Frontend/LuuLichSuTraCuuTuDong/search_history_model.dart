import 'dart:convert';

class SearchHistoryItem {
  final String query;
  final DateTime timestamp;
  final String type; // 'drug', 'icd', 'interaction'

  SearchHistoryItem({
    required this.query,
    required this.timestamp,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
    };
  }

  factory SearchHistoryItem.fromJson(Map<String, dynamic> json) {
    return SearchHistoryItem(
      query: json['query'],
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'],
    );
  }
}
