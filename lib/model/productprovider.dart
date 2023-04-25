import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_login_auth/model/productmodel.dart';
import 'package:flutter/foundation.dart';

class ProductProvider with ChangeNotifier{
  final CollectionReference todos =
  FirebaseFirestore.instance.collection('todos');

  Stream<List<Product>> get todoStream {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;
    return getProduct(userId);
  }

  // final FirebaseAuth _auth = FirebaseAuth.instance;

  // User? _user;
  //
  // User? get user => _user;
  //
  // // other methods and properties go here
  //
  // void getCurrentUser() async {
  //   _user = await _auth.currentUser;
  //   notifyListeners();
  // }


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
      'barcodeId' : todo.barcodeId,
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
      'barcodeId' : todo.barcodeId,
    };

    await todoCollection.doc(todo.productId).update(todoData);
  }

  Stream<List<Product>> getProduct(String userId) {
    final userRef = FirebaseFirestore.instance.collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users').doc(userId);

    final todoCollection = userRef.collection('todos');

    return todoCollection.snapshots().map((querySnapshot) => querySnapshot.docs.map((doc) {
      final data = doc.data();
      return Product(
        productId: doc.id,
        productTitle: data['productTitle'],
        productPrice: data['productPrice'],
        completed: data['completed'],
        userId: data['userId'],
        barcodeId: data['barcodeId'],
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
}
