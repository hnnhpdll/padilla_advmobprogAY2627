import '../widgets/custom_info.dart' as notif;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<Map<String, dynamic>> notifications = [
    {
      "name": "Hannah Padilla",
      "postId": 1,
      "postNumber": 1,
      "description": "Had a great day at the park!",
      "date": DateTime(2025, 12, 9),
      "numOfLikes": 35,
      "profileImageUrl": "assets/images/avatar.jpg",
    },
    {
      "name": "Bretman Rock",
      "postId": 2,
      "postNumber": 2,
      "description": "New vlog is up, check it out!",
      "date": DateTime(2025, 12, 8),
      "numOfLikes": 120,
      "profileImageUrl": "assets/images/bretman.JPG",
    },
    {
      "name": "LANY",
      "postId": 3,
      "postNumber": 3,
      "description": "Holiday shopping spree today 🎁",
      "date": DateTime(2025, 12, 7),
      "numOfLikes": 98,
      "profileImageUrl": "assets/images/lany.png",
    },
    {
      "name": "Justin Bieber",
      "postId": 4,
      "postNumber": 4,
      "description": "Coffee time before work ☕",
      "date": DateTime(2025, 12, 6),
      "numOfLikes": 15,
      "profileImageUrl": "assets/images/jb.jpg",
    },
    {
      "name": "keshi",
      "postId": 5,
      "postNumber": 5,
      "description": "Success is not final; keep pushing!",
      "date": DateTime(2025, 12, 5),
      "numOfLikes": 42,
      "profileImageUrl": "assets/images/keshi.jpg",
    },
    {
      "name": "The 1975",
      "postId": 6,
      "postNumber": 6,
      "description": "Excited for the weekend!",
      "date": DateTime(2025, 12, 4),
      "numOfLikes": 27,
      "profileImageUrl": "assets/images/1975.jpg",
    },
    {
      "name": "Taylor Swift",
      "postId": 7,
      "postNumber": 7,
      "description": "Reading a new book today.",
      "date": DateTime(2025, 12, 3),
      "numOfLikes": 51,
      "profileImageUrl": "assets/images/taylor.jpg",
    },
    {
      "name": "CAS",
      "postId": 8,
      "postNumber": 8,
      "description": "Morning workout complete 💪",
      "date": DateTime(2025, 12, 2),
      "numOfLikes": 65,
      "profileImageUrl": "assets/images/cas.jpg",
    },
    {
      "name": "The Marias",
      "postId": 9,
      "postNumber": 9,
      "description": "Learning Flutter is fun!",
      "date": DateTime(2025, 12, 1),
      "numOfLikes": 89,
      "profileImageUrl": "assets/images/marias.jpg",
    },
    {
      "name": "SchooB",
      "postId": 10,
      "postNumber": 10,
      "description": "Movie night with friends 🍿",
      "date": DateTime(2025, 11, 30),
      "numOfLikes": 150,
      "profileImageUrl": "assets/images/schoob1.jpg",
    },
    {
      "name": "Men I Trust",
      "postId": 11,
      "postNumber": 11,
      "description": "Trying out a new recipe today.",
      "date": DateTime(2025, 11, 29),
      "numOfLikes": 73,
      "profileImageUrl": "assets/images/men.jpeg",
    },
    {
      "name": "NIKI",
      "postId": 12,
      "postNumber": 12,
      "description": "Stand-up comedy session later!",
      "date": DateTime(2025, 11, 28),
      "numOfLikes": 201,
      "profileImageUrl": "assets/images/niki.jpg",
    },
  ];

  String formatDate(DateTime date) {
    return "${date.month}/${date.day}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.separated(
        padding: EdgeInsets.all(10.sp),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => Divider(height: 1.h),
        itemBuilder: (context, index) {
          final item = notifications[index];

          return notif.CustomInformation(
  name: item['name'],
  post: "Post #${item['postNumber']}",
  postId: item['postId'], // ADD THIS
  description: item['description'],
  date: formatDate(item['date']),
  numOfLikes: item['numOfLikes'],
  profileImageUrl: item['profileImageUrl'] ?? "",
);
        },
      ),
    );
  }
}