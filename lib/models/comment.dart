class Comment {
  final int id;
  final int postId;
  final String body;
  final int userId;
  final String username;

  Comment({
    required this.id,
    required this.postId,
    required this.body,
    required this.userId,
    required this.username,
  });

// Converts the JSON response from the API into a Comment object.
  factory Comment.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};

    return Comment(
      id: json['id'] ?? 0,
      postId: json['postId'] ?? 0,
      body: json['body'] ?? '',
      userId: user['id'] ?? 0,
      username: user['username'] ?? '',
    );
  }

// Converts the Comment object into JSON format when sending or storing comment data.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'body': body,
      'user': {
        'id': userId,
        'username': username,
      },
    };
  }
}