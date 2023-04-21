import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_login_auth/model/constant.dart';
import 'package:firebase_login_auth/model/user.dart';
import 'package:firebase_login_auth/pages/userlist.dart';
import 'package:flutter/material.dart';

class AdminSettings extends StatefulWidget {
  const AdminSettings({Key? key}) : super(key: key);

  @override
  State<AdminSettings> createState() => _AdminSettingsState();
}

class _AdminSettingsState extends State<AdminSettings> {
  final user = FirebaseAuth.instance.currentUser!;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    checkAdminUser();
  }

  Future<void> checkAdminUser() async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('admin_users')
        .where('email', isEqualTo: user.email)
        .get();
    final List<DocumentSnapshot> documents = result.docs;
    if (documents.isNotEmpty) {
      setState(() {
        _isAdmin = true;
      });
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
            if (_isAdmin)
              MaterialButton(
                onPressed: () {
                },
                color: primaryBtnColor,
                child: const Text('View all users'),
              ),
          ],
        ),
      ),
    );
  }
}
