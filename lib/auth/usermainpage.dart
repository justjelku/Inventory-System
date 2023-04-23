import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_login_auth/auth/userlogin.dart';
import 'package:firebase_login_auth/pages/homepage.dart';
import 'package:firebase_login_auth/userroleselection.dart';
import 'package:flutter/material.dart';

class UserMainPage extends StatefulWidget {
  const UserMainPage({
    Key? key}) : super(key: key);

  @override
  State<UserMainPage> createState() => _UserMainPageState();
}

class _UserMainPageState extends State<UserMainPage> {
  // bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    // _checkAdmin();
  }

  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.hasError) {
            isLoading = false; // set isLoading to false
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLoading) // show CircularProgressIndicator conditionally
                    const CircularProgressIndicator(),
                  const SizedBox(height: 16.0),
                  const Text('Loading'),
                ],
              ),
            );
          }
          if (snapshot.data == null) {
            // User is not logged in
            isLoading = false; // set isLoading to false
            return const BasicUserLogin();
          }
          // User is logged in
          isLoading = false; // set isLoading to false
          return const HomePage();
        },
      ),
    );
  }
}

