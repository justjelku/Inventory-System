// ignore_for_file: library_private_types_in_public_api
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_login_auth/inventory/addproduct.dart';
import 'package:firebase_login_auth/inventory/editproduct.dart';
import 'package:firebase_login_auth/model/constant.dart';
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
          value: ProductProvider()
              .getProduct(FirebaseAuth.instance.currentUser!.uid),
          initialData: const [], // Use an empty list as the initial data
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Products'),
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
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          // add your code here for when the image is tapped
                        },
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: mainTextColor,
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Image.network(item.productImage)
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(item.productTitle),
                          subtitle: Text('\$${item.productPrice}.00',
                              style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold, fontSize: 20,
                            ),
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                              const PopupMenuItem(
                                value: 'edit',
                                child: ListTile(
                                  leading: Icon(Icons.edit),
                                  title: Text('Edit'),
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: ListTile(
                                  leading: Icon(Icons.delete),
                                  title: Text('Delete'),
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              switch (value) {
                                case 'edit':
                                  Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => EditProduct(
                                                  todo: item,
                                                ),
                                              ),
                                            );
                                  break;
                                case 'delete':
                                  ProductProvider().deleteProduct(item.productId);
                                  break;
                                default:
                                  break;
                              }
                            },
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
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
