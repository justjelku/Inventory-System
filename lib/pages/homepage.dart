import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_login_auth/pages/profilepage.dart';
import 'package:firebase_login_auth/inventory/productdashboard.dart';
import 'package:firebase_login_auth/inventory/productlist.dart';
import 'package:flutter/material.dart';
import 'settings.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    // TodoList(),
    ProductDashboard(),
    ProfilePage(),
    Settings(),
  ];

  static const List<String> _appBarTitles = <String>[
    'HomePage',
    'Profile',
    'Settings',
  ];


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   title: Text(_appBarTitles[_selectedIndex]),
      // ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 30,),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 30,),
            label: '',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.person, size: 35,),
          //   label: '',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined, size: 30,),
            label: '',
          ),
        ],
      ),
    );
  }
}
