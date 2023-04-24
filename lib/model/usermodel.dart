class UserModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String role;
  late bool status;

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.role,
    required this.status,
  });

  UserModel copyWith({
    String? uid,
    String? firstName,
    String? lastName,
    String? username,
    String? email,
    String? role,
    bool? status,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'email': email,
      'role': role,
      'enabled': status,
    };
  }


}