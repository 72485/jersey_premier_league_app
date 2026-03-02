import 'package:flutter/material.dart';

// 🚨 CHANGE: Updated RegisterCallback to return Future<void>
// It should no longer return a User? since registration isn't complete until verification.
typedef RegisterCallback = Future<void> Function(String name, String email, String password);

class RegisterPage extends StatefulWidget {
  final RegisterCallback onRegister;
  final VoidCallback onGoToLogin;

  const RegisterPage({
    super.key,
    required this.onRegister,
    required this.onGoToLogin,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  // 🆕 NEW: State to show success message after email is sent
  bool _registrationSuccessful = false;

  void _attemptRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _registrationSuccessful = false;
      });

      try {
        await widget.onRegister(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        // 🆕 NEW LOGIC: If onRegister succeeds (meaning user created and email sent)
        setState(() {
          _registrationSuccessful = true;
        });

        // 💡 Guide the user back to the login screen after a delay
        // to check their email for the verification link.
        await Future.delayed(const Duration(seconds: 3));

        if (mounted) {
          widget.onGoToLogin();
        }

      } catch (e) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // REMOVE: const Color primaryColor = Color(0xFF1E88E5);
    final themePrimaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('JPL Registration'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Icon - use theme color
                Icon(Icons.person_add, size: 80, color: themePrimaryColor),
                const SizedBox(height: 16),
                const Text(
                  'Create Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 32),

                // 🆕 NEW: Success Message Block
                if (_registrationSuccessful)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Column(
                      children: [
                        Icon(Icons.email, size: 60, color: themePrimaryColor),
                        const SizedBox(height: 10),
                        const Text(
                          'Success! Please verify your email.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.green,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'You are being redirected to the login page.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),

                // Fields and Button are only shown if registration is not successful
                if (!_registrationSuccessful) ...[
                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    validator: (value) => value == null || value.isEmpty ? 'Please enter your name.' : null,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person, color: themePrimaryColor),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value == null || !value.contains('@') ? 'Enter a valid email.' : null,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.lock, color: themePrimaryColor),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    validator: (value) => value == null || value.length < 6 ? 'Password must be 6+ characters.' : null,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock, color: themePrimaryColor),
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

                  // Register Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _attemptRegister,
                    style: ElevatedButton.styleFrom(
                      // backgroundColor is now inherited
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    )
                        : const Text(
                      'Register',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                ], // End of !_registrationSuccessful block

                // Go to Login
                TextButton(
                  onPressed: widget.onGoToLogin,
                  child: Text('Already have an account? Sign In', style: TextStyle(color: themePrimaryColor)), // Use theme color
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}