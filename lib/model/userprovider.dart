import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_login_auth/model/usermodel.dart';

class UserProvider {
  final CollectionReference _usersCollection =
  FirebaseFirestore.instance.collection('users');
  late BasicUserModel _basicCurrentUser;
  late AdminUserModel _adminCurrentUser;

  BasicUserModel get basicCurrentUser => _basicCurrentUser;
  AdminUserModel get adminCurrentUser => _adminCurrentUser;

  Stream<BasicUserModel> get basicUserStream {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;
    final userRef = _usersCollection.doc(userId).collection('basic_users').doc(userId);
    return userRef.snapshots().map((doc) {
      final data = doc.data();
      return BasicUserModel(
        uid: doc.id,
        firstName: data!['first_name'],
        lastName: data['last_name'],
        email: data['email'],
        username: data['username'],
      );
    });
  }

  Stream<AdminUserModel> get adminUserStream {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;
    final userRef = _usersCollection.doc(userId).collection('admin_users').doc(userId);
    return userRef.snapshots().map((doc) {
      final data = doc.data();
      return AdminUserModel(
        uid: doc.id,
        firstName: data!['first_name'],
        lastName: data['last_name'],
        email: data['email'],
        username: data['username'],
        isAdmin: data['is_admin'],
      );
    });
  }

  Future<void> addBasicUser(BasicUserModel user) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userRef = _usersCollection.doc(currentUser!.uid).collection('basic_users').doc(user.uid);
    await userRef.set(user.toMap());
  }

  Future<void> addAdminUser(AdminUserModel user) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userRef = _usersCollection.doc(currentUser!.uid).collection('admin_users').doc(user.uid);
    await userRef.set(user.toMap());
  }

  Future<void> updateBasicUser(BasicUserModel user) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userRef = _usersCollection.doc(currentUser!.uid).collection('basic_users').doc(user.uid);
    await userRef.update(user.toMap());
  }

  Future<void> updateAdminUser(AdminUserModel user) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userRef = _usersCollection.doc(currentUser!.uid).collection('admin_users').doc(user.uid);
    await userRef.update(user.toMap());
  }

  Future<void> deleteBasicUser(String uid) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userRef = _usersCollection.doc(currentUser!.uid).collection('basic_users').doc(uid);
    await userRef.delete();
  }

  Future<void> deleteAdminUser(String uid) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userRef = _usersCollection.doc(currentUser!.uid).collection('admin_users').doc(uid);
    await userRef.delete();
  }
}
