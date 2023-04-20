import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_login_auth/model/user.dart';
import 'package:flutter/material.dart';

class UserListPage extends StatelessWidget {
  final List<UserModel> users;
  const UserListPage({Key? key, required this.users}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }

          final users = snapshot.data!.docs.map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>)).toList();

          return DataTable(
            columns: const [
              DataColumn(label: Text('UID')),
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('First Name')),
              DataColumn(label: Text('Last Name')),
              DataColumn(label: Text('Username')),
            ],
            rows: users.map((user) => DataRow(
              cells: [
                DataCell(Text(user.uid)),
                DataCell(Text(user.email)),
                DataCell(Text(user.firstName)),
                DataCell(Text(user.lastName)),
                DataCell(Text(user.username)),
              ],
            )).toList(),
          );
        },
      ),
    );
  }
}
