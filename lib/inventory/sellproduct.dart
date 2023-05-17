import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shoes_inventory_ms/database/productupdateservice.dart';
import 'package:shoes_inventory_ms/model/constant.dart';
import 'package:shoes_inventory_ms/model/productmodel.dart';

class SellProductPage extends StatefulWidget {
  final Product product;

  SellProductPage({required this.product});

  @override
  _SellProductPageState createState() => _SellProductPageState();
}

class _SellProductPageState extends State<SellProductPage> {
  int _quantity = 1;

  void _sellProduct() async {
    final productUpdateService = ProductUpdateService();

    // Create a new document in the "productout" collection
    final soldProduct = {
      'productId': widget.product.productId,
      'productImage': widget.product.productImage,
      'barcodeId': widget.product.barcodeId,
      'barcodeUrl': widget.product.barcodeUrl,
      'productSize': widget.product.productSize,
      'qrcodeUrl': widget.product.qrcodeUrl,
      'branch': widget.product.branch,
      'productTitle': widget.product.productTitle,
      'productDetails': widget.product.productDetails,
      'productBrand': widget.product.productBrand,
      'productPrice': widget.product.productPrice,
      'productQuantity': _quantity,
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'soldAt': DateTime.now(),
    };
    await FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('sold_products')
        .doc(widget.product.productId)
        .set(soldProduct);

    final newQuantity = widget.product.productQuantity - _quantity;
    await productUpdateService.updateProductQuantity(widget.product.productId, newQuantity);

    // Show a confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Product sold!'),
        content: Text('You have successfully sold $_quantity ${widget.product.productTitle} to the customer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sell Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                widget.product.productImage,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                widget.product.productTitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Brand: ${widget.product.productBrand}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Price: \₱${widget.product.productPrice}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Size: ${widget.product.productSize}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              widget.product.productQuantity == 0 ? 'Quantity: Out of stock' : 'Quantity: $_quantity',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Branch: ${widget.product.branch}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Details: ${widget.product.productDetails}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: () => setState(() {
                    _quantity = _quantity > 1 ? _quantity - 1 : 1;
                  }),
                  icon: const Icon(Icons.remove),
                ),
                Text(
                  '$_quantity',
                  style: const TextStyle(fontSize: 20.0),
                ),
                IconButton(
                  onPressed: () => setState(() {
                    _quantity = _quantity + 1;
                  }),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _sellProduct(),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBtnColor,
                // padding: const EdgeInsets.all(20),
                shadowColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: primaryBtnColor,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Center(
                    child: Text("Sell Product",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17
                        )
                    ),
                  )
              ),
            )
          ],
        ),
      ),
    );
  }
}
