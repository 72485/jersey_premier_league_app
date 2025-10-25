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

        try {
          final errorBody = json.decode(response.body);
          if (errorBody.containsKey('error')) {
            errorMessage = errorBody['error'] as String;
          } else {
            errorMessage = 'Request failed with status: ${response.statusCode}';
          }
        } catch (e) {
          errorMessage = 'Request failed with status: ${response.statusCode}. Could not parse error details.';
        }

        throw Exception(errorMessage);
      }
    } on TimeoutException { // 👈 This will now be recognized
      throw Exception('Network request timed out. Please check your connection.');
    } catch (e) {
      rethrow;
    }
  }

  // ... (signIn, register, signOut, updateFplTeamID methods are unchanged)
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
    try {
      final response = await _post(
        '/api/profile/update',
        {
          'fpl_team_ID': teamId,
          'id': user.id,
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

  Future<User> updateProfile(User user, {String? name, String? fplTeamId}) async {
    try {
      // 1. Prepare the request body, only including non-null/non-empty fields.
      final Map<String, dynamic> body = {};
      if (name != null && name.isNotEmpty) {
        body['name'] = name;
      }
      if (fplTeamId != null && fplTeamId.isNotEmpty) {
        body['fpl_team_ID'] = fplTeamId;
      }

      // NOTE: The ID is automatically included on the backend via the JWT.
      // It's unnecessary to send it in the body.

      // If no data to update, throw a local exception or return current user
      if (body.isEmpty) {
        throw Exception('No data provided for profile update.');
      }

      // 2. Call the backend API
      final response = await _post(
        '/api/profile/update',
        body,
        token: user.token,
      );

      // 3. Update the local User model with the new data
      final updatedUser = user.copyWith(
        name: body.containsKey('name')
            ? body['name'] as String
            : user.name, // Use the new name from the request body
        fpl_team_ID: body.containsKey('fpl_team_ID')
            ? body['fpl_team_ID'] as String?
            : user.fpl_team_ID, // Use the new FPL ID
      );

      // 4. Notify the rest of the app (like the Dashboard)
      currentUserNotifier.value = updatedUser;

      return updatedUser;
    } catch (e) {
      debugPrint('Profile Update Error: $e');
      // Re-throw the error for the UI to catch
      throw Exception('Failed to update profile. Please try again.');
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
    // The backend handles the actual password hash update.
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

    // final String idToken = googleAuth.idToken!; // The token to send to the backend
    // ----------------------------------------------------

    // ⚠️ Placeholder: You must replace this with the real token retrieval flow above
    //const String idToken = 'REAL_GOOGLE_ID_TOKEN_PLACEHOLDER';

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
