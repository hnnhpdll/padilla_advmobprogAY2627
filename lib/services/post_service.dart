import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/post.dart';

class PostService {
  // Gets a list of posts from the API using pagination.
  Future<List<Post>> getPosts({
    int limit = 30,
    int skip = 0,
  }) async {
    final uri = Uri.parse('$host/posts?limit=$limit&skip=$skip');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      final List postsJson = data['posts'] ?? [];

      return postsJson
          .map((p) => Post.fromJson(p))
          .toList();
    } else {
      throw Exception(
        'Failed to load posts: ${response.statusCode}',
      );
    }
  }

  // Gets all posts created by a specific user from the API.
  Future<List<Post>> getPostsByUserId(int userId) async {
    final uri = Uri.parse('$host/posts/user/$userId');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      final List postsJson = data['posts'] ?? [];

      return postsJson
          .map((p) => Post.fromJson(p))
          .toList();
    } else {
      throw Exception(
        'Failed to load user posts: ${response.statusCode}',
      );
    }
  }
}