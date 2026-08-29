import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/custom_dialogs.dart';
import '../constants.dart';
import '../widgets/custom_font.dart';
import '../widgets/custom_inkwell_button.dart';
import '../widgets/custom_textformfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController mobilenumController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordController =
  TextEditingController();

  void register() {
    if (firstnameController.text.trim().isEmpty) {
      customDialog(
        context,
        title: "Invalid Input",
        content: "Please enter your first name.",
        onYes: () {},
      );
      return;
    }

    if (lastnameController.text.trim().isEmpty) {
      customDialog(
        context,
        title: "Invalid Input",
        content: "Please enter your last name.",
        onYes: () {},
      );
      return;
    }

    if (!RegExp(r'^09\d{9}$').hasMatch(mobilenumController.text.trim())) {
      customDialog(
        context,
        title: "Invalid Mobile Number",
        content: "Please enter a valid 11-digit mobile number starting with 09.",
        onYes: () {},
      );
      return;
    }

    if (usernameController.text.trim().length < 5) {
      customDialog(
        context,
        title: "Invalid Username",
        content: "Username must be at least 5 characters long.",
        onYes: () {},
      );
      return;
    }

    if (!RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$',
    ).hasMatch(passwordController.text)) {
      customDialog(
        context,
        title: "Weak Password",
        content:
        "Password must contain uppercase, lowercase, number, special character and be at least 8 characters.",
        onYes: () {},
      );
      return;
    }

    if (passwordController.text != confirmpasswordController.text) {
      customDialog(
        context,
        title: "Password Mismatch",
        content: "Password and Confirm Password do not match.",
        onYes: () {},
      );
      return;
    }

    // Save the registered account
    registeredFirstName = firstnameController.text.trim();
    registeredLastName = lastnameController.text.trim();
    registeredUsername = usernameController.text.trim();
    registeredPassword = passwordController.text;

    customDialog(
      context,
      title: "Success",
      content: "Registration Successful!",
      onYes: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: ScreenUtil().screenHeight,
          width: ScreenUtil().screenWidth,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              25.w,
              40.h,
              25.w,
              10.h,
            ),
            child: Column(
              children: [
                SizedBox(height: 25.h),

                CustomFont(
                  text: "Register Here",
                  fontSize: 50.sp,
                  fontWeight: FontWeight.bold,
                  color: FB_DARK_PRIMARY,
                ),

                SizedBox(height: 25.h),

                CustomTextFormField(
                  height: 50.h,
                  width: double.infinity,
                  controller: firstnameController,
                  hintText: "First Name",
                  hintTextSize: 15.sp,
                  fontSize: 15.sp,
                  validator: (value) => null,
                  onSaved: (value) {},
                  fontColor: FB_DARK_PRIMARY,
                ),

                SizedBox(height: 10.h),

                CustomTextFormField(
                  height: 50.h,
                  width: double.infinity,
                  controller: lastnameController,
                  hintText: "Last Name",
                  hintTextSize: 15.sp,
                  fontSize: 15.sp,
                  validator: (value) => null,
                  onSaved: (value) {},
                  fontColor: FB_DARK_PRIMARY,
                ),

                SizedBox(height: 10.h),

                CustomTextFormField(
                  height: 50.h,
                  width: double.infinity,
                  controller: mobilenumController,
                  keyboardType: TextInputType.phone,
                  maxLength: 11,
                  hintText: "Mobile Number",
                  hintTextSize: 15.sp,
                  fontSize: 15.sp,
                  validator: (value) => null,
                  onSaved: (value) {},
                  fontColor: FB_DARK_PRIMARY,
                ),

                SizedBox(height: 10.h),

                CustomTextFormField(
                  height: 50.h,
                  width: double.infinity,
                  controller: usernameController,
                  hintText: "Username",
                  hintTextSize: 15.sp,
                  fontSize: 15.sp,
                  validator: (value) => null,
                  onSaved: (value) {},
                  fontColor: FB_DARK_PRIMARY,
                ),

                SizedBox(height: 10.h),

                CustomTextFormField(
                  height: 50.h,
                  width: double.infinity,
                  controller: passwordController,
                  isObscure: true,
                  hintText: "Password",
                  hintTextSize: 15.sp,
                  fontSize: 15.sp,
                  validator: (value) => null,
                  onSaved: (value) {},
                  fontColor: FB_DARK_PRIMARY,
                ),

                SizedBox(height: 10.h),

                Text(
                  "Password should be at least 8 characters and contain uppercase, lowercase, numbers, and special characters.",
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 10.sp,
                  ),
                ),

                SizedBox(height: 10.h),

                CustomTextFormField(
                  height: 50.h,
                  width: double.infinity,
                  controller: confirmpasswordController,
                  isObscure: true,
                  hintText: "Confirm Password",
                  hintTextSize: 15.sp,
                  fontSize: 15.sp,
                  validator: (value) => null,
                  onSaved: (value) {},
                  fontColor: FB_DARK_PRIMARY,
                ),

                const Spacer(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "You have an account? ",
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 15.sp,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.popAndPushNamed(context, "/login");
                      },
                      child: Text(
                        "Login here",
                        style: TextStyle(
                          color: FB_DARK_PRIMARY,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10.h),

                CustomInkwellButton(
                  onTap: register,
                  height: 45.h,
                  width: double.infinity,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  buttonName: "Submit",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}