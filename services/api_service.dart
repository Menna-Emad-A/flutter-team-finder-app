import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class ApiService {
  static const String _baseUrl = 'https://newsapi.org/v2/top-headlines';
  static const String _apiKey = '044b4316c4b84857adb25000c2bcae64';
  static const String _country = 'us';
  static const String _category = 'sports';

  static Future<List<Article>> fetchArticles() async {
    final response = await http.get(
      Uri.parse('$_baseUrl?country=$_country&category=$_category&apiKey=$_apiKey'),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      List<dynamic> articlesJson = jsonResponse['articles'];

      return articlesJson.map((json) => Article.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load articles');
    }
  }
}
