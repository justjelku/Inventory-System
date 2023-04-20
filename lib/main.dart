import 'package:firebase_login_auth/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'model/constant.dart';


Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp( MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Login',
    theme: ThemeData(
      backgroundColor: gradientStartColor,
    ),
    home: LoginPage(),
  )
  );
}

