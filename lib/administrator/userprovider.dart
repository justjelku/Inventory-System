import 'package:firebase_login_auth/model/user.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _usersCollection =
  FirebaseFirestore.instance.collection('users');
  late UserModel _currentUser;

  UserModel get currentUser => _currentUser;

  Future<void> updateUser(UserModel user) async {
    await _usersCollection.doc(user.uid).set(user.toMap());
    _currentUser = user;
    notifyListeners();
  }

  Future<void> deleteUser(String uid) async {
    await _usersCollection.doc(uid).delete();
    _currentUser = UserModel(
      uid: '',
      email: '',
      firstName: '',
      lastName: '',
      username: '',
    );
    notifyListeners();
  }

  Future<void> addUser(UserModel user) async {
    final DocumentReference userDoc = _usersCollection.doc(user.uid);
    final DocumentSnapshot userSnap = await userDoc.get();
    if (!userSnap.exists) {
      await userDoc.set(user.toMap());
      _currentUser = user;
      notifyListeners();
    } else {
      throw Exception('User with this UID already exists');
    }
  }
}
