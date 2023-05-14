import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shoes_inventory_ms/model/productmodel.dart';

class ProductUpdateService {
  late final User _user;
  late final CollectionReference _productCollection;

  ProductUpdateService() : _user = FirebaseAuth.instance.currentUser! {
    _productCollection = FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(_user.uid)
        .collection('products');
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _productCollection.doc(product.productId).update(product.toMap());
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  Future<void> updateProductQuantity(String productId, int newQuantity) async {
    await _productCollection.doc(productId).update({'productQuantity': newQuantity});
  }

  Future<void> updateProductDetails(String productId, Map<String, dynamic> newDetails) async {
    await _productCollection.doc(productId).update(newDetails);
  }
}
