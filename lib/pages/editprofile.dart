import 'dart:io';
import 'package:firebase_login_auth/database/firebaseservice.dart';
import 'package:firebase_login_auth/model/constant.dart';
import 'package:firebase_login_auth/model/usermodel.dart';
import 'package:firebase_login_auth/model/userprovider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class EditProfile extends StatefulWidget {
  final UserModel userData;
  const EditProfile({Key? key, required this.userData}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isEditing = true;
  late ImageProvider<Object> defaultImage;

  @override
  initState() {
    super.initState();
    defaultImage = const AssetImage('assets/logo.png');
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

  Future<void> _deleteUser(BuildContext context) async {
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

  late File userProfileImage;
  File? _image;

  Future<void> _openImagePicker(BuildContext context) async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });

      // Upload the image to Firebase Storage and Firestore
      // ignore: use_build_context_synchronously
      await Provider.of<UserProvider>(context, listen: false).uploadProfilePicture(widget.userData.uid, _image!);
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {

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
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final data = snapshot.data?.data() as Map<String, dynamic>;
        _firstNameController.text = data['first name'] as String? ?? '';
        _lastNameController.text = data['last name'] as String? ?? '';
        _userNameController.text = data['username'] as String? ?? '';
        _emailController.text = data['email'] as String? ?? '';
        _passwordController.text = data['password'] as String? ?? '';
        final userdata = widget.userData;

        return Scaffold(
          // backgroundColor: gradientEndColor,
          appBar: AppBar(
            title: const Text('Edit Page'),
            automaticallyImplyLeading: true,
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
                      Stack(
                        children: <Widget> [
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: CircleAvatar(
                              radius: 43,
                              backgroundImage: const AssetImage('assets/logo.png'),
                              backgroundColor: Colors.grey,
                              child: ClipOval(
                                child: FutureBuilder<String?>(
                                  future: Provider.of<UserProvider>(context).getProfilePicture(FirebaseAuth.instance.currentUser!.uid),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const Center(child: CircularProgressIndicator());
                                    }
                                    if (snapshot.hasError) {
                                      return const Center(child: Text('Error retrieving profile picture'));
                                    }
                                    if (snapshot.data == null) {
                                      return const Center(child: Text(''));
                                    }
                                    return Center(
                                      child: CircleAvatar(
                                        radius: 60,
                                        backgroundImage: NetworkImage(snapshot.data!),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 1,
                            right: 1,
                            child: Container(
                              height: 35,
                              width: 35,
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              ),
                              child: InkWell(
                                onTap: () {
                                  _openImagePicker(context);
                                },
                                child: const Icon(
                                  Icons.add_a_photo,
                                  size: 15.0,
                                  color: Color(0xFF404040),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${userdata.firstName} ${userdata.lastName}',
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Status: ${userdata.status ? 'Enabled' : 'Disabled'}',
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
                                // final userProvider = Provider.of<UserProvider>(context, listen: false);
                                // final user = userProvider.user;
                                if (_formKey.currentState!.validate()) {
                                  final updatedUsers = widget.userData.copyWith(
                                    firstName: _firstNameController.text,
                                    lastName: _lastNameController.text,
                                    username: _userNameController.text,
                                    email: _emailController.text,
                                    role: 'basic',
                                    status: true,
                                    profilePictureUrl: '',
                                  );
                                  UserProvider().updateUser(updatedUsers);
                                  setState(() {
                                    _isEditing = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('User updated successfully!'),
                                    ),
                                  );
                                  Navigator.pop(context);
                                }else{
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('You dont have permission, please contact your admin!'),
                                    ),
                                  );
                                }
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
                                // ignore: use_build_context_synchronously
                                _deleteUser(context);
                                // ignore: use_build_context_synchronously
                                Provider.of<UserProvider>(context, listen: false).deleteUser(FirebaseAuth.instance.currentUser!.uid);
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
          // floatingActionButton: _isEditing
          //     ? FloatingActionButton(
          //   onPressed: () async {
          //     final userProvider = Provider.of<UserProvider>(context, listen: false);
          //     final user = userProvider.user;
          //     if (_formKey.currentState!.validate()) {
          //       final updatedUsers = user.copyWith(
          //         firstName: _firstNameController.text,
          //         lastName: _lastNameController.text,
          //         username: _userNameController.text,
          //         email: _emailController.text,
          //         role: 'basic',
          //         status: true,
          //       );
          //       UserProvider().updateUser(updatedUsers);
          //       setState(() {
          //         _isEditing = false;
          //       });
          //       ScaffoldMessenger.of(context).showSnackBar(
          //         const SnackBar(
          //           content: Text('User updated successfully!'),
          //         ),
          //       );
          //     }else{
          //       ScaffoldMessenger.of(context).showSnackBar(
          //         const SnackBar(
          //           content: Text('You dont have permission, please contact your admin!'),
          //         ),
          //       );
          //     }
          //   },
          //   backgroundColor: gradientEndColor,
          //   child: const Icon(Icons.save),
          // )
          //     : FloatingActionButton(
          //   onPressed: () {
          //     setState(() {
          //       _isEditing = true;
          //     });
          //   },
          //   backgroundColor: gradientEndColor,
          //   child: Icon(
          //     _firstNameController.text != '' ||
          //         _lastNameController.text != '' ||
          //         _userNameController.text != ''
          //         ? Icons.edit
          //         : Icons.save,
          //     color: mainTextColor,
          //   ),
          // ),
        );
      },
    );
  }
}