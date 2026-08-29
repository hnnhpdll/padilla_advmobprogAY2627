import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/user.dart';

class UserService {
  Map<String, dynamic> data = {};
  // ENHANCEMENT 2: LAB 4
  // User authentication using DummyJSON.
  // This method sends the username and password to the
  // DummyJSON authentication endpoint. If the login is
  // successful, the returned user information and tokens
  // are saved using SharedPreferences.
  Future<Map<String, dynamic>> loginUser(
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$host/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
        'expiresInMins': 60,
      }),
    );

    if (response.statusCode == 200) {
      data = jsonDecode(response.body);

      await saveUserData(data);

      return data;
    } else {
      throw Exception(response.body);
    }
  }

  // ENHANCEMENT 3: LAB 4 
  // Retrieves the currently authenticated user's information.
  // The saved access token is sent to DummyJSON's /auth/me
  // endpoint. The returned information is converted into
  // the User model and used by the Profile screen.
  Future<User> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();

    final accessToken =
        prefs.getString('accessToken') ?? '';

    if (accessToken.isEmpty) {
      throw Exception('No access token found.');
    }

    final response = await http.get(
      Uri.parse('$host/auth/me'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final userData = jsonDecode(response.body);

      return User.fromJson({
        ...userData,
        'accessToken': accessToken,
        'refreshToken':
            prefs.getString('refreshToken') ?? '',
      });
    } else {
      throw Exception(
        'Failed to get current user: ${response.body}',
      );
    }
  }

  // ENHANCEMENT 3: LAB 4
  // Refreshes the user's access token.
  // The saved refresh token is sent to DummyJSON's
  // /auth/refresh endpoint. The newly returned access token
  // is then saved to SharedPreferences.
  Future<void> refreshAccessToken() async {
    final prefs = await SharedPreferences.getInstance();

    final refreshToken =
        prefs.getString('refreshToken') ?? '';

    if (refreshToken.isEmpty) {
      throw Exception('No refresh token found.');
    }

    final response = await http.post(
      Uri.parse('$host/auth/refresh'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'refreshToken': refreshToken,
        'expiresInMins': 60,
      }),
    );

    if (response.statusCode == 200) {
      final tokenData = jsonDecode(response.body);

      final newAccessToken =
          tokenData['accessToken'] ?? '';

      if (newAccessToken.isEmpty) {
        throw Exception(
          'No access token returned from refresh.',
        );
      }

      await prefs.setString(
        'accessToken',
        newAccessToken,
      );

      await prefs.setString(
        'token',
        newAccessToken,
      );

      await prefs.setString(
        'refreshToken',
        tokenData['refreshToken'] ?? refreshToken,
      );
    } else {
      throw Exception(
        'Failed to refresh token: ${response.body}',
      );
    }
  }
  // ENHANCEMENT 2: LAB 4
  // Saves the authenticated user's information and tokens.
  // SharedPreferences is used so the user's authentication
  // information can remain available even after restarting
  // the application.
  Future<void> saveUserData(
    Map<String, dynamic> userData,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final user = User.fromJson(userData);

    await prefs.setInt(
      'id',
      user.id,
    );

    await prefs.setString(
      'username',
      user.username,
    );

    await prefs.setString(
      'email',
      user.email,
    );

    await prefs.setString(
      'firstName',
      user.firstName,
    );

    await prefs.setString(
      'lastName',
      user.lastName,
    );

    await prefs.setString(
      'gender',
      user.gender,
    );

    await prefs.setString(
      'image',
      user.image,
    );

    await prefs.setString(
      'accessToken',
      user.accessToken,
    );

    await prefs.setString(
      'refreshToken',
      user.refreshToken,
    );

    // Save the generic token if it is returned by the API.
    if (userData.containsKey('token')) {
      await prefs.setString(
        'token',
        userData['token'] ?? '',
      );
    } else if (user.accessToken.isNotEmpty) {
      await prefs.setString(
        'token',
        user.accessToken,
      );
    }
  }

  // ============================================================
  // ENHANCEMENT 1:
  // Retrieves the saved user information from SharedPreferences.

  // This allows the application to retrieve the user's
  // information when checking persistent authentication.
  // ============================================================
  Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'id': prefs.getInt('id') ?? 0,
      'username':
          prefs.getString('username') ?? '',
      'email':
          prefs.getString('email') ?? '',
      'firstName':
          prefs.getString('firstName') ?? '',
      'lastName':
          prefs.getString('lastName') ?? '',
      'gender':
          prefs.getString('gender') ?? '',
      'image':
          prefs.getString('image') ?? '',
      'accessToken':
          prefs.getString('accessToken') ?? '',
      'refreshToken':
          prefs.getString('refreshToken') ?? '',
      'token':
          prefs.getString('token') ??
          prefs.getString('accessToken') ??
          '',
    };
  }
  // ENHANCEMENT 3: LAB 4
  // Converts the saved user information into the User model.
  // This allows other screens, such as the Profile screen,
  // to work with a User object instead of using raw Maps.
  Future<User> getUser() async {
    final userData = await getUserData();

    return User.fromJson(userData);
  }
  // ENHANCEMENT 1: LAB 4
  // Checks whether the user is already authenticated.
  // The saved access token is checked to determine whether
  // the user should proceed to the Home screen or be sent
  // to the Sign In screen.
  Future<bool> isLoggedIn() async {
    final prefs =
        await SharedPreferences.getInstance();

    final token =
        prefs.getString('accessToken') ??
        prefs.getString('token');

    return token != null && token.isNotEmpty;
  }
  // ENHANCEMENT 1: LAB 4
  // Logs the user out by clearing the saved authentication
  // information and user data from SharedPreferences.
  Future<void> logout() async {
    try {
      final prefs =
          await SharedPreferences.getInstance();

      await prefs.clear();
    } catch (e) {
      throw Exception(
        'Failed to log out: $e',
      );
    }
  }
}