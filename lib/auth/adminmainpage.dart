import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_login_auth/administrator/dashboard.dart';
import 'package:firebase_login_auth/auth/adminlogin.dart';
import 'package:flutter/material.dart';

class AdminMainPage extends StatefulWidget {
  const AdminMainPage({
    Key? key}) : super(key: key);

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {

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
            return const AdminLogin();
          }
          // User is logged in
          isLoading = false; // set isLoading to false
          return const AdminDashboard();
        },
      ),
    );
  }
}