import 'package:flutter/material.dart';
import 'package:jersey_premier_league/models/user_model.dart';

// New typedefs reflecting the direct calls to AuthService
typedef SignInCallback = Future<User?> Function(String email, String password);
typedef GoToRegisterCallback = VoidCallback;

class LoginPage extends StatefulWidget {
  final SignInCallback onSignIn;
  final Future<User?> Function() onGoogleSignIn; // Now uses the new Guest Login signature
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
  bool _localLoading = false; // Separate loading state for the buttons

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
      });
      return;
    }

    try {
      await widget.onSignIn(_emailController.text, _passwordController.text);
      // Success: The AuthService's ValueNotifier updates the main app state.
    } catch (e) {
      // Display error message thrown by AuthService
      setState(() => _errorMessage = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _localLoading = false);
      }
    }
  }

  void _attemptGuestLogin() async {
    if (_localLoading) return;
    setState(() {
      _errorMessage = null;
      _localLoading = true;
    });

    try {
      await widget.onGoogleSignIn();
      // Success: AuthService updates state
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _localLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF1E88E5);

    final bool combinedLoading = _localLoading || widget.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('JPL Login'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // App Icon/Logo
              const Icon(Icons.sports_soccer, size: 80, color: primaryColor),
              const SizedBox(height: 16),
              const Text(
                'Sign In',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 32),

              // Email Field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Try test@user.com or admin@user.com (password: password)',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'password',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

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
                  backgroundColor: primaryColor,
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

              // Guest Login Button (Mocked)
              OutlinedButton.icon(
                onPressed: combinedLoading ? null : _attemptGuestLogin,
                icon: const Icon(Icons.person_pin, color: primaryColor),
                label: const Text(
                  'Sign in as Guest',
                  style: TextStyle(fontSize: 16, color: primaryColor),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: primaryColor, width: 1.5),
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // Go to Register
              TextButton(
                onPressed: combinedLoading ? null : widget.onGoToRegister,
                child: const Text('Don\'t have an account? Register', style: TextStyle(color: primaryColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
