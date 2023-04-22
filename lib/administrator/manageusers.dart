// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
//
// class ManageUsers extends StatefulWidget {
//   const ManageUsers({Key? key}) : super(key: key);
//
//   @override
//   State<ManageUsers> createState() => _ManageUsersState();
// }
//
// class _ManageUsersState extends State<ManageUsers> {
//   List<Map<String, dynamic>> _authorizedUsers = [];
//
//   Future<void> _listAuthorizedUsers() async {
//     try {
//       final adminUsersRef = FirebaseFirestore.instance.collection('users').doc('qIglLalZbFgIOnO0r3Zu').collection('admin_users');
//       final basicUsersRef = FirebaseFirestore.instance.collection('users').doc('qIglLalZbFgIOnO0r3Zu').collection('basic_users');
//
//       final adminUsersSnapshot = await adminUsersRef.get();
//       final basicUsersSnapshot = await basicUsersRef.get();
//
//       final adminUserDocs = adminUsersSnapshot.docs;
//       final basicUserDocs = basicUsersSnapshot.docs;
//
//       final List<Map<String, dynamic>> authorizedUsers = [];
//
//       for (var adminUserDoc in adminUserDocs) {
//         final data = adminUserDoc.data();
//         authorizedUsers.add({
//           'uid': data['uid'],
//           'email': data['email'],
//           'role': 'admin'
//         });
//       }
//
//       for (var basicUserDoc in basicUserDocs) {
//         final data = basicUserDoc.data();
//         authorizedUsers.add({
//           'uid': data['uid'],
//           'email': data['email'],
//           'role': 'basic'
//         });
//       }
//
//       print('List authorized users successful.');
//       print('Collection: admin_users');
//       for (var user in authorizedUsers) {
//         print('User: ${user['email']}, Role: ${user['role']}');
//       }
//
//       setState(() {
//         _authorizedUsers = authorizedUsers;
//       });
//
//     } catch (error) {
//       print('Error listing authorized users: $error');
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _listAuthorizedUsers();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: ListView.builder(
//         itemCount: _authorizedUsers.length,
//         itemBuilder: (context, index) {
//           final user = _authorizedUsers[index];
//           return ListTile(
//             title: Text(user['email'] ?? ''),
//             subtitle: Text(user['uid'] ?? ''),
//             trailing: Text(user['role'] ?? ''),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_login_auth/administrator/edituser.dart';
import 'package:firebase_login_auth/model/constant.dart';
import 'package:firebase_login_auth/model/user.dart';
import 'package:flutter/material.dart';

class ManageUser extends StatefulWidget {
  final String userId;

  ManageUser({required this.userId});

  @override
  _ManageUserState createState() => _ManageUserState();
}

class _ManageUserState extends State<ManageUser> {
  List<Map<String, dynamic>> _authorizedUsers = [];
  late UserModel _user;
  bool _isAdmin = true;
  bool showUsersList = false;
  late final userRef = FirebaseFirestore.instance
      .collection('users')
      .doc('qIglLalZbFgIOnO0r3Zu')
      .collection('admin_users')
      .doc(FirebaseAuth.instance.currentUser!.uid);

  @override
  void initState() {
    super.initState();
    _listAuthorizedUsers();
    final user = FirebaseAuth.instance.currentUser!;
    _user = UserModel(
      uid: user.uid,
      email: user.email!,
      firstName: '',
      lastName: '',
      username: '',
    );
    _getUserDetails();
  }

  Future<void> _listAuthorizedUsers() async {
    try {
      final adminUsersRef = FirebaseFirestore.instance.collection('users')
          .doc('qIglLalZbFgIOnO0r3Zu')
          .collection('admin_users');
      final basicUsersRef = FirebaseFirestore.instance.collection('users')
          .doc('qIglLalZbFgIOnO0r3Zu')
          .collection('basic_users');

      final adminUsersSnapshot = await adminUsersRef.get();
      final basicUsersSnapshot = await basicUsersRef.get();

      final adminUserDocs = adminUsersSnapshot.docs;
      final basicUserDocs = basicUsersSnapshot.docs;

      final List<Map<String, dynamic>> authorizedUsers = [];

      for (var adminUserDoc in adminUserDocs) {
        final data = adminUserDoc.data();
        authorizedUsers.add({
          'uid': adminUserDoc.id,
          'email': data['email'],
          'role': 'admin'
        });
        // uids.add(data['uid']);
      }

      for (var basicUserDoc in basicUserDocs) {
        final data = basicUserDoc.data();
        authorizedUsers.add({
          'uid': basicUserDoc.id,
          'email': data['email'],
          'role': 'basic'
        });
        // uids.add(data['uid']);
      }

      print('List authorized users successful.');
      print('Collection: admin_users');
      for (var user in authorizedUsers) {
        print('User: ${user['email']}, UID: ${user['uid']}, Role: ${user['role']}');
      }

      setState(() {
        _authorizedUsers = authorizedUsers;
      });

      // Check if the user is authorized to view the user list
      bool isAuthorized = authorizedUsers.any((user) => user['uid'] == _user.uid);
      if (!isAuthorized) {
        // _showMsg('You are authorized to manage the user list.', true);
        setState(() {
          showUsersList = false;
        });
      }
      setState(() {
        showUsersList = false;
      });

    } catch (error) {
      _showMsg('You are not authorized to manage the user list.', false);
    }
  }

  void _getUserDetails() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc('qIglLalZbFgIOnO0r3Zu')
          .collection('admin_users')
          .doc(currentUser.uid)
          .get();
      if (userSnapshot.exists) {
        final userData = userSnapshot.data()!;
        setState(() {
          _user = UserModel.fromMap(userData);
          _isAdmin =
              userData['isAdmin'] == true || userData['isAdmin'] == true;
          _user.firstName = currentUser.displayName?.split(' ')[0] ?? '';
          _user.lastName = currentUser.displayName?.split(' ')[1] ?? '';
          _user.username = currentUser.email?.split('@')[0] ?? '';
        });
      }
    }
  }
  // userData['isAdmin'] == true || userData['isSuperAdmin'] == true;

  void _showMsg(String message, bool isSuccess) {
    Color color = isSuccess ? Colors.green : Colors.red;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: color,
            width: 2,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: showUsers(),
    );
  }

  Widget showUsers() {
    // If user details are not loaded yet, show a loading spinner
    if (_user == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // final user = FirebaseAuth.instance.currentUser!;
    final userRef = FirebaseFirestore.instance.collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('admin_users')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    // Build the UI once user details are loaded
    return FutureBuilder<DocumentSnapshot>(
      future: userRef.get(),
      builder: (BuildContext context,
          AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('Error retrieving user data...'),
              ],
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                Text('Retrieving user data...'),
                ],
            ),
          );
        }
        final data = snapshot.data?.data() as Map<String, dynamic>;
        return Scaffold(
          body: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue, // Change background color here
                      backgroundImage: AssetImage('assets/logo.png'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Admin Information',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text('Name: ${data['first name'] ?? 'N/A'}${data['last name'] ?? 'N/A'} '),
                  const SizedBox(height: 8.0),
                  Text('Email: ${_user.email}'),
                  const SizedBox(height: 8.0),
                  Text('Username: ${data['username']}'),
                  const SizedBox(height: 16.0),
                  _isAdmin
                      ? GestureDetector(
                        onTap: (){
                        // Perform admin-specific action here
                        setState(() {
                          showUsersList = true;
                        });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: primaryBtnColor,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Center(
                            child: Text("View all users",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17
                              )
                            ),
                          )
                        ),
                      )
                      : const SizedBox(height: 20),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Visibility(
                      visible: showUsersList,
                      child: SingleChildScrollView(
                        child: Column(
                          children: _authorizedUsers.map((user) => Container(
                            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              tileColor: const Color(0xFF3a506b),
                              iconColor: Colors.white,
                              textColor: Colors.white,
                              leading: const Icon(
                                Icons.account_circle_rounded,
                                size: 30,
                              ),
                              title: Text(user['email'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(user['role'] ?? ''), //user['role'] == 'admin' ?
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  size: 30,
                                ),
                                onPressed: () => _editUser(user['uid']),
                              ) //: null,
                            ),
                          )).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  // void _editUser(String uid) {
  //   final user = _authorizedUsers.firstWhere((user) => user['uid'] == uid);
  //   final emailController = TextEditingController(text: user['email']);
  //   final firstNameController = TextEditingController(text: user['first name']);
  //   final lastNameController = TextEditingController(text: user['last name']);
  //   final usernameController = TextEditingController(text: user['username']);
  //   final passwordController = TextEditingController();
  //
  //   print(uid);
  //   print(user['first name']);
  //   print(user['last name']);
  //   print(user['username']);
  //   print(user['email']);
  //
  //   showDialog(
  //     context: context,
  //     builder: (_) => AlertDialog(
  //       title: const Text('Edit User'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           TextField(
  //             controller: firstNameController,
  //             decoration: const InputDecoration(hintText: 'First Name'),
  //           ),
  //           TextField(
  //             controller: firstNameController,
  //             decoration: const InputDecoration(hintText: 'Last Name'),
  //           ),
  //           TextField(
  //             controller: firstNameController,
  //             decoration: const InputDecoration(hintText: 'Username'),
  //           ),
  //           TextField(
  //             controller: emailController,
  //             decoration: const InputDecoration(hintText: 'Email'),
  //           ),
  //           TextField(
  //             controller: firstNameController,
  //             obscureText: true,
  //             decoration: const InputDecoration(hintText: 'Password'),
  //           ),
  //           // Add additional text fields for last name, username, and password here
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //           },
  //           child: const Text('Cancel'),
  //         ),
  //         ElevatedButton(
  //           onPressed: () {
  //             final newEmail = emailController.text.trim();
  //             final newFirstName = firstNameController.text.trim();
  //             final newLastName = lastNameController.text.trim();
  //             final newUsername = usernameController.text.trim();
  //             final newPassword = passwordController.text.trim();
  //             if (newEmail.isNotEmpty) {
  //               // Update the user's email in Firestore
  //               FirebaseFirestore.instance
  //                   .collection('users')
  //                   .doc('qIglLalZbFgIOnO0r3Zu')
  //                   .collection('admin_users')
  //                   .doc(uid)
  //                   .update({'email': newEmail, 'first name': newFirstName, 'last name': newFirstName, 'username': newFirstName, 'password': newFirstName});
  //
  //               // Update the user's email in the authorized users list
  //               setState(() {
  //                 final index = _authorizedUsers.indexWhere((user) => user['uid'] == uid);
  //                 _authorizedUsers[index]['email'] = newEmail;
  //               });
  //
  //               Navigator.pop(context);
  //             }
  //           },
  //           child: const Text('Save'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _editUser(String uid) async {

    final adminUserRef = FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('admin_users')
        .doc(uid);

    final basicUserRef = FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(uid);

    final adminUserSnapshot = await adminUserRef.get();
    final basicUserSnapshot = await basicUserRef.get();

    final userDetails = adminUserSnapshot.exists ? adminUserSnapshot : basicUserSnapshot;

    final user = _authorizedUsers.firstWhere((user) => user['uid'] == uid);
    final roleController = TextEditingController(text: user['role']);
    final firstNameController = TextEditingController(text: userDetails['first name']);
    final lastNameController = TextEditingController(text: userDetails['last name']);
    final usernameController = TextEditingController(text: userDetails['username']);
    final emailController = TextEditingController(text: user['email']);
    final passwordController = TextEditingController();

    print(uid);
    print(userDetails['first name']);
    print(userDetails['last name']);
    print(userDetails['username']);
    print(user['email']);
    print(user['role']);


    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: roleController,
                decoration: const InputDecoration(hintText: 'Role (admin or basic user)'),
              ),
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(hintText: 'First Name'),
              ),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(hintText: 'Last Name'),
              ),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(hintText: 'Username'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(hintText: 'Email'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(hintText: 'New Password'),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newRole = roleController.text.trim();
              final newFirstName = firstNameController.text.trim();
              final newLastName = lastNameController.text.trim();
              final newUsername = usernameController.text.trim();
              final newEmail = emailController.text.trim();
              final newPassword = passwordController.text.trim();
              if (newEmail.isNotEmpty) {

                // Update the user's details in Firestore
                FirebaseFirestore.instance
                    .collection('users')
                    .doc('qIglLalZbFgIOnO0r3Zu')
                    .collection('admin_users')
                    .doc(uid)
                    .update({
                  'role': newRole,
                  'first name': newFirstName,
                  'last name': newLastName,
                  'username': newUsername,
                  'email': newEmail,
                });
                FirebaseFirestore.instance
                    .collection('users')
                    .doc('qIglLalZbFgIOnO0r3Zu')
                    .collection('basic_users')
                    .doc(uid)
                    .update({
                  'first name': newFirstName,
                  'last name': newLastName,
                  'username': newUsername,
                  'email': newEmail,
                });

                if (newPassword.isNotEmpty) {
                  // Update the user's password in Firebase Authentication
                  await FirebaseAuth.instance.currentUser!.updatePassword(newPassword);
                }

                // Update the user's email in Firebase Authentication
                await FirebaseAuth.instance.currentUser!.updateEmail(newEmail);

                // Update the user's details in the authorized users list
                setState(() {
                  final index =
                  _authorizedUsers.indexWhere((user) => user['uid'] == uid);
                  _authorizedUsers[index]['role'] = newRole;
                  _authorizedUsers[index]['firstName'] = newFirstName;
                  _authorizedUsers[index]['lastName'] = newLastName;
                  _authorizedUsers[index]['username'] = newUsername;
                  _authorizedUsers[index]['email'] = newEmail;
                });

                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

}


