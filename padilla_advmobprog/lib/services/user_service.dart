import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants.dart';
import '../models/user.dart';

class UserService {
  Map<String, dynamic> data = {};

  // ============================================================
  // FIREBASE AUTHENTICATION
  // ============================================================

  final firebase_auth.FirebaseAuth firebaseAuth =
      firebase_auth.FirebaseAuth.instance;

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  firebase_auth.User? get currentUser =>
      firebaseAuth.currentUser;

  Stream<firebase_auth.User?> get authStateChanges =>
      firebaseAuth.authStateChanges();

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

  // ENHANCEMENT 3: PROFILE SCREEN
  // Retrieves user information depending on the login type.
  // DummyJSON user data is retrieved from SharedPreferences.
  // Firebase user data is retrieved from Firestore.
  Future<Map<String, dynamic>> getUserData() async {
    final loginType = await getLoginType();

    // ============================================================
    // DUMMYJSON USER
    // ============================================================
    if (loginType == 'dummyJson') {
      final prefs = await SharedPreferences.getInstance();

      return {
        'id': prefs.getInt('id') ?? 0,
        'username': prefs.getString('username') ?? '',
        'email': prefs.getString('email') ?? '',
        'firstName': prefs.getString('firstName') ?? '',
        'lastName': prefs.getString('lastName') ?? '',
        'gender': prefs.getString('gender') ?? '',
        'image': prefs.getString('image') ?? '',
        'accessToken': prefs.getString('accessToken') ?? '',
        'refreshToken': prefs.getString('refreshToken') ?? '',
        'token': prefs.getString('token') ??
            prefs.getString('accessToken') ??
            '',
      };
    }

    // ============================================================
    // FIREBASE USER
    // ============================================================
    if (loginType == 'firebase') {
      final user = firebaseAuth.currentUser;

      if (user == null) {
        throw Exception(
          'No Firebase user is currently signed in.',
        );
      }

      final document = await firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!document.exists) {
        throw Exception(
          'Firebase user profile not found.',
        );
      }

      final firebaseData = document.data() ?? {};

      return {
        'uid': user.uid,
        'fName': firebaseData['fName'] ?? '',
        'lName': firebaseData['lName'] ?? '',
        'age': firebaseData['age'] ?? 0,
        'contactNo': firebaseData['contactNo'] ?? '',
        'username': firebaseData['username'] ?? '',
        'emailAddress':
            firebaseData['emailAddress'] ?? user.email ?? '',
      };
    }

    throw Exception('Unknown login type.');
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

  // ============================================================
  // FIREBASE AUTHENTICATION METHODS
  // ============================================================

  Future<firebase_auth.UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<firebase_auth.UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> saveFirebaseUserData({
    required String fName,
    required String lName,
    required int age,
    required String contactNo,
    required String username,
    required String emailAddress,
  }) async {
    final user = firebaseAuth.currentUser;

    if (user == null) {
      throw Exception(
        'No Firebase user is currently signed in.',
      );
    }

    await firestore
        .collection('users')
        .doc(user.uid)
        .set({
      'uid': user.uid,
      'fName': fName,
      'lName': lName,
      'age': age,
      'contactNo': contactNo,
      'username': username,
      'emailAddress': emailAddress,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  Future<void> updateUsername(String username) async {
  final user = firebaseAuth.currentUser;

  if (user == null) {
    throw Exception(
      'No Firebase user is currently signed in.',
    );
  }

  // Update the username in Firebase Authentication.
  await user.updateDisplayName(username);

  // Update the username in Firestore.
  await firestore
      .collection('users')
      .doc(user.uid)
      .update({
    'username': username,
  });
}

  Future<void> deleteAccount({
  required String email,
  required String password,
}) async {
  final user = currentUser;

  if (user == null) {
    throw Exception(
      'No Firebase user is currently signed in.',
    );
  }

  final credential =
      firebase_auth.EmailAuthProvider.credential(
    email: email,
    password: password,
  );

  // Re-authenticate the user before deleting the account.
  await user.reauthenticateWithCredential(
    credential,
  );

  // Delete the user's Firestore profile first.
  await firestore
      .collection('users')
      .doc(user.uid)
      .delete();

  // Delete the Firebase Authentication account.
  await user.delete();

  // Sign out from Firebase.
  await firebaseAuth.signOut();
}

  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    firebase_auth.AuthCredential credential =
        firebase_auth.EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );

    await currentUser!.reauthenticateWithCredential(
      credential,
    );

    await currentUser!.updatePassword(newPassword);
  }

  Future<String?> refreshFirebaseToken() async {
    final user = firebaseAuth.currentUser;

    if (user == null) {
      throw Exception(
        'No Firebase user is currently signed in.',
      );
    }

    final token = await user.getIdToken(true);

    return token;
  }

  // ENHANCEMENT 3: PROFILE SCREEN
  // Saves the login type used by the current user.
  Future<void> saveLoginType(String loginType) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'loginType',
      loginType,
    );
  }

  // ENHANCEMENT 3: PROFILE SCREEN
  // Retrieves the login type used by the current user.
  Future<String> getLoginType() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('loginType') ?? 'dummyJson';
  }
}