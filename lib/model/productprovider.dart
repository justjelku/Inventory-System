import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shoes_inventory_ms/model/productmodel.dart';
import 'package:shoes_inventory_ms/model/usermodel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class ProductProvider with ChangeNotifier {
  final CollectionReference todos =
  FirebaseFirestore.instance.collection('products');

  Stream<List<Product>> get productStream {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;
    return getProduct(userId);
  }

  late Product _todo;

  Product get todo => _todo;

  ProductProvider._() {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;
    fetchProductFromFirestore(userId).then((fetchedUser) {
      _todo = fetchedUser!;
      notifyListeners();
    });
  }

  factory ProductProvider() {
    return ProductProvider._();
  }

  @override
  void dispose() {
    _todo = ProductProvider() as Product;
    super.dispose();
  }

  // Future<UserModel?> fetchUserFromFirestore(String userId) async {
  //   final userRef = FirebaseFirestore.instance
  //       .collection('users')
  //       .doc('qIglLalZbFgIOnO0r3Zu')
  //       .collection('basic_users')
  //       .doc(userId);
  //
  //   final snapshot = await userRef.get();
  //   if (snapshot.exists) {
  //     return UserModel(
  //       uid: snapshot.id,
  //       firstName: snapshot.data()!['first name'],
  //       lastName: snapshot.data()!['last name'],
  //       username: snapshot.data()!['username'],
  //       email: snapshot.data()!['email'],
  //       role: snapshot.data()!['role'],
  //       status: snapshot.data()!['enabled'],
  //     );
  //   } else {
  //     return null;
  //   }
  // }

  Future<Product?> fetchProductFromFirestore(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    final userRef = FirebaseFirestore.instance.collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(user!.uid)
        .collection('products')
        .doc(productId);

    final snapshot = await userRef.get();
    if (snapshot.exists) {
      return Product(
        productId: snapshot.data()!['productId'],
        productSize: snapshot.data()!['productSize'] ?? 0,
        productTitle: snapshot.data()!['productTitle'],
        productPrice: snapshot.data()!['productPrice'] ?? 0,
        productDetails: snapshot.data()!['productDetails'],
        productQuantity: snapshot.data()!['productQuantity'] ?? 0,
        userId: snapshot.data()!['userId'],
        barcodeId: snapshot.data()!['barcodeId'],
        barcodeUrl: snapshot.data()!['barcodeUrl'] ?? '',
        qrcodeUrl: snapshot.data()!['qrcodeUrl'] ?? '',
        productImage: snapshot.data()!['productImage'] ?? '',
        branch: snapshot.data()!['branch'],
      );
    } else {
      return null;
    }
  }

  Future<void> addProduct(Product todo, File file) async {

    final fileName = basename(file.path);
    final ref = FirebaseStorage.instance.ref().child(
        'products/productImage/$fileName');
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();

    final user = FirebaseAuth.instance.currentUser;
    final userRef = FirebaseFirestore.instance.collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users').doc(user!.uid);

    final todoCollection = userRef.collection('products').doc(todo.productId);

    final todoData = {
      'productId': todo.productId,
      'productSize': todo.productSize,
      'productTitle': todo.productTitle,
      'productPrice': todo.productPrice,
      'productDetails': todo.productDetails,
      'productQuantity': todo.productQuantity,
      'userId': todo.userId,
      'barcodeId': todo.barcodeId,
      'barcodeUrl': todo.barcodeUrl,
      'qrcodeUrl': todo.qrcodeUrl,
      'productImage': downloadUrl,
      'branch': todo.branch,
      'createdTime': FieldValue.serverTimestamp(), // add this field
      'updatedTime': FieldValue.serverTimestamp(), // add this field
    };

    await todoCollection.set(todoData);
  }

  Future<void> updateProduct(Product todo) async {
    final user = FirebaseAuth.instance.currentUser;
    final userRef = FirebaseFirestore.instance.collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users').doc(user!.uid);

    final todoCollection = userRef.collection('products').doc(todo.productId);

    final todoData = {
      'productId': todo.productId,
      'productSize': todo.productSize,
      'productTitle': todo.productTitle,
      'productPrice': todo.productPrice,
      'productDetails': todo.productDetails,
      'productQuantity': todo.productQuantity,
      'userId': todo.userId,
      'barcodeId': todo.barcodeId,
      'barcodeUrl': todo.barcodeUrl,
      'qrcodeUrl': todo.qrcodeUrl,
      'productImage': todo.productImage,
      'branch': todo.branch,
      'createdTime': FieldValue.serverTimestamp(), // add this field
      'updatedTime': FieldValue.serverTimestamp(), // add this field
    };

    await todoCollection.set(todoData, SetOptions(merge: true));
  }

  Stream<List<Product>> getProduct(String userId) {
    final userRef = FirebaseFirestore.instance.collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users').doc(userId);

    final todoCollection = userRef.collection('products');

    return todoCollection.snapshots().map((querySnapshot) =>
        querySnapshot.docs.map((doc) {
          final data = doc.data();
          var productPrice = data['productPrice'];
          var productSize = data['productSize'];
          var productQuantity = data['productQuantity'];

          // Check if productPrice is a String and convert to int if necessary
          if (productPrice is String || productSize is String) {
            productPrice = int.parse(productPrice);
            productSize = int.parse(productSize);
            productQuantity = int.parse(productQuantity);
          }

          return Product(
            productId: doc.id,
            productSize: data['productSize'] ?? 0,
            productTitle: data['productTitle'],
            productPrice: productPrice ?? 0,
            productDetails: data['productDetails'],
            productQuantity: productQuantity ?? 0,
            userId: data['userId'],
            barcodeId: data['barcodeId'],
            barcodeUrl: data['barcodeUrl'] ?? '',
            qrcodeUrl: data['qrcodeUrl'] ?? '',
            productImage: data['productImage'] ?? '',
            branch: data['branch'],
          );
        }).toList());
  }

  // Method to add a new sub-collection under the todos collection of the current user
  Future<void> addBranch(String branchName) async {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    try {
      // Create a new sub-collection for the given branch name
      final branchCollection = FirebaseFirestore.instance
          .collection('products')
          .doc(branchName)
          .collection('branch');

      // Add a dummy item to the new sub-collection
      await branchCollection.add({'branchName': branchName});

      // Notify listeners that the data has changed
      notifyListeners();
    } catch (e) {
      print('Error adding branch: $e');
      rethrow;
    }
  }

  Future<List<String>> getBranches() async {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    try {
      final branchesCollection = userRef.collection('branches');
      final branches = await branchesCollection.get();
      return branches.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print('Error getting branches: $e');
      rethrow;
    }
  }


  Stream<int> getProductCount(String userId) {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(userId);

    final todoCollection = userRef.collection('products');

    return todoCollection.snapshots().map((querySnapshot) {
      final productIds = Set<String>();
      querySnapshot.docs.forEach((doc) {
        productIds.add(doc.id);
      });
      return productIds.length;
    });
  }


  Future<void> deleteProduct(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    final userRef = FirebaseFirestore.instance.collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users').doc(user!.uid);

    final todoRef = userRef.collection('products').doc(productId);
    await todoRef.delete();
  }

  Future<void> uploadBarcodes(String productId, File file, Product todo) async {
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
        .collection('products')
        .doc(productId) // creates a new document with a unique ID
        .collection(
        'barcodes'); // creates a new subcollection with name 'qrcodes'
    // Update the barcode URL of the current user in the app state
    final newDocRef = await todoCollection.add({'barcodeUrl': downloadUrl});
    notifyListeners();
  }

  Future<void> uploadQrcodes(String productId, File file, Product todo) async {
    final fileName = basename(file.path);
    final ref = FirebaseStorage.instance.ref().child(
        'products/qrcodeImages/$fileName');
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
        .collection('products')
        .doc(productId) // creates a new document with a unique ID
        .collection(
        'qrcodes'); // creates a new subcollection with name 'qrcodes'
    // Update the barcode URL of the current user in the app state
    final newDocRef = await todoCollection.add({'qrcodesUrl': downloadUrl});
    notifyListeners();
  }

  Future<void> uploadImage(String productId, File file) async {
    final fileName = basename(file.path);
    final ref = FirebaseStorage.instance.ref().child(
        'products/productImage/$fileName');
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();

    // Update the profile picture URL of the current user in Firestore database
    final user = FirebaseAuth.instance.currentUser;
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(user!.uid);

    final todoCollection = userRef.collection('products').doc(todo.productId);

    final todoData = {
      'productImage': downloadUrl,
      'createdTime': FieldValue.serverTimestamp(), // add this field
      'updatedTime': FieldValue.serverTimestamp(), // add this field
    };

    await todoCollection.set(todoData, SetOptions(merge: true));

    // final todoCollection = userRef
    //     .collection('products');
        // .doc(productId) // creates a new document with a unique ID
        // .collection('productImages'); // creates a new subcollection with name 'qrcodes'
    // final newDocRef = await todoCollection.add({productImage: downloadUrl});

    // Update the product image URL of the current user in the app state
    // final updatedProd = todo.copyWith(productImage: downloadUrl);
    // _todo = updatedProd;
    notifyListeners();
  }

  Future<void> updateImage(String productId, File file) async {
    final fileName = basename(file.path);
    final ref = FirebaseStorage.instance.ref().child('products/productImage/$fileName');
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();

    // Update the product image URL in Firestore database
    final productRef = FirebaseFirestore.instance.collection('products').doc(productId);
    final imagesCollectionRef = productRef.collection('productImages');
    final imageDocSnapshot = await imagesCollectionRef.get();
    final imageDoc = imageDocSnapshot.docs.firstWhere((doc) => doc['prodImgUrl'] == _todo.productImage);
    await imagesCollectionRef.doc(imageDoc.id).update({'prodImgUrl': downloadUrl});

    // Update the product image URL in the app state
    final updatedProduct = _todo.copyWith(productImage: downloadUrl);
    _todo = updatedProduct;
    notifyListeners();
  }


  Future<String?> getProductImage(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(user!.uid);
    final productRef = userRef
        .collection('products')
        .doc(productId)
        .collection('productImages');
    final productData = await productRef.get();
    if (productData.docs.isNotEmpty) {
      final productImage = productData.docs.first;
      return productImage.get('prodImgUrl');
    }
    return null;
  }

  Stream<Map<String, int>> getBranchCount(String userId) {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(userId);

    final todoCollection = userRef.collection('products');

    return todoCollection.snapshots().map((querySnapshot) {
      final branchProductCountMap = Map<String, int>();
      querySnapshot.docs.forEach((doc) {
        final data = doc.data();
        final branch = data['branch'] as String?;
        if (branch != null) {
          if (branchProductCountMap.containsKey(branch)) {
            branchProductCountMap[branch] = branchProductCountMap[branch]! + 1;
          } else {
            branchProductCountMap[branch] = 1;
          }
        }
      });
      return branchProductCountMap;
    });
  }

  // final String userId;
  // final CollectionReference productCollection;
  //
  // ProductProvider({required this.userId})
  //     : productCollection = FirebaseFirestore.instance
  //     .collection('users')
  //     .doc('qIglLalZbFgIOnO0r3Zu')
  //     .collection('basic_users')
  //     .doc(userId)
  //     .collection('products');

  Future<List<Map<String, dynamic>>> getProductList(String userId) async {
    final user = FirebaseAuth.instance.currentUser;
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(user!.uid);

    final todoCollection = userRef.collection('products');
    final querySnapshot = await todoCollection.get();
    final productList = <Map<String, dynamic>>[];
    querySnapshot.docs.forEach((doc) {
      final data = doc.data();
      final productTitle = data['productTitle'] as String?;
      final productPrice = data['productPrice'] as int?;
      if (productTitle != null && productPrice != null) {
        productList.add({
          'productTitle': productTitle,
          'productPrice': productPrice,
        });
      }
    });
    return productList;
  }
}







