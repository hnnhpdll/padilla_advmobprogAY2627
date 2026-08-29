import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/user.dart';

class UserService {
  // Sends the user's login credentials to the API and saves the returned user data locally.
  Future<User> loginUser(String username, String password) async {
    final uri = Uri.parse('$host/user/login');

    final response = await http.post(
      uri,
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
      final data = jsonDecode(response.body);

      final user = User.fromJson(data);

      final prefs = await SharedPreferences.getInstance();

      await prefs.setInt('userId', user.id);
      await prefs.setString('username', user.username);
      await prefs.setString('email', user.email);
      await prefs.setString('firstName', user.firstName);
      await prefs.setString('lastName', user.lastName);
      await prefs.setString('image', user.image);
      await prefs.setString('accessToken', user.accessToken);
      await prefs.setString('refreshToken', user.refreshToken);

      return user;
    } else {
      throw Exception('Login failed: ${response.statusCode}');
    }
  }

  // Retrieves the saved user's information from local storage and reconstructs the User object.
  Future<User?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();

    final userId = prefs.getInt('userId');

    if (userId == null) {
      return null;
    }

    return User(
      id: userId,
      username: prefs.getString('username') ?? '',
      email: prefs.getString('email') ?? '',
      firstName: prefs.getString('firstName') ?? '',
      lastName: prefs.getString('lastName') ?? '',
      image: prefs.getString('image') ?? '',
      accessToken: prefs.getString('accessToken') ?? '',
      refreshToken: prefs.getString('refreshToken') ?? '',
    );
  }

  // Clears the saved user information from local storage when the user signs out.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();
  }
}