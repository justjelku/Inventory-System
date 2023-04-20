import 'package:firebase_login_auth/database/firebaseservice.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _usernameController;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser!;
    _firstNameController = TextEditingController(text: user.displayName?.split(' ')[0] ?? '');
    _lastNameController = TextEditingController(text: user.displayName?.split(' ')[1] ?? '');
    _usernameController = TextEditingController(text: user.email!.split('@')[0]);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _updateUserProfile() async {
    final user = FirebaseAuth.instance.currentUser!;
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    await userRef.update({
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'username': _usernameController.text,
    });

    await user.updateDisplayName('${_firstNameController.text} ${_lastNameController.text}');
  }

  Future<void> _deleteUser() async {
    final user = FirebaseAuth.instance.currentUser!;
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    await userRef.delete();
    await user.delete();

    // TODO: navigate to login screen
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = true;
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: userRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data!.data()!;
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(user.photoURL ?? ''),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _firstNameController,
                    enabled: _isEditing,
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
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lastNameController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      hintText: 'Enter your last name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
			TextFormField(
                    controller: _usernameController,
                    enabled: _isEditing,
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
                  Row(
  				          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  				          children: [
    					        ElevatedButton(
      					        onPressed: () async {
        						      await DatabaseService(uid: user.uid).updateUser(
          							    _firstNameController.text,
          							    _lastNameController.text,
          							    _usernameController.text,
       						        );
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
        						await FirebaseService(uid: user.uid).deleteUser();
        						ScaffoldMessenger.of(context).showSnackBar(
          							const SnackBar(
            							content: Text('User deleted successfully!'),
          							),
        						);
      					},
      				child: const Text('Delete'),
    					),
  				],
		  ),
    )
	);
}

