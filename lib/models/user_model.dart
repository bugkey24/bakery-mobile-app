// lib/models/user_model.dart
class User {
  final int? id;
  final String username;
  final String password;
  final String role; // 'admin' or 'buyer'

  User({
    this.id,
    required this.username,
    required this.password,
    required this.role,
  });

  // Conversion Map (from SQLite) to User object
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      role: map['role'],
    );
  }

  // Conversion object to Map (for inserting into SQLite)
  Map<String, dynamic> toMap() {
    return {'id': id, 'username': username, 'password': password, 'role': role};
  }
}
