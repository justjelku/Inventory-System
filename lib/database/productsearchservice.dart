import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductSearchService {
  Future<QuerySnapshot<Map<String, dynamic>>> searchById(String userId, String searchId) async {
    return FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(userId)
        .collection('products')
        .where('barcodeId', isEqualTo: searchId)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> searchByBarcodeId(String userId, String barcodeId) async {
    return FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(userId)
        .collection('products')
        .where('barcodeId', isEqualTo: barcodeId)
        .get();
  }
}
