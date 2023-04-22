// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();

  late String _displayName;
  late String _bio;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    final userDoc = await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get();
    setState(() {
      _displayName = userDoc['displayName'];
      _bio = userDoc['bio'];
    });
  }
  Future<void> updateUserProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .update({'displayName': _displayName, 'bio': _bio});
        Navigator.of(context).pop();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update profile.')));
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Form(
        key: _formKey,
        child: StreamBuilder<DocumentSnapshot>(
          stream: _firestore
              .collection('users')
              .doc(_auth.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              var userDocument = snapshot.data;
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(userDocument!['photoUrl']),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _displayName,
                    decoration: const InputDecoration(labelText: 'Display Name'),
                    validator: (value) {
                      if (value!.trim().length < 3) {
                        return 'Display Name must be at least 3 characters long.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _displayName = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _bio,
                    decoration: const InputDecoration(labelText: 'Bio'),
                    maxLength: 200,
                    onSaved: (value) {
                      _bio = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: updateUserProfile,
                    child: const Text('Save Changes'),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}