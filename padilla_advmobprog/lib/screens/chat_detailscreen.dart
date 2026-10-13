import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/custom_text.dart';
import '../services/chat_service.dart';
import '../services/user_service.dart';

final ChatService chatService = ChatService();

class ChatDetailScreen extends StatefulWidget {
  final String currentUserEmail;
  final Map<String, dynamic> tappedUser;

  const ChatDetailScreen({
    Key? key,
    required this.currentUserEmail,
    required this.tappedUser,
  }) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final FocusNode _msgFocus = FocusNode();
  final ScrollController _scrollCtrl = ScrollController();

  late Future<String> _currentUserIdFuture;

  bool _isSending = false;
  Timestamp? _sendingStartedAt;

  static const _postSendDelay =
      Duration(milliseconds: 600);

  @override
  void initState() {
    super.initState();
    _currentUserIdFuture = _getCurrentUserId();
  }

  Future<String> _getCurrentUserId() async {
    final userData = await UserService().getUserData();

    return (userData['uid'] ?? '').toString();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _msgFocus.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send(
    String currentUserId,
    String receiverId,
  ) async {
    final text = _msgCtrl.text.trim();

    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
      _sendingStartedAt = Timestamp.now();
    });

    try {
      await chatService.sendMessage(
        receiverId,
        text,
      );

      _msgCtrl.clear();
      _msgFocus.requestFocus();

      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          0.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }

      await Future.delayed(_postSendDelay);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
          _sendingStartedAt = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tappedUserId =
        (widget.tappedUser['uid'] ?? '').toString();

    // Your Firebase user documents use fName
    // instead of the professor's firstName.
    final tappedUserName =
        (widget.tappedUser['fName'] ?? 'Unknown').toString();

    return Material(
  child: FutureBuilder<String>(
      future: _currentUserIdFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snap.hasError ||
            !snap.hasData ||
            snap.data!.isEmpty) {
          return const Scaffold(
            body: Center(
              child: Text('Error loading user data'),
            ),
          );
        }

        final currentUserId = snap.data!;
// ENHANCEMENT 3: Mark received messages as read when the chat is opened

        chatService.markMessagesAsRead(
  currentUserId,
  tappedUserId,
);

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: CustomText(
              text: tappedUserName,
              fontSize: 25.sp,
            ),
          ),

          body: Column(
            children: [
        
              // MESSAGES
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: chatService.getMessage(
                    currentUserId,
                    tappedUserId,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading messages: ${snapshot.error}',
                        ),
                      );
                    }

                    final docs =
                        snapshot.data?.docs ?? [];

                    // Hide just-sent messages until
                    // the short delay is finished.
                    final filteredDocs =
                        docs.where((doc) {
                      if (_sendingStartedAt == null) {
                        return true;
                      }

                      final data =
                          doc.data()
                              as Map<String, dynamic>;

                      final timestamp =
                          data['timestamp'];

                      if (timestamp is! Timestamp) {
                        return true;
                      }

                      return timestamp
                          .compareTo(_sendingStartedAt!) < 0;
                    }).toList();

                    if (filteredDocs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No messages yet',
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollCtrl,
                      reverse: true,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        final data =
                            filteredDocs[index].data()
                                as Map<String, dynamic>;

                        final senderId =
                            (data['senderId'] ?? '')
                                .toString();

                        final message =
                            (data['message'] ?? '')
                                .toString();
// ENHANCEMENT 3: Display the timestamp of each message
                                final timestamp = data['timestamp'] is Timestamp
    ? data['timestamp'] as Timestamp
    : null;

                        final isMe =
                            senderId == currentUserId;

// ENHANCEMENT 3: Redesigned chat detail screen with
// modern chat bubbles, animations, sending status,
// and message checkmarks
// ENHANCEMENT 3: Message slide-in animation
                        return TweenAnimationBuilder<Offset>(
  tween: Tween<Offset>(
    begin: isMe
        ? const Offset(0.15, 0)
        : const Offset(-0.15, 0),
    end: Offset.zero,
  ),
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeOut,
  builder: (context, offset, child) {
    return Transform.translate(
      offset: offset * 20,
      child: child,
    );
  },
  child: Align(
    alignment: isMe
        ? Alignment.centerRight
        : Alignment.centerLeft,
    child: Container(
      constraints: BoxConstraints(
        maxWidth:
            MediaQuery.of(context).size.width * 0.75,
      ),
      margin: EdgeInsets.only(
        bottom: 8.h,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 15.w,
        vertical: 10.h,
      ),
      decoration: BoxDecoration(
        color: isMe
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18.r),
          topRight: Radius.circular(18.r),
          bottomLeft: Radius.circular(
            isMe ? 18.r : 4.r,
          ),
          bottomRight: Radius.circular(
            isMe ? 4.r : 18.r,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
  child: Column(
    crossAxisAlignment:
        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
    children: [
      CustomText(
        text: message,
        fontSize: 15.sp,
      ),
      SizedBox(height: 3.h),
      CustomText(
        text: timestamp != null
        // ENHANCEMENT 3: Display message time
            ? timestamp.toDate().toLocal().toString().substring(11, 16)
            : '',
        fontSize: 10.sp,
      ),
    ],
  ),
),

          if (isMe) ...[
            SizedBox(width: 5.w),
            Icon(
              // ENHANCEMENT 3: Message delivery
              Icons.done_all,
              size: 16.sp,
            ),
          ],
        ],
      ),
    ),
  ),
);
                      },
                    );
                  },
                ),
              ),

              // =====================================================
              // MESSAGE COMPOSER
              // =====================================================
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _msgCtrl,
                          focusNode: _msgFocus,
                          enabled: !_isSending,
                          minLines: 1,
                          maxLines: 4,
                          textInputAction:
                              TextInputAction.send,
                          onSubmitted: (_) {
                            _send(
                              currentUserId,
                              tappedUserId,
                            );
                          },
                          decoration: InputDecoration(
                            hintText:
                                'Type a message...',
                            isDense: true,
                            border:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                20.r,
                              ),
                            ),
                            contentPadding:
                                EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 10.h,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 8.w),
                      // ENHANCEMENT 3: Display sending status while the message is being sent _isSending
                      _isSending
    ? Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
          SizedBox(width: 6.w),
          CustomText(
            text: 'Sending...',
            fontSize: 12.sp,
          ),
        ],
      )
                          : IconButton(
                              onPressed: () {
                                _send(
                                  currentUserId,
                                  tappedUserId,
                                );
                              },
                              icon: const Icon(
                                Icons.send,
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
  )
    );
  }
}