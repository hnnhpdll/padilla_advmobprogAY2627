import '../widgets/custom_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../screens/detail_screen.dart';

class CustomInformation extends StatelessWidget {
  const CustomInformation({
    super.key,
    required this.name,
    required this.post,
    required this.description,
    required this.postId,
    this.icon = const Icon(Icons.person),
    this.profileImageUrl = "",
    this.atProfile = false,
    required this.date,
    this.imageUrl = "",
    this.numOfLikes = 0,
  });

  final String name;
  final String post;
  final String description;
  final int postId; // ADD THIS
  final Icon icon;
  final String profileImageUrl;
  final String date;
  final int numOfLikes;
  final String imageUrl;
  final bool atProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.sp),
      child: InkWell(
        onTap: () {
          if (!atProfile) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(
                  postId: postId,
                  userName: name,
                  postContent: description,
                  date: date,
                  numOfLikes: numOfLikes,
                  imageUrl: imageUrl,
                  profileImageUrl: profileImageUrl,
                ),
              ),
            );
          }
        },
        child: Row(
          children: [

            // PROFILE IMAGE
            profileImageUrl.isEmpty
                ? CircleAvatar(
                    radius: 25.r,
                    child: icon,
                  )
                : CircleAvatar(
                    radius: 25.r,
                    backgroundImage: AssetImage(profileImageUrl),
                  ),

            SizedBox(width: 10.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  CustomFont(
                    text: name,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black,
                  ),

                  CustomFont(
                    text: "Posted: $post",
                    fontSize: 13.sp,
                    color: Colors.black,
                  ),

                  CustomFont(
                    text: description,
                    fontSize: 12.sp,
                    color: Colors.black,
                    fontStyle: FontStyle.italic,
                  ),

                  SizedBox(height: 5.h),

                  CustomFont(
                    text: date,
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),

            const Icon(Icons.more_horiz),
          ],
        ),
      ),
    );
  }
}