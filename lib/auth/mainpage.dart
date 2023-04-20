import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_login_auth/auth/login.dart';
import 'package:firebase_login_auth/pages/homepage.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({
    Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 16.0),
                  Text('Loading'),
                ],
              ),
            );
          }
          if (snapshot.data == null) {
            // User is not logged in
            return const LoginPage();
          }
          // User is logged in
          return const HomePage();
        },
      ),
    );
  }
}
