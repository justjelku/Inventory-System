// ignore_for_file: library_private_types_in_public_api
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_login_auth/inventory/addproduct.dart';
import 'package:firebase_login_auth/inventory/editproduct.dart';
import 'package:firebase_login_auth/model/productmodel.dart';
import 'package:firebase_login_auth/model/productprovider.dart';
import 'package:firebase_login_auth/pages/barcode.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: duplicate_ignore
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
          value: ProductProvider().getProduct(FirebaseAuth.instance.currentUser!.uid),
          initialData: const [], // Use an empty list as the initial data
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
          builder: (context, prod, child) {
            if (prod.isEmpty) {
              return const Center(
                child: Text('No products found.'),
              );
            }
            return ListView.builder(
              itemCount: prod.length,
              itemBuilder: (context, index) {
                final item = prod[index];
                return Column(
                  children: [
                    // const SizedBox(
                    //   height: 20,
                    // ),
                    // BarcodeWidget(
                    //   barcode: Barcode.code128(),
                    //   data: item.barcodeId,
                    //   width: 200,
                    //   height: 100,
                    //   drawText: true,
                    // ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(item.productTitle),
                        subtitle: Text('\$${item.productPrice}.00', style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold, fontSize: 20,
                        ),),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.action == 'view') Checkbox(
                              value: item.completed,
                              onChanged: (newValue) {
                                setState(() {
                                  item.completed = newValue!;
                                });
                                ProductProvider().updateProduct(item);
                              },
                            ),
                            if (widget.action == 'edit') IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProduct(
                                      todo: item,
                                    ),
                                  ),
                                );
                              },
                            ),
                            if (widget.action == 'delete') IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                ProductProvider().deleteProduct(item.productId);
                              },
                            ),
                          ],
                        ),
                        onTap: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BarcodePage(
                                  todo: item,
                                ),
                              ),
                          );
                        },
                      ),
                    ),
                    const Divider(
                      height: 5,
                      thickness: 5,
                    )
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
