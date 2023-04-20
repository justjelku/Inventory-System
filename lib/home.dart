import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_login_auth/user.dart';
import 'package:firebase_login_auth/userlist.dart';
import 'package:flutter/material.dart';

import 'constant.dart';

List<UserModel> userList = [];

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    getUsers();
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

  Future<void> getUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    setState(() {
      userList = snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Sign in as: ${user.email!}"),
            MaterialButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                _showMsg('Signed out successfully.', true);
              },
              color: secondaryBtnColor,
              child: const Text('Sign Out'),
            ),
            MaterialButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserListPage(users: userList),
                  ),
                );
              },
              color: primaryBtnColor,
              child: const Text('View all users'),
            )
          ],
        ),
      ),
    );
  }
}
