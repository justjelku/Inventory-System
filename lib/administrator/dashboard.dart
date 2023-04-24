import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_login_auth/administrator/adminsetting.dart';
import 'package:firebase_login_auth/administrator/manageusers.dart';
import 'package:firebase_login_auth/model/usermodel.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final user = FirebaseAuth.instance.currentUser!;
  int _selectedIndex = 0;

  static Future<List<UserModel>> _fetchUsers(String userId) async {
    try {
      final usersRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('basic_users');
      final snapshot = await usersRef.get();

      if (snapshot.docs.isEmpty) {
        return [];
      }

      final users = snapshot.docs
          .map((doc) => UserModel(
        uid: doc.id,
        firstName: doc.data()['first name'],
        lastName: doc.data()['last name'],
        username: doc.data()['username'],
        email: doc.data()['email'],
        role: doc.data()['role'],
        status: doc.data()['enabled'],
      )).toList();

      return users;
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }


  static final List<Widget> _widgetOptions = <Widget>[
    const Text("This is dashboard"),
    Builder(
      builder: (BuildContext context) {
        final user = FirebaseAuth.instance.currentUser;
        final userId = user!.uid;
        return FutureBuilder<List<UserModel>>(
          future: _fetchUsers(userId),
          builder: (BuildContext context, AsyncSnapshot<List<UserModel>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final usersList = snapshot.data ?? [];
              return ManageUser(usersId: usersList);
            }
          },
        );
      },
    ),
    const AdminSettings(),
  ];

  static const List<String> _appBarTitles = <String>[
    'Dashboard',
    'Manage Users',
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(_appBarTitles[_selectedIndex]),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Manage Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
