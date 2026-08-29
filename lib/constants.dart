// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const Color FB_PRIMARY = Color(0xFFE91E63);
const Color FB_SECONDARY = Color(0xFFF06292);
const Color FB_DARK_PRIMARY = Color(0xFFC2185B);
const Color FB_LIGHT_PRIMARY = Color(0xFFF8BBD0);
const Color FB_TEXT_COLOR_WHITE = Color(0xFFFFB6B3);

// ================= API =================

String get host => dotenv.env['API_URL'] ?? 'https://dummyjson.com';

// ================= USER DATA =================

String registeredFirstName = "";
String registeredLastName = "";
String registeredUsername = "";
String registeredPassword = "";
String loggedInUser = "";