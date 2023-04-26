import 'package:firebase_login_auth/model/productmodel.dart';
import 'package:firebase_login_auth/model/productprovider.dart';
import 'package:flutter/material.dart';

class EditProduct extends StatefulWidget {
  final Product todo;

  const EditProduct({super.key, required this.todo});

  @override
  // ignore: library_private_types_in_public_api
  _EditProductState createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  late String _title;
  late String _description;

  @override
  void initState() {
    super.initState();
    _title = widget.todo.productTitle;
    _description = widget.todo.productPrice;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Todo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16.0),
            const Text('Title'),
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
            const Text('Description'),
            const SizedBox(height: 8.0),
            TextFormField(
              initialValue: _description,
              onChanged: (value) {
                setState(() {
                  _description = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Enter description',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                final updatedTodo = widget.todo.copyWith(
                  productTitle: _title,
                  productPrice: _description,
                  barcodeUrl: '',
                  qrcodeUrl: '',
                );
                ProductProvider().updateProduct(updatedTodo);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
