import 'package:firebase_login_auth/database/firebaseservice.dart';
import 'package:firebase_login_auth/model/constant.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late String _initialUserName = "";
  late String _initialFirstName = "";
  late String _initialLastName = "";
  late String _initialPassword = "";
  late String _initialEmail = "";

  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isEditing = false;

  @override
  initState() {
    super.initState();
    _getUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _getUserData() async {
    // final user = FirebaseAuth.instance.currentUser!;
    final userRef = FirebaseFirestore.instance.collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    final userData = await userRef.get();

    final data = userData.data() as Map<String, dynamic>;
    setState(() {
      _initialUserName = data['username'];
      _initialFirstName = data['first name'];
      _initialLastName = data['last name'];
      _initialEmail = data['email'];
      _initialPassword = data['password'];
    });
  }

  Future _updateUserProfile(String firstName, String lastName, String userName,
      String email) async {
    final user = FirebaseAuth.instance.currentUser;

    // Update the user's display name
    await user?.updateDisplayName('$firstName $lastName');

    // Add the user details to the Firestore collection
    await FirebaseFirestore.instance.collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      'first name': firstName,
      'last name': lastName,
      'username': userName,
      'email': email,
    });
  }

  Future<void> _deleteUser() async {
    final user = FirebaseAuth.instance.currentUser!;
    final userRef = FirebaseFirestore.instance.collection('users').doc('qIglLalZbFgIOnO0r3Zu').collection('basic_users').doc(
        user.uid);

    await userRef.delete();
    await user.delete();

    // Navigate to login screen
    // ignore: use_build_context_synchronously
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/basicUserLoginPage',
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    _userNameController.text = _initialUserName;
    _firstNameController.text = _initialFirstName;
    _lastNameController.text = _initialLastName;
    _emailController.text = _initialEmail;
    _passwordController.text = _initialPassword;

    // final user = FirebaseAuth.instance.currentUser!;
    final userRef = FirebaseFirestore.instance.collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    return FutureBuilder<DocumentSnapshot>(
      future: userRef.get(),
      builder: (BuildContext context,
          AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Error retrieving user data.');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Retrieving user data...');
        }
        final data = snapshot.data?.data() as Map<String, dynamic>;
        _firstNameController.text = data['first name'] as String? ?? '';
        _lastNameController.text = data['last name'] as String? ?? '';
        _userNameController.text = data['username'] as String? ?? '';
        _emailController.text = data['email'] as String? ?? '';
        _passwordController.text = data['password'] as String? ?? '';
        return Scaffold(
          backgroundColor: gradientEndColor,
          appBar: AppBar(
            title: const Text('Profile Page'),
            automaticallyImplyLeading: false,
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundImage: const AssetImage('assets/logo.png'),
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${data['first name'] ?? 'Error:'} ${data['last name'] ?? 'Null'}',
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Status: ${data['enabled'] ? 'Enabled' : 'Disabled'}',
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _firstNameController,
                          enabled: _isEditing,
                          // initialValue: _initialFirstName,
                          decoration: const InputDecoration(
                            labelText: 'First Name',
                            hintText: 'Enter your first name',
                          ),
                          // validator: (value) {
                          //   if (value == null || value.isEmpty) {
                          //     return 'Please enter your first name';
                          //   }
                          //   return null;
                          // },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _lastNameController,
                          enabled: _isEditing,
                          // initialValue: _initialLastName,
                          decoration: const InputDecoration(
                            labelText: 'Last Name',
                            hintText: 'Enter your last name',
                          ),
                          // validator: (value) {
                          //   if (value == null || value.isEmpty) {
                          //     return 'Please enter your last name';
                          //   }
                          //   return null;
                          // },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _userNameController,
                          enabled: _isEditing,
                          // initialValue: _initialUserName,
                          decoration: const InputDecoration(
                            labelText: 'UserName',
                            hintText: 'Enter your username',
                          ),
                          // validator: (value) {
                          //   if (value == null || value.isEmpty) {
                          //     return 'Please enter your username';
                          //   }
                          //   return null;
                          // },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _emailController,
                          enabled: _isEditing,
                          // initialValue: _initialEmail,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter your email',
                          ),
                          // validator: (value) {
                          //   if (value == null || value.isEmpty) {
                          //     return 'Please enter your email';
                          //   }
                          //   return null;
                          // },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _passwordController,
                          enabled: _isEditing,
                          // initialValue: _initialPassword,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter your password',
                          ),
                          // validator: (value) {
                          //   if (value == null || value.isEmpty) {
                          //     return 'Please enter your password';
                          //   }
                          //   return null;
                          // },
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: () {
                                _updateUserProfile(
                                  _firstNameController.text,
                                  _lastNameController.text,
                                  _userNameController.text,
                                  _emailController.text,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('User updated successfully!'),
                                    ),
                                );
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
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: primaryBtnColor,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Text('Update',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17
                                    )
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                await FirebaseService().deleteUser(FirebaseAuth.instance.currentUser!.uid);
                                _deleteUser();
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('User deleted successfully!'),
                                  ),
                                );
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
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: secondaryBtnColor,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Text('Delete',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17
                                    )
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
                // Other widgets in your app
              ],
            ),
          ),
          floatingActionButton: _isEditing
              ? FloatingActionButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await FirebaseService().updateUser(
                        FirebaseAuth.instance.currentUser!.uid,
                        _firstNameController.text,
                        _lastNameController.text,
                        _userNameController.text,
                      );
                      setState(() {
                      _isEditing = false;
                      });
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('User updated successfully!'),
                      ));
                    }else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please make changes before saving.'),
                        ),
                      );
                    }
                  },
                  backgroundColor: gradientEndColor,
                  child: const Icon(Icons.save),
              )
              : FloatingActionButton(
                  onPressed: () {
                      setState(() {
                        _isEditing = true;
                      });
                  },
                  backgroundColor: gradientEndColor,
                  child: Icon(
                    _firstNameController.text != '' ||
                    _lastNameController.text != '' ||
                    _userNameController.text != ''
                    ? Icons.edit
                    : Icons.save,
                    color: mainTextColor,
                  ),
              ),
        );
      },
    );
  }
}