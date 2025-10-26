import 'package:flutter/material.dart';
import 'package:jersey_premier_league/models/user_model.dart';
import 'package:jersey_premier_league/main.dart'; // Import main.dart to access gradient colors

// Update the typedefs to remove the one for admin sign-in (if it existed)
typedef SignInCallback = Future<User?> Function(String email, String password);
typedef GoogleSignInCallback = Future<User?> Function();
typedef GoToRegisterCallback = VoidCallback;


class LoginPage extends StatefulWidget {
  final SignInCallback onSignIn;
  final GoogleSignInCallback onGoogleSignIn;
  final GoToRegisterCallback onGoToRegister;
  final bool isLoading;
  // ⚡ FIX: Removed the 'onAdminSignIn' declaration and requirement
  // final SignInCallback onAdminSignIn; // <-- This line is removed

  const LoginPage({
    super.key,
    required this.onSignIn,
    required this.onGoogleSignIn,
    required this.isLoading,
    required this.onGoToRegister,
    // required this.onAdminSignIn, // <-- This is removed from the constructor
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
    // ... (logic remains the same)
    if (_localLoading) return;

    setState(() {
      _errorMessage = null;
      _localLoading = true;
    });

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = "Please enter both email and password.";
        _localLoading = false;
      });
      return;
    }

    try {
      final user = await widget.onSignIn(_emailController.text, _passwordController.text);
      if (user == null) {
        setState(() {
          _errorMessage = "Invalid email or password.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Login failed: ${e.toString()}";
      });
    } finally {
      if (mounted) {
        setState(() {
          _localLoading = false;
        });
      }
    }
  }

  void _attemptGoogleLogin() async {
    if (widget.isLoading || _localLoading) return;

    setState(() {
      _errorMessage = null;
      _localLoading = true;
    });

    try {
      await widget.onGoogleSignIn();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Google sign-in failed: ${e.toString()}";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _localLoading = false;
        });
      }
    }
  }

  // NOTE: If you had a dedicated button/logic for admin login, you must remove it here as well.

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themePrimaryColor = Theme.of(context).colorScheme.primary;
    final combinedLoading = widget.isLoading || _localLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('JPL Login'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            // Use the gradient colors defined in main.dart
            gradient: LinearGradient(
              colors: appBarGradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              // Email Field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                enabled: !combinedLoading,
              ),
              const SizedBox(height: 20),
              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                enabled: !combinedLoading,
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 30),

              // Standard Login Button
              ElevatedButton(
                onPressed: combinedLoading ? null : _attemptLogin,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
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
                onPressed: combinedLoading ? null : _attemptGoogleLogin,
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
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // Go to Register
              TextButton(
                onPressed: combinedLoading ? null : widget.onGoToRegister,
                child: Text("Don't have an account? Register", style: TextStyle(color: themePrimaryColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}