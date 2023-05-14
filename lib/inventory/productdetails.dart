import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shoes_inventory_ms/model/constant.dart';
import 'package:shoes_inventory_ms/model/productmodel.dart';
import 'package:shoes_inventory_ms/pages/barcode.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product product;

  const ProductDetailsPage({Key? key, required this.product}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late String _title;
  late String _brand;
  late int _price;
  late String _imageF;
  late String _details;
  int? _shoeSize;
  late String _branch;
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _title = widget.product.productTitle;
    _brand = widget.product.productBrand;
    _price = widget.product.productPrice;
    _shoeSize = widget.product.productSize;
    _details = widget.product.productDetails;
    _quantity = widget.product.productQuantity;
    _branch = widget.product.branch;
    _imageF = widget.product.productImage;
  }

  @override
  Widget build(BuildContext context) {
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
              _imageF,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              _title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Brand: $_brand',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Price: \₱$_price',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Size: $_shoeSize',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            _quantity == 0 ? 'Quantity: Out of stock' : 'Quantity: $_quantity',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Branch: $_branch',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Details: $_details',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BarcodePage(
                    todo: widget.product,
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
                  child: Text("View more",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17
                      )
                  ),
                )
            ),
          )
        ],
      )
    );
  }
}
