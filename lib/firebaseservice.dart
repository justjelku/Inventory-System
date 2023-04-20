import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_login_auth/user.dart';

class FirebaseService {
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

  Stream<List<UserModel>> getUsers() {
    return usersCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
    });
  }
}
