import 'package:barcode_widget/barcode_widget.dart';
import 'package:firebase_login_auth/todo/addproduct.dart';
import 'package:firebase_login_auth/todo/editproduct.dart';
import 'package:firebase_login_auth/todo/productmodel.dart';
import 'package:firebase_login_auth/todo/productprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductList extends StatefulWidget {
  final String action;

  const ProductList({required this.action, Key? key}) : super(key: key);

  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<List<Product>>(
          create: (_) => [], // Initialize an empty list
        ),
        StreamProvider<List<Product>>.value(
          value: ProductProvider().todoStream,
          initialData: [], // Use an empty list as the initial data
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              widget.action == 'edit'
                  ? 'Edit Products'
                  : widget.action == 'delete'
                  ? 'Delete Products'
                  : 'Products'
          ),
        ),
        body: Consumer<List<Product>>(
          builder: (context, todos, child) {
            if (todos.isEmpty) {
              return const Center(
                child: Text('No products found.'),
              );
            }
            return ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    BarcodeWidget(
                      barcode: Barcode.code128(),
                      data: todo.barcodeId,
                      width: 200,
                      height: 100,
                      drawText: true,
                    ),
                    ListTile(
                      title: Text(todo.productTitle),
                      subtitle: Text(todo.productPrice),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.action == 'view') Checkbox(
                            value: todo.completed,
                            onChanged: (newValue) {
                              setState(() {
                                todo.completed = newValue!;
                              });
                              ProductProvider().updateProduct(todo);
                            },
                          ),
                          if (widget.action == 'edit') IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProduct(
                                    todo: todo,
                                  ),
                                ),
                              );
                            },
                          ),
                          if (widget.action == 'delete') IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              ProductProvider().deleteProduct(todo.productId);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
        floatingActionButton: widget.action == 'view'
            ? FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddProduct(),
              ),
            );
          },
        )
            : null,
      ),
    );
  }
}
