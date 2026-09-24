
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/custom_text.dart';
import '../services/user_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fNameController =
      TextEditingController();

  final TextEditingController _lNameController =
      TextEditingController();

  final TextEditingController _ageController =
      TextEditingController();

  final TextEditingController _contactNoController =
      TextEditingController();

  final TextEditingController _usernameController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  bool _obscurePassword = true;
  final UserService _userService = UserService();
bool _isLoading = false;

  @override
  void dispose() {
    _fNameController.dispose();
    _lNameController.dispose();
    _ageController.dispose();
    _contactNoController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  String? _requiredValidator(
    String? value,
    String fieldName,
  ) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }

    final emailRegex =
        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }

    return null;
  }

  String? _ageValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Age is required';
    }

    final age = int.tryParse(value.trim());

    if (age == null) {
      return 'Enter a valid age';
    }

    if (age <= 0) {
      return 'Age must be greater than 0';
    }

    return null;
  }

  String? _contactValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Contact number is required';
    }

    if (value.trim().length < 10) {
      return 'Enter a valid contact number';
    }

    return null;
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() {
    _isLoading = true;
  });

  try {
    final userCredential = await _userService.createAccount(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    await userCredential.user?.updateDisplayName(
      _usernameController.text.trim(),
    );
    
    await _userService.saveFirebaseUserData(
  fName: _fNameController.text.trim(),
  lName: _lNameController.text.trim(),
  age: int.parse(_ageController.text.trim()),
  contactNo: _contactNoController.text.trim(),
  username: _usernameController.text.trim(),
  emailAddress: _emailController.text.trim(),
);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account created successfully!'),
      ),
    );

    Navigator.pushReplacementNamed(
      context,
      '/signin',
    );
  } catch (e) {
    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Account creation failed: $e'),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: 'Create Account',
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.r),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                CustomText(
                  text: 'Sign Up',
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                ),

                SizedBox(height: 8.h),

                CustomText(
                  text: 'Create your account to continue.',
                  fontSize: 14.sp,
                ),

                SizedBox(height: 24.h),

                _buildTextField(
                  label: 'First Name',
                  controller: _fNameController,
                  validator: (value) =>
                      _requiredValidator(
                    value,
                    'First name',
                  ),
                ),

                _buildTextField(
                  label: 'Last Name',
                  controller: _lNameController,
                  validator: (value) =>
                      _requiredValidator(
                    value,
                    'Last name',
                  ),
                ),

                _buildTextField(
                  label: 'Age',
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  validator: _ageValidator,
                ),

                _buildTextField(
                  label: 'Contact Number',
                  controller: _contactNoController,
                  keyboardType: TextInputType.phone,
                  validator: _contactValidator,
                ),

                _buildTextField(
                  label: 'Username',
                  controller: _usernameController,
                  validator: (value) =>
                      _requiredValidator(
                    value,
                    'Username',
                  ),
                ),

                _buildTextField(
                  label: 'Email Address',
                  controller: _emailController,
                  keyboardType:
                      TextInputType.emailAddress,
                  validator: _emailValidator,
                ),

                _buildTextField(
                  label: 'Password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: _passwordValidator,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword =
                            !_obscurePassword;
                      });
                    },
                  ),
                ),

                SizedBox(height: 8.h),

                SizedBox(
                  height: 50.h,
                  child: ElevatedButton(
  onPressed: _isLoading ? null : _submitForm,
  child: _isLoading
      ? SizedBox(
          width: 24.w,
          height: 24.h,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
          ),
        )
      : CustomText(
          text: 'Create Account',
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
),
                ),

                SizedBox(height: 12.h),

                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/signin',
                    );
                  },
                  child: const Text(
                    'Already have an account? Sign In',
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