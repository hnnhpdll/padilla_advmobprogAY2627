import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../services/user_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  final UserService _userService = UserService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // ENHANCEMENT 2: LAB 4
  // Uses UserService to authenticate the user through
  // DummyJSON's authentication endpoint. The user's
  // authentication tokens and user information are saved
  // by UserService for persistent authentication.
  // After successful authentication, the user is redirected
  // to the Home screen.
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _userService.loginUser(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // ENHANCEMENT 2: LAB 4
      // Redirects the authenticated user to the Home screen
      // and passes the returned user data as route arguments.
      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: response,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // ENHANCEMENT 2: LAB 4
      // Displays an error message when authentication fails.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Login failed: ${e.toString()}',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: 28.w,
              vertical: 20.h,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  // ENHANCEMENT 2: LAB 4
                  // Custom UI for the Sign In screen using
                  // the application's logo.
                  Center(
                    child: Image.asset(
                      'assets/images/dummylogo.png',
                      width: 180.w,
                      fit: BoxFit.contain,
                    ),
                  ),

                  SizedBox(height: 25.h),

                  // ENHANCEMENT 2: LAB 4
                  // Displays a custom welcome message
                  // for the Sign In screen.
                  Text(
                    'Welcome Back!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8.h),

                  Text(
                    'Sign in to continue shopping',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // ENHANCEMENT 2: LAB 4
                  // Username input field used for authentication.
                  TextFormField(
                    controller: _usernameController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(
                        Icons.person_outline,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Please enter your username';
                      }

                      return null;
                    },
                  ),

                  SizedBox(height: 18.h),

                  // ENHANCEMENT 2: LAB 4
                  // Password input field used for authentication.
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword =
                                !_obscurePassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty) {
                        return 'Please enter your password';
                      }

                      return null;
                    },
                  ),

                  SizedBox(height: 28.h),

                  // ENHANCEMENT 2: LAB 4
                  // Custom Sign In button that starts the
                  // authentication process and shows a loading
                  // indicator while the request is processing.
                  SizedBox(
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed:
                          _isLoading ? null : _login,
                      child: _isLoading
                          ? SizedBox(
                              width: 24.w,
                              height: 24.h,
                              child:
                                  const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'SIGN IN',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}