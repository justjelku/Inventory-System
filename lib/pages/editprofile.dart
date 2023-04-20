import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();

  String _displayName;
  String _bio;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text('Edit Profile'),
    ),
    body: Form(
    key: _formKey,
    child: StreamBuilder<DocumentSnapshot>(
    stream: _firestore
        .collection('users')
        .doc(_auth.currentUser.uid)
        .snapshots(),
    builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
        var userDocument = snapshot.data;
        return ListView(
          padding: EdgeInsets.all(16),
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(userDocument!['photoUrl']),
            ),
            Column(

    )
    }



