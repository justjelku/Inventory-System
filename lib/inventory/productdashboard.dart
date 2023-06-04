import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shoes_inventory_ms/inventory/productout.dart';
import 'package:shoes_inventory_ms/model/constant.dart';
import 'package:shoes_inventory_ms/inventory/addproduct.dart';
import 'package:shoes_inventory_ms/inventory/productin.dart';
import 'package:shoes_inventory_ms/model/productprovider.dart';
import 'package:shoes_inventory_ms/pages/qrscan.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoes_inventory_ms/pages/scannerpage.dart';
import 'package:shoes_inventory_ms/pages/searchfriend.dart';
import 'package:shoes_inventory_ms/pages/searchpage.dart';
import 'package:rxdart/rxdart.dart';


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
            backgroundColor: mainTextColor,
            title: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                'Dashboard',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.business_sharp, color: darkBlue),
                onPressed: () {
                  // Handle scan button press here
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchFriendPage()),
                  );
                },
              ),
              Container(
                padding: const EdgeInsets.only(right: 20.0),
                child: IconButton(
                  icon: Icon(Icons.search, color: darkBlue),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SearchPage()),
                    );
                  },
                ),
              ),
            ],
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
              padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          StreamBuilder<int>(
                            stream: getProductInCount(FirebaseAuth.instance.currentUser!.uid),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final productCount = snapshot.data!;
                                return _buildButton(
                                  context,
                                  icon: Icons.stacked_line_chart,
                                  text: 'Product In $productCount',
                                  color: Colors.blue,
                                  onPressed: () {
                                    // Navigate to the View Products screen
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const ProductIn(),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return const SizedBox.shrink();
                              }
                            },
                          ),
                          StreamBuilder<int>(
                            stream: getStockOutCount(FirebaseAuth.instance.currentUser!.uid),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final productCount = snapshot.data!;
                                return _buildButton(
                                  context,
                                  icon: Icons.stacked_bar_chart,
                                  text: 'Stock Out $productCount',
                                  color: Colors.red,
                                  onPressed: () {
                                    // Navigate to the View Products screen
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const ProductOut(),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return const SizedBox.shrink();
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          StreamBuilder<int>(
                            stream: getStockInCount(FirebaseAuth.instance.currentUser!.uid),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final productCount = snapshot.data!;
                                return _buildButton(
                                  context,
                                  icon: Icons.add_shopping_cart,
                                  text: 'Stock In $productCount',
                                  color: Colors.cyan,
                                  onPressed: () {
                                    // Navigate to the View Products screen
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (context) => const ProductIn(),
                                    //   ),
                                    // );
                                  },
                                );
                              } else {
                                return const SizedBox.shrink();
                              }
                            },
                          ),
                          StreamBuilder<int>(
                            stream: getProductCount(FirebaseAuth.instance.currentUser!.uid),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final productCount = snapshot.data!;
                                return _buildButton(
                                  context,
                                  icon: Icons.inventory,
                                  text: 'Total Products $productCount',
                                  color: Colors.green,
                                  onPressed: () {
                                    // Navigate to the View Products screen
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (context) => const ProductOut(),
                                    //   ),
                                    // );
                                  },
                                );
                              } else {
                                return const SizedBox.shrink();
                              }
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
                              tileColor: const Color(0xff1c2541),
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
              ],
            ),
          ),
        );
      }
    );
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

  Stream<int> getProductInCount(String userId) {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(userId);

    final todoCollection = userRef.collection('products');

    return todoCollection.snapshots().map((querySnapshot) {
      int totalQuantity = 0;
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        int productQuantity = data['productQuantity'];
        totalQuantity += productQuantity;
      }
      return totalQuantity;
    });
  }

  Stream<int> getProductCount(String userId) {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(userId);

    final todoCollection = userRef.collection('products');
    final soldProductsCollection = userRef.collection('sold_products');

    final todoCountStream = todoCollection.snapshots().map((querySnapshot) {
      int totalQuantity = 0;
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        int productQuantity = data['productQuantity'];
        totalQuantity += productQuantity;
      }
      return totalQuantity;
    });

    final soldCountStream = soldProductsCollection.snapshots().map((querySnapshot) {
      int totalQuantity = 0;
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        int productQuantity = data['productQuantity'];
        totalQuantity += productQuantity;
      }
      return totalQuantity;
    });

    return Rx.combineLatest<int, int>([todoCountStream, soldCountStream], (values) {
      return values.fold(0, (previousValue, element) => previousValue + element);
    });
  }




  Stream<int> getStockOutCount(String userId) {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(userId);

    final soldProductsCollection = userRef.collection('stock_out');

    return soldProductsCollection.snapshots().map((querySnapshot) {
      int totalQuantity = 0;
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        int productQuantity = data['productQuantity'];
        totalQuantity += productQuantity;
      }
      return totalQuantity;
    });
  }

  Stream<int> getStockInCount(String userId) {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(userId);

    final soldProductsCollection = userRef.collection('stock_in');

    return soldProductsCollection.snapshots().map((querySnapshot) {
      int totalQuantity = 0;
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        int productQuantity = data['productQuantity'];
        totalQuantity += productQuantity;
      }
      return totalQuantity;
    });
  }



  Stream<int> getProductSales(String userId) {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(userId);

    final soldProductsCollection = userRef.collection('sold_products');

    return soldProductsCollection.snapshots().map((querySnapshot) {
      double totalSales = 0.0;
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        var productQuantity = data['productQuantity'];
        var productPrice = data['productPrice'];
        totalSales += productPrice * productQuantity;
      }
      return totalSales.toInt();
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
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final branch = data['branch'] as String?;
        final productQuantity = data['productQuantity'] as int?;
        if (branch != null && branch.isNotEmpty && productQuantity != null && productQuantity > 0) {
          if (branchProductCountMap.containsKey(branch)) {
            branchProductCountMap[branch] = branchProductCountMap[branch]! + 1;
          } else {
            branchProductCountMap[branch] = 1;
          }
        }
      }
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
      for (var doc in querySnapshot.docs) {
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
      }

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
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final branch = data['branch'] as String?;
        final productId = doc.id;

        if (branch != null) {
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
      }

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
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final branch = data['branch'] as String?;
        final productId = doc.id;
        final productName = data['name'] as String?;
        final productQuantity = data['quantity'] as int?;

        if (branch != null && branch.isNotEmpty && productName != null && productQuantity != null) {
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
      }
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
