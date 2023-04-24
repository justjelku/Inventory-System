import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_login_auth/model/usermodel.dart';

class FirebaseService {
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

  Stream<List<UserModel>> getUsers() {
    return usersCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final userData = doc.data() as Map<String, dynamic>;
        final userModel = UserModel(
          uid: doc.id,
          firstName: userData['firstName'] as String,
          lastName: userData['lastName'] as String,
          username: userData['username'] as String,
          email: userData['email'] as String,
          role: userData['role'] as String,
          status: userData['enabled'] as bool,
        );
        return userModel.copyWith(role: 'new role'); // Example usage of copyWith
      }).toList();
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
