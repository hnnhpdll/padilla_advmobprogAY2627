import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/comment.dart';

class CommentService {
  // Gets all comments associated with a specific post from the API.
  Future<List<Comment>> getCommentsByPostId(int postId) async {
    final uri = Uri.parse('$host/comments/post/$postId');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List commentsJson = data['comments'] ?? [];

      return commentsJson
          .map((comment) => Comment.fromJson(comment))
          .toList();
    } else {
      throw Exception(
        'Failed to load comments: ${response.statusCode}',
      );
    }
  }

  // Sends a new comment to the API using the post ID, user ID, and comment body.
  Future<Comment> addComment({
    required int postId,
    required int userId,
    required String body,
  }) async {
    final uri = Uri.parse('$host/comments/add');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'body': body,
        'postId': postId,
        'userId': userId,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);

      return Comment.fromJson(data);
    } else {
      throw Exception(
        'Failed to add comment: ${response.statusCode}',
      );
    }
  }
}