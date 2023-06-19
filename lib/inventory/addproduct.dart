import 'dart:math';
import 'package:pretty_qr_code/pretty_qr_code.dart';
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
import 'dart:io';
import 'dart:ui' as ui;
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
  final _quantityController = TextEditingController();
  final _brandController = TextEditingController();
  final _categoryController = TextEditingController();
  final _colorController = TextEditingController();
  late TextEditingController _branchController;
  File? _imageFile;
  String? _shoeSize;
  String? _category;
  String? _color;
  String? _selectedColor;
  String? _selectedSystem;
  String? _selectedSize;

  final List<String> usSizes = ['5', '5.5', '6', '6.5', '7', '7.5', '8', '8.5', '9'];
  final List<String> ukSizes = ['4.5', '5', '5.5', '6', '6.5', '7', '7.5', '8', '8.5'];
  final List<String> euSizes = ['37', '37.5', '38', '38.5', '39', '40', '40.5', '41', '42'];
  String? _selectedCategory;
  final _detailsController = TextEditingController();

  String? barcodeData;
  String? productId;
  GlobalKey brGlobalKey = GlobalKey();
  GlobalKey qrGlobalKey = GlobalKey();
  late GlobalKey _barcodeKey;
  BarcodeWidget? _barcodeImage;
  PrettyQr? _qrImage;
  String? productTitle;

  List<String> branchList = [];
  String? _selectedBranch;
  File? barcodeImageUrl;
  File? qrCodeImageUrl;
  bool _isOtherCategorySelected = false;


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
      width: 200,
      height: 150,
      drawText: false,
    );
    _qrImage = PrettyQr(
      image: const AssetImage('assets/logo.png'),
      size: 300,
      data: '',
      errorCorrectLevel: QrErrorCorrectLevel.M,
      typeNumber: null,
      roundEdges: true,
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
        drawText: false,
      );
      _qrImage = PrettyQr(
        image: const AssetImage('assets/logo.png'),
        size: 300,
        data: barcodeData!,
        errorCorrectLevel: QrErrorCorrectLevel.M,
        typeNumber: null,
        roundEdges: true,
      );
    });

    await generateBarcodeImage();
    await generateQRCodeImage();
  }

  Future<void> generateBarcodeImage() async {
    final RenderRepaintBoundary boundary = brGlobalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    dynamic bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    bytes = bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);

    final Directory documentDirectory = await getApplicationDocumentsDirectory();
    final String path = documentDirectory.path;
    String imageName = '$barcodeData.png';
    imageCache.clear();
    File barcodeFile = File('$path/$imageName');
    barcodeFile.writeAsBytesSync(bytes);

    barcodeImageUrl = barcodeFile; // Save the barcode image URL
  }

  Future<void> generateQRCodeImage() async {
    final RenderRepaintBoundary boundary = qrGlobalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    dynamic bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    bytes = bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);

    final Directory documentDirectory = await getApplicationDocumentsDirectory();
    final String path = documentDirectory.path;
    String imageName = '$barcodeData.png';
    imageCache.clear();
    File qrFile = File('$path/$imageName');
    qrFile.writeAsBytesSync(bytes);

    qrCodeImageUrl = qrFile; // Save the QR code image URL
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
              title: const Text('Add Stock'),
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
                        labelText: 'Men Size',
                      ),
                      value: _selectedSystem,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedSystem = value;
                          _selectedSize = null; // Reset selected size when changing the system
                        });
                      },
                      items: <String>[
                        'US',
                        'UK',
                        'EU',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    if (_selectedSystem != null)
                      Column(
                        children: [
                          const SizedBox(height: 16),
                          Text('Selected System: $_selectedSystem'),
                          const SizedBox(height: 16),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: (_selectedSystem == 'US')
                                  ? usSizes.map((size) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedSize = size;
                                      });
                                    },
                                    child: Text(size),
                                  ),
                                );
                              }).toList()
                                  : (_selectedSystem == 'UK')
                                  ? ukSizes.map((size) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedSize = size;
                                      });
                                    },
                                    child: Text(size),
                                  ),
                                );
                              }).toList()
                                  : euSizes.map((size) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedSize = size;
                                      });
                                    },
                                    child: Text(size),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          if (_selectedSize != null)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text('Selected Size: $_selectedSize'),
                            ),
                        ],
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
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Category',
                      ),
                      value: _category,
                      onChanged: (String? value) {
                        setState(() {
                          if (value == 'Other') {
                            _isOtherCategorySelected = true;
                          } else {
                            _category = value!;
                            _isOtherCategorySelected = false;
                          }
                        });
                      },
                      items: const <DropdownMenuItem<String>>[
                        DropdownMenuItem<String>(
                          value: 'Basketball Shoes',
                          child: Text('Basketball Shoes'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'Other',
                          child: Text('Other'),
                        ),
                      ],
                    ),
                    if (_isOtherCategorySelected)
                      TextFormField(
                        controller: _categoryController,
                        decoration: const InputDecoration(
                            hintText: 'Category',
                            labelText: 'Category'
                        ),
                        validator: (value){
                          return (value == '')? "Category" : null;
                        },
                      ),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Color',
                      ),
                      value: _color,
                      onChanged: (String? value) {
                        setState(() {
                          if (value == 'Other') {
                            _isOtherCategorySelected = true;
                          } else {
                            _color = value!;
                            _isOtherCategorySelected = false;
                          }
                        });
                      },
                      items: const <DropdownMenuItem<String>>[
                        DropdownMenuItem<String>(
                          value: 'Blue',
                          child: Text('Blue'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'Black',
                          child: Text('Black'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'Other',
                          child: Text('Other'),
                        ),
                      ],
                    ),
                    if (_isOtherCategorySelected)
                      TextFormField(
                        controller: _colorController,
                        decoration: const InputDecoration(
                            hintText: 'Color',
                            labelText: 'Color'
                        ),
                        validator: (value){
                          return (value == '')? "Color" : null;
                        },
                      ),
                    TextFormField(
                      controller: _brandController,
                      decoration: const InputDecoration(
                          hintText: 'Brand',
                          labelText: 'Brand'
                      ),
                      validator: (value){
                        return (value == '')? "Brand" : null;
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
                        labelText: 'Quantity',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a quantity';
                        }
                        final quantity = int.tryParse(value);
                        if (quantity == null) {
                          return 'Please enter a valid number';
                        }
                        if (quantity > 100) {
                          return 'Maximum quantity is 100';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    RepaintBoundary(
                      key: brGlobalKey,
                      child: _barcodeImage ?? Container(), // Use _barcodeImage instead of BarcodeWidget
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    RepaintBoundary(
                      key: qrGlobalKey,
                      child: _qrImage ?? Container(), // Use _qrImage instead of PrettyQr
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
                            child: Text("Generate",
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
                        Text('$barcodeData'),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final title = _titleController.text.trim();
                              final category = _category == 'Other' ? _categoryController.text.trim() : _category!;
                              final brand = _brandController.text.trim();
                              final price = _priceController.text.trim();
                              final description = _detailsController.text.trim();
                              final quantity = _quantityController.text.trim();
                              final branch = _branchController.text.trim();
                              final productSize = _selectedSize!;
                              final productSizeSystem = _selectedSystem!;
                              final color = _color == 'Other' ? _colorController.text.trim() : _color!;

                              final todo = Product(
                                productId: productId!,
                                category: category,
                                productSize: int.parse(_selectedSize!),
                                sizeSystem: productSizeSystem,
                                productTitle: title,
                                productBrand: brand,
                                color: color,
                                productPrice: price,
                                productDetails: description,
                                productQuantity: int.parse(quantity),
                                userId: FirebaseAuth.instance.currentUser!.uid,
                                barcodeId: barcodeData!,
                                barcodeUrl: '',
                                qrcodeUrl: '',
                                productImage: '',
                                branch: branch,
                                type: '',
                              );
                              await ProductProvider().addProduct(todo, _imageFile!, barcodeImageUrl!, qrCodeImageUrl!);
                              // if (_imageFile != null) {
                              //   ProductProvider().uploadImage(productId!, _imageFile!);
                              // }
                              _showMsg('You have added a new stock!', true);
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
                                _selectedSize = null;
                              });
                            }
                            else{
                              _showMsg('No stock was added!', false);
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