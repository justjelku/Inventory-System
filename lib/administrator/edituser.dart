// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditUser extends StatefulWidget {
  final User user;
  const EditUser({Key? key, required this.user}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _EditUserState createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();

  bool _isEditing = false;

  String? _firstName;
  String? _lastName;
  String? _username;
  String? _email;

  @override
  void initState() {
  super.initState();


  // Populate the form fields with the selected user's data
  // _firstName = widget.user.firstName;
  // _lastName = widget.user.lastName;
  // _username = widget.user.username;
  _email = widget.user.email;
  }

  Future<void> updateUser(String userId, String firstName, String lastName, String username) async {
    try {
      await FirebaseFirestore.instance.collection('users')
          .doc('qIglLalZbFgIOnO0r3Zu')
          .collection('admin_users')
          .doc(userId)
          .update({
        'first name': firstName,
        'last name': lastName,
        'username': username,
      });
    } catch (e) {
      // Handle error
    }
  }


  // Future<void> getUserData() async {
  //   final userDoc = await _firestore
  //       .collection('users')
  //       .doc(_auth.currentUser!.uid)
  //       .get();
  //   setState(() {
  //     _displayName = userDoc['displayName'];
  //     _bio = userDoc['bio'];
  //   });
  // }
  // Future<void> updateUserProfile() async {
  //   if (_formKey.currentState!.validate()) {
  //     _formKey.currentState!.save();
  //     try {
  //       await _firestore
  //           .collection('users')
  //           .doc(_auth.currentUser!.uid)
  //           .update({'displayName': _displayName, 'bio': _bio});
  //       Navigator.of(context).pop();
  //     } catch (error) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Failed to update profile.')));
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              // controller: ,
              enabled: _isEditing,
              // initialValue: _initialFirstName,
              decoration: const InputDecoration(
                labelText: 'First Name',
                hintText: 'Enter your first name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your first name';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              // controller: _lastNameController,
              enabled: _isEditing,
              // initialValue: _initialLastName,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                hintText: 'Enter your last name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your last name';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              // controller: _userNameController,
              enabled: _isEditing,
              // initialValue: _initialUserName,
              decoration: const InputDecoration(
                labelText: 'UserName',
                hintText: 'Enter your username',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your username';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              // controller: _emailController,
              enabled: _isEditing,
              // initialValue: _initialEmail,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              // controller: _passwordController,
              enabled: _isEditing,
              // initialValue: _initialPassword,
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    // // Navigator.push(
                    // //   context,
                    // //   MaterialPageRoute(
                    // //     builder: (context) => ManageUserPage(
                    // //       userId: user['uid'],
                    // //       firstName: user['first name'] ?? '',
                    // //       lastName: user['last name'] ?? '',
                    // //       username: user['username'] ?? '',
                    // //       updateUser: updateUser,
                    // //     ),
                    // //   ),
                    // );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('User updated successfully!'),
                      ),
                    );
                  },
                  child: const Text('Update'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // await FirebaseService().deleteUser(FirebaseAuth.instance.currentUser!.uid);
                    // _deleteUser();
                    // // ignore: use_build_context_synchronously
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   const SnackBar(
                    //     content: Text('User deleted successfully!'),
                    //   ),
                    // );
                  },
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: _isEditing
          ? FloatingActionButton(
        onPressed: () {
          // if (_formKey.currentState!.validate()) {
          //   await FirebaseService().updateUser(
          //     FirebaseAuth.instance.currentUser!.uid,
          //     _firstNameController.text,
          //     _lastNameController.text,
          //     _userNameController.text,
          //   );
          //   setState(() {
          //     _isEditing = false;
          //   });
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     const SnackBar(
          //       content: Text('User updated successfully!'),
          //     ),
          //   );
          // }
        },
        child: const Icon(Icons.save),
      )
          : FloatingActionButton(
        onPressed: () {
          setState(() {
            _isEditing = true;
          });
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}