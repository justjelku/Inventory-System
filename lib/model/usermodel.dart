class UserModel {
  final String userId;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String role;
  late String status;
  UserModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.role,
    required this.status,
  });

  UserModel copyWith({
    String? userId,
    String? firstName,
    String? lastName,
    String? username,
    String? email,
    String? role,
    String? status,
    String? profilePictureUrl,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'first name': firstName,
      'last name': lastName,
      'username': username,
      'email': email,
      'role': role,
      'enabled': status,
    };
  }
}