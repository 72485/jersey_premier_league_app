import 'package:flutter/material.dart';
import 'package:jersey_premier_league/models/user_model.dart';
import 'package:jersey_premier_league/services/auth_service.dart';

class TeamSetupPage extends StatefulWidget {
  final User user;
  final AuthService authService; // **Fix for Error 2: 'authService' isn't defined.**
  // Note: The old 'onTeamIdSaved' is removed to fix Error 1.

  const TeamSetupPage({
    super.key,
    required this.user,
    required this.authService,
  });

  @override
  State<TeamSetupPage> createState() => _TeamSetupPageState();
}

class _TeamSetupPageState extends State<TeamSetupPage> {
  final TextEditingController _teamIdController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  String? _errorMessage;

  void _saveTeamId() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
        _errorMessage = null;
      });

      try {
        // Use the AuthService to update the ID via the mocked API
        await widget.authService.updateFplTeamID(widget.user, _teamIdController.text);

        // Success: The user stream in main.dart will update the state
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to save ID. Please try again.';
        });
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // REMOVE: const Color primaryColor = Color(0xFF1E88E5);
    final themePrimaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Prevent back button since this is mandatory
        title: const Text('Mandatory Setup'),
        centerTitle: true,
        actions: [
          // Allow sign-out from the setup page
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: widget.authService.signOut,
            tooltip: 'Logout',
          ),
        ],
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
                Icon(Icons.star, size: 80, color: themePrimaryColor),
                const SizedBox(height: 16),
                const Text(
                  'Set Your FPL Team ID',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  'Welcome, ${widget.user.name}! To access the dashboard, please enter your Fantasy Premier League (FPL) Team ID.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                TextFormField(
                  controller: _teamIdController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'FPL Team ID',
                    hintText: 'e.g., 123456',
                    prefixIcon: Icon(Icons.numbers, color: themePrimaryColor), // Use theme color
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Team ID cannot be empty.';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

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

                // Save Button - relies on inherited ElevatedButtonTheme
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveTeamId,
                  style: ElevatedButton.styleFrom(
                    // backgroundColor is now inherited
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                  )
                      : const Text(
                    'Save and Continue',
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
