import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:shoes_inventory_ms/model/constant.dart';
import 'package:shoes_inventory_ms/model/productmodel.dart';
import 'package:shoes_inventory_ms/model/productprovider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';

class EditProduct extends StatefulWidget {
  final Product todo;

  const EditProduct({super.key, required this.todo});

  @override
  // ignore: library_private_types_in_public_api
  _EditProductState createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  late String _title;
  late int _price;
  late String _brand;
  late String _imageF;
  late String _details;
  int? _shoeSize;
  late String _branch;
  File? _imageFile;
  File? _image;
  int? _selectedSize;
  late int _quantity;
  final _formKey = GlobalKey<FormState>();

  late String barcodeData;
  GlobalKey brGlobalKey = GlobalKey();
  GlobalKey qrGlobalKey = GlobalKey();
  late GlobalKey _barcodeKey;
  BarcodeWidget? _barcodeImage;
  String? productId;

  @override
  void initState() {
    super.initState();
    _barcodeKey = GlobalKey();
    barcodeData = widget.todo.barcodeId;
    _title = widget.todo.productTitle;
    _brand = widget.todo.productBrand;
    _price = widget.todo.productPrice;
    _shoeSize = widget.todo.productSize;
    _details = widget.todo.productDetails;
    _quantity = widget.todo.productQuantity;
    _branch = widget.todo.branch;
    _imageF = widget.todo.productImage;
  }

  void _pickImage() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // set selected image path
      });
    }
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
  Widget build(BuildContext context) {
    final userdata = widget.todo;
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  decoration: BoxDecoration(
                    color: mainTextColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  width: double.infinity,
                  height: 200,
                  child: _imageFile == null // if no image is selected
                      ? GestureDetector(
                          onTap: _pickImage,
                          child: Center(
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Image.network(_imageF
                                      ),
                                ),
                                Positioned(
                                  bottom: 5,
                                  right: 5,
                                  child: IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: _pickImage,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Image.file(
                          File(_imageFile!.path),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (BuildContext context, Object exception,
                              StackTrace? stackTrace) {
                            return const Text('Image not found');
                          },
                        ), // if an image is selected
                ),
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                initialValue: _title,
                onChanged: (value) {
                  setState(() {
                    _title = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Enter title',
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                initialValue: _brand,
                onChanged: (value) {
                  setState(() {
                    _brand = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Enter brand',
                ),
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Shoe Size',
                ),
                value: _shoeSize.toString(),
                onChanged: (String? value) {
                  setState(() {
                    _shoeSize = int.parse(
                        value!); // parse the selected value to an integer
                    _selectedSize = int.tryParse(value.replaceAll('.',
                        '')); // parse the value to an int, removing any decimal point if present
                  });
                },
                items: <String>[
                  '5',
                  '5.5',
                  '6',
                  '6.5',
                  '7',
                  '7.5',
                  '8',
                  '8.5',
                  '9'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              TextFormField(
                initialValue: _branch,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                    hintText: 'Branch', labelText: 'Branch'),
                onChanged: (value) {
                  setState(() {
                    _branch = value;
                  });
                },
              ),
              TextFormField(
                initialValue: _price.toString(),
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(hintText: "0.00", labelText: 'Price'),
                onChanged: (value) {
                  setState(() {
                    _price = int.parse(value);
                  });
                },
              ),
              const SizedBox(
                height: 20,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                initialValue: _details,
                onChanged: (value) {
                  setState(() {
                    _details = value;
                  });
                },
                decoration: const InputDecoration(
                    hintText: 'Details', labelText: 'Details'),
                validator: (value) {
                  return (value == '') ? "Details" : null;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                initialValue: _quantity.toString(),
                onChanged: (value) {
                  setState(() {
                    _quantity = int.parse(value);
                  });
                },
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(hintText: "0", labelText: 'Quantity'),
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
              RepaintBoundary(
                key: brGlobalKey,
                child: BarcodeWidget(
                  color: secondaryTextColor,
                  barcode: Barcode.code128(),
                  data: barcodeData,
                  width: 350,
                  height: 200,
                  drawText: false,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              RepaintBoundary(
                key: qrGlobalKey,
                child: PrettyQr(
                  image: const AssetImage('assets/logo.png'),
                  size: 300,
                  data: barcodeData,
                  errorCorrectLevel: QrErrorCorrectLevel.M,
                  typeNumber: null,
                  roundEdges: true,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const SizedBox(height: 20),
              barcodeData == ''
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
                      child: Text("Generate",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17
                          )
                      ),
                    )
                ),
              ) : Column(
                children: [
                  Text(barcodeData),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final title = _title;
                      final brand = _brand;
                      final int price = _price;
                      final description = _details;
                      final int quantity = _quantity;
                      final branch = _branch;
                      final productSize = _shoeSize;

                      if (_formKey.currentState!.validate()) {
                        // final RenderRepaintBoundary boundary = brGlobalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
                        //
                        // final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
                        // dynamic bytes = await image.toByteData(format: ui.ImageByteFormat.png);
                        // bytes = bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
                        //
                        // final Directory documentDirectory = await getApplicationDocumentsDirectory();
                        // final String path = documentDirectory.path;
                        // String imageName = '$_title$barcodeData.png';
                        // imageCache.clear();
                        // File barcodeFile = File('$path/$imageName');
                        // barcodeFile.writeAsBytesSync(bytes);
                        //
                        // final RenderRepaintBoundary boundary1 = qrGlobalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
                        //
                        // final ui.Image image1 = await boundary1.toImage(pixelRatio: 3.0);
                        // dynamic bytes1 = await image1.toByteData(format: ui.ImageByteFormat.png);
                        // bytes = bytes.buffer.asUint8List(bytes1.offsetInBytes, bytes1.lengthInBytes);
                        //
                        // final Directory documentDirectory1 = await getApplicationDocumentsDirectory();
                        // final String path1 = documentDirectory1.path;
                        // String imageName1 = '$_title$barcodeData.png';
                        // imageCache.clear();
                        // File qrFile = File('$path1/$imageName1');
                        // qrFile.writeAsBytesSync(bytes1);

                        final updatedTodo = Product(
                          productId: productId!,
                          productSize: productSize!,
                          productTitle: title,
                          productBrand: brand,
                          productPrice: price,
                          productDetails: description,
                          productQuantity: quantity,
                          userId: FirebaseAuth.instance.currentUser!.uid,
                          barcodeId: barcodeData!,
                          barcodeUrl: '',
                          qrcodeUrl: '',
                          productImage: '',
                          branch: branch,
                        );

                        // final updatedTodo = widget.todo.copyWith(
                        //   productTitle: _title,
                        //   productBrand: _brand,
                        //   productPrice: _price,
                        //   productSize: _shoeSize,
                        //   productDetails: _details,
                        //   productQuantity: _quantity,
                        //   branch: _branch,
                        //   barcodeId: barcodeData,
                        //   // barcodeUrl: '',
                        //   // qrcodeUrl: '',
                        //   // productImage: '',
                        // );
                        await ProductProvider().updateProduct(updatedTodo, _imageFile!);
                        _showMsg('You have updated the product!', true);
                        Navigator.pop(context);
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
                          child: Text("Update Product",
                              style: TextStyle(color: Colors.white, fontSize: 17)),
                        )),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
