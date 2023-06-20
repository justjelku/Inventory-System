import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shoes_inventory_ms/inventory/productdetails.dart';
import 'package:shoes_inventory_ms/inventory/scanproductdetails.dart';
import 'package:shoes_inventory_ms/inventory/stockdetails.dart';
import 'package:shoes_inventory_ms/model/productmodel.dart';
import 'package:shoes_inventory_ms/model/stockmodel.dart';

class StockHistoryPage extends StatelessWidget {
  final String productId;

  StockHistoryPage({required this.productId});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Stock History'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Stock In'),
              Tab(text: 'Stock Out'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            StockInHistoryTab(productId: productId),
            StockOutHistoryTab(productId: productId),
          ],
        ),
      ),
    );
  }
}

class StockInHistoryTab extends StatelessWidget {
  final String productId;

  StockInHistoryTab({required this.productId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: getStockIn(productId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final productList = snapshot.data!;
          return ListView.builder(
            itemCount: productList.length,
            itemBuilder: (context, index) {
              final productData = productList[index];
              // Access the fields using the key-value pairs in productData map
              final productTitle = productData['productTitle'];
              final productQuantity = productData['productQuantity'];

              // Return a widget to display the product information
              return ListTile(
                title: Text(productTitle),
                subtitle: Text('Quantity: $productQuantity'),
              );
            },
          );
        } else if (snapshot.hasError) {
          return const Center(
            child: Text('Error loading products'),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
  Stream<List<Map<String, dynamic>>> getStockIn(String productId) {
    final collectionRef = FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('stock');

    final query = collectionRef
        .where('stock', isEqualTo: 'Stock In')
        .where('productId', isEqualTo: productId)
        .snapshots();

    return query.map((querySnapshot) =>
        querySnapshot.docs.map((doc) => doc.data()).toList());
  }
}

class StockOutHistoryTab extends StatelessWidget {
  final String productId;

  StockOutHistoryTab({required this.productId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: getStockOut(productId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final productList = snapshot.data!;
          return ListView.builder(
            itemCount: productList.length,
            itemBuilder: (context, index) {
              final productData = productList[index];
              // Access the fields using the key-value pairs in productData map
              final productTitle = productData['productTitle'];
              final productQuantity = productData['productQuantity'];

              // Return a widget to display the product information
              return ListTile(
                title: Text(productTitle),
                subtitle: Text('Quantity: $productQuantity'),
              );
            },
          );
        } else if (snapshot.hasError) {
          return const Center(
            child: Text('Error loading products'),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Stream<List<Map<String, dynamic>>> getStockOut(String productId) {
    final collectionRef = FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('stock');

    final query = collectionRef
        .where('stock', isEqualTo: 'Stock Out')
        .where('productId', isEqualTo: productId)
        .snapshots();

    return query.map((querySnapshot) =>
        querySnapshot.docs.map((doc) => doc.data()).toList());
  }
}


// Stream<List<StockInModel>> getStockIn(String productId) {
//   final user = FirebaseAuth.instance.currentUser;
//   final userRef = FirebaseFirestore.instance
//       .collection('users')
//       .doc('qIglLalZbFgIOnO0r3Zu')
//       .collection('basic_users')
//       .doc(user!.uid)
//       .collection('products')
//       .doc(productId);
//
//   final todoCollection = userRef.collection('stock_in');
//
//   return todoCollection
//       .orderBy('updatedtime', descending: true)
//       .snapshots()
//       .map((querySnapshot) => querySnapshot.docs.map((doc) {
//     final data = doc.data();
//     var productPrice = data['productPrice'];
//     var productSize = data['productSize'];
//     var productQuantity = data['productQuantity'];
//
//     // Check if productPrice is a String and convert to int if necessary
//     if (productPrice is String || productSize is String) {
//       productPrice = int.parse(productPrice);
//       productSize = int.parse(productSize);
//       productQuantity = int.parse(productQuantity);
//     }
//
//     return StockInModel(
//       productId: doc.id,
//       category: data['category'] ?? '',
//       productSize: data['productSize'] ?? 0,
//       sizeSystem: data['sizeSystem'] ?? '',
//       color: data['color'] ?? '',
//       productTitle: data['productTitle'],
//       productBrand: data['productBrand'],
//       productPrice: data['productPrice'] ?? 0,
//       productDetails: data['productDetails'],
//       productQuantity: data['productQuantity'] ?? 0,
//       userId: data['userId'],
//       barcodeId: data['barcodeId'],
//       barcodeUrl: data['barcodeUrl'] ?? '',
//       qrcodeUrl: data['qrcodeUrl'] ?? '',
//       productImage: data['productImage'] ?? '',
//       branch: data['branch'],
//       type: data['type'], stockInId: data['stockInId'], stock: data['stock'], updatedAt: data['updatedtime'],
//     );
//   }).toList());
// }
