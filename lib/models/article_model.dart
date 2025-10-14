class Article {
  final String title;
  final String? description;
  final String url;
  final String? image;
  final String publishedAt;
  final String? content;
  final Source source;

  Article({
    required this.title,
    required this.description,
    required this.url,
    required this.image,
    required this.publishedAt,
    required this.content,
    required this.source,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
        title: json['title'] ?? 'No title',
        description: json['description'],
        url: json['url'] ?? '',
        image: json['image'],
        publishedAt: json['publishedAt'] ?? '',
        content: json['content'],
        source: Source.fromJson(json['source']),
    );
  }
}

class Source {
  final String name;
  final String url;

  Source({
    required this.name,
    required this.url,
  });

  factory Source.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Source(name: 'Unknown', url: '');
    }
    return Source(
      name: json['name'] ?? 'Unknown Source',
      url: json['url'] ?? '',
    );
  }
}