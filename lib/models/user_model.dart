// lib/models/user_model.dart (Frontend Model)

class Result {
  final bool success;
  final String message;

  Result({required this.success, this.message = ''});
}

class User {
  final int id;
  final String email;
  final String name;
  final String token;
  final String? fpl_team_id;
  // ⚡ FIX: Add the email verification status
  final bool is_email_verified;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.token,
    required this.is_email_verified, // ⚡ FIX: Make it required in constructor
    this.fpl_team_id,
  });

  // Factory constructor to create a User from a mock API response Map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      name: json['name'] as String,
      token: (json['token'] as String?) ?? '',
      // ⚡ FIX: Read the is_email_verified field
      is_email_verified: json['is_email_verified'] as bool,
      // FPL ID is nullable
      fpl_team_id: json['fpl_team_id'] as String?,
    );
  }

  // Helper method to create a new User instance with an updated fpl_team_ID
  User copyWith({
    String? fpl_team_id,
    String? name,
    bool? is_email_verified, // Allow updating verification status on the client side if needed
  }) {
    return User(
      id: id,
      email: email,
      name: name ?? this.name,
      token: token,
      fpl_team_id: fpl_team_id ?? this.fpl_team_id,
      is_email_verified: is_email_verified ?? this.is_email_verified, // Update here
    );
  }
}