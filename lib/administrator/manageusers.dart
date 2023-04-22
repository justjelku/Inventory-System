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
          'uid': data['uid'],
          'email': data['email'],
          'role': 'admin'
        });
      }

      for (var basicUserDoc in basicUserDocs) {
        final data = basicUserDoc.data();
        authorizedUsers.add({
          'uid': data['uid'],
          'email': data['email'],
          'role': 'basic'
        });
      }

      print('List authorized users successful.');
      print('Collection: admin_users');
      for (var user in authorizedUsers) {
        print('User: ${user['email']}, Role: ${user['role']}');
      }

      setState(() {
        _authorizedUsers = authorizedUsers;
      });

      // Check if the user is authorized to view the user list
      bool isAuthorized = authorizedUsers.any((user) => user['uid'] == _user.uid);
      if (!isAuthorized) {
        _showMsg('You are authorized to manage the user list.', true);
        setState(() {
          showUsersList = true;
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
              userData['isAdmin'] == true || userData['isSuperAdmin'] == true;
          _user.firstName = currentUser.displayName?.split(' ')[0] ?? '';
          _user.lastName = currentUser.displayName?.split(' ')[1] ?? '';
          _user.username = currentUser.email?.split('@')[0] ?? '';
        });
      }
    }
  }

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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                    ? ElevatedButton(
                  onPressed: () {
                    // Perform admin-specific action here
                    setState(() {
                      showUsersList = true;
                    });
                  },
                  child: const Text('Perform Admin Action'),
                )
                    : const SizedBox(),
                Expanded(
                  child: Visibility(
                    visible: showUsersList,
                    child: ListView.builder(
                      itemCount: _authorizedUsers.length,
                      itemBuilder: (context, index) {
                        final user = _authorizedUsers[index];
                        return ListTile(
                          title: Text(user['email'] ?? ''),
                          subtitle: Text(user['uid'] ?? ''),
                          trailing: Text(user['role'] ?? ''),
                        );
                      },
                    ),
                  ),
                ),

              ],
            ),
          ),
        );
      },
    );
  }
}


