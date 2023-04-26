import 'dart:math';
import 'package:firebase_login_auth/model/productprovider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_login_auth/model/constant.dart';
import 'package:firebase_login_auth/model/productmodel.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({Key? key}) : super(key: key);

  @override
  State<AddProduct> createState() => _AddProductState();
}
class _AddProductState extends State<AddProduct> {

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();

  String? barcodeData;
  GlobalKey globalKey = GlobalKey();
  late GlobalKey _barcodeKey;
  BarcodeWidget? _barcodeImage;
  String? productTitle;


  @override
  void initState() {
    super.initState();
    _barcodeKey = GlobalKey();
    _barcodeImage = BarcodeWidget(
      barcode: Barcode.code128(),
      data: '',
      key: _barcodeKey,
      width: 350,
      height: 200,
      drawText: true,
    );
  }

  Future<void> _generateBarcode() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;

    // Get the last product ID for this user
    final lastProductId = await getLastProductId();

    // Create the barcode data using the first four characters of the user ID
    // and the last three characters of the last product ID
    barcodeData =
    '2023${userId.substring(0, 4)}${lastProductId.substring(lastProductId.length - 3)}';

    setState(() {
      _barcodeImage = BarcodeWidget(
        barcode: Barcode.code128(),
        data: barcodeData!,
        width: 350,
        height: 200,
        drawText: true,
      );
    });
  }

  Future<String> getLastProductId() async {
    final random = Random();
    final number = random.nextInt(99999);
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;
    final userPrefix = userId.substring(0, 3);
    return '$userPrefix${number.toString().padLeft(5, '0')}';
  }
  void _showMsg(String message, bool isSuccess) {
    Color color = isSuccess ? Colors.green : Colors.red;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: color,
            width: 2,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Provider<ProductProvider>(
        create: (_) => ProductProvider(),
        builder:(context, child){
          return Scaffold(
            appBar: AppBar(
              title: const Text('Generate Barcode'),
            ),
            body: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    if (_barcodeImage != null) _barcodeImage!,
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                          hintText: 'Name',
                          labelText: 'Product'
                      ),
                      validator: (value){
                        return (value == '')? "Product" : null;
                      },
                    ),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                          hintText: "0.00",
                          labelText: 'Price'
                      ),
                      validator: (value){
                        return (value == '')? "Price" : null;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const SizedBox(height: 20),
                    barcodeData == null
                        ? ElevatedButton(
                          onPressed: _generateBarcode,
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
                              child: Text("Generate Barcode",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17
                                )
                              ),
                            )
                          ),
                        )
                        : Column(
                          children: [
                            Text('BarcodeId: $barcodeData'),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBtnColor,
                                padding: const EdgeInsets.all(20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  final title = _titleController.text.trim();
                                  final description = _priceController.text.trim();
                                  final todo = Product(
                                    productId: '',
                                    productTitle: title,
                                    productPrice: description,
                                    completed: false,
                                    userId: FirebaseAuth.instance.currentUser!.uid,
                                    barcodeId: barcodeData!,
                                    barcodeUrl: '',
                                    qrcodeUrl: '',
                                  );
                                  await ProductProvider().addProduct(todo);
                                  _showMsg('You have added a new product!', true);
                                  // Clear form fields and reset barcodeData
                                  _titleController.clear();
                                  _priceController.clear();
                                  setState(() {
                                    barcodeData = null;
                                  });
                                }
                                else{
                                  _showMsg('No product was added!', false);
                                }
                              },
                              child: Container(
                                  // padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: primaryBtnColor,
                                    // borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: const Center(
                                    child: Text("Add Product",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20
                                        )
                                    ),
                                  )
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        }
    );
  }
}






