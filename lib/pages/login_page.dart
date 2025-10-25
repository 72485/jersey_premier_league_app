import 'package:flutter/material.dart';
import 'package:jersey_premier_league/models/user_model.dart';

// New typedefs reflecting the direct calls to AuthService
typedef SignInCallback = Future<User?> Function(String email, String password);
typedef GoToRegisterCallback = VoidCallback;

// REMOVED: const Color primaryColor = Color(0xFF0D1B2A); // Dark Blue (No longer needed, using theme)

class LoginPage extends StatefulWidget {
  final SignInCallback onSignIn;
  final Future<User?> Function() onGoogleSignIn; // Used for Google/mock sign in
  final GoToRegisterCallback onGoToRegister;
  final bool isLoading;

  const LoginPage({
    super.key,
    required this.onSignIn,
    required this.onGoogleSignIn,
    required this.isLoading,
    required this.onGoToRegister,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;
  bool _localLoading = false;

  // --- Core Login Logic ---
  void _attemptLogin() async {
    if (_localLoading) return;

    setState(() {
      _errorMessage = null;
      _localLoading = true;
    });

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both email and password.';
        _localLoading = false;
        return;
      });
    }

    try {
      final user = await widget.onSignIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // If 'user' is returned successfully, the AuthService state changes,
      // and main.dart automatically navigates.
      if (user == null) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Invalid email or password. Please try again.';
            _localLoading = false;
          });
        }
      }

      // Optional: Clear fields on success
      _emailController.clear();
      _passwordController.clear();

    } catch (e) {
      // API or Network Error
      if (mounted) {
        setState(() {
          _errorMessage = 'Login failed: ${e.toString().replaceAll('Exception: ', '')}';
          _localLoading = false;
        });
      }
    }
  }

  // ⚡ FIX: Renamed method to _attemptGoogleLogin for clarity
  void _attemptGoogleLogin() async {
    if (_localLoading) return;

    setState(() {
      _errorMessage = null;
      _localLoading = true;
    });

    try {
      // Calls the new signInWithGoogle (mock) method via the widget callback
      await widget.onGoogleSignIn();
      // If successful (if mock was removed and actual sign-in implemented), main.dart navigates.
    } on Exception catch (e) {
      // Display the specific error message from the service
      if (mounted) {
        setState(() {
          // Use the specific message from the AuthService: "Google Sign-In is not yet implemented."
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _localLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An unknown error occurred during Google sign-in.';
          _localLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    // Access ambient primary color from the theme
    final themePrimaryColor = Theme.of(context).colorScheme.primary;

    // We use a combined loading state to disable all buttons during any auth attempt
    final combinedLoading = _localLoading || widget.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('JPL Login'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Use theme color for icon
              Icon(Icons.sports_football, size: 80, color: themePrimaryColor),
              const SizedBox(height: 30),

              Text(
                'Sign In',
                textAlign: TextAlign.center,
                // Use theme color for text
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: themePrimaryColor),
              ),
              const SizedBox(height: 40),

              // Email Field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  // Use theme color for prefix icon
                  prefixIcon: Icon(Icons.email_outlined, color: themePrimaryColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
                enabled: !combinedLoading,
              ),
              const SizedBox(height: 16),

              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  // Use theme color for prefix icon
                  prefixIcon: Icon(Icons.lock_outline, color: themePrimaryColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
                enabled: !combinedLoading,
              ),
              const SizedBox(height: 20),

              // Error Message
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Login Button
              ElevatedButton(
                onPressed: combinedLoading ? null : _attemptLogin,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                child: combinedLoading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                )
                    : const Text(
                  'Login',
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),

              const Text('OR', style: TextStyle(color: Colors.black54), textAlign: TextAlign.center),
              const SizedBox(height: 20),

              // Google Login Button
              OutlinedButton.icon(
                // ⚡ FIX: Use the new _attemptGoogleLogin method
                onPressed: combinedLoading ? null : _attemptGoogleLogin,
                // Use a Google-like icon
                icon: Icon(
                  Icons.g_mobiledata_outlined,
                  color: themePrimaryColor,
                  size: 30,
                ),
                label: Text(
                  'Login with Google',
                  style: TextStyle(fontSize: 16, color: themePrimaryColor),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: themePrimaryColor, width: 1.5),
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // Go to Register
              TextButton(
                onPressed: combinedLoading ? null : widget.onGoToRegister,
                // ⚡ FIX: Use themePrimaryColor instead of hardcoded primaryColor
                child: Text('Don\'t have an account? Register', style: TextStyle(color: themePrimaryColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}