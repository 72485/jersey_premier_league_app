import 'package:flutter/foundation.dart';
import 'package:jersey_premier_league/models/user_model.dart';
// Note: In a real app, you would import 'package:http/http.dart' as http;

/// Mock Backend Data
/// We use mock data to simulate successful responses from a REST API.
const _mockUserProfiles = [
  {
    'id': 'user123',
    'name': 'Test User',
    'email': 'test@user.com',
    'token': 'mock_jwt_token_12345',
    'fpl_team_ID': null, // Starts without FPL ID
  },
  {
    'id': 'admin456',
    'name': 'Admin User',
    'email': 'admin@user.com',
    'token': 'mock_jwt_token_45678',
    'fpl_team_ID': '987654321', // Already has FPL ID
  },
];

class AuthService {
  // Use ValueNotifier to notify listeners (like AuthGate) of state changes.
  final ValueNotifier<User?> currentUserNotifier = ValueNotifier(null);

  // Private helper to simulate network delay and custom API responses
  Future<Map<String, dynamic>> _makeApiRequest(
      String endpoint, Map<String, dynamic> body) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate latency

    // --- Mock Login Endpoint ---
    if (endpoint == '/api/login') {
      final email = body['email'];
      final password = body['password'];

      if (email == 'test@user.com' && password == 'password') {
        return {'status': 'success', 'user': _mockUserProfiles[0]};
      }
      if (email == 'admin@user.com' && password == 'password') {
        return {'status': 'success', 'user': _mockUserProfiles[1]};
      }
      throw Exception('Invalid username or password.');
    }

    // --- Mock Register Endpoint ---
    if (endpoint == '/api/register') {
      if (body['email'] == 'exists@user.com') {
        throw Exception('Email already exists. Please login.');
      }
      // Simulate successful registration for a new user
      return {
        'status': 'success',
        'user': {
          'id': 'newuser${DateTime.now().millisecondsSinceEpoch}',
          'name': body['name'],
          'email': body['email'],
          'token': 'new_user_token_${DateTime.now().millisecond}',
          'fpl_team_ID': null,
        }
      };
    }

    // --- Mock Update Profile Endpoint ---
    if (endpoint == '/api/profile/update') {
      // Check for a valid token/session
      if (body['token'] != currentUserNotifier.value?.token) {
        throw Exception('Session expired. Please log in again.');
      }
      // Simulate successful update
      return {
        'status': 'success',
        'fpl_team_ID': body['fpl_team_ID'],
      };
    }

    throw Exception('Unknown API error.');
  }

  // Retrieves the currently logged-in user object
  User? get currentUser => currentUserNotifier.value;

  // Sign Up method
  Future<User?> signUp(String name, String email, String password) async {
    try {
      final response = await _makeApiRequest('/api/register', {
        'name': name,
        'email': email,
        'password': password,
      });

      if (response['status'] == 'success') {
        final user = User.fromJson(response['user']);
        currentUserNotifier.value = user; // Update the state
        return user;
      }
    } catch (e) {
      rethrow; // Re-throw the specific exception from the mock request
    }
    return null;
  }

  // Sign In method
  Future<User?> signIn(String email, String password) async {
    try {
      final response = await _makeApiRequest('/api/login', {
        'email': email,
        'password': password,
      });

      if (response['status'] == 'success') {
        final user = User.fromJson(response['user']);
        currentUserNotifier.value = user; // Update the state
        return user;
      }
    } catch (e) {
      rethrow; // Re-throw the specific exception from the mock request
    }
    return null;
  }

  // Mock Google Sign-In is now a Guest Login, relying on a hardcoded mock user
  Future<User?> signInAsGuest() async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final guestUser = User(
        id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
        email: 'guest@jpl.com',
        name: 'Guest Player',
        token: 'guest_token_${DateTime.now().millisecond}',
        fpl_team_ID: null,
      );

      currentUserNotifier.value = guestUser;
      return guestUser;
    } catch (e) {
      throw Exception('Failed to sign in as guest.');
    }
  }

  // Sign Out method
  Future<void> signOut() async {
    // In a real app, you would call a /api/logout endpoint here
    await Future.delayed(const Duration(milliseconds: 200));
    currentUserNotifier.value = null; // Clear the state
  }

  // Method to update the FPL ID via API
  Future<User> updateFplTeamID(User user, String teamId) async {
    try {
      final response = await _makeApiRequest('/api/profile/update', {
        'token': user.token,
        'fpl_team_ID': teamId,
      });

      if (response['status'] == 'success') {
        // Create an updated user object and set it as the new current user
        final updatedUser = user.copyWith(fpl_team_ID: teamId);
        currentUserNotifier.value = updatedUser; // Update the state
        return updatedUser;
      }
    } catch (e) {
      rethrow;
    }
    // Fallback in case API returns success but no data (shouldn't happen)
    throw Exception('Failed to update FPL ID.');
  }
}
