import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/login_type.dart';
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

  // ENHANCEMENT 3: PROFILE SCREEN
  // Stores the authentication method selected by the user.
  LoginType _loginType = LoginType.dummyJson;

  // ENHANCEMENT 2: LAB 4
  // Uses UserService to authenticate the user through
  // DummyJSON or Firebase Authentication depending on
  // the selected LoginType.
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_loginType == LoginType.dummyJson) {
        final response = await _userService.loginUser(
          _usernameController.text.trim(),
          _passwordController.text,
        );
await _userService.saveLoginType('dummyJson');

        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: response,
        );
      } else {
        final userCredential = await _userService.signIn(
          email: _usernameController.text.trim(),
          password: _passwordController.text,
        );

        await _userService.refreshFirebaseToken();
        await _userService.saveLoginType('firebase');

        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: userCredential.user,
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

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

                  // ENHANCEMENT 3: PROFILE SCREEN
                  // Allows the user to select whether to log in
                  // using DummyJSON or Firebase Authentication.
                  DropdownButtonFormField<LoginType>(
                    value: _loginType,
                    decoration: const InputDecoration(
                      labelText: 'Login Type',
                      prefixIcon: Icon(Icons.login),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: LoginType.dummyJson,
                        child: Text('DummyJSON'),
                      ),
                      DropdownMenuItem(
                        value: LoginType.firebase,
                        child: Text('Firebase'),
                      ),
                    ],
                    onChanged: _isLoading
                        ? null
                        : (value) {
                            if (value == null) return;

                            setState(() {
                              _loginType = value;
                              _usernameController.clear();
                            });
                          },
                  ),

                  SizedBox(height: 18.h),

                  // ENHANCEMENT 2: LAB 4
                  // Username or email input field used for authentication.
                  TextFormField(
                    controller: _usernameController,
                    keyboardType:
                        _loginType == LoginType.firebase
                            ? TextInputType.emailAddress
                            : TextInputType.text,
                    decoration: InputDecoration(
                      labelText:
                          _loginType == LoginType.firebase
                              ? 'Email Address'
                              : 'Username',
                      prefixIcon: Icon(
                        _loginType == LoginType.firebase
                            ? Icons.email_outlined
                            : Icons.person_outline,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return _loginType == LoginType.firebase
                            ? 'Please enter your email address'
                            : 'Please enter your username';
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
                  // selected authentication process.
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

                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/signup',
                      );
                    },
                    child: Text(
                      "Don't have an account? Sign Up",
                      style: TextStyle(
                        fontSize: 14.sp,
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