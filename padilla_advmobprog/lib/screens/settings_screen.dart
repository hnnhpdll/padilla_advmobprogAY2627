import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';

// ENHANCEMENT 3: Settings page
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final UserService _userService = UserService();

  // ENHANCEMENT 3: Change Password
  Future<void> _showChangePasswordDialog() async {
    String currentPassword = '';
    String newPassword = '';
    String confirmPassword = '';

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  obscureText: true,
                  onChanged: (value) {
                    currentPassword = value;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                    border: OutlineInputBorder(),
                  ),
                ),

                SizedBox(height: 12.h),

                TextFormField(
                  obscureText: true,
                  onChanged: (value) {
                    newPassword = value;
                  },
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(),
                  ),
                ),

                SizedBox(height: 12.h),

                TextFormField(
                  obscureText: true,
                  onChanged: (value) {
                    confirmPassword = value;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                if (currentPassword.isEmpty ||
                    newPassword.isEmpty ||
                    confirmPassword.isEmpty) {
                  return;
                }

                if (newPassword.length < 6) {
                  return;
                }

                if (newPassword != confirmPassword) {
                  return;
                }

                Navigator.pop(dialogContext, true);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );

    if (!mounted || result != true) {
      return;
    }

    try {
      final user = _userService.currentUser;

      if (user == null || user.email == null) {
        throw Exception(
          'No Firebase user is currently signed in.',
        );
      }

      await _userService.resetPasswordFromCurrentPassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        email: user.email!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password updated successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update password: $e',
          ),
        ),
      );
    }
  }

  // ENHANCEMENT 3: Delete Account
  Future<void> _showDeleteAccountDialog() async {
    String currentPassword = '';

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Are you sure you want to delete your account? '
                  'This action cannot be undone.',
                ),

                SizedBox(height: 16.h),

                TextFormField(
                  obscureText: true,
                  onChanged: (value) {
                    currentPassword = value;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                if (currentPassword.isEmpty) {
                  return;
                }

                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete Account'),
            ),
          ],
        );
      },
    );

    if (!mounted || result != true) {
      return;
    }

    try {
      final user = _userService.currentUser;

      if (user == null || user.email == null) {
        throw Exception(
          'No Firebase user is currently signed in.',
        );
      }

      await _userService.deleteAccount(
        email: user.email!,
        password: currentPassword,
      );

      // Clear saved session/token
      await _userService.logout();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account deleted successfully.',
          ),
        ),
      );

      // Redirect to Sign In
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/signin',
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete account: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ENHANCEMENT 3: Access the existing ThemeProvider
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: 'Settings',
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
        ),
      ),

      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          // ENHANCEMENT 3: Dark/Light mode setting
          Card(
            child: SwitchListTile(
              title: CustomText(
                text: 'Dark Mode',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),

              subtitle: CustomText(
                text: themeProvider.isDark
                    ? 'Dark theme is enabled'
                    : 'Light theme is enabled',
                fontSize: 13.sp,
              ),

              value: themeProvider.isDark,

              // ENHANCEMENT 3: Toggle the existing theme
              onChanged: (value) {
                context
                    .read<ThemeProvider>()
                    .toggleTheme();
              },

              secondary: Icon(
                themeProvider.isDark
                    ? Icons.dark_mode
                    : Icons.light_mode,
                size: 24.sp,
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // ENHANCEMENT 3: Change password
          Card(
            child: ListTile(
              leading: Icon(
                Icons.lock_outline,
                size: 24.sp,
              ),

              title: CustomText(
                text: 'Change Password',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),

              subtitle: CustomText(
                text: 'Update your account password',
                fontSize: 13.sp,
              ),

              onTap: _showChangePasswordDialog,
            ),
          ),

          SizedBox(height: 16.h),

          // ENHANCEMENT 3: Delete Account
          Card(
            child: ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 24.sp,
              ),

              title: CustomText(
                text: 'Delete Account',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),

              subtitle: CustomText(
                text: 'Permanently delete your account',
                fontSize: 13.sp,
              ),

              onTap: _showDeleteAccountDialog,
            ),
          ),

          SizedBox(height: 16.h),

          // ENHANCEMENT 1: Logout button
          Card(
            child: ListTile(
              leading: Icon(
                Icons.logout,
                color: Colors.red,
                size: 24.sp,
              ),

              title: CustomText(
                text: 'Logout',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),

              subtitle: CustomText(
                text: 'Sign out of your account',
                fontSize: 13.sp,
              ),

              onTap: () async {
                try {
                  final userService = UserService();

                  // Sign out from Firebase
                  await userService.signOut();

                  // Clear saved session/token
                  await userService.logout();

                  if (!context.mounted) return;

                  // Redirect to Sign In
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/signin',
                    (route) => false,
                  );
                } catch (e) {
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Logout failed: $e',
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}