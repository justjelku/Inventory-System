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
    return StreamBuilder<List<StockInModel>>(
      stream: getStockIn(productId), // Replace with your stream for stock in history
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final stockInHistory = snapshot.data!;
          return ListView.builder(
            itemCount: stockInHistory.length,
            itemBuilder: (context, index) {
              final stockInItem = stockInHistory[index];
              return ListTile(
                leading: Image.network(stockInItem.productImage),
                title: Text(stockInItem.productTitle),
                subtitle: Text('Quantity: ${stockInItem.productQuantity}'),
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StockDetailsPage(
                        product: stockInItem,
                      ),
                    ),
                  );
                },
              );
            },
          );
        } else if (snapshot.hasError) {
          return const Center(
            child: Text('Error loading stock in history'),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class StockOutHistoryTab extends StatelessWidget {
  final String productId;

  StockOutHistoryTab({required this.productId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<StockInModel>>(
      stream: getStockOut(productId), // Replace with your stream for stock out history
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final stockOutHistory = snapshot.data!;
          return ListView.builder(
            itemCount: stockOutHistory.length,
            itemBuilder: (context, index) {
              final stockOutItem = stockOutHistory[index];
              return ListTile(
                leading: Image.network(stockOutItem.productImage),
                title: Text(stockOutItem.productTitle),
                subtitle: Text('Quantity: ${stockOutItem.productQuantity}'),
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StockDetailsPage(
                        product: stockOutItem,
                      ),
                    ),
                  );
                },
              );
            },
          );
        } else if (snapshot.hasError) {
          return const Center(
            child: Text('Error loading stock out history'),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

Stream<List<StockInModel>> getStockOut(String productId) {
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

  return query.map((querySnapshot) => querySnapshot.docs.map((doc) {
    final data = doc.data();
    return StockInModel(
      productId: doc.id,
      category: data['category'] ?? '',
      productSize: data['productSize'] ?? 0,
      sizeSystem: data['sizeSystem'] ?? '',
      color: data['color'] ?? '',
      productTitle: data['productTitle'],
      productBrand: data['productBrand'],
      productPrice: data['productPrice'] ?? 0,
      productDetails: data['productDetails'],
      productQuantity: data['productQuantity'] ?? 0,
      userId: data['userId'],
      barcodeId: data['barcodeId'],
      barcodeUrl: data['barcodeUrl'] ?? '',
      qrcodeUrl: data['qrcodeUrl'] ?? '',
      productImage: data['productImage'] ?? '',
      branch: data['branch'],
      type: data['type'], stockinId: data['stockInId'], stock: data['stock'], updatedAt: data['updatedtime'],
    );
  }).toList());
}

Stream<List<StockInModel>> getStockIn(String productId) {
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

  return query.map((querySnapshot) => querySnapshot.docs.map((doc) {
    final data = doc.data();
    return StockInModel(
      productId: doc.id,
      stockinId: data['stockinId'],
      category: data['category'] ?? '',
      productSize: data['productSize'] ?? 0,
      sizeSystem: data['sizeSystem'] ?? '',
      color: data['color'] ?? '',
      productTitle: data['productTitle'],
      productBrand: data['productBrand'],
      productPrice: data['productPrice'] ?? 0,
      productDetails: data['productDetails'],
      productQuantity: data['productQuantity'] ?? 0,
      userId: data['userId'],
      barcodeId: data['barcodeId'],
      barcodeUrl: data['barcodeUrl'] ?? '',
      qrcodeUrl: data['qrcodeUrl'] ?? '',
      productImage: data['productImage'] ?? '',
      branch: data['branch'],
      type: data['type'], stock: data['stock'], updatedAt: data['updatedtime'],
    );
  }).toList());
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
