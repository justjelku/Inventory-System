import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class ManageUsers extends StatefulWidget {
  const ManageUsers({Key? key}) : super(key: key);

  @override
  State<ManageUsers> createState() => _ManageUsersState();
}

class _ManageUsersState extends State<ManageUsers> {
  List<dynamic> _users = [];

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> getUserByUID(String uid) async {
    User? user;
    try {
      user = FirebaseAuth.instance.currentUser;
      print('User details:');
      print('UID: ${user?.uid}');
      print('Email: ${user?.email}');
      print('Display Name: ${user?.displayName}');
      // you can access other details of the user as well, like the photo URL, etc.
    } catch (e) {
      print('Error getting user details by UID: $e');
    }
    return user;
  }


  Future<void> listAllUsers() async {
    try {
      final String token = await FirebaseAuth.instance.currentUser!.getIdToken();
      const String uri = 'https://identitytoolkit.googleapis.com/v1/accounts:batchGet?key=AIzaSyD4mkkFbQE79wPgO4Xd-UIfpcOI72rLs_E';
      final http.Response response = await http.post(
        Uri.parse(uri),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          <String, dynamic>{
            'maxResults': 1000,
            'returnSecureToken': true,
          },
        ),
      );
      print(response.body);
      final List<dynamic> users = jsonDecode(response.body)['users'];
      setState(() {
        _users = users;
      });
      print('Users fetched successfully: $_users');

    } catch (e) {
      // Handle error here
      print('Error fetching auth token: $e');
    }
  }


  @override
  void initState() {
    super.initState();
    listAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return ListTile(
            title: Text(user['email']),
            subtitle: Text(user['localId']),
          );
        },
      ),
    );
  }
}
