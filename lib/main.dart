import 'package:flutter/material.dart';

import 'package:jersey_premier_league/models/user_model.dart';
import 'package:jersey_premier_league/services/auth_service.dart';
import 'package:jersey_premier_league/pages/login_page.dart';
import 'package:jersey_premier_league/pages/dashboard_page.dart';
import 'package:jersey_premier_league/pages/team_setup_page.dart';
import 'package:jersey_premier_league/pages/register_page.dart';

// --- Global Constants and Styling ---
const Color primaryColor = Color(0xFF1E88E5); // Blue for primary
const Color accentColor = Color(0xFFFFC107); // Amber for accent/buttons
const Color backgroundColor = Color(0xFFF5F5F5); // Light background

// --- Main Application Widget ---
void main() {
  runApp(const FantasyApp());
}

// Enum to manage the top-level Auth state (Login vs Register)
enum AuthFlowState { login, register }

class FantasyApp extends StatelessWidget {
  const FantasyApp({super.key});

  // Since we removed Firebase init, we can create the service directly.
  // It's defined here and passed down.
  static final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JPL', // App Title
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryColor,
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: accentColor),
        scaffoldBackgroundColor: backgroundColor,
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          color: primaryColor,
          elevation: 0,
        ),
      ),
      home: AuthGate(authService: authService),
    );
  }
}

// Widget to handle the Auth state stream (ValueNotifier) and top-level navigation
class AuthGate extends StatefulWidget {
  final AuthService authService;

  const AuthGate({super.key, required this.authService});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  // Use a state variable to switch between Login and Register pages
  AuthFlowState _authFlowState = AuthFlowState.login;
  bool _isLoading = false; // State for loading indicator in Login/Register

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder listens to the currentUserNotifier in the AuthService
    return ValueListenableBuilder<User?>(
      valueListenable: widget.authService.currentUserNotifier,
      builder: (context, user, child) {
        // --- Conditional Navigation Logic ---
        final bool isLoggedIn = user != null;

        // 1. User is NOT Logged In
        if (!isLoggedIn) {
          if (_authFlowState == AuthFlowState.login) {
            return LoginPage(
              onSignIn: widget.authService.signIn,
              onGoogleSignIn: widget.authService.signInAsGuest, // Renamed/Refactored to Guest Login
              onGoToRegister: () => setState(() => _authFlowState = AuthFlowState.register),
              isLoading: _isLoading,
            );
          } else {
            return RegisterPage(
              onRegister: widget.authService.signUp,
              onGoToLogin: () => setState(() => _authFlowState = AuthFlowState.login),
            );
          }
        }

        // 2. User IS Logged In, but needs FPL ID setup
        if (user!.fpl_team_ID == null || user.fpl_team_ID!.isEmpty) {
          return TeamSetupPage(
            user: user,
            authService: widget.authService, // Pass the service for saving the ID
          );
        }

        // 3. User is Logged In and FPL ID is set -> Show Dashboard
        return DashboardPage(
          user: user,
          onSignOut: widget.authService.signOut,
        );
      },
    );
  }
}
