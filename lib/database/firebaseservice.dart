import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_login_auth/model/user.dart';

class FirebaseService {
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

  Stream<List<UserModel>> getUsers() {
    return usersCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
    });
  }

  Future<void> updateUser(String uid, String firstName, String lastName, String username) async {
    final docRef = usersCollection.doc(uid);
    await docRef.update({
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
    });
  }

  Future<void> deleteUser(String uid) async {
    final docRef = usersCollection.doc(uid);
    await docRef.delete();
  }
}
