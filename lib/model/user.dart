class UserModel {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String username;

  UserModel({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.username,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    if (data['type'] == 'admin') {
      return AdminUserModel.fromUserModel(
        UserModel(
          uid: data['uid'],
          email: data['email'],
          firstName: data['firstName'],
          lastName: data['lastName'],
          username: data['username'],
        ),
      );
    } else {
      return BasicUserModel.fromUserModel(
        UserModel(
          uid: data['uid'],
          email: data['email'],
          firstName: data['firstName'],
          lastName: data['lastName'],
          username: data['username'],
        ),
      );
    }
  }


  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
    };
  }
}


class AdminUserModel extends UserModel {
  AdminUserModel({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
    required String username,
  }) : super(
    uid: uid,
    email: email,
    firstName: firstName,
    lastName: lastName,
    username: username,
  );

  factory AdminUserModel.fromUserModel(UserModel userModel) {
    return AdminUserModel(
      uid: userModel.uid,
      email: userModel.email,
      firstName: userModel.firstName,
      lastName: userModel.lastName,
      username: userModel.username,
    );
  }
  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = super.toMap();
    data['type'] = 'admin';
    return data;
  }
}

class BasicUserModel extends UserModel {
  BasicUserModel({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
    required String username,
  }) : super(
    uid: uid,
    email: email,
    firstName: firstName,
    lastName: lastName,
    username: username,
  );

  factory BasicUserModel.fromUserModel(UserModel userModel) {
    return BasicUserModel(
      uid: userModel.uid,
      email: userModel.email,
      firstName: userModel.firstName,
      lastName: userModel.lastName,
      username: userModel.username,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = super.toMap();
    data['type'] = 'basic';
    return data;
  }
}
