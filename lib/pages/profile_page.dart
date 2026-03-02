// lib/pages/profile_page.dart

import 'package:flutter/material.dart';
import 'package:jersey_premier_league/models/user_model.dart';
// 🔑 CRITICAL DEPENDENCY: This import brings in the AuthService class AND the external Result class definition.
import 'package:jersey_premier_league/services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  final User user;
  final AuthService authService;
  final VoidCallback onSignOut;

  const ProfilePage({
    super.key,
    required this.user,
    required this.authService,
    required this.onSignOut,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Form Key for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers for editable fields
  late TextEditingController _nameController;
  late TextEditingController _fplTeamIdController;

  // Track the saving state
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current user data
    _nameController = TextEditingController(text: widget.user.name);
    _fplTeamIdController = TextEditingController(text: widget.user.fpl_team_id);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fplTeamIdController.dispose();
    super.dispose();
  }

  // Helper method to show a SnackBar message
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 1. Trim the new values from controllers
    final newName = _nameController.text.trim();
    final String fplIdTrimmed = _fplTeamIdController.text.trim();

    // Explicitly map the empty string to null (since the model field is String?)
    final String? newFplTeamId = fplIdTrimmed.isNotEmpty ? fplIdTrimmed : null;

    // 2. Check if any value has actually changed before proceeding
    final isNameUnchanged = newName == widget.user.name;
    final isFplIdUnchanged = newFplTeamId == widget.user.fpl_team_id;

    if (isNameUnchanged && isFplIdUnchanged) {
      _showSnackBar('No changes detected.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // Create a new User object with the updated details
    final updatedUser = widget.user.copyWith(
      name: newName,
      fpl_team_id: newFplTeamId,
    );

    try {
      // Service call updates the database AND the currentUserNotifier.value
      final result = await widget.authService.updateUser(updatedUser);

      if (mounted) {
        if (result.success) {
          // 🔑 CRITICAL FIX START: Read the latest data from the central state
          final latestUser = widget.authService.currentUserNotifier.value;

          if (latestUser != null) {
            // 🔑 CRITICAL FIX 1: Update the name controller with the new (trimmed) name
            _nameController.text = latestUser.name;

            // 🔑 CRITICAL FIX 2: Update the FPL ID controller with the new FPL Team ID
            // This is the saved value from the database (may be null/empty string)
            _fplTeamIdController.text = latestUser.fpl_team_id ?? '';
          }
          // 🔑 CRITICAL FIX END

          _showSnackBar('Profile updated successfully!');

        } else {
          // Handle specific error case for duplicate FPL Team ID (or others)
          if (result.message.contains('FPL Team ID is already in use by another account')) {
            _showSnackBar(
              'This FPL Team ID is already in use by another user.',
              isError: true,
            );
          } else {
            _showSnackBar(
              'Failed to update profile: ${result.message}',
              isError: true,
            );
          }
        }
      }
    } catch (e) {
      // Catch network or unhandled errors
      if (mounted) {
        _showSnackBar('An unexpected error occurred.', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- Email (Not Editable) ---
            const Text(
              'Email (Not Editable)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: widget.user.email,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
                fillColor: Colors.grey, // Visually indicate it's disabled
                filled: true,
              ),
              enabled: false, // Disables editing
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),

            // --- Name (Editable) ---
            const Text(
              'Name',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
                hintText: 'Enter your full name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name.';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // --- FPL Team ID (Editable & Unique Check) ---
            const Text(
              'FPL Team ID',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _fplTeamIdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.sports_soccer),
                hintText: 'Enter your FPL Team ID (e.g., 12345)',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your FPL Team ID.';
                }
                if (int.tryParse(value) == null) {
                  return 'FPL Team ID must be a number.';
                }
                // The actual uniqueness check (FPL_TEAM_ID_EXISTS) is handled
                // in the _updateProfile function upon saving.
                return null;
              },
            ),
            const SizedBox(height: 32),

            // --- Save Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _updateProfile,
                icon: _isSaving
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.save),
                label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // --- Sign Out Button ---
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: widget.onSignOut,
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}