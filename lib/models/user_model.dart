class User {
  final int? id;
  final String email;
  final String password;
  final String fullName;
  final String phone;
  final String address;
  final String? profileImage;
  final String role; // 'admin', 'vendor', or 'user'
  final DateTime createdAt;

  User({
    this.id,
    required this.email,
    required this.password,
    required this.fullName,
    required this.phone,
    required this.address,
    this.profileImage,
    this.role = 'user', // default role is 'user'
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert User to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'fullName': fullName,
      'phone': phone,
      'address': address,
      'profileImage': profileImage,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create User from Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      email: map['email'] as String,
      password: map['password'] as String,
      fullName: map['fullName'] as String,
      phone: map['phone'] as String,
      address: map['address'] as String,
      profileImage: map['profileImage'] as String?,
      role: map['role'] as String? ?? 'user',
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  // Create a copy with updated fields
  User copyWith({
    int? id,
    String? email,
    String? password,
    String? fullName,
    String? phone,
    String? address,
    String? profileImage,
    String? role,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Helper methods to check user role
  bool get isAdmin => role == 'admin';
  bool get isVendor => role == 'vendor';
  bool get isRegularUser => role == 'user';
}
