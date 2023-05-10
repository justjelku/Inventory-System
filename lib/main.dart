import 'package:shoes_inventory_ms/auth/adminlogin.dart';
import 'package:shoes_inventory_ms/auth/adminmainpage.dart';
import 'package:shoes_inventory_ms/auth/userlogin.dart';
import 'package:shoes_inventory_ms/auth/usermainpage.dart';
import 'package:shoes_inventory_ms/model/productprovider.dart';
import 'package:shoes_inventory_ms/model/userprovider.dart';
import 'package:shoes_inventory_ms/screens/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        // add more providers here if needed
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          backgroundColor: gradientStartColor,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/basicUserLoginPage': (context) => const BasicUserLogin(),
          '/adminLoginPage': (context) => const AdminLogin(),
          '/admin': (context) => const AdminMainPage(),
          '/user': (context) => const UserMainPage(),
        },
      ),
    );
  }
}
