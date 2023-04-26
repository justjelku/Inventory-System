import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_login_auth/model/productmodel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class ProductProvider with ChangeNotifier {
  final CollectionReference todos =
  FirebaseFirestore.instance.collection('todos');

  Stream<List<Product>> get productStream {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;
    return getProduct(userId);
  }

  late Product _user;

  Product get user => _user;

  ProductProvider._() {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;
    fetchProductFromFirestore(userId).then((fetchedUser) {
      _user = fetchedUser!;
      notifyListeners();
    });
  }

  factory ProductProvider() {
    return ProductProvider._();
  }

  @override
  void dispose() {
    _user = ProductProvider() as Product;
    super.dispose();
  }

  Future<Product?> fetchProductFromFirestore(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    final userRef = FirebaseFirestore.instance.collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(user!.uid)
        .collection('todos')
        .doc(productId);

    final snapshot = await userRef.get();
    if (snapshot.exists) {
      return Product(
        productId: snapshot.data()!['productId'],
        productTitle: snapshot.data()!['productTitle'],
        productPrice: snapshot.data()!['productPrice'],
        completed: snapshot.data()!['completed'],
        userId: snapshot.data()!['userId'],
        barcodeId: snapshot.data()!['barcodeId'],
        barcodeUrl: '',
        qrcodeUrl: '',
      );
    } else {
      return null;
    }
  }

  Future<void> addProduct(Product todo) async {
    final user = FirebaseAuth.instance.currentUser;
    final userRef = FirebaseFirestore.instance.collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users').doc(user!.uid);

    final todoCollection = userRef.collection('todos');

    final todoData = {
      'productId': todo.productId,
      'productTitle': todo.productTitle,
      'productPrice': todo.productPrice,
      'completed': todo.completed,
      'userId': todo.userId,
      'barcodeId': todo.barcodeId,
      'barcodeUrl': todo.barcodeUrl,
      'qrcodeUrl': todo.qrcodeUrl,
    };

    await todoCollection.add(todoData);
  }

  Future<void> updateProduct(Product todo) async {
    final user = FirebaseAuth.instance.currentUser;
    final userRef = FirebaseFirestore.instance.collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users').doc(user!.uid);

    final todoCollection = userRef.collection('todos');

    final todoData = {
      'productId': todo.productId,
      'productTitle': todo.productTitle,
      'productPrice': todo.productPrice,
      'completed': todo.completed,
      'userId': todo.userId,
      'barcodeId': todo.barcodeId,
      'barcodeUrl': todo.barcodeUrl,
      'qrcodeUrl': todo.qrcodeUrl,
    };

    await todoCollection.doc(todo.productId).update(todoData);
  }

  Stream<List<Product>> getProduct(String userId) {
    final userRef = FirebaseFirestore.instance.collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users').doc(userId);

    final todoCollection = userRef.collection('todos');

    return todoCollection.snapshots().map((querySnapshot) =>
        querySnapshot.docs.map((doc) {
          final data = doc.data();
          return Product(
            productId: doc.id,
            productTitle: data['productTitle'],
            productPrice: data['productPrice'],
            completed: data['completed'],
            userId: data['userId'],
            barcodeId: data['barcodeId'],
            barcodeUrl: '',
            qrcodeUrl: '',
          );
        }).toList());
  }

  Future<void> deleteProduct(String todoId) async {
    final user = FirebaseAuth.instance.currentUser;
    final userRef = FirebaseFirestore.instance.collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users').doc(user!.uid);

    final todoRef = userRef.collection('todos').doc(todoId);
    await todoRef.delete();
  }

  Future<void> uploadBarcodes(String userId, File file, Product todo) async {
    final fileName = basename(file.path);
    final ref = FirebaseStorage.instance.ref().child(
        'products/barcodesImages/$fileName');
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask.whenComplete(() {});
    String downloadUrl;

    // ignore: unnecessary_null_comparison
    if (snapshot != null) {
      downloadUrl = await snapshot.ref.getDownloadURL();
    } else {
      // Handle the case where the snapshot is null, perhaps by throwing an exception or displaying an error message
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(user!.uid);

    final todoCollection = userRef
        .collection('todos')
        .doc() // creates a new document with a unique ID
        .collection('barcodes'); // creates a new subcollection with name 'qrcodes'
    // Update the barcode URL of the current user in the app state
    final newDocRef = await todoCollection.add({'barcodeUrl': downloadUrl});
    notifyListeners();
  }

  Future<void> uploadQrcodes(String userId, File file, Product todo) async {
    final fileName = basename(file.path);
    final ref = FirebaseStorage.instance.ref().child('products/qrcodeImages/$fileName');
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask.whenComplete(() {});
    String downloadUrl;

    // ignore: unnecessary_null_comparison
    if (snapshot != null) {
      downloadUrl = await snapshot.ref.getDownloadURL();
    } else {
      // Handle the case where the snapshot is null, perhaps by throwing an exception or displaying an error message
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(user!.uid);

    final todoCollection = userRef
        .collection('todos')
        .doc() // creates a new document with a unique ID
        .collection('qrcodes'); // creates a new subcollection with name 'qrcodes'
    // Update the barcode URL of the current user in the app state
    final newDocRef = await todoCollection.add({'qrcodesUrl': downloadUrl});
    notifyListeners();
  }
}
