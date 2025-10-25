import 'package:flutter/material.dart';

class User {
  final int id;
  final String email;
  final String name;
  final String token; // New: Required for REST API session management
  final String? fpl_team_ID;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.token,
    this.fpl_team_ID,
  });

  // Factory constructor to create a User from a mock API response Map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      name: json['name'] as String,
      token: json['token'] as String,
      // FPL ID is nullable
      fpl_team_ID: json['fpl_team_ID'] as String?,
    );
  }

  // Helper method to create a new User instance with an updated fpl_team_ID
  User copyWith({
    String? fpl_team_ID,
    String? name,
  }) {
    return User(
      id: id,
      email: email,
      name: name ?? this.name,
      token: token,
      fpl_team_ID: fpl_team_ID ?? this.fpl_team_ID,
    );
  }
}
