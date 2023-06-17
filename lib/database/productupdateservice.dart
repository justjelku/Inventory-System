import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
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

  // Future<void> updateProductDetails(String productId, Map<String, dynamic> newDetails) async {
  //   await _productCollection.doc(productId).update(newDetails);
  // }

  Future<void> updateProductDetails(
      String productId,
      String title,
      String brand,
      int price,
      String description,
      int quantity,
      String branch,
      int productSize,
      File imgFile,
      File barcodeQrFile,
      File qrFile,
      ) async {
    final fileName2 = basename(qrFile.path);
    final ref2 = FirebaseStorage.instance.ref().child('products/qrcodeImages/$fileName2');
    final uploadTask2 = ref2.putFile(qrFile);
    final snapshot2 = await uploadTask2.whenComplete(() {});
    String downloadQrUrl;

    if (snapshot2 != null) {
      downloadQrUrl = await snapshot2.ref.getDownloadURL();
    } else {
      throw Exception('Failed to upload QR code image');
    }

    final fileName1 = basename(barcodeQrFile.path);
    final ref1 = FirebaseStorage.instance.ref().child('products/barcodesImages/$fileName1');
    final uploadTask1 = ref1.putFile(barcodeQrFile);
    final snapshot1 = await uploadTask1.whenComplete(() {});
    String downloadBarcodeUrl;

    if (snapshot1 != null) {
      downloadBarcodeUrl = await snapshot1.ref.getDownloadURL();
    } else {
      throw Exception('Failed to upload barcode image');
    }

    final fileName = basename(imgFile.path);
    final ref = FirebaseStorage.instance.ref().child('products/productImage/$fileName');
    final uploadTask = ref.putFile(imgFile);
    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();

    final user = FirebaseAuth.instance.currentUser;
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(user!.uid);

    final todoCollection = userRef.collection('products').doc(productId);

    final todoData = {
      'productQuantity':quantity,
      'updatedTime': FieldValue.serverTimestamp(),
    };

    await todoCollection.update(todoData);
  }

}
