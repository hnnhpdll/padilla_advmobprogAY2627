import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:padilla_mobprog/constants.dart';
import '../services/user_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Creates an instance of UserService to access the saved user data.
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();

    // Starts the login validation as soon as the splash screen is created.
    getIsLogin();
  }

  // check the user's saved login data before redirecting.
  // if a valid saved user exists, the splash screen is displayed before entering the Home page.
  Future<void> getIsLogin() async {

    // Retrieves the saved user data from UserService.
    final user = await _userService.getUserData();

    // Prevents navigation if the splash screen is no longer active.
    if (!mounted) return;

    if (user != null) {
      // Saves the logged-in user's first name for use throughout the app.
      loggedInUser = user.firstName;

      //short delay so the splash screen is visibly displayed before redirecting to the Home page.
      await Future.delayed(const Duration(seconds: 2));

      // Checks again if the widget is still active after the delay.
      if (!mounted) return;

      // Replaces the splash screen with the Home page.
      // pushReplacement prevents the user from returning to the splash screen using the Back button.
      Navigator.pushReplacementNamed(context, "/home");
    } else {
      // If there is no saved user, the user is redirected to Login.
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  Widget build(BuildContext context) {
  
    //visual design of the splash screen.
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
         
            Image.asset(
              'assets/images/applogo.png',
              width: 180.w,
            ),

            SizedBox(height: 50.h),

           
            // animated loading indicator to give visual feedback while the application checks the user's login status.
            SizedBox(
              width: 30.w,
              height: 30.h,
              child: const CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  FB_DARK_PRIMARY,
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // Displays a message informing the user that the application is preparing to redirect them to the appropriate screen.
            Text(
              'Getting Ready...',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: FB_DARK_PRIMARY,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
