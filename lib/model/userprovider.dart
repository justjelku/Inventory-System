import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_login_auth/model/usermodel.dart';
import 'package:flutter/foundation.dart';

class UserProvider with ChangeNotifier {
  // late UserModel _user;
  //
  // UserModel get user => _user;

  final CollectionReference usersCollection = FirebaseFirestore.instance
      .collection('users')
      .doc('qIglLalZbFgIOnO0r3Zu')
      .collection('basic_users');

  Stream<List<UserModel>> get basicUserStream {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;
    return getAllBasicUsers(userId);
  }

  StreamSubscription<List<UserModel>>? _userSubscription;

  void listenToUsers() {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;
    _userSubscription?.cancel();
    _userSubscription = getAllBasicUsers(userId).listen((users) {
      if (users.isNotEmpty) {
        // data is available
        print('Found ${users.length} users in the basic_users subcollection:');
        for (var user in users) {
          print('${user.firstName} ${user.lastName}');
        }
      } else {
        // no data available
        print('No users found in the basic_users subcollection');
      }
    });
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  Stream<List<UserModel>> getAllBasicUsers(String userId) {
    final user = FirebaseAuth.instance.currentUser;
    // final userId = user!.uid;

    return FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
        .map((doc) => UserModel(
      uid: doc.id,
      firstName: doc.data()['first name'],
      lastName: doc.data()['last name'],
      username: doc.data()['username'],
      email: doc.data()['email'],
      role: doc.data()['role'],
      status: doc.data()['enabled'],
    )).toList(growable: true)
    );
  }



  Stream<List<UserModel>> get userStream {
    final user = FirebaseAuth.instance.currentUser;
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(user!.uid);

    return userRef.snapshots().map((snapshot) {
      final userModel = UserModel(
        uid: snapshot.id,
        firstName: snapshot.data()!['first name'],
        lastName: snapshot.data()!['last name'],
        username: snapshot.data()!['username'],
        email: snapshot.data()!['email'],
        role: snapshot.data()!['role'],
        status: snapshot.data()!['enabled'],
      );
      print('Successful ${userModel.toMap()}');
      return [userModel];
    });
  }


  Future<void> updateUser(UserModel user) async {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(user.uid);

    final userData = {
      'first name': user.firstName,
      'last name': user.lastName,
      'username': user.username,
      'email': user.email,
      'role': user.role,
      'enabled':user.status,
    };

    await userRef.update(userData);

    // _user = user;
    notifyListeners();
  }

  Future<void> addBasicUser(UserModel user) async {
    final userCollection = FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users');

    final userData = {
      'first name': user.firstName,
      'last name': user.lastName,
      'username': user.username,
      'email': user.email,
      'role': user.role,
      'enabled': true,
    };

    await userCollection.add(userData);
    notifyListeners();
  }

  // Future<void> deleteUser(String userId) async {
  //   await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc('qIglLalZbFgIOnO0r3Zu')
  //       .collection('basic_users')
  //       .doc(userId)
  //       .delete();
  //
  //   await FirebaseAuth.instance.currentUser?.delete();
  //   notifyListeners();
  // }


}
