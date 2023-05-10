import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shoes_inventory_ms/model/constant.dart';
import 'package:shoes_inventory_ms/inventory/addproduct.dart';
import 'package:shoes_inventory_ms/inventory/productlist.dart';
import 'package:shoes_inventory_ms/model/productprovider.dart';
import 'package:shoes_inventory_ms/pages/qrscan.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductDashboard extends StatelessWidget {
  const ProductDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final String? userName = FirebaseAuth.instance.currentUser!.uid;

    final userRef = FirebaseFirestore.instance.collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    return FutureBuilder<DocumentSnapshot>(
        future: userRef.get(),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Error retrieving user data.');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final data = snapshot.data?.data() as Map<String, dynamic>;
          String userName = data['username'] as String? ?? '';
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            // leading: const Icon(Icons.menu, color: Colors.black,),
            backgroundColor: mainTextColor,
            title: Padding(
              padding: const EdgeInsets.all(10),
              child: Text('Dashboard',
                style: TextStyle(
                    color: secondaryTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                ),
              ),
            ),
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.qr_code),
                          onPressed: () {
                            // Handle scan button press here
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QRCodeScanner(),
                              ),
                            );
                          },
                        ),
                        const Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Product ID',
                              suffixIcon: Icon(Icons.search),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          StreamBuilder<int>(
                            stream: getProductCount(FirebaseAuth.instance.currentUser!.uid),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final productCount = snapshot.data!;
                                return _buildButton(
                                  context,
                                  icon: Icons.stacked_line_chart,
                                  text: 'Product In ($productCount)',
                                  color: Colors.blue,
                                  onPressed: () {
                                    // Navigate to the View Products screen
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const ProductList(action: 'view'),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return const SizedBox.shrink();
                              }
                            },
                          ),
                          _buildButton(
                            context,
                            icon: Icons.delete_outline,
                            text: 'Product Out',
                            color: Colors.red,
                            onPressed: () {
                              // Navigate to the Delete Products screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProductList(action: 'delete'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                StreamBuilder<Map<String, int>>(
                  stream: getBranchCount(FirebaseAuth.instance.currentUser!.uid),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final branchProductCountMap = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap : true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: branchProductCountMap.length,
                        itemBuilder: (context, index) {
                          final branchName = branchProductCountMap.keys.toList()[index];
                          final productCount = branchProductCountMap[branchName]!;
                          return Padding(
                            padding: const EdgeInsets.all(10),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              tileColor: const Color(0xFF3a506b),
                              iconColor: Colors.white,
                              textColor: Colors.white,
                              title: Text(branchName),
                              trailing: Text('$productCount Products'),
                            ),
                          );
                        },
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
                // const SizedBox(height: 10),
                // Row(
                //   children: [
                //     FutureBuilder<List<Map<String, dynamic>>>(
                //       future: ProductProvider().getProductList(FirebaseAuth.instance.currentUser!.uid),
                //       builder: (context, snapshot) {
                //         if (snapshot.connectionState == ConnectionState.waiting) {
                //           return const Center(child: CircularProgressIndicator());
                //         } else if (snapshot.hasError) {
                //           return Center(child: Text('Error: ${snapshot.error}'));
                //         } else {
                //           final productList = snapshot.data!;
                //           return ListView.builder(
                //             shrinkWrap : true,
                //             physics: const NeverScrollableScrollPhysics(),
                //             itemCount: productList.length,
                //             itemBuilder: (context, index) {
                //               final product = productList[index];
                //               return ListTile(
                //                 title: Text(product['productTitle']),
                //                 subtitle: Text('\$${product['productPrice']}'),
                //               );
                //             },
                //           );
                //         }
                //       },
                //     ),
                //   ],
                // ),
                // // Wrap the FutureBuilder in a SizedBox with fixed height
                // // SizedBox(
                // //   height: 300,
                // //   child: FutureBuilder<Map<String, int>>(
                // //     future: getAllProductQuantities(FirebaseAuth.instance.currentUser!.uid),
                // //     builder: (context, snapshot) {
                // //       if (snapshot.hasData) {
                // //         final productQuantityMap = snapshot.data!;
                // //         final productList = productQuantityMap.keys.toList();
                // //         return ListView.builder(
                // //           itemCount: productList.length,
                // //           itemBuilder: (context, index) {
                // //             final productName = productList[index];
                // //             final productQuantity = productQuantityMap[productName]!;
                // //             print('Prod: ${productName}');
                // //             return ListTile(
                // //               title: Text(productName),
                // //               trailing: Text(productQuantity.toString()),
                // //             );
                // //           },
                // //         );
                // //       } else if (snapshot.hasError) {
                // //         return Text('Error: ${snapshot.error}');
                // //       } else {
                // //         return Center(child: CircularProgressIndicator());
                // //       }
                // //     },
                // //   ),
                // // ),
                // // // StreamBuilder<Map<String, Map<String, int>>>(
                // // //   stream: getBranchProductQuantities(FirebaseAuth.instance.currentUser!.uid),
                // // //   builder: (context, snapshot) {
                // // //     if (snapshot.hasData) {
                // // //       final branchProductQuantityMap = snapshot.data!;
                // // //       // final branchList = branchProductQuantityMap.keys.toList();
                // // //       if (branchProductQuantityMap.isNotEmpty) {
                // // //         print(branchProductQuantityMap);
                // // //       }
                // // //       return ListView.builder(
                // // //         shrinkWrap: true,
                // // //         physics: const NeverScrollableScrollPhysics(),
                // // //         itemCount: branchProductQuantityMap.length,
                // // //         itemBuilder: (context, index) {
                // // //           final branchName = branchProductQuantityMap.keys.toList()[index];
                // // //           final productQuantityMap = branchProductQuantityMap[branchName]!;
                // // //           final productQuantityList = productQuantityMap.entries.toList();
                // // //           return Column(
                // // //             crossAxisAlignment: CrossAxisAlignment.start,
                // // //             children: [
                // // //               const SizedBox(height: 10),
                // // //               Text(
                // // //                 branchName,
                // // //                 style: Theme.of(context).textTheme.subtitle1,
                // // //               ),
                // // //               const SizedBox(height: 5),
                // // //               ListView.builder(
                // // //                 shrinkWrap: true,
                // // //                 physics: const NeverScrollableScrollPhysics(),
                // // //                 itemCount: productQuantityList.length,
                // // //                 itemBuilder: (context, index) {
                // // //                   final productQuantityEntry = productQuantityList[index];
                // // //                   final productName = productQuantityEntry.key;
                // // //                   final productQuantity = productQuantityEntry.value;
                // // //                   return ListTile(
                // // //                     shape: RoundedRectangleBorder(
                // // //                         borderRadius: BorderRadius.circular(20)
                // // //                     ),
                // // //                     tileColor: const Color(0xFF3a506b),
                // // //                     iconColor: Colors.white,
                // // //                     textColor: Colors.white,
                // // //                     title: Text('Product: ${productName}'),
                // // //                     trailing: Text('Quantity: ${productQuantity.toString()}'),
                // // //                   );
                // // //                 },
                // // //               ),
                // // //             ],
                // // //           );
                // // //         },
                // // //       );
                // // //     } else {
                // // //       return const SizedBox.shrink();
                // // //     }
                // // //   },
                // // // ),
              ],
            ),
          ),
        );
      }
    );
  }

  Future<Map<String, int>> getAllProductQuantities(String userId) async {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(userId);

    final todoCollection = userRef.collection('products');

    final querySnapshot = await todoCollection.get();

    final productQuantityMap = <String, int>{};
    querySnapshot.docs.forEach((doc) {
      final data = doc.data();
      final productName = data['name'] as String?;
      final productQuantity = data['quantity'] as int?;

      if (productName != null && productQuantity != null) {
        if (productQuantityMap.containsKey(productName)) {
          productQuantityMap[productName] = productQuantityMap[productName]! + productQuantity;
        } else {
          productQuantityMap[productName] = productQuantity;
        }
      }
    });
    return productQuantityMap;
  }


  Widget _buildButton(
      BuildContext context, {
        required IconData icon,
        required String text,
        required Color color,
        required VoidCallback onPressed,
      }) {
    return SizedBox(
      width: 150,
      height: 150,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          primary: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
            ),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Stream<int> getProductCount(String userId) {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(userId);

    final todoCollection = userRef.collection('products');

    return todoCollection.snapshots().map((querySnapshot) {
      final productIds = Set<String>();
      querySnapshot.docs.forEach((doc) {
        productIds.add(doc.id);
      });
      return productIds.length;
    });
  }
  Stream<Map<String, int>> getBranchCount(String userId) {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(userId);

    final todoCollection = userRef.collection('products');

    return todoCollection.snapshots().map((querySnapshot) {
      final branchProductCountMap = <String, int>{};
      querySnapshot.docs.forEach((doc) {
        final data = doc.data();
        final branch = data['branch'] as String?;
        if (branch != null && branch.isNotEmpty) {
          if (branchProductCountMap.containsKey(branch)) {
            branchProductCountMap[branch] = branchProductCountMap[branch]! + 1;
          } else {
            branchProductCountMap[branch] = 1;
          }
        }
      });
      return branchProductCountMap;
    });
  }
  Stream<List<Map<String, dynamic>>> getProductsGroupedByBranch(String userId) {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(userId);

    final todoCollection = userRef.collection('products');

    return todoCollection.snapshots().map((querySnapshot) {
      final branchProductCountMap = <String, Map<String, int>>{};
      querySnapshot.docs.forEach((doc) {
        final data = doc.data();
        final branch = data['branch'] as String?;
        final product = data['product'] as String?;
        final quantity = data['quantity'] as int?;

        if (branch != null && product != null && quantity != null) {
          if (!branchProductCountMap.containsKey(branch)) {
            branchProductCountMap[branch] = <String, int>{};
          }

          if (branchProductCountMap[branch]!.containsKey(product)) {
            branchProductCountMap[branch]![product] = branchProductCountMap[branch]![product]! + quantity;
          } else {
            branchProductCountMap[branch]![product] = quantity;
          }
        }
      });

      final branchProductCountList = <Map<String, dynamic>>[];
      branchProductCountMap.forEach((branch, productQuantityMap) {
        productQuantityMap.forEach((product, quantity) {
          branchProductCountList.add({
            'branch': branch,
            'product': product,
            'count': quantity,
          });
        });
      });

      return branchProductCountList;
    });
  }
  Stream<Map<String, Map<String, int>>> getProductQuantitiesByBranch(String userId) {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(userId);

    return userRef.collection('products').snapshots().map((querySnapshot) {
      final branchProductQuantityMap = <String, Map<String, int>>{};
      querySnapshot.docs.forEach((doc) {
        final data = doc.data();
        final branch = data['branch'] as String?;
        final productId = doc.id;

        if (branch != null && productId != null) {
          FirebaseFirestore.instance
              .collection('products')
              .doc(productId)
              .get()
              .then((productSnapshot) {
            final productData = productSnapshot.data();
            final productName = productData?['name'] as String?;
            final productQuantity = productData?['quantity'] as int?;

            if (productName != null && productQuantity != null) {
              if (branchProductQuantityMap.containsKey(branch)) {
                final productQuantityMap = branchProductQuantityMap[branch]!;
                if (productQuantityMap.containsKey(productName)) {
                  productQuantityMap[productName] =
                      productQuantityMap[productName]! + productQuantity;
                } else {
                  productQuantityMap[productName] = productQuantity;
                }
              } else {
                branchProductQuantityMap[branch] = {productName: productQuantity};
              }
            }
          });
        }
      });

      return branchProductQuantityMap;
    });
  }
  Stream<Map<String, Map<String, int>>> getBranchProductQuantities(String userId) {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(userId);

    final todoCollection = userRef.collection('products');

    return todoCollection.snapshots().map((querySnapshot) {
      final branchProductQuantityMap = <String, Map<String, int>>{};
      querySnapshot.docs.forEach((doc) {
        final data = doc.data();
        final branch = data['branch'] as String?;
        final productId = doc.id;
        final productName = data['name'] as String?;
        final productQuantity = data['quantity'] as int?;

        if (branch != null && branch.isNotEmpty && productId != null && productName != null && productQuantity != null) {
          if (branchProductQuantityMap.containsKey(branch)) {
            final productQuantityMap = branchProductQuantityMap[branch]!;
            if (productQuantityMap.containsKey(productName)) {
              productQuantityMap[productName] = productQuantityMap[productName]! + productQuantity;
            } else {
              productQuantityMap[productName] = productQuantity;
            }
          } else {
            branchProductQuantityMap[branch] = {productName: productQuantity};
          }
        }
      });
      return branchProductQuantityMap;
    }).map((branchProductQuantityMap) {
      final newBranchProductQuantityMap = <String, Map<String, int>>{};
      branchProductQuantityMap.forEach((branch, productQuantityMap) {
        final newProductQuantityMap = <String, int>{};
        productQuantityMap.forEach((productName, productQuantity) {
          final existingProductQuantity = newProductQuantityMap[productName] ?? 0;
          newProductQuantityMap[productName] = existingProductQuantity + productQuantity;
        });
        newBranchProductQuantityMap[branch] = newProductQuantityMap;
      });
      return newBranchProductQuantityMap;
    });
  }
}
