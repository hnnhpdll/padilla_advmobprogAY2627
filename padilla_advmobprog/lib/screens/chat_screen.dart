import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../services/chat_service.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';
import 'chat_detailscreen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _searchChatController =
      TextEditingController();

  final ChatService _chatService = ChatService();
  final UserService _userService = UserService();

  String? _currentUserEmail;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUserEmail();

    _searchChatController.addListener(() {
      setState(() {
        _searchText = _searchChatController.text;
      });
    });
  }

  Future<void> _loadCurrentUserEmail() async {
    try {
      final userData = await _userService.getUserData();

      if (!mounted) return;

      setState(() {
        _currentUserEmail =
            userData['emailAddress'] ?? userData['email'] ?? '';
      });
    } catch (e) {
      debugPrint('Error loading current user: $e');
    }
  }

  @override
  void dispose() {
    _searchChatController.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
  appBar: AppBar(
    leading: IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
    title: const Text('Chat'),
  ),
  body: SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 23.w),
            child: TextField(
              controller: _searchChatController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search chat..',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchChatController.text.isNotEmpty
                    ? IconButton(
                        tooltip: 'Clear',
                        icon: const Icon(Icons.cancel),
                        onPressed: () {
                          setState(() {
                            _searchChatController.clear();
                            _searchText = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          SizedBox(height: 10.h),

          // Users Stream
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _chatService.getUsersStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  height: ScreenUtil().screenHeight * 0.6,
                  padding: EdgeInsets.all(16.sp),
                  child: const Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Container(
                  height: ScreenUtil().screenHeight * 0.6,
                  padding: EdgeInsets.all(16.sp),
                  child: Center(
                    child: CustomText(
                      text: 'Error loading users',
                      fontSize: 16.sp,
                    ),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Container(
                  height: ScreenUtil().screenHeight * 0.6,
                  padding: EdgeInsets.all(16.sp),
                  child: Center(
                    child: CustomText(
                      text: 'No users found',
                      fontSize: 16.sp,
                    ),
                  ),
                );
              }

              final currentUserId = _chatService.currentUserId;

              final users = snapshot.data!.where((user) {
                // Don't display the currently logged-in user
                if (user['uid'] == currentUserId) {
                  return false;
                }

                final firstName =
                    user['fName']?.toString().toLowerCase() ?? '';

                final lastName =
                    user['lName']?.toString().toLowerCase() ?? '';

                final username =
                    user['username']?.toString().toLowerCase() ?? '';

                final email =
                    user['emailAddress']?.toString().toLowerCase() ?? '';

                final search = _searchText.toLowerCase();

                return firstName.contains(search) ||
                    lastName.contains(search) ||
                    username.contains(search) ||
                    email.contains(search);
              }).toList();

              if (users.isEmpty) {
                return Container(
                  height: ScreenUtil().screenHeight * 0.6,
                  padding: EdgeInsets.all(16.sp),
                  child: Center(
                    child: CustomText(
                      text: 'No users found',
                      fontSize: 16.sp,
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];

                  final firstName =
                      user['fName']?.toString() ?? 'Unknown';

                  final lastName =
                      user['lName']?.toString() ?? '';

                  final email =
                      user['emailAddress']?.toString() ?? 'No email';

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailScreen(
                            currentUserEmail: _currentUserEmail ?? '',
                            tappedUser: user,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: CustomText(
                            text: firstName.isNotEmpty
                                ? firstName[0].toUpperCase()
                                : '?',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        title: CustomText(
                          text: '$firstName $lastName',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        subtitle: CustomText(
                          text: email,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    )
    );
  }
}