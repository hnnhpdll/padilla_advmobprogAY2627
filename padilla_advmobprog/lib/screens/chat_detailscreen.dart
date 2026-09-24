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
              // =====================================================
              // MESSAGES
              // =====================================================
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

                        final isMe =
                            senderId == currentUserId;

                        return Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            constraints:
                                BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context)
                                          .size
                                          .width *
                                      0.75,
                            ),
                            margin: EdgeInsets.only(
                              bottom: 8.h,
                            ),
                            padding:
                                EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 10.h,
                            ),
                            decoration:
                                BoxDecoration(
                              color: isMe
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                              borderRadius:
                                  BorderRadius.circular(
                                15.r,
                              ),
                            ),
                           child: CustomText(
  text: message,
  fontSize: 15.sp,
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

                      _isSending
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
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