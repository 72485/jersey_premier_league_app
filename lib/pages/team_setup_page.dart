import 'package:flutter/material.dart';
import 'package:jersey_premier_league/models/user_model.dart';
import 'package:jersey_premier_league/services/auth_service.dart'; // Ensure Result is defined here

class TeamSetupPage extends StatefulWidget {
  final User user;
  final AuthService authService;
  // Note: The old 'onTeamIdSaved' is removed as the app flow now relies on
  // the main App builder detecting the fpl_team_ID update via the ValueNotifier.

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

      // 1. Create a User object with the updated FPL Team ID.
      final String fplIdInput = _teamIdController.text.trim();

      // 🔑 CRITICAL FIX: Ensure an empty string is mapped to null,
      // although the validator should prevent an empty string here.
      final String? newFplTeamId = fplIdInput.isNotEmpty ? fplIdInput : null;

      final updatedUser = widget.user.copyWith(
        fpl_team_id: newFplTeamId, // Pass the now correctly-nullable value
        name: widget.user.name, // Ensure name is preserved
      );

      try {
        // 2. Use the updated method: updateUser which returns a Result object.
        final result = await widget.authService.updateFplTeamID(newFplTeamId);

        if (!result.success) {
          // 3. Handle specific error cases from the Result object.
          String errorMsg = 'Failed to save ID. Please try again.';

          if (result.message.contains('FPL_TEAM_ID_EXISTS')) {
            errorMsg = 'This FPL Team ID is already in use by another user.';
          } else if (result.message.isNotEmpty) {
            errorMsg = result.message.replaceFirst('Exception: ', '');
          }

          setState(() {
            _errorMessage = errorMsg;
          });
        }
        // If successful (result.success is true), the main.dart ValueListenableBuilder
        // will detect the user change and navigate away from this page.

      } catch (e) {
        setState(() {
          _errorMessage = 'An unexpected error occurred: ${e.toString()}';
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
                const SizedBox(height: 24),
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
