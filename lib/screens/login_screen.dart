import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/custom_dialogs.dart';
import '../constants.dart';
import '../widgets/custom_inkwell_button.dart';
import '../widgets/custom_textformfield.dart';
import '../services/user_service.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();

  bool isPasswordHidden = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: ScreenUtil().screenHeight,
          width: ScreenUtil().screenWidth,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Bar
                Container(
                  width: ScreenUtil().screenWidth,
                  height: 40.h,
                  color: FB_DARK_PRIMARY,
                ),

                // Login Form
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.w),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/applogo.png',
                        height: 200.h,
                      ),

                      SizedBox(height: 30.h),

                      // Username
                      CustomTextFormField(
                        height: 20.h,
                        width: double.infinity,
                        controller: usernameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter your username';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          usernameController.text = value!;
                        },
                        fontSize: 15.sp,
                        fontColor: FB_DARK_PRIMARY,
                        hintTextSize: 15.sp,
                        hintText: "Username",
                      ),

                      SizedBox(height: 10.h),

                      // Password
                      CustomTextFormField(
                        height: 20.h,
                        width: double.infinity,
                        controller: passwordController,
                        isObscure: isPasswordHidden,
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordHidden
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: FB_DARK_PRIMARY,
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordHidden = !isPasswordHidden;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter your password';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          passwordController.text = value!;
                        },
                        fontSize: 15.sp,
                        fontColor: FB_DARK_PRIMARY,
                        hintTextSize: 15.sp,
                        hintText: "Password",
                      ),

                      SizedBox(height: 50.h),

                      // Login Button
                      CustomInkwellButton(
                        onTap: isLoading
                            ? () {}
                            : () async {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }

                                setState(() {
                                  isLoading = true;
                                });

                                try {
                                  final user =
                                      await _userService.loginUser(
                                    usernameController.text.trim(),
                                    passwordController.text.trim(),
                                  );

                                  if (!context.mounted) return;

                                  loggedInUser = user.firstName;

                                  Navigator.pushReplacementNamed(
                                    context,
                                    "/splash",
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;

                                  customDialog(
                                    context,
                                    title: "Login Failed",
                                    content:
                                        "Invalid username or password.",
                                    onYes: () {},
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                }
                              },
                        height: 40.h,
                        width: double.infinity,
                        buttonName:
                            isLoading ? "Logging in..." : "Login",
                        fontSize: 15.sp,
                      ),
                    ],
                  ),
                ),

                // Bottom Bar
                Container(
                  width: ScreenUtil().screenWidth,
                  height: 40.h,
                  color: FB_DARK_PRIMARY,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'You do not have an account? ',
                        style: TextStyle(
                          color: Colors.grey.shade200,
                          fontSize: 15.sp,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: Text(
                          'Register here',
                          style: TextStyle(
                            color: FB_LIGHT_PRIMARY,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}