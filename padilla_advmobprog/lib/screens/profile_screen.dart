import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();

  Map<String, dynamic>? _userData;
  String _loginType = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // ENHANCEMENT 3: PROFILE SCREEN
  // Retrieves the logged-in user's information depending
  // on whether the user signed in using DummyJSON or Firebase.
  Future<void> _loadUser() async {
    try {
      final loginType = await _userService.getLoginType();
      final userData = await _userService.getUserData();

      if (!mounted) return;

      setState(() {
        _loginType = loginType;
        _userData = userData;
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

  // ENHANCEMENT 3: PROFILE SCREEN
  // Allows the Firebase user to update their username.
  Future<void> _showUpdateUsernameDialog() async {
  String newUsername =
      (_userData?['username'] ?? '').toString();

  final result = await showDialog<String>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Update Username'),
        content: TextFormField(
          initialValue: newUsername,
          onChanged: (value) {
            newUsername = value;
          },
          decoration: const InputDecoration(
            labelText: 'Username',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final username = newUsername.trim();

              if (username.isEmpty) {
                return;
              }

              Navigator.pop(dialogContext, username);
            },
            child: const Text('Update'),
          ),
        ],
      );
    },
  );

  if (!mounted || result == null || result.isEmpty) {
    return;
  }

  try {
    await _userService.updateUsername(result);

    if (!mounted) return;

    setState(() {
      _userData!['username'] = result;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Username updated successfully.',
        ),
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Failed to update username: $e',
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

    if (_userData == null) {
      return const Center(
        child: Text(
          'Unable to load user profile',
        ),
      );
    }

    final isFirebase = _loginType == 'firebase';

    final firstName = isFirebase
        ? (_userData!['fName'] ?? '').toString()
        : (_userData!['firstName'] ?? '').toString();

    final lastName = isFirebase
        ? (_userData!['lName'] ?? '').toString()
        : (_userData!['lastName'] ?? '').toString();

    final username =
        (_userData!['username'] ?? '').toString();

    final email = isFirebase
        ? (_userData!['emailAddress'] ?? '').toString()
        : (_userData!['email'] ?? '').toString();

    final image =
        (_userData!['image'] ?? '').toString();

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.r),
      child: Column(
        children: [
          SizedBox(height: 20.h),

          // ENHANCEMENT 3: PROFILE SCREEN
          // Displays the DummyJSON profile image when available.
          CircleAvatar(
            radius: 55.r,
            backgroundImage: !isFirebase && image.isNotEmpty
                ? NetworkImage(image)
                : null,
            child: isFirebase || image.isEmpty
                ? Icon(
                    Icons.person,
                    size: 55.sp,
                  )
                : null,
          ),

          SizedBox(height: 20.h),

          Text(
            '$firstName $lastName',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 5.h),

          Text(
            '@$username',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey,
            ),
          ),

          SizedBox(height: 30.h),

          _buildProfileItem(
            Icons.person_outline,
            'Username',
            username,
          ),

          _buildProfileItem(
            Icons.email_outlined,
            isFirebase ? 'Email Address' : 'Email',
            email,
          ),

          _buildProfileItem(
            Icons.badge_outlined,
            'First Name',
            firstName,
          ),

          _buildProfileItem(
            Icons.badge_outlined,
            'Last Name',
            lastName,
          ),

          if (isFirebase) ...[
            _buildProfileItem(
              Icons.cake_outlined,
              'Age',
              (_userData!['age'] ?? '').toString(),
            ),

            _buildProfileItem(
              Icons.phone_outlined,
              'Contact Number',
              (_userData!['contactNo'] ?? '').toString(),
            ),
          ] else ...[
            _buildProfileItem(
              Icons.wc_outlined,
              'Gender',
              (_userData!['gender'] ?? '').toString(),
            ),
          ],

          SizedBox(height: 10.h),

          if (isFirebase)
  SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: _showUpdateUsernameDialog,
      icon: const Icon(Icons.edit),
      label: const Text('Update Username'),
    ),
  ),
        ],
      ),
    );
  }

  // ENHANCEMENT 3: PROFILE SCREEN
  // Reusable widget for displaying user information.
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