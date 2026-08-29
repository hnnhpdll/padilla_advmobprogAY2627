import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:padilla_mobprog/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../widgets/custom_font.dart';
import '../widgets/comment_card.dart';

import '../services/comment_service.dart';
import '../services/user_service.dart';
import '../models/comment.dart';

class DetailScreen extends StatefulWidget {
  final int postId;

  final String userName;
  final String postContent;
  final String date;
  final int numOfLikes;
  final String imageUrl;
  final String profileImageUrl;

  final ValueChanged<int>? onLikeChanged;

  const DetailScreen({
    super.key,
    required this.postId,
    required this.userName,
    required this.postContent,
    required this.date,
    this.numOfLikes = 0,
    this.imageUrl = "",
    this.profileImageUrl = "",
    this.onLikeChanged,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late int likes;
  bool liked = false;

  final CommentService _commentService = CommentService();
  final UserService _userService = UserService();

  final TextEditingController _commentController =
      TextEditingController();

  List<Comment> comments = [];
  bool isLoadingComments = true;
  bool isAddingComment = false;

  @override
  void initState() {
    super.initState();

    likes = widget.numOfLikes;

    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // LIKE
  // Updates the local like count and notifies the previous screen of the new value.
  void toggleLike() {
    setState(() {
      if (liked) {
        likes--;
      } else {
        likes++;
      }

      liked = !liked;
    });

    widget.onLikeChanged?.call(likes);
  }

  // LOAD COMMENTS
  // Retrieves all comments belonging to the current post from the API.
  Future<void> _loadComments() async {
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
    }
  }

  // ADD COMMENT
  // Gets the logged-in user, sends the new comment to the API,
// and adds the returned comment to the displayed comment list.
  Future<void> _addComment() async {
    final text = _commentController.text.trim();

    if (text.isEmpty) return;

    setState(() {
      isAddingComment = true;
    });

    try {
      // GET LOGGED-IN USER
      final user = await _userService.getUserData();

      if (user == null) {
       
        if (mounted) {
          setState(() {
            isAddingComment = false;
          });
        }

        return;
      }

      // SEND COMMENT TO API
      final newComment = await _commentService.addComment(
        postId: widget.postId,
        userId: user.id,
        body: text,
      );

      // CREATE COMMENT USING THE LOGGED-IN USER
      final myComment = Comment(
        id: newComment.id,
        postId: widget.postId,
        body: text,
        userId: user.id,
        username: user.username,
      );

      if (!mounted) return;

      setState(() {
        comments.add(myComment);
        _commentController.clear();
        isAddingComment = false;
      });
    } catch (e) {
  
      if (!mounted) return;

      setState(() {
        isAddingComment = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add comment.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: CustomFont(
          text: widget.userName,
          fontSize: 20.sp,
          color: Colors.black,
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            // POST IMAGE
            if (widget.imageUrl.isNotEmpty)
              widget.imageUrl.startsWith('http')
                  ? CachedNetworkImage(
                      imageUrl: widget.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.broken_image),
                    )
                  : Image.asset(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                    ),

            SizedBox(height: 20.h),

            // POST HEADER
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [

                  widget.profileImageUrl.isEmpty
                      ? const CircleAvatar(
                          radius: 25,
                          child: Icon(Icons.person),
                        )
                      : CircleAvatar(
                          radius: 25.r,
                          backgroundImage:
                              widget.profileImageUrl.startsWith('http')
                                  ? CachedNetworkImageProvider(
                                      widget.profileImageUrl,
                                    )
                                  : AssetImage(
                                      widget.profileImageUrl,
                                    ) as ImageProvider,
                        ),

                  SizedBox(width: 10.w),

                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      CustomFont(
                        text: widget.userName,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black,
                      ),

                      Row(
                        children: [
                          CustomFont(
                            text: widget.date,
                            fontSize: 15.sp,
                            color: Colors.grey,
                          ),

                          SizedBox(width: 3.w),

                          Icon(
                            Icons.public,
                            color: Colors.grey,
                            size: 18.sp,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Spacer(),

                  const Icon(Icons.more_horiz),
                ],
              ),
            ),

            SizedBox(height: 15.h),

            // POST CONTENT
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: CustomFont(
                  text: widget.postContent,
                  fontSize: 18.sp,
                  color: Colors.black,
                ),
              ),
            ),

            SizedBox(height: 30.h),

            const Divider(),

            // ACTION BUTTONS
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [

                  // LIKE
                  TextButton.icon(
                    onPressed: toggleLike,
                    icon: Icon(
                      Icons.thumb_up,
                      color: liked
                          ? Colors.blue
                          : FB_DARK_PRIMARY,
                    ),
                    label: CustomFont(
                      text: likes.toString(),
                      fontSize: 12.sp,
                      color: liked
                          ? Colors.blue
                          : FB_DARK_PRIMARY,
                    ),
                  ),

                  // COMMENT
                  TextButton.icon(
                    onPressed: () {
                      FocusScope.of(context).requestFocus(
                        FocusNode(),
                      );
                    },
                    icon: const Icon(
                      Icons.comment,
                      color: FB_DARK_PRIMARY,
                    ),
                    label: CustomFont(
                      text: "Comment",
                      fontSize: 12.sp,
                      color: FB_DARK_PRIMARY,
                    ),
                  ),

                  // SHARE
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.redo,
                      color: FB_DARK_PRIMARY,
                    ),
                    label: CustomFont(
                      text: "Share",
                      fontSize: 12.sp,
                      color: FB_DARK_PRIMARY,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            // COMMENTS TITLE
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: CustomFont(
                  text: 'Comments',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            SizedBox(height: 10.h),

            // COMMENTS
if (isLoadingComments)
  const Padding(
    padding: EdgeInsets.all(20),
    child: Center(
      child: CircularProgressIndicator(),
    ),
  )
else if (comments.isEmpty)
  Padding(
    padding: const EdgeInsets.all(20),
    child: CustomFont(
      text: 'No comments yet.',
      fontSize: 14.sp,
      color: Colors.grey,
    ),
  )
else
  ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: comments.length,
    itemBuilder: (context, index) {
      return CommentCard(
        comment: comments[index],
      );
    },
  ),

SizedBox(height: 10.h),

// ADD COMMENT
Padding(
  padding: EdgeInsets.symmetric(horizontal: 20.w),
  child: Row(
    children: [
      const CircleAvatar(
        radius: 18,
        child: Icon(
          Icons.person,
          size: 20,
        ),
      ),

      SizedBox(width: 10.w),

      Expanded(
        child: TextField(
          controller: _commentController,
          enabled: !isAddingComment,
          decoration: InputDecoration(
            hintText: 'Write a comment...',
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),

      IconButton(
        onPressed: isAddingComment ? null : _addComment,
        icon: isAddingComment
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : const Icon(
                Icons.send,
                color: FB_DARK_PRIMARY,
              ),
      ),
    ],
  ),
),

SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }
}