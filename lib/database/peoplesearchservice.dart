import 'package:cloud_firestore/cloud_firestore.dart';

class PeopleSearchService {
  final CollectionReference _usersCollectionRef =
  FirebaseFirestore.instance.collection('users');

  Future<QuerySnapshot<Map<String, dynamic>>> searchOtherUsers(String userId, String firstName) async {
    return _usersCollectionRef
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .where(FieldPath.documentId, isNotEqualTo: userId)
        .where('first name', isEqualTo: firstName)
        .get();
  }
}
