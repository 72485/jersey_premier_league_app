// In main.dart

import 'package:flutter/material.dart';
import 'package:jersey_premier_league/services/auth_service.dart'; // REQUIRED: Imports the service
import 'package:jersey_premier_league/models/user_model.dart'; // REQUIRED: Imports the User model

// Import all required pages
import 'package:jersey_premier_league/pages/login_page.dart';
import 'package:jersey_premier_league/pages/register_page.dart';
import 'package:jersey_premier_league/pages/team_setup_page.dart';
import 'package:jersey_premier_league/pages/dashboard_page.dart';
import 'package:jersey_premier_league/pages/profile_page.dart'; // Assuming this exists from previous step
import 'package:jersey_premier_league/pages/change_password_page.dart'; // Assuming this exists from previous step


// Define a common color for the app theme (Ambient Blue Grey 800)
const Color primaryColor = Color(0xFF37474F);

void main() {
  // Initialize the AuthService instance once and run the app.
  final authService = AuthService();
  runApp(MyApp(authService: authService));
}

class MyApp extends StatelessWidget {
  final AuthService authService;

  const MyApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jersey Premier League',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Use the new ambient primary color
        primaryColor: primaryColor,
        useMaterial3: true,
        textTheme: Theme.of(context).textTheme.apply(
          fontFamily: 'Inter',
        ),
        // Define an Ambient ColorScheme
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          // Muted Lime for secondary/accent
          secondary: const Color(0xFFD4E157),
        ),
        // Apply ambient theme globally for consistency
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      // The home widget listens to the AuthService state change
      home: ValueListenableBuilder<User?>(
        valueListenable: authService.currentUserNotifier,
        builder: (context, user, child) {
          // 1. User is NOT authenticated (Show Login/Register Flow)
          if (user == null) {
            return AuthFlowPage(authService: authService);
          }

          // 2. User IS authenticated but hasn't set up FPL ID (Show Team Setup)
          if (user.fpl_team_ID == null || user.fpl_team_ID!.isEmpty) {
            return TeamSetupPage(user: user, authService: authService);
          }

          // 3. User is fully set up (Show Dashboard)
          return DashboardPage(
            user: user,
            authService: authService, // FIX: Pass the required argument
            onSignOut: authService.signOut,
          );
        },
      ),
    );
  }
}

// ... (AuthFlowPage and its state remain the same)

// Helper widget to manage the flow between Login and Register pages
class AuthFlowPage extends StatefulWidget {
  final AuthService authService;

  const AuthFlowPage({super.key, required this.authService});

  @override
  State<AuthFlowPage> createState() => _AuthFlowPageState();
}

enum AuthMode { login, register }

class _AuthFlowPageState extends State<AuthFlowPage> {
  AuthMode _authMode = AuthMode.login;

  // Since main.dart uses ValueListenableBuilder, the local loading state is mainly for button disabling.
  // We can simplify this by just letting the button handle its own local loading state (already done in login_page.dart).

  void _goToRegister() {
    setState(() {
      _authMode = AuthMode.register;
    });
  }

  void _goToLogin() {
    setState(() {
      _authMode = AuthMode.login;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine which page to show
    if (_authMode == AuthMode.login) {
      return LoginPage(
        // Pass the methods directly from the service
        onSignIn: widget.authService.signIn,
        onGoogleSignIn: widget.authService.signInAsGuest, // Used for guest/mock sign in
        isLoading: false, // Local loading is handled in the page
        onGoToRegister: _goToRegister,
      );
    } else {
      return RegisterPage(
        // Pass the methods directly from the service
        onRegister: widget.authService.register,
        onGoToLogin: _goToLogin,
      );
    }
  }
}
