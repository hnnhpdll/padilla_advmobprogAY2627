import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../services/user_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  // ENHANCEMENT 1: LAB 4
  // Implements persistent authentication on the splash screen.
  // The saved access token is checked to determine whether
  // the user is already logged in. The user is redirected
  // to Home if authenticated, otherwise to the Sign In screen.
  Future<void> _checkAuthentication() async {
    try {
      // ENHANCEMENT 1: LAB 4
      // Adds a short delay to display the custom splash screen
      // before checking the user's authentication status.
      await Future.delayed(
        const Duration(milliseconds: 3000),
      );

      final loggedIn = await _userService.isLoggedIn();

      if (!mounted) return;

      if (loggedIn) {
        // ENHANCEMENT 1: LAB 4
        // Retrieves the saved user data after successful
        // authentication and passes it to the Home screen.
        final userData = await _userService.getUserData();

        if (!mounted) return;

        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: userData,
        );
      } else {
        // ENHANCEMENT 1: LAB 4
        // Redirects users who are not authenticated to
        // the Sign In screen.
        Navigator.pushReplacementNamed(
          context,
          '/signin',
        );
      }
    } catch (e) {
      if (!mounted) return;

      // ENHANCEMENT 1: LAB 4
      // If an authentication check fails, the user is
      // redirected to Sign In instead of remaining on
      // the splash screen.
      Navigator.pushReplacementNamed(
        context,
        '/signin',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ENHANCEMENT 1: LAB 4
            // Creates a custom splash screen UI using
            // the application's logo.
            Image.asset(
              'assets/images/dummylogo.png',
              width: 180.w,
              fit: BoxFit.contain,
            ),

            SizedBox(height: 15.h),

            // ENHANCEMENT 1: LAB 4
            // Displays the application name below the logo.
            Text(
              'NUBD Exchange',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 8.h),

            // ENHANCEMENT 1: LAB 4
            // Displays a linear loading indicator while
            // the authentication status is being checked.
            SizedBox(
              width: 180.w,
              child: const LinearProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}