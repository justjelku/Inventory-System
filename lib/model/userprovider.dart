import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_login_auth/model/usermodel.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

  factory UserProvider() {
    return UserProvider._();
  }

  UserProvider._() {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;
    fetchUserFromFirestore(userId).then((fetchedUser) {
      _user = fetchedUser!;
      notifyListeners();
    });
  }

  late UserModel _user;

  UserModel get user => _user;

  @override
  void dispose() {
    _userSubscription?.cancel();
    _user = UserProvider() as UserModel;
    super.dispose();
  }

  Future<void> updateUser(UserModel todo) async {
    try {
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc('qIglLalZbFgIOnO0r3Zu')
          .collection('basic_users')
          .doc(FirebaseAuth.instance.currentUser?.uid);

      final userData = {
        'first name': todo.firstName,
        'last name': todo.lastName,
        'username': todo.username,
        'email': todo.email,
        'role': todo.role,
        'enabled': todo.status,
      };

      await userRef.update(userData);

      // _user = user;
      notifyListeners();
    } catch (e) {
      print('Error updating user: $e');
      throw Exception('Failed to update user. Please contact the admin.');
    }
  }

  Future<UserModel?> fetchUserFromFirestore(String userId) async {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(userId);

    final snapshot = await userRef.get();
    if (snapshot.exists) {
      return UserModel(
        uid: snapshot.id,
        firstName: snapshot.data()!['first name'],
        lastName: snapshot.data()!['last name'],
        username: snapshot.data()!['username'],
        email: snapshot.data()!['email'],
        role: snapshot.data()!['role'],
        status: snapshot.data()!['enabled'],
      );
    } else {
      return null;
    }
  }


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


  Stream<List<UserModel>> getAllBasicUsers(String userId) {
    // final user = FirebaseAuth.instance.currentUser;
    // // final userId = user!.uid;

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
      'profileUrl':'',
    };

    await userCollection.add(userData);
    notifyListeners();
  }

  Future<void> deleteUser(String userId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(userId)
        .delete();

    await FirebaseAuth.instance.currentUser?.delete();
    notifyListeners();
  }

  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> uploadProfilePicture(String userId, File file) async {
    final fileName = basename(file.path);
    final ref = FirebaseStorage.instance.ref().child('profilePictures/$fileName');
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();

    // Update the profile picture URL of the current user in Firestore database
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(_user.uid);
    final todoCollection = userRef.collection('profilePhoto');
    final newDocRef = await todoCollection.add({'profileUrl': downloadUrl});

    // Update the profile picture URL of the current user in the app state
    final updatedUser = user.copyWith(profilePictureUrl: downloadUrl);
    _user = updatedUser;
    notifyListeners();
  }

  // Future<void> uploadBarcodes(String userId, File file) async {
  //   final fileName = basename(file.path);
  //   final ref = FirebaseStorage.instance.ref().child('barcodeImages/$fileName');
  //   final uploadTask = ref.putFile(file);
  //   final snapshot = await uploadTask.whenComplete(() {});
  //   final downloadUrl = await snapshot.ref.getDownloadURL();
  //
  //   // Update the profile picture URL of the current user in Firestore database
  //   final userRef = FirebaseFirestore.instance
  //       .collection('users')
  //       .doc('qIglLalZbFgIOnO0r3Zu')
  //       .collection('basic_users')
  //       .doc(_user.uid);
  //   final todoCollection = userRef.collection('barcodeImages');
  //   final newDocRef = await todoCollection.add({'barcodeUrl': downloadUrl});
  //
  //   // Update the barcode URL of the current user in the app state
  //   final updatedUser = user.copyWith(barcodeUrl: downloadUrl);
  //   _user = updatedUser;
  //   notifyListeners();
  // }

  Future<String?> getProfilePicture(String userId) async {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(userId);
    final profilePhoto = await userRef.collection('barcodeImages').get();
    if (profilePhoto.docs.isNotEmpty) {
      return profilePhoto.docs.first.get('barcodeUrl');
    }
    return null;
  }
}
