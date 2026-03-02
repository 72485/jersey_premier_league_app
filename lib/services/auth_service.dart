// lib/services/auth_service.dart (Frontend)

import 'package:flutter/foundation.dart';
import 'package:jersey_premier_league/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';

// --- NEW CLASS: Required to match the logic in ProfilePage ---
class Result {
  final bool success;
  final String message;

  Result({required this.success, this.message = ''});
}
// -----------------------------------------------------------


// 🔑 PRODUCTION: Points to Render backend
const String _baseUrl = 'https://jerseypremierleague-api.onrender.com';

class AuthService {
  final ValueNotifier<User?> currentUserNotifier = ValueNotifier(null);

  // Private helper for making authenticated POST requests
  Future<Map<String, dynamic>> _post(
      String endpoint, Map<String, dynamic> body, {String? token}) async {

    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = {
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      ).timeout(const Duration(seconds: 60)); // Increased to 60s for Render cold starts

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Explicitly cast to Map<String, dynamic> for safety
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        String errorMessage = 'Request failed with status: ${response.statusCode}';
        String errorCode = '';

        try {
          final errorBody = json.decode(response.body);
          if (errorBody.containsKey('error')) {
            // Extract the error message from the response
            errorMessage = (errorBody['error'] as String?) ?? 'Server error.';
          }
          if (errorBody.containsKey('code')) {
            errorCode = errorBody['code'] as String;
          }
        } catch (e) {
          // If we can't parse the error body, keep the generic message
          debugPrint('Error parsing response body: $e');
        }

        // Throw an exception that includes the most specific error message available
        throw Exception(errorCode.isNotEmpty ? errorCode : errorMessage);
      }
    } on TimeoutException {
      throw Exception('Network request timed out. Please check your connection.');
    } catch (e) {
      rethrow;
    }
  }

  // Updated to handle 'isEmailVerified' in the User model
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
      debugPrint('Login Error: $e');
      return null;
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      // Backend must handle: 1. User creation (unverified), 2. Email verification sending.
      final response = await _post(
        '/api/register',
        {
          'name': name,
          'email': email,
          'password': password,
        },
      );
      // Success means the user account is created
      debugPrint('Registration successful: $response');
      return;

    } on TimeoutException {
      debugPrint('Registration Error: Request timed out');
      throw Exception('Registration is taking too long. Please check your internet connection and try again.');
    } catch (e) {
      debugPrint('Registration Error: $e');
      if (e.toString().contains('EMAIL_EXISTS') || e.toString().contains('already exists')) {
        throw Exception('An account with this email already exists.');
      }
      // Re-throw the actual error message instead of generic one
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<User?> signInAsGuest() async {
    throw Exception('Guest login not yet implemented on the real API.');
  }

  // 🔑 NEW METHOD: Verify user email with token
  Future<void> verifyEmail(String token) async {
    try {
      await _post(
        '/api/email/verify',
        {
          'token': token,
        },
      );
      debugPrint('Email verification successful');
      return;
    } catch (e) {
      debugPrint('Email Verification Error: $e');
      if (e.toString().contains('INVALID_TOKEN')) {
        throw Exception('Invalid or expired verification token');
      }
      if (e.toString().contains('TOKEN_EXPIRED')) {
        throw Exception('Verification token has expired');
      }
      throw Exception('Email verification failed: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    currentUserNotifier.value = null;
  }


  // 🔑 NEW METHOD: Dedicated function to only update the FPL Team ID
  Future<Result> updateFplTeamID(String? fplTeamid) async {
    final currentUser = currentUserNotifier.value;
    if (currentUser == null) {
      return Result(success: false, message: 'User not authenticated.');
    }

    try {
      // 1. Prepare the payload with only the FPL Team ID
      final Map<String, dynamic> body = {
        'fplTeamID': fplTeamid, // Can be String or null
      };

      // 2. Call the new dedicated API endpoint
      final response = await _post(
        '/api/profile/fpl-team-id',
        body,
        token: currentUser.token,
      );

      // 3. Update state from the API response
      final updatedUser = User.fromJson(response);
      currentUserNotifier.value = updatedUser;

      return Result(success: true);

    } catch (e) {
      // Ensure the fix for the Null-to-String cast is also applied in _post
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('FPL Team ID Update Error: $e');

      // Handle the specific FPL Team ID conflict error returned by the server
      if (errorMessage.contains('FPL Team ID is already in use by another account.') ||
          errorMessage == 'FPL_TEAM_ID_EXISTS') { // Handle both server response and dev-mode response
        return Result(
          success: false,
          message: 'FPL_TEAM_ID_EXISTS',
        );
      }

      // Handle other general errors
      return Result(
        success: false,
        message: 'Failed to update FPL Team ID: $errorMessage',
      );
    }
  }

  // 🔑 CRITICAL FIX: Robust implementation of updateUser
  Future<Result> updateUser(User updatedUserFields) async {
    final currentUser = currentUserNotifier.value;
    if (currentUser == null) {
      return Result(success: false, message: 'User not authenticated.');
    }

    try {
      // 1. Prepare the payload (only send fields that have changed and validate client-side)
      final Map<String, dynamic> body = {};

      // 🔑 Name Logic
      // Trim the new name for storage and comparison
      final newName = updatedUserFields.name.trim();
      if (newName != currentUser.name) {
        if (newName.isEmpty) {
          return Result(success: false, message: 'Name cannot be empty.');
        }
        body['name'] = newName;
      }

      // 🔑 FPL ID Logic
      // Apply trim here, as input from the UI can contain whitespace.
      final newFplIdInputTrimmed = updatedUserFields.fpl_team_id?.trim();

      // We compare the TRIMMED input to the current (already clean) value.
      if (newFplIdInputTrimmed != currentUser.fpl_team_id) {
        // Send null if the new FPL ID is null or empty string (to clear it)
        // We use the trimmed input for this check.
        final fplIdForPayload = (newFplIdInputTrimmed == null || newFplIdInputTrimmed.isEmpty)
            ? null
            : newFplIdInputTrimmed;

        // The server will perform its own trim, but sending a clean value from the client
        // is always the safer and more efficient approach.
        body['fplTeamID'] = fplIdForPayload;
      }

      // 🔑 Check: Prevent unnecessary API call if no changes were made
      if (body.isEmpty) {
        return Result(success: true, message: 'No changes detected.');
      }

      // 2. Make the authenticated POST request
      final response = await _post(
        '/api/profile/update',
        body,
        token: currentUser.token,
      );

      // 3. Update state from the API response (FIX for stale data)
      final updatedUser = User.fromJson(response);
      currentUserNotifier.value = updatedUser;

      return Result(success: true, message: 'Profile updated successfully.');

    } catch (e) {
      // ... (Error handling remains the same) ...
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      //debugPrint('Profile Update Error: $e');

      if (errorMessage.contains('409')) {
        return Result(
          success: false,
          message: 'FPL Team ID is already in use by another account.',
        );
      }
      if (errorMessage.contains('401')) {
        return Result(
          success: false,
          message: 'Session Expired. Please log in again.',
        );
      }
      if (errorMessage.contains('Name cannot be empty')) {
        return Result(
          success: false,
          message: 'Name cannot be empty.',
        );
      }

      return Result(
        success: false,
        message: 'Failed to update profile: $errorMessage',
      );
    }
  }

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
  }

  Future<User?> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      serverClientId: '1017396303090-5no4v1s8j7hdl158cktde84bapjc9u2q.apps.googleusercontent.com',
    );
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      throw Exception('Google Sign-In cancelled by user.');
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final String? idToken = googleAuth.idToken;

    if (idToken == null) {
      throw Exception('Failed to retrieve Google ID Token.');
    }

    try {
      final response = await _post(
        '/api/auth/google',
        {
          'id_token': idToken,
        },
      );

      final user = User.fromJson(response);
      currentUserNotifier.value = user;

      return user;
    } on Exception catch (e) {
      debugPrint('Google Sign-In API Error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', 'Google Sign-In failed: '));
    }
  }
}