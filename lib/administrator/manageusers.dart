// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_login_auth/model/constant.dart';
import 'package:firebase_login_auth/model/usermodel.dart';
import 'package:firebase_login_auth/model/userprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManageUser extends StatefulWidget {
  final List<UserModel> usersId;

  const ManageUser({Key? key, required this.usersId}) : super(key: key);

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

  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();


  var formKey = GlobalKey<FormState>();

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
      role: '',
      status: false,
    );
    _getUserDetails();
  }

  Future<void> _listAuthorizedUsers() async {
    try {
      final basicUsersRef = FirebaseFirestore.instance.collection('users')
          .doc('qIglLalZbFgIOnO0r3Zu')
          .collection('basic_users');

      // final adminUsersSnapshot = await adminUsersRef.get();
      final basicUsersSnapshot = await basicUsersRef.get();

      // final adminUserDocs = adminUsersSnapshot.docs;
      final basicUserDocs = basicUsersSnapshot.docs;

      final List<Map<String, dynamic>> authorizedUsers = [];

      for (var basicUserDoc in basicUserDocs) {
        final data = basicUserDoc.data();
        authorizedUsers.add({
          'uid': basicUserDoc.id,
          'email': data['email'],
          'role': data['role'],
          'enabled': data['enabled'],
        });
      }

      print('List authorized users successful.');
      print('Collection: admin_users');
      for (var user in authorizedUsers) {
        print('User: ${user['email']}, UID: ${user['uid']}, Role: ${user['role']}, Status: ${user['enabled']}');
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
        if (userData['enabled'] == true) {
          setState(() {
            _user = UserModel(
              uid: currentUser.uid,
              firstName: currentUser.displayName?.split(' ')[0] ?? '',
              lastName: currentUser.displayName?.split(' ')[1] ?? '',
              email: currentUser.email ?? '',
              username: currentUser.email?.split('@')[0] ?? '',
              role: '',
              status: true,
            ).copyWith(
              uid: userData['uid'],
              firstName: userData['firstName'],
              lastName: userData['lastName'],
              username: userData['username'],
              role: userData['role'],
              status: userData['enabled'],
              profilePictureUrl: userData['profileUrl'],
            );
            _isAdmin =
                userData['isAdmin'] == true || userData['superAdmin'] == true;
          });
        } else {
          // User is not enabled
          _showMsg('User is not enabled', false);
        }
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
    // final user = FirebaseAuth.instance.currentUser!;
    final userRef = FirebaseFirestore.instance.collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('admin_users')
        .doc(FirebaseAuth.instance.currentUser!.uid);

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
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Column(
                  children: [
                    Expanded(
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
                          Text('Name: ${data['first name']}${data['last name']}'),
                          const SizedBox(height: 8.0),
                          Text('Email: ${_user.email}'),
                          const SizedBox(height: 8.0),
                          Text('Username: ${data['username']}'),
                          const SizedBox(height: 8.0),
                          Text('Status: ${data['enabled'] ? 'Enabled' : 'Disabled'}'),
                          const SizedBox(height: 16.0),
                          if (!_isAdmin)
                            GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
                                  ),
                                  builder: (BuildContext context) => _showUserList(),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: primaryBtnColor,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Center(
                                  child: Text(
                                    "View all users",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            const SizedBox(height: 20),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    // if (showUsersList) const UserList()
                  ],
                ),
              ),
            ),
          );
        },
    );
  }

  Widget _showUserList() {
    return MultiProvider(
      providers: [
        Provider<List<UserModel>>(
          // Add the create method
          create: (_) {
            UserProvider().listenToUsers();
            return []; // Initialize an empty list
          },
        ),
        StreamProvider<List<UserModel>>.value(
          value: UserProvider().basicUserStream,
          initialData: [],
          catchError: (context, error) {
            // Handle the error here
            return [];
          },
          updateShouldNotify: (_, __) => true,
        ),
      ],
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              height: 50,
              alignment: Alignment.center,
              child: const Icon(Icons.arrow_drop_down),
            ),
          ),
          Expanded(
            child: Consumer<List<UserModel>>(
              builder: (context, list, child) {
                if (list.isEmpty) {
                  return const Center(
                    child: Text('No info found.'),
                  );
                }
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
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
                        title: Text(item.email,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(item.role),
                        trailing: PopupMenuButton(
                          itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                            PopupMenuItem(
                              value: item.status ? 'disable' : 'enable',
                              child: Text(item.status ? 'Disable' : 'Enable'),
                            ),
                            const PopupMenuDivider(),
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                          onSelected: (value) {
                            switch (value) {
                              case 'disable':
                                _disableUser(item.uid);
                                break;
                              case 'enable':
                                _enableUser(item.uid);
                                break;
                              case 'edit':
                                _editUser(item.uid);
                                break;
                              case 'delete':
                                _deleteUser(item.uid);
                                // _deleteUser(item.uid);
                                break;
                              default:
                                break;
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                showMyDialogue();
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primaryBtnColor,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Center(
                  child: Text(
                    "Add User",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }

  void _editUser(String uid) async {

    final basicUserRef = FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(uid);

    final basicUserSnapshot = await basicUserRef.get();

    final userDetails = basicUserSnapshot;

    final user = _authorizedUsers.firstWhere((user) => user['uid'] == uid);
    final roleController = TextEditingController(text: user['role']);
    final firstNameController = TextEditingController(text: userDetails['first name']);
    final lastNameController = TextEditingController(text: userDetails['last name']);
    final usernameController = TextEditingController(text: userDetails['username']);
    final statusController = TextEditingController(text: user['enabled'] ? 'enabled' : 'disabled');
    final emailController = TextEditingController(text: user['email']);
    final passwordController = TextEditingController();


    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        backgroundColor: gradientEndColor,
        scrollable: true,
        title: const Center(
            child: Text('Edit User')
        ),
        content: Form(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: roleController,
                  decoration: InputDecoration(
                      hintText: 'Role (admin or basic user)',
                    labelStyle: TextStyle(color: mainTextColor),
                    hintStyle: TextStyle(color: mainTextColor),
                  ),
                ),
                TextField(
                  controller: statusController,
                  decoration: InputDecoration(
                    hintText: 'Status',
                    labelStyle: TextStyle(color: mainTextColor),
                    hintStyle: TextStyle(color: mainTextColor),
                  ),
                ),
                TextField(
                  controller: firstNameController,
                  decoration: InputDecoration(hintText: 'First Name',
                    labelStyle: TextStyle(color: mainTextColor),
                    hintStyle: TextStyle(color: mainTextColor),
                  ),
                ),
                TextField(
                  controller: lastNameController,
                  decoration: InputDecoration(
                      hintText: 'Last Name',
                    labelStyle: TextStyle(color: mainTextColor),
                    hintStyle: TextStyle(color: mainTextColor),
                  ),
                ),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(hintText: 'Username',
                    labelStyle: TextStyle(color: mainTextColor),
                    hintStyle: TextStyle(color: mainTextColor),
                  ),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                      hintText: 'Email',
                    labelStyle: TextStyle(color: mainTextColor),
                    hintStyle: TextStyle(color: mainTextColor),
                  ),
                ),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                      hintText: 'New Password',
                    labelStyle: TextStyle(color: mainTextColor),
                    hintStyle: TextStyle(color: mainTextColor),
                  ),
                  obscureText: true,
                ),
              ],
            ),
          ),
        ),
        actions: [
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

                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              }
            },
            style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsets>(
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
              ),
              backgroundColor: MaterialStateProperty.all<Color>(primaryBtnColor),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
            child: Center(
              child: Text('Update',
                style: TextStyle(
                  color: mainTextColor,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsets>(
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              ),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
            child: Center(
              child: Text("Cancel",
                style: TextStyle(
                  color: mainTextColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(String uid) async {
    try {
      final basicUserRef = FirebaseFirestore.instance
          .collection('users')
          .doc('qIglLalZbFgIOnO0r3Zu')
          .collection('basic_users')
          .doc(uid);

      await basicUserRef.delete();

      setState(() {
        _authorizedUsers.removeWhere((user) => user['uid'] == uid);
      });

      _showMsg('User deleted successfully', true);
    } catch (error) {
      _showMsg('Failed to delete user', false);
    }
  }

  Future<void> _disableUser(String uid) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('qIglLalZbFgIOnO0r3Zu')
          .collection('basic_users')
          .doc(uid)
          .update({'enabled': false});
      setState(() {
        for (var user in _authorizedUsers) {
          if (user['uid'] == uid) {
            user['enabled'] = false;
          }
        }
      });
      _showMsg('User disabled successfully.', true);
    } catch (error) {
      _showMsg('Error disabling user: $error', false);
    }
  }

  Future<void> _enableUser(String uid) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('qIglLalZbFgIOnO0r3Zu')
          .collection('basic_users')
          .doc(uid)
          .update({'enabled': true});
      setState(() {
        for (var user in _authorizedUsers) {
          if (user['uid'] == uid) {
            user['enabled'] = true;
          }
        }
      });
      _showMsg('User enabled successfully.', true);
    } catch (error) {
      _showMsg('Error enabling user: $error', false);
    }
  }

  void showMyDialogue() async {

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            backgroundColor: gradientEndColor,
            scrollable: true,
            title: Center(
              child: Text('Add New Account',
                style: TextStyle(
                  color: mainTextColor,
                ),
              ),
            ),
            content: Container(
              padding: const EdgeInsets.all(10.0),
              child: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _roleController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          labelText: "Role",
                          hintText: "Admin or Basic",
                          labelStyle: TextStyle(color: mainTextColor),
                          hintStyle: TextStyle(color: mainTextColor),
                        ),
                        validator: (value){
                          return (value == '')? "First Name" : null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _firstNameController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          labelText: "First Name",
                          labelStyle: TextStyle(color: mainTextColor),
                          hintStyle: TextStyle(color: mainTextColor),
                        ),
                        validator: (value){
                          return (value == '')? "First Name" : null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _lastNameController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          labelText: "Last Name",
                          labelStyle: TextStyle(color: mainTextColor),
                          hintStyle: TextStyle(color: mainTextColor),
                        ),
                        validator: (value){
                          return (value == '')? "Last Name" : null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _userNameController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          labelText: "Username",
                          labelStyle: TextStyle(color: mainTextColor),
                          hintStyle: TextStyle(color: mainTextColor),
                        ),
                        validator: (value){
                          return (value == '')? "Username" : null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "Email Address",
                          labelStyle: TextStyle(color: mainTextColor),
                          hintStyle: TextStyle(color: mainTextColor),
                        ),
                        validator: (value){
                          return (value == '')? "Email Address" : null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _passwordController,
                        keyboardType: TextInputType.name,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: TextStyle(color: mainTextColor),
                          hintStyle: TextStyle(color: mainTextColor),
                        ),
                        validator: (value){
                          return (value == '')? "Password" : null;
                        },
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  newSignUp();
                  Navigator.pop(context);
                },
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
                  ),
                  backgroundColor: MaterialStateProperty.all<Color>(primaryBtnColor),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
                child: Center(
                  child: Text("Submit",
                    style: TextStyle(
                      color: mainTextColor,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
                child: Center(
                  child: Text("Cancel",
                    style: TextStyle(
                      color: mainTextColor,
                    ),
                  ),
                ),
              )
            ],
          );
        }
    );
  }

  Future newAddUserDetails(String firstName, String lastName, String userName, String email, String role, bool status) async{
    final userRef = FirebaseFirestore.instance.collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu');
    final userDetailsRef = userRef.collection('basic_users')
        .doc();
    final userDetails = {
      'first name': firstName,
      'last name': lastName,
      'username': userName,
      'email': email,
      'role': role,
      'enabled': status,
    };
    await userDetailsRef.set(userDetails);
  }

  bool passwordConfirmed() {
    if(_passwordController.text.trim() == _passwordController.text.trim()){
      return true;
    } else{
      return false;
    }
  }

  Future<void> newSignUp() async {
    try {
      showDialog(
        context: context,
        builder: (context){
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      if (passwordConfirmed()) {
        //create user
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        //add user details
        newAddUserDetails(
          _firstNameController.text.trim(),
          _lastNameController.text.trim(),
          _userNameController.text.trim(),
          _emailController.text.trim(),
          'basic',
          true,
        );
        Navigator.of(context).pop();

        //show dialog to ask user to log in as new user or keep current user profile
        bool loginNewUser = false;
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Log in as new user?"),
              content: const Text("Do you want to log in as the newly created user or keep the current user profile?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Keep current user profile"),
                ),
                TextButton(
                  onPressed: () {
                    loginNewUser = true;
                    Navigator.of(context).pop();
                  },
                  child: const Text("Log in as new user"),
                ),
              ],
            );
          },
        );

        //log in as new user or stay logged in as current user
        if (loginNewUser) {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
        }
        _showMsg('Account created!', true);
      } else {
        _showMsg('The password confirmation does not match.', false);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _showMsg('The account already exists for that email.', false);
      } else if (e.code == 'invalid-email') {
        _showMsg('The email address is not valid.', false);
      } else if (e.code == 'weak-password') {
        _showMsg('The password is too weak.', false);
      } else {
        _showMsg('Error: ${e.message}', false);
      }
    } catch (e) {
      _showMsg('Error: ${e.toString()}', false);
    }
  }
}


