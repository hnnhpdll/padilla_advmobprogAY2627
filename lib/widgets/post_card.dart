import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../constants.dart';
import '../screens/detail_screen.dart';
import '../services/comment_service.dart';
import '../models/comment.dart';
import 'custom_font.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 18.sp,
                ),
                SizedBox(width: 5.w),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NewsFeedCard extends StatefulWidget {
  final int postId;

  final String userName;
  final String postContent;
  final String date;
  final int numOfLikes;
  final String imageUrl;
  final String profileImageUrl;

  final ValueChanged<int> onLikeChanged;

  const NewsFeedCard({
    super.key,
    required this.postId,
    required this.userName,
    required this.postContent,
    required this.numOfLikes,
    required this.date,
    required this.onLikeChanged,
    this.imageUrl = "",
    this.profileImageUrl = "",
  });

  @override
  State<NewsFeedCard> createState() => _NewsFeedCardState();
}

class _NewsFeedCardState extends State<NewsFeedCard> {
  final CommentService _commentService = CommentService();

  final TextEditingController _commentController =
      TextEditingController();

  late int likes;

  bool liked = false;
  bool showComments = false;
  bool isLoadingComments = false;

  List<Comment> comments = [];

  @override
  void initState() {
    super.initState();
    likes = widget.numOfLikes;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }


  // LIKE - Updates the like count and notifies the parent widget when the user likes or unlikes a post.

  void toggleLike() {
    setState(() {
      if (liked) {
        likes--;
      } else {
        likes++;
      }

      liked = !liked;
    });

    widget.onLikeChanged(likes);
  }

  // LOAD COMMENTS
// Retrieves comments for the current post through CommentService and updates the comment list.
  Future<void> loadComments() async {
    if (showComments) {
      setState(() {
        showComments = false;
      });
      return;
    }

    setState(() {
      showComments = true;
      isLoadingComments = true;
    });

    try {
      final result =
          await _commentService.getCommentsByPostId(widget.postId);

      if (!mounted) return;

      setState(() {
        comments = result;
        isLoadingComments = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingComments = false;
      });

      debugPrint('Error loading comments: $e');
    }
  }

  // =========================
  // ADD COMMENT
  // =========================

  void addComment() {
    final text = _commentController.text.trim();

    if (text.isEmpty) {
      return;
    }

    setState(() {
      comments.add(
        Comment(
          id: DateTime.now().millisecondsSinceEpoch,
          postId: widget.postId,
          body: text,
          userId: 0,
          username: widget.userName,
        ),
      );

      _commentController.clear();
      showComments = true;
    });
  }

  // =========================
  // DETAIL SCREEN
  // =========================

  void openDetailScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(
  postId: widget.postId,
  userName: widget.userName,
  postContent: widget.postContent,
  date: widget.date,
  numOfLikes: likes,
          imageUrl: widget.imageUrl,
          profileImageUrl: widget.profileImageUrl,
          onLikeChanged: (newLikes) {
            setState(() {
              likes = newLikes;
              liked = newLikes > widget.numOfLikes;
            });

            widget.onLikeChanged(newLikes);
          },
        ),
      ),
    );
  }

  // =========================
  // COMMENT INPUT
  // =========================

  Widget buildCommentInput() {
    return Row(
      children: [
        CircleAvatar(
          radius: 15,
          backgroundColor: Colors.grey[300],
          child: const Icon(
            Icons.person,
            size: 18,
            color: Colors.grey,
          ),
        ),

        SizedBox(width: 10.w),

        Expanded(
          child: TextField(
            controller: _commentController,
            decoration: InputDecoration(
              hintText: 'Write a comment...',
              hintStyle: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey,
              ),
              filled: true,
              fillColor: Colors.grey[200],
              contentPadding: EdgeInsets.symmetric(
                horizontal: 10.w,
                vertical: 5.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        SizedBox(width: 5.w),

        IconButton(
          icon: Icon(
            Icons.send,
            color: FB_DARK_PRIMARY,
            size: 20.sp,
          ),
          onPressed: addComment,
        ),
      ],
    );
  }

  // =========================
  // COMMENT LIST
  // =========================

  Widget buildComments() {
    if (isLoadingComments) {
      return const Padding(
        padding: EdgeInsets.all(10),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (comments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Text(
          'No comments yet.',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      );
    }

    return Column(
      children: comments.map((comment) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: Colors.grey[300],
                child: const Icon(
                  Icons.person,
                  size: 16,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.username.isEmpty
                            ? 'User'
                            : comment.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        comment.body,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10.sp),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => openDetailScreen(context),
        child: Padding(
          padding: EdgeInsets.all(10.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // =========================
              // PROFILE HEADER
              // =========================

              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[300],
                    child: ClipOval(
                      child: widget.profileImageUrl
                              .startsWith('http')
                          ? CachedNetworkImage(
                              imageUrl:
                                  widget.profileImageUrl,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) {
                                return const CircularProgressIndicator(
                                  strokeWidth: 2,
                                );
                              },
                              errorWidget:
                                  (context, url, error) {
                                return const Icon(
                                  Icons.person,
                                );
                              },
                            )
                          : const Icon(
                              Icons.person,
                            ),
                    ),
                  ),

                  SizedBox(width: 10.w),

                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      CustomFont(
                        text: widget.userName,
                        fontSize: 15.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),

                      Row(
                        children: [
                          CustomFont(
                            text: widget.date,
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),

                          SizedBox(width: 3.w),

                          Icon(
                            Icons.public,
                            color: Colors.grey,
                            size: 15.sp,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Spacer(),

                  const Icon(Icons.more_horiz),
                ],
              ),

              SizedBox(height: 8.h),

              // =========================
              // POST CONTENT
              // =========================

              CustomFont(
                text: widget.postContent,
                fontSize: 12.sp,
                color: Colors.black,
              ),

              SizedBox(height: 8.h),

              // =========================
              // IMAGE
              // =========================

              if (widget.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                    errorWidget: (context, url, error) {
                      return const Icon(
                        Icons.broken_image,
                      );
                    },
                  ),
                ),

              SizedBox(height: 10.h),

              // =========================
              // ACTION BUTTONS
              // =========================

              Row(
                children: [

                  ActionButton(
                    icon: Icons.thumb_up,
                    label: likes.toString(),
                    color: liked
                        ? Colors.blue
                        : FB_DARK_PRIMARY,
                    onTap: toggleLike,
                  ),

                  ActionButton(
                    icon: Icons.comment,
                    label: 'Comment',
                    color: FB_DARK_PRIMARY,
                    onTap: loadComments,
                  ),

                  ActionButton(
                    icon: Icons.redo,
                    label: 'Share',
                    color: FB_DARK_PRIMARY,
                    onTap: () {},
                  ),
                ],
              ),

              SizedBox(height: 10.h),

              // =========================
              // COMMENT INPUT
              // =========================

              buildCommentInput(),

              SizedBox(height: 10.h),

              // =========================
              // VIEW COMMENTS
              // =========================

              GestureDetector(
                onTap: loadComments,
                child: CustomFont(
                  text: showComments
                      ? "Hide comments"
                      : "View comments",
                  fontSize: 12.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // =========================
              // COMMENTS
              // =========================

              if (showComments) ...[
                SizedBox(height: 10.h),
                buildComments(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}