import 'package:flutter/material.dart';
import 'package:jersey_premier_league/models/user_model.dart';
import 'package:jersey_premier_league/services/auth_service.dart';

// Assuming primaryColor is defined somewhere, for consistency with other pages
const Color primaryColor = Color(0xFF1E88E5);

class ProfilePage extends StatefulWidget {
  final User user;
  final AuthService authService;

  const ProfilePage({
    super.key,
    required this.user,
    required this.authService,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _teamIdController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current user data
    _nameController.text = widget.user.name;
    _teamIdController.text = widget.user.fpl_team_ID ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _teamIdController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if the user is already saving
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final newName = _nameController.text.trim();
    // Use null for empty string FPL IDs, consistent with database structure
    final newFplId = _teamIdController.text.trim().isEmpty ? null : _teamIdController.text.trim();

    // Check if anything has actually changed before calling the API
    if (newName == widget.user.name && newFplId == widget.user.fpl_team_ID) {
      setState(() {
        _isSaving = false;
        _errorMessage = 'No changes detected.';
      });
      return;
    }

    try {
      // The updateProfile function handles both name and fplTeamId updates
      await widget.authService.updateProfile(
        widget.user,
        name: newName,
        fplTeamId: newFplId,
      );

      // Success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        setState(() => _isSaving = false);
      }

    } catch (e) {
      setState(() {
        _isSaving = false;
        _errorMessage = 'Failed to update profile: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          // Save Icon in the AppBar
          IconButton(
            icon: _isSaving
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
            )
                : const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // --- Uneditable Email Display ---
              Text(
                'Email (Login Identifier)',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                widget.user.email,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const Divider(height: 32),

              // --- Editable Name ---
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // --- Editable FPL Team ID ---
              TextFormField(
                controller: _teamIdController,
                decoration: const InputDecoration(
                  labelText: 'FPL Team ID (Optional)',
                  hintText: 'Enter your FPL Team ID',
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),

              // Error Message
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}