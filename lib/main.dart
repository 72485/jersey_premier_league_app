// lib/main.dart

import 'package:flutter/material.dart';
import 'package:jersey_premier_league/services/auth_service.dart';
import 'package:jersey_premier_league/models/user_model.dart';

// Import all required pages
import 'package:jersey_premier_league/pages/login_page.dart';
import 'package:jersey_premier_league/pages/register_page.dart';
import 'package:jersey_premier_league/pages/team_setup_page.dart';

// Import the wrapper
import 'package:jersey_premier_league/pages/jpl_navigation_wrapper.dart';

import 'package:jersey_premier_league/pages/profile_page.dart';
import 'package:jersey_premier_league/pages/change_password_page.dart';
import 'package:jersey_premier_league/pages/fixtures_page.dart';

// ⚡ THEME COLORS
const Color newPrimaryColor = Color(0xFFE91E63); // Dark Pink/Magenta
const Color newSecondaryColor = Color(0xFF00BCD4); // Cyan/Sky Blue
const Color newAccentColor = Color(0xFFFFEB3B); // Bright Yellow
const Color newNeutralColor = Color(0xFFBDBDBD); // Grey

// ⚡ GRADIENT COLORS for AppBars
const List<Color> appBarGradientColors = [
  newPrimaryColor, // Start color (Magenta)
  newSecondaryColor, // End color (Cyan)
];

// Hardcoded FPL ID and username constants REMOVED or left unused.
const String ADMIN_FPL_ID_STRING = '123'; // Retained but unused
const String ADMIN_USERNAME = 'JPL_ADMIN_User'; // Retained but unused


void main() {
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
        // Use the new primary color consistently
        primaryColor: newPrimaryColor,
        useMaterial3: true,

        // Set global font family
        fontFamily: 'Inter',

        // Define a vibrant ColorScheme based on the screenshot
        colorScheme: ColorScheme.fromSeed(
          seedColor: newPrimaryColor,
          primary: newPrimaryColor,
          onPrimary: Colors.white,
          secondary: newSecondaryColor,
          onSecondary: Colors.black,
          tertiary: newAccentColor,
          onTertiary: Colors.black,
          error: Colors.red.shade700,
          onError: Colors.white,
          background: Colors.white,
          onBackground: Colors.black,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        // Removed AppBarTheme to allow custom gradient on individual pages
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: newPrimaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: newPrimaryColor,
            side: BorderSide(color: newPrimaryColor, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: newPrimaryColor,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: newPrimaryColor, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: newNeutralColor, width: 1),
          ),
          labelStyle: TextStyle(color: newPrimaryColor),
          prefixIconColor: newPrimaryColor,
          floatingLabelStyle: TextStyle(color: newPrimaryColor),
          fillColor: newNeutralColor.withOpacity(0.1),
          filled: true,
        ),
        // ⚡ FIX: Change CardTheme to CardThemeData to match the required type.
        cardTheme: CardThemeData(
          color: newPrimaryColor.withOpacity(0.05),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      home: ValueListenableBuilder<User?>(
        valueListenable: authService.currentUserNotifier,
        builder: (context, user, child) {
          if (user == null) {
            return AuthFlowPage(authService: authService);
          }
          if (user.fpl_team_ID == null || user.fpl_team_ID!.isEmpty) {
            return TeamSetupPage(user: user, authService: authService);
          }
          // ROUTE TO JPLNavigationWrapper
          return JPLNavigationWrapper(
            user: user,
            authService: authService,
            onSignOut: authService.signOut,
          );
        },
      ),
    );
  }
}

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

  // ⚡ FIX: Removed the _attemptAdminLogin function entirely.

  @override
  Widget build(BuildContext context) {
    if (_authMode == AuthMode.login) {
      return LoginPage(
        onSignIn: widget.authService.signIn,
        onGoogleSignIn: widget.authService.signInWithGoogle,
        isLoading: false,
        onGoToRegister: _goToRegister,
        // onAdminSignIn parameter remains removed here.
      );
    } else {
      return RegisterPage(
        onRegister: widget.authService.register,
        onGoToLogin: _goToLogin,
      );
    }
  }
}