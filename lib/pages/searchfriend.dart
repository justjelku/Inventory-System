import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:shoes_inventory_ms/database/peoplesearchservice.dart';
import 'package:shoes_inventory_ms/database/productsearchservice.dart';
import 'package:shoes_inventory_ms/inventory/productdetails.dart';
import 'package:shoes_inventory_ms/inventory/scanproductdetails.dart';
import 'package:shoes_inventory_ms/model/constant.dart';

class SearchFriendPage extends StatefulWidget {
  const SearchFriendPage({super.key});

  @override
  _SearchFriendPageState createState() => _SearchFriendPageState();
}

class _SearchFriendPageState extends State<SearchFriendPage> {
  final TextEditingController _searchController = TextEditingController();
  List<ListTile> _searchResults = [];
  String _scanBarcodes = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
          ),
          style: const TextStyle(
            color: Colors.white,
          ),
          onChanged: (value) {
            setState(() {
              _searchResults.clear();
            });
          },
          onSubmitted: (value) {
            _search();
          },
        ),
      ),
      body: ListView(
        children: _searchResults,
      ),
    );
  }

  void _search() async {
    final user = FirebaseAuth.instance.currentUser;

    Future<void> addNewUser(String currentUserID, String existingUserID, Map<String, dynamic> userData) async {
      // Grant the existing user access to the current user's collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc('qIglLalZbFgIOnO0r3Zu')
          .collection('basic_users')
          .doc(currentUserID)
          .collection('members')
          .doc(existingUserID)
          .set(userData);
    }

    String firstName = _searchController.text.trim();

    var results =
        await PeopleSearchService().searchOtherUsers(user!.uid, firstName);

    setState(() {
      _searchResults = results.docs.map((doc) {
        return ListTile(
          title: Text('${doc['first name']} ${doc['last name']}'),
          subtitle: Text(doc['role']),
          trailing: InkWell(
            onTap: () async {
              // your function here
              await addNewUser(FirebaseAuth.instance.currentUser!.uid, doc.id, doc.data());
            },
            child: const Icon(Icons.add),
          ),
        );
      }).toList();
      if (_searchResults.isEmpty) {
        _searchResults.add(const ListTile(
          title: Text('No user found.'),
        ));
      }
    });
  }
}
