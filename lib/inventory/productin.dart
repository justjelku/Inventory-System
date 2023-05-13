// ignore_for_file: library_private_types_in_public_api
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shoes_inventory_ms/inventory/addproduct.dart';
import 'package:shoes_inventory_ms/inventory/editproduct.dart';
import 'package:shoes_inventory_ms/inventory/productdetails.dart';
import 'package:shoes_inventory_ms/model/constant.dart';
import 'package:shoes_inventory_ms/model/productmodel.dart';
import 'package:shoes_inventory_ms/model/productprovider.dart';
import 'package:shoes_inventory_ms/pages/barcode.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: duplicate_ignore
class ProductIn extends StatefulWidget {

  const ProductIn({Key? key}) : super(key: key);

  @override
  _ProductInState createState() => _ProductInState();
}

class _ProductInState extends State<ProductIn> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<List<Product>>(
          create: (_) => [], // Initialize an empty list
        ),
        StreamProvider<List<Product>>.value(
          value: ProductProvider()
              .getProduct(FirebaseAuth.instance.currentUser!.uid, includeOutOfStock: false),
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
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: Image.network(item.productImage),
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
                                value: 'view',
                                child: ListTile(
                                  leading: Icon(Icons.info),
                                  title: Text('Info'),
                                ),
                              ),
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
                                case 'view':
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetailsPage(
                                        product: item,
                                      ),
                                    ),
                                  );
                                  break;
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
