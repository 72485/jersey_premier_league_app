// lib/main.dart

import 'package:flutter/material.dart';
import 'package:jersey_premier_league/services/auth_service.dart';
import 'package:jersey_premier_league/models/user_model.dart';

// Import all required pages
import 'package:jersey_premier_league/pages/login_page.dart';
import 'package:jersey_premier_league/pages/register_page.dart';
import 'package:jersey_premier_league/pages/team_setup_page.dart';

// Import the real AdminHomePage
import 'package:jersey_premier_league/pages/admin_home_page.dart';

// Import the wrapper
import 'package:jersey_premier_league/pages/jpl_navigation_wrapper.dart';

// ... (other imports)

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

// 🆕 NEW: VerificationPendingPage (Placeholder)
class VerificationPendingPage extends StatelessWidget {
  final User user;
  final VoidCallback onSignOut;
  const VerificationPendingPage({super.key, required this.user, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: onSignOut,
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email, size: 80, color: Color(0xFFE91E63)),
              const SizedBox(height: 20),
              const Text(
                "Verification Required",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "A verification link has been sent to ${user.email}. Please click the link to confirm your registration. You will need to log out and back in after verifying.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ❌ REMOVED: AdminHomePage placeholder class has been removed.

class MyApp extends StatelessWidget {
  final AuthService authService;

  const MyApp({super.key, required this.authService});

  // 🔑 DEFINED: The correct list of admin emails (lowercase for routing check)
  static const List<String> _adminEmails = [
    "jerseypremierleaguee@gmail.com",
    "jpl_admin2@gmail.com",
    "jpl_admin3@gmail.com",
    "jpl_admin4@gmail.com",
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jersey Premier League',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: newPrimaryColor,
        useMaterial3: true,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: newPrimaryColor,
          primary: newPrimaryColor,
          onPrimary: Colors.white,
          secondary: newSecondaryColor,
          // ... (rest of color scheme)
        ),
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

          // 1. ADMIN ROUTE CHECK (Now using the imported AdminHomePage)
          if (_adminEmails.contains(user.email.toLowerCase())) {
            return AdminHomePage(onSignOut: authService.signOut);
          }

          // 2. EMAIL VERIFICATION CHECK (Only for non-admins)
          if (user.is_email_verified == false) {
            return VerificationPendingPage(
              user: user,
              onSignOut: authService.signOut,
            );
          }

          // 3. FPL TEAM SETUP CHECK (Only for verified non-admins)
          if (user.fpl_team_id == null || user.fpl_team_id!.isEmpty) {
            return TeamSetupPage(user: user, authService: authService);
          }

          // 4. NORMAL USER HOME ROUTE (Fully set up)
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

  // Simplified Method to handle Admin Login
  void _goToAdminHome() {
    // This is correctly designed to do nothing, as the successful login
    // updates the auth state, which triggers the MyApp builder above
    // to check the email and route automatically.
    print('LOG: Admin login successful, MyApp builder will handle routing.');
  }

  @override
  Widget build(BuildContext context) {
    if (_authMode == AuthMode.login) {
      return LoginPage(
        onSignIn: widget.authService.signIn,
        onGoogleSignIn: widget.authService.signInWithGoogle,
        isLoading: false,
        onGoToRegister: _goToRegister,
        onAdminLogin: _goToAdminHome,
      );
    } else {
      return RegisterPage(
        onRegister: widget.authService.register,
        onGoToLogin: _goToLogin,
      );
    }
  }
}