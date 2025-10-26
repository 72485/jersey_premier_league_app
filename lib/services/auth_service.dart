// lib/services/auth_service.dart

import 'package:flutter/foundation.dart';
import 'package:jersey_premier_league/models/user_model.dart';
import 'package:http/http.dart' as http; // Official HTTP package for network calls
import 'dart:convert'; // Required for JSON encoding/decoding
import 'dart:async';
// ⚡ ADD: You need to add 'google_sign_in: ^6.1.0' (or latest) to your pubspec.yaml
import 'package:google_sign_in/google_sign_in.dart';

// --- Configuration ---
// IMPORTANT: Reverting to 10.0.2.2 as the backend server is running and accessible
// only via this address on the Android Emulator.
const String _baseUrl = 'http://192.168.137.1:8080'; // CORRECT ADDRESS FOR ANDROID EMULATOR
//const String _baseUrl = 'http://localhost:8080'; //chrome test
class AuthService {
  final ValueNotifier<User?> currentUserNotifier = ValueNotifier(null);

  // Private helper for making authenticated POST requests
  Future<Map<String, dynamic>> _post(
      String endpoint, Map<String, dynamic> body, {String? token}) async {

    final url = Uri.parse('$_baseUrl$endpoint'); // Correct URL construction
    print(url);
    final headers = {
      'Content-Type': 'application/json',
    };

    // Add Authorization header if a token is provided (used for updates/protected routes)
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      ).timeout(const Duration(seconds: 10)); // Uses TimeoutException

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        // Logic to extract specific error message (e.g., "Incorrect current password")
        String errorMessage = 'An unknown server error occurred.';
        String errorCode = ''; // Used to send specific codes like FPL_TEAM_ID_EXISTS

        try {
          final errorBody = json.decode(response.body);
          if (errorBody.containsKey('error')) {
            errorMessage = errorBody['error'] as String;
          }
          if (errorBody.containsKey('code')) {
            errorCode = errorBody['code'] as String; // Assume backend sends a 'code' like FPL_TEAM_ID_EXISTS
          } else {
            errorMessage = 'Request failed with status: ${response.statusCode}';
          }
        } catch (e) {
          errorMessage = 'Request failed with status: ${response.statusCode}. Could not parse error details.';
        }

        // Throw an exception that includes the specific code if available
        throw Exception(errorCode.isNotEmpty ? errorCode : errorMessage);
      }
    } on TimeoutException { // 👈 This will now be recognized
      throw Exception('Network request timed out. Please check your connection.');
    } catch (e) {
      rethrow;
    }
  }

  // ... (signIn, register, signOut methods are unchanged)
  Future<User?> signIn(String email, String password) async {
    try {
      final response = await _post(
        '/api/login',
        {
          'email': email,
          'password': password,
        },
      );

      final user = User.fromJson(response);
      currentUserNotifier.value = user;

      return user;
    } catch (e) {
      // The error is handled by the LoginPage and displayed as _errorMessage
      debugPrint('Login Error: $e');
      return null;
    }
  }

  Future<User?> register(String name, String email, String password) async {
    try {
      final response = await _post(
        '/api/register',
        {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      final user = User.fromJson(response);
      currentUserNotifier.value = user;

      return user;
    } catch (e) {
      debugPrint('Registration Error: $e');
      if (e is Exception && e.toString().contains('409')) {
        throw Exception('An account with this email already exists.');
      }
      throw Exception('Registration failed.');
    }
  }

  Future<User?> signInAsGuest() async {
    throw Exception('Guest login not yet implemented on the real API.');
  }

  Future<void> signOut() async {
    currentUserNotifier.value = null;
  }

  Future<User> updateFplTeamID(User user, String teamId) async {
    // This old method is now redundant and should be integrated or deprecated.
    // Keeping it here for now, but the new updateUser should be used.
    try {
      final response = await _post(
        '/api/profile/update',
        {
          'fpl_team_ID': teamId,
          'id': user.id, // ID is often unnecessary if token is used
        },
        token: user.token,
      );

      if (response.containsKey('fpl_team_ID')) {
        final updatedUser = user.copyWith(fpl_team_ID: response['fpl_team_ID'] as String);
        currentUserNotifier.value = updatedUser;
        return updatedUser;
      }
      throw Exception('Update response missing FPL ID.');
    } catch (e) {
      debugPrint('Update FPL ID Error: $e');
      throw Exception('Failed to update FPL Team ID.');
    }
  }

  // ⚡ FIX: Renamed from updateProfile and changed return type to Future<Result>
  Future<Result> updateUser(User user) async {
    try {
      // 1. Prepare the request body from the incoming User object
      final Map<String, dynamic> body = {
        // Only include fields that are meant to be updated
        'name': user.name,
        'fpl_team_ID': user.fpl_team_ID,
      };

      // 2. Call the backend API
      // The backend should handle which fields are actually different and only update those.
      final response = await _post(
        '/api/profile/update',
        body,
        token: user.token,
      );

      // 3. Update the local User model with the potentially new data
      //    (The response should ideally return the fully updated user object)
      //    For simplicity here, we assume the provided 'user' object is the correct updated model.

      // We will assume the backend returns the updated fields for simplicity,
      // and we merge them with the existing user data.
      final updatedUser = user.copyWith(
        name: response['name'] ?? user.name,
        fpl_team_ID: response['fpl_team_ID'] ?? user.fpl_team_ID,
      );

      // 4. Notify the rest of the app
      currentUserNotifier.value = updatedUser;

      return Result(success: true);
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('Profile Update Error: $e');

      // Check for the specific FPL Team ID conflict code returned from the backend
      if (errorMessage == 'FPL_TEAM_ID_EXISTS') {
        return Result(
          success: false,
          message: 'FPL_TEAM_ID_EXISTS',
        );
      }

      // Handle other generic errors
      return Result(
        success: false,
        message: 'Failed to update profile: $errorMessage',
      );
    }
  }

  // NEW METHOD: Change Password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = currentUserNotifier.value;
    if (user == null) {
      throw Exception('Authentication required for password change.');
    }

    await _post(
      '/api/password/change',
      {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
      token: user.token,
    );

    // Password change is successful (no need to update user object, as token is unchanged)
  }

  // ⚡ ACTUAL IMPLEMENTATION: Now uses Google Sign-In and calls the backend
  Future<User?> signInWithGoogle() async {
    // ----------------------------------------------------
    // 1. Initialize Google Sign-In
    final GoogleSignIn googleSignIn = GoogleSignIn();

    // 2. Perform sign-in and get authentication details
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      // User cancelled the sign-in process
      throw Exception('Google Sign-In cancelled by user.');
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final String? idToken = googleAuth.idToken;

    if (idToken == null) {
      throw Exception('Failed to retrieve Google ID Token.');
    }

    // ----------------------------------------------------

    try {
      // 3. Send ID token to your backend via a new endpoint
      final response = await _post(
        '/api/auth/google',
        {
          'id_token': idToken,
        },
      );

      // 4. Backend returns User object + JWT
      final user = User.fromJson(response);
      currentUserNotifier.value = user;

      return user;
    } on Exception catch (e) {
      debugPrint('Google Sign-In API Error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', 'Google Sign-In failed: '));
    }
  }
}