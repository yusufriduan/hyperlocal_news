import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article_model.dart';

class NewsApiService {
  final String _apiKey = dotenv.env['GNEWS_API_KEY'] ?? '';
  final String _baseUrl = 'https://gnews.io/api/v4/';

  Future<List<Article>> fetchTopHeadlines(String country) async {
    final response = await http.get(Uri.parse('${_baseUrl}top-headlines?country=$country&apikey=$_apiKey'));

    if (response.statusCode == 200)
    {
      final Map<String, dynamic> json = jsonDecode(response.body);
      if (json['articles'] != null) {
        List<dynamic> body = json['articles'];
        List<Article> articles = body.map((dynamic item) => Article.fromJson(item)).toList();
        return articles;
      } else {
        throw Exception(json['errors']?.join(', ') ?? 'Failed to parse articles');
      }
    } else {
      throw Exception('Failed to load articles: ${response.body}');
    }
  }

  Future<List<Article>> fetchNewsByCategory(String country, String category) async {
    final prefs = await SharedPreferences.getInstance();

    final String cacheKey = 'news_category_${country}_$category';
    final String timestampKey = 'news_category_timestamp_${country}_$category';

    final cachedData = prefs.getString(cacheKey);
    final cachedTimestamp = prefs.getInt(timestampKey);

    if (cachedData != null && cachedTimestamp != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final oneHourInMilis = 3600 * 1000;

      if ((now - cachedTimestamp) < oneHourInMilis) {
        print('Using cached data for category: $category');
        final List<dynamic> body = jsonDecode(cachedData);
        final List<Article> articles = body.map((dynamic item) => Article.fromJson(item)).toList();
        return articles;
      }
    }

    print('Fetching new data for category: $category');
    final response = await http.get(Uri.parse('${_baseUrl}top-headlines?country=$country&category=$category&apikey=$_apiKey'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      if (json['articles'] != null) {
        List<dynamic> body = json['articles'];
        List<Article> articles = body.map((dynamic item) => Article.fromJson(item)).toList();
        await prefs.setString(cacheKey, jsonEncode(body));
        await prefs.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);
        return articles;
      } else {
        throw Exception(json['errors']?.join(', ') ?? 'Failed to parse articles');
      }
    } else {
      throw Exception('Failed to load articles: ${response.body}');
    }
  }

}