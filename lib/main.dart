import 'package:firebase_login_auth/auth/adminlogin.dart';
import 'package:firebase_login_auth/auth/adminmainpage.dart';
import 'package:firebase_login_auth/auth/userlogin.dart';
import 'package:firebase_login_auth/auth/usermainpage.dart';
import 'package:firebase_login_auth/userroleselection.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'model/constant.dart';


Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        backgroundColor: gradientStartColor,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const UserRoleSelectionPage(),
        '/basicUserLoginPage': (context) => const BasicUserLogin(),
        '/adminLoginPage': (context) => const AdminLogin(),
        '/admin': (context) => const AdminMainPage(),
        '/user': (context) => const UserMainPage(),
      },
    );
  }
}

