import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/user.dart';
import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();

  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // ENHANCEMENT 3: LAB 4
  // Uses UserService to retrieve the currently authenticated
  // user's information from DummyJSON's /auth/me endpoint.
  // The returned data is converted into the custom User model
  // and stored in the _user variable.
  Future<void> _loadUser() async {
    try {
      final user = await _userService.getCurrentUser();

      if (!mounted) return;

      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load profile: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_user == null) {
      return const Center(
        child: Text(
          'Unable to load user profile',
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.r),
      child: Column(
        children: [
          SizedBox(height: 20.h),

          // ENHANCEMENT 3: LAB 4
          // Renders the logged-in user's profile image
          // using the image value stored in the User model.
          CircleAvatar(
            radius: 55.r,
            backgroundImage: _user!.image.isNotEmpty
                ? NetworkImage(_user!.image)
                : null,
            child: _user!.image.isEmpty
                ? Icon(
                    Icons.person,
                    size: 55.sp,
                  )
                : null,
          ),

          SizedBox(height: 20.h),

          // ENHANCEMENT 3: LAB 4
          // Renders the user's first name and last name
          // from the custom User model.
          Text(
            '${_user!.firstName} ${_user!.lastName}',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 5.h),

          // ENHANCEMENT 3: LAB 4
          // Renders the authenticated user's username.
          Text(
            '@${_user!.username}',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey,
            ),
          ),

          SizedBox(height: 30.h),

          // ENHANCEMENT 3: LAB 4
          // Renders the user's information from the User model
          // through reusable profile information components.
          _buildProfileItem(
            Icons.person_outline,
            'Username',
            _user!.username,
          ),

          _buildProfileItem(
            Icons.email_outlined,
            'Email',
            _user!.email,
          ),

          _buildProfileItem(
            Icons.badge_outlined,
            'First Name',
            _user!.firstName,
          ),

          _buildProfileItem(
            Icons.badge_outlined,
            'Last Name',
            _user!.lastName,
          ),

          _buildProfileItem(
            Icons.wc_outlined,
            'Gender',
            _user!.gender,
          ),
        ],
      ),
    );
  }

  // ENHANCEMENT 3: LAB 4
  // Reusable widget for displaying the user's information
  // from the custom User model.
  Widget _buildProfileItem(
    IconData icon,
    String label,
    String value,
  ) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24.sp,
          ),

          SizedBox(width: 15.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),

                SizedBox(height: 3.h),

                Text(
                  value.isEmpty
                      ? 'Not provided'
                      : value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}