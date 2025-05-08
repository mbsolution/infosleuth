class SearchQuery {
  final String id;
  final String query;
  final DateTime timestamp;
  SearchQuery({required this.id, required this.query, required this.timestamp});
  factory SearchQuery.fromJson(Map<String, dynamic> json) => SearchQuery(
        id: json['id'],
        query: json['query'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}
