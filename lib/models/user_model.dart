class UserModel {
  final String id;
  final String email;
  final String name;
  final String role;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.role = 'user',
    this.createdAt,
  });

  /// Alias for id to match Firebase Auth uid conventions
  String get uid => id;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedCreatedAt;
    if (json['createdAt'] != null) {
      if (json['createdAt'] is DateTime) {
        parsedCreatedAt = json['createdAt'] as DateTime;
      } else if (json['createdAt'] is String) {
        parsedCreatedAt = DateTime.tryParse(json['createdAt'] as String);
      } else {
        // Handle Firestore Timestamp dynamically without requiring direct class coupling if dynamic
        try {
          final dynamic timestamp = json['createdAt'];
          parsedCreatedAt = timestamp.toDate();
        } catch (_) {
          parsedCreatedAt = null;
        }
      }
    }

    return UserModel(
      id: (json['id'] ?? json['uid'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      role: (json['role'] ?? 'user') as String,
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': id,
      'email': email,
      'name': name,
      'role': role,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'uid': id,
      'email': email,
      'name': name,
      'role': role,
      'createdAt': createdAt,
    };
  }
}
