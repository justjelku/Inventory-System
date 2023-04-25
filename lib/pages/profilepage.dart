import 'package:firebase_login_auth/database/firebaseservice.dart';
import 'package:firebase_login_auth/model/constant.dart';
import 'package:firebase_login_auth/model/usermodel.dart';
import 'package:firebase_login_auth/model/userprovider.dart';
import 'package:firebase_login_auth/pages/editprofile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

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
  late String _initialRole;
  late String _initialStatus;

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
      _initialRole = data['role'];
      _initialStatus = data['enabled'];
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
      'enabled': true,
      'role':'basic'
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
    Stream<DocumentSnapshot> userDataStream = FirebaseFirestore.instance.collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(FirebaseAuth.instance.currentUser!.uid).snapshots();

    return StreamBuilder<DocumentSnapshot>(
      stream: userDataStream,
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
        return Scaffold(
          // backgroundColor: gradientEndColor,
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
                      CircleAvatar(
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
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ) // Other widgets in your app
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
                  onPressed: () async {
                    final userData = UserModel(
                        uid: FirebaseAuth.instance.currentUser!.uid,
                        firstName: _firstNameController.text,
                        lastName: _lastNameController.text,
                        username: _userNameController.text,
                        email: _emailController.text,
                        role: 'basic',
                        status: true,
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfile(userData: userData),
                      ),
                    );
                  },
                  backgroundColor: gradientEndColor,
                  child: const Icon(Icons.edit),
          ),
        );
      },
    );
  }
}