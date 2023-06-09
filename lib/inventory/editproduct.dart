import 'dart:io';
import 'package:shoes_inventory_ms/model/constant.dart';
import 'package:shoes_inventory_ms/model/productmodel.dart';
import 'package:shoes_inventory_ms/model/productprovider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  late String _imageF;
  late String _details;
  String? _shoeSize;
  String? _category;
  String? _color;
  String? _selectedColor;
  String? _selectedCategory;
  late String _branch;
  File? _imageFile;
  File? _image;
  String? _selectedSize;
  late int _quantity;
  bool _isOtherCategorySelected = false;
  bool _isOtherColorSelected = false;
  String? _selectedSystem;
  final _colorController = TextEditingController();
  final List<String> usSizes = [
    '5',
    '5.5',
    '6',
    '6.5',
    '7',
    '7.5',
    '8',
    '8.5',
    '9'
  ];
  final List<String> ukSizes = [
    '4.5',
    '5',
    '5.5',
    '6',
    '6.5',
    '7',
    '7.5',
    '8',
    '8.5'
  ];
  final List<String> euSizes = [
    '37',
    '37.5',
    '38',
    '38.5',
    '39',
    '40',
    '40.5',
    '41',
    '42'
  ];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _title = widget.todo.productTitle;
    _category = widget.todo.category;
    _color = widget.todo.color;
    _selectedSystem = widget.todo.sizeSystem;
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
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Image.network(_imageF
                                              // loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                              //   if (loadingProgress == null) return child;
                                              //   return Center(
                                              //     child: Positioned(
                                              //       bottom: 5,
                                              //       right: 5,
                                              //       child: IconButton(
                                              //         icon: const Icon(Icons.edit),
                                              //         onPressed: _pickImage,
                                              //       ),
                                              //     ),
                                              //   );
                                              // },
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
                                  errorBuilder: (BuildContext context,
                                      Object exception,
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
                      // DropdownButtonFormField<String>(
                      //   decoration: const InputDecoration(
                      //     labelText: 'Category',
                      //   ),
                      //   value: _category,
                      //   onChanged: (String? value) {
                      //     setState(() {
                      //       if (value == 'Other') {
                      //         _isOtherCategorySelected = true;
                      //       } else {
                      //         _category = value!;
                      //         _isOtherCategorySelected = false;
                      //       }
                      //     });
                      //   },
                      //   items: const <DropdownMenuItem<String>>[
                      //     DropdownMenuItem<String>(
                      //       value: '',
                      //       child: Text(''),
                      //     ),
                      //     DropdownMenuItem<String>(
                      //       value: 'Basketball Shoes',
                      //       child: Text('Basketball Shoes'),
                      //     ),
                      //     DropdownMenuItem<String>(
                      //       value: 'Men Shoes',
                      //       child: Text('Men Shoes'),
                      //     ),
                      //     DropdownMenuItem<String>(
                      //       value: 'Other',
                      //       child: Text('Other'),
                      //     ),
                      //   ],
                      // ),
                      // if (_isOtherCategorySelected)
                      //   TextFormField(
                      //     initialValue: _category,
                      //     onChanged: (value) {
                      //       setState(() {
                      //         _category = value;
                      //       });
                      //     },
                      //     decoration: const InputDecoration(
                      //         hintText: 'Category', labelText: 'Category'),
                      //     validator: (value) {
                      //       return (value == '') ? "Category" : null;
                      //     },
                      //   ),
                      const SizedBox(height: 16.0),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Men Size',
                        ),
                        value: _selectedSystem,
                        onChanged: (String? value) {
                          setState(() {
                            _selectedSystem = value;
                            _selectedSize =
                                null; // Reset selected size when changing the system
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
                            Text('Selected size: $_shoeSize'),
                            const SizedBox(height: 16),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: (_selectedSystem == 'US')
                                    ? usSizes.map((size) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                _selectedSize = size;
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary:
                                                  _selectedSize == _shoeSize &&
                                                          _selectedSize == size
                                                      ? Colors.green
                                                      : null,
                                            ),
                                            child: Text(size),
                                          ),
                                        );
                                      }).toList()
                                    : (_selectedSystem == 'UK')
                                        ? ukSizes.map((size) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _selectedSize = size;
                                                  });
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  primary: _selectedSize ==
                                                              _shoeSize &&
                                                          _selectedSize == size
                                                      ? Colors.green
                                                      : null,
                                                ),
                                                child: Text(size),
                                              ),
                                            );
                                          }).toList()
                                        : euSizes.map((size) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _selectedSize = size;
                                                  });
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  primary: _selectedSize ==
                                                              _shoeSize &&
                                                          _selectedSize == size
                                                      ? Colors.green
                                                      : null,
                                                ),
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
                            value: 'Other',
                            child: Text('Other'),
                          ),
                          DropdownMenuItem<String>(
                            value: '',
                            child: Text(''),
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
                      const SizedBox(height: 16.0),
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
                        decoration: const InputDecoration(
                            hintText: "0.00", labelText: 'Price'),
                        onChanged: (value) {
                          setState(() {
                            _price = int.parse(value);
                          });
                        },
                      ),
                      // const SizedBox(
                      //   height: 20,
                      // ),
                      // const Text('Price'),
                      // const SizedBox(height: 8.0),
                      // TextFormField(
                      //   initialValue: _price.toString(),
                      //   onChanged: (value) {
                      //     setState(() {
                      //       _price = int.parse(value);
                      //     });
                      //   },
                      //   decoration: const InputDecoration(
                      //     hintText: 'Enter Price',
                      //   ),
                      // ),
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
                        decoration: const InputDecoration(
                            hintText: "0", labelText: 'Quantity'),
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
                      ElevatedButton(
                        onPressed: () {
                          final color = _color == 'Other' ? _colorController.text.trim() : _color!;

                          if (_formKey.currentState!.validate()) {
                            final updatedTodo = widget.todo.copyWith(
                              productTitle: _title,
                              productPrice: int.parse(_price as String),
                              category: _category,
                              productSize: _selectedSize!,
                              sizeSystem: _selectedSystem,
                              color: color,
                              productDetails: _details,
                              productQuantity: _quantity,
                              branch: _branch,
                              // barcodeUrl: '',
                              // qrcodeUrl: '',
                              // productImage: '',
                            );
                            ProductProvider().updateProduct(updatedTodo);
                            if (_imageFile != null) {
                              ProductProvider().uploadImage(
                                  widget.todo.productId, _imageFile!);
                            }
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
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 17)),
                            )),
                      )
                    ]))));
  }
}
