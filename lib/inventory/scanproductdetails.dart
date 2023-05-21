import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shoes_inventory_ms/database/productsearchservice.dart';
import 'package:shoes_inventory_ms/inventory/stockout.dart';
import 'package:shoes_inventory_ms/inventory/stockin.dart';
import 'package:shoes_inventory_ms/model/constant.dart';
import 'package:shoes_inventory_ms/model/productmodel.dart';
import 'package:shoes_inventory_ms/pages/barcode.dart';

class ScanProductDetailsPage extends StatefulWidget {
  final String barcode;

  const ScanProductDetailsPage({required this.barcode});

  @override
  _ScanProductDetailsPageState createState() => _ScanProductDetailsPageState();
}

class _ScanProductDetailsPageState extends State<ScanProductDetailsPage> {
  Product? _product;

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
  }

  void _fetchProductDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    final product = await ProductSearchService()
        .searchByBarcodeId(user!.uid, widget.barcode);
    setState(() {
      _product = product.docs.map((doc) => Product.fromMap(doc.data())).first;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_product == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return Scaffold(
          appBar: AppBar(
            title: const Text('Product Details'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  _product!.productImage,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  _product!.productTitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Brand: ${_product!.productBrand}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Price: \₱${_product!.productPrice}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Size: ${_product!.productSize}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                _product!.productQuantity == 0
                    ? 'Quantity: Out of stock'
                    : 'Quantity: ${_product!.productQuantity}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Branch: ${_product!.branch}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Details: ${_product!.productDetails}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StockInPage(
                        product: _product!,
                      ),
                    ),
                  );
                },
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
                      child: Text("Stock In",
                          style: TextStyle(color: Colors.white, fontSize: 17)),
                    )),
              ),
              const SizedBox(height: 20,),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StockOutPage(
                        product: _product!,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryBtnColor,
                  // padding: const EdgeInsets.all(20),
                  shadowColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: secondaryBtnColor,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Center(
                      child: Text("Stock Out",
                          style: TextStyle(color: Colors.white, fontSize: 17)),
                    )),
              )
            ],
          ));
    }
  }
}
