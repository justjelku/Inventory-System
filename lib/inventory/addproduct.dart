import 'dart:math';
import 'package:shoes_inventory_ms/model/productprovider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shoes_inventory_ms/model/constant.dart';
import 'package:shoes_inventory_ms/model/productmodel.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({Key? key}) : super(key: key);

  @override
  State<AddProduct> createState() => _AddProductState();
}
class _AddProductState extends State<AddProduct> {

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  late TextEditingController _branchController;
  File? _imageFile;
  String? _shoeSize;
  int? _selectedSize;
  final _detailsController = TextEditingController();

  String? barcodeData;
  String? productId;
  GlobalKey globalKey = GlobalKey();
  late GlobalKey _barcodeKey;
  BarcodeWidget? _barcodeImage;
  String? productTitle;

  List<String> branchList = [];
  String? _selectedBranch;

  Future<void> getBranches() async {
    // fetch branches from Firebase using product provider
    branchList = await ProductProvider().getBranches();

    // // add fetched branches to branchList
    // branchList.addAll();

    // add the default branch to the beginning of the list
    branchList.insert(0, 'Main Branch');

    setState(() {});
  }


  @override
  void initState() {
    super.initState();
    _branchController = TextEditingController(text: _selectedBranch);
    getBranches();
    _barcodeKey = GlobalKey();
    _barcodeImage = BarcodeWidget(
      barcode: Barcode.code128(),
      data: '',
      key: _barcodeKey,
      width: 200,
      height: 150,
      drawText: true,
    );
  }

  void _pickImage() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = File(pickedFile!.path);
    });
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

    productId =
    '2023${userId.substring(0, 5)}${lastProductId.substring(lastProductId.length - 8)}';

    setState(() {
      _barcodeImage = BarcodeWidget(
        barcode: Barcode.code128(),
        data: barcodeData!,
        width: 200,
        height: 150,
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
  void dispose() {
    _branchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Provider<ProductProvider>(
        create: (_) => ProductProvider(),
        builder:(context, child){
          return Scaffold(
            appBar: AppBar(
              title: const Text('Add Product'),
              automaticallyImplyLeading: false,
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
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        width: double.infinity,
                        height: 200,
                        child: _imageFile == null ? const Icon(Icons.image, size: 50,) : Image.file(_imageFile!),
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Shoe Size',
                      ),
                      value: _shoeSize,
                      onChanged: (String? value) {
                        setState(() {
                          _shoeSize = value!;
                          _selectedSize = int.tryParse(value.replaceAll('.', '')); // parse the value to an int, removing any decimal point if present
                        });
                      },
                      items: <String>['5', '5.5', '6', '6.5', '7', '7.5', '8', '8.5', '9']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    // const SizedBox(height: 20),
                    TextFormField(
                      controller: _branchController,
                      decoration: const InputDecoration(
                          hintText: 'Branch',
                          labelText: 'Branch'
                      ),
                      validator: (value){
                        return (value == '')? "Branch" : null;
                      },
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
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          hintText: "0.00",
                          labelText: 'Price'
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a price';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: _detailsController,
                      decoration: const InputDecoration(
                          hintText: 'Details',
                          labelText: 'Details'
                      ),
                      validator: (value){
                        return (value == '')? "Details" : null;
                      },
                    ),

                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          hintText: "0",
                          labelText: 'Quantity'
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a quantity';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    if (_barcodeImage != null) _barcodeImage!,
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
                    ) : Column(
                      children: [
                        Text('BarcodeId: $barcodeData'),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final title = _titleController.text.trim();
                              final price = _priceController.text.trim();
                              final description = _detailsController.text.trim();
                              final quantity = _quantityController.text.trim();
                              final branch = _branchController.text.trim();
                              final productSize = int.parse(_shoeSize!.split('.')[0]);

                              final todo = Product(
                                productId: productId!,
                                productSize: int.parse(_shoeSize!.split('.')[0]),
                                productTitle: title,
                                productPrice: int.parse(price),
                                productDetails: description,
                                productQuantity: int.parse(quantity),
                                userId: FirebaseAuth.instance.currentUser!.uid,
                                barcodeId: barcodeData!,
                                barcodeUrl: '',
                                qrcodeUrl: '',
                                productImage: '',
                                branch: branch,
                              );
                              await ProductProvider().addProduct(todo, _imageFile!);
                              // if (_imageFile != null) {
                              //   ProductProvider().uploadImage(productId!, _imageFile!);
                              // }
                              _showMsg('You have added a new product!', true);
                              // Navigator.of(context).pop();
                              // ignore: use_build_context_synchronously
                              // Clear form fields and reset barcodeData
                              _titleController.clear();
                              _priceController.clear();
                              _quantityController.clear();
                              _detailsController.clear();
                              setState(() {
                                barcodeData = null;
                                _imageFile = null;
                                _shoeSize = null;
                              });
                            }
                            else{
                              _showMsg('No product was added!', false);
                              // Navigator.of(context).pop();
                            }
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
                                child: Text('Add Product',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17
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