import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shoes_inventory_ms/model/constant.dart';
import 'package:shoes_inventory_ms/inventory/addproduct.dart';
import 'package:shoes_inventory_ms/inventory/productin.dart';
import 'package:shoes_inventory_ms/model/productprovider.dart';
import 'package:shoes_inventory_ms/pages/qrscan.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:shoes_inventory_ms/model/userstatistics.dart';


class AdminHomePage extends StatelessWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final String? userName = FirebaseAuth.instance.currentUser!.uid;

    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users');

    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: userRef.get(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasError) {
            return const Text('Error retrieving user data.');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final users = snapshot.data!.docs;
          List<Map<String, dynamic>> userIds =
              users.map((doc) => doc.data()).toList();

          final int userCount = users.length;

          // Generate user statistics for the chart
          final List<UserStatistic> userStatistics = [];
          // You can modify this part based on your requirements, e.g., monthly statistics
          userStatistics.add(UserStatistic('Jan', 20));
          userStatistics.add(UserStatistic('Feb', 30));
          userStatistics.add(UserStatistic('Mar', 15));
          // ...

          // Create the series data for the chart
          final List<UserStatistic> chartData = userStatistics.map((statistic) {
            return UserStatistic(statistic.month, statistic.userCount);
          }).toList();

          final userRef = FirebaseFirestore.instance
              .collection('users')
              .doc('qIglLalZbFgIOnO0r3Zu')
              .collection('basic_users')
              .doc()
              .collection('products');
          
          

          // final data = snapshot.data?.data() as Map<String, dynamic>;
          // String userName = data['username'] as String? ?? '';
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              // leading: const Icon(Icons.menu, color: Colors.black,),
              backgroundColor: mainTextColor,
              title: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  'Registered Users',
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
              ),
              automaticallyImplyLeading: false,
              centerTitle: true,
            ),
            body: ListView.builder(
              itemCount: userIds.length,
              itemBuilder: (BuildContext context, int index) {
                final firstName = userIds[index]['first name'];
                final username = userIds[index]['username'];
                final userId = userIds[index]['userId'];

                return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  future: userRef.doc(userId).collection('products').get(),
                  builder: (
                      BuildContext context,
                      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
                      ) {
                    if (snapshot.hasError) {
                      return const Text('Error retrieving product data.');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final products = snapshot.data!.docs;
                    List<Map<String, dynamic>> productList =
                    products.map((doc) => doc.data()).toList();

                    return Column(
                      children: [
                        // Expanded(
                        //   child: Padding(
                        //     padding: const EdgeInsets.all(8.0),
                        //     child: SfCartesianChart(
                        //         primaryXAxis: CategoryAxis(),
                        //         // Chart title
                        //         title: ChartTitle(text: 'Half yearly sales analysis'),
                        //         // Enable legend
                        //         legend: Legend(isVisible: true),
                        //         // Enable tooltip
                        //         tooltipBehavior: TooltipBehavior(enable: true),
                        //         series: <ChartSeries<UserStatistic, String>>[
                        //           LineSeries<UserStatistic, String>(
                        //               dataSource: userStatistics,
                        //               xValueMapper: (UserStatistic sales, _) => sales.month,
                        //               yValueMapper: (UserStatistic sales, _) => sales.userCount,
                        //               name: 'Sales',
                        //               // Enable data label
                        //               dataLabelSettings: const DataLabelSettings(isVisible: true))
                        //         ]),
                        //   ),
                        // ),
                        // Expanded(
                        //   child: Padding(
                        //     padding: const EdgeInsets.all(8.0),
                        //     //Initialize the spark charts widget
                        //     child: SfSparkLineChart.custom(
                        //       //Enable the trackball
                        //       trackball: const SparkChartTrackball(
                        //           activationMode: SparkChartActivationMode.tap),
                        //       //Enable marker
                        //       marker: const SparkChartMarker(
                        //           displayMode: SparkChartMarkerDisplayMode.all),
                        //       //Enable data label
                        //       labelDisplayMode: SparkChartLabelDisplayMode.all,
                        //       xValueMapper: (int index) => userStatistics[index].month,
                        //       yValueMapper: (int index) => userStatistics[index].userCount,
                        //       dataCount: 5,
                        //     ),
                        //   ),
                        // ),
                        GestureDetector(
                          onTap: () {
                            // Handle username tile clicked
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  backgroundColor: gradientEndColor,
                                  scrollable: true,
                                  title: Center(
                                    child: Text(
                                      username,
                                      style: TextStyle(
                                        color: mainTextColor,
                                      ),
                                    ),
                                  ),
                                  content: SingleChildScrollView(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      children: [
                                        Center(
                                          child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceEvenly,
                                                children: [
                                                  StreamBuilder<int>(
                                                    stream: getProductInCount(
                                                        userId),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot.hasData) {
                                                        final productCount =
                                                        snapshot.data!;
                                                        return _buildButton(
                                                          context,
                                                          icon: Icons
                                                              .stacked_line_chart,
                                                          text:
                                                          'Product In $productCount',
                                                          color: Colors.blue,
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
                                                        return const SizedBox
                                                            .shrink();
                                                      }
                                                    },
                                                  ),
                                                  const SizedBox(height: 30),
                                                  StreamBuilder<int>(
                                                    stream: getProductOutCount(
                                                        userId),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot.hasData) {
                                                        final productCount =
                                                        snapshot.data!;
                                                        return _buildButton(
                                                          context,
                                                          icon: Icons
                                                              .stacked_bar_chart,
                                                          text:
                                                          'Product Out $productCount',
                                                          color: Colors.red,
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
                                                        return const SizedBox
                                                            .shrink();
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
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceEvenly,
                                                children: [
                                                  StreamBuilder<int>(
                                                    stream:
                                                    getProductSales(userId),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot.hasData) {
                                                        final productCount =
                                                        snapshot.data!;
                                                        return _buildButton(
                                                          context,
                                                          icon: Icons.php,
                                                          text:
                                                          'Sales \₱$productCount',
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
                                                        return const SizedBox
                                                            .shrink();
                                                      }
                                                    },
                                                  ),
                                                  const SizedBox(height: 30),
                                                  StreamBuilder<
                                                      Map<String, int>>(
                                                    stream:
                                                    getProductCount(userId),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot.hasData) {
                                                        final productCount =
                                                        snapshot
                                                            .data!['count'];
                                                        return _buildButton(
                                                          context,
                                                          icon: Icons.inventory,
                                                          text:
                                                          'Total Products $productCount',
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
                                                        return const SizedBox
                                                            .shrink();
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              tileColor: const Color(0xff1c2541),
                              iconColor: Colors.white,
                              textColor: Colors.white,
                              title: Text(username),
                            ),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: productList.length,
                          itemBuilder: (BuildContext context, int index) {
                            final product = productList[index];
                            final productName = product['name'];
                            final productPrice = product['price'];
                            // Access other product fields here

                            return ListTile(
                              title: Text(productName),
                              subtitle: Text('Price: $productPrice'),
                              // Display other product fields as needed
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          );
        });
  }

  Future<Map<String, int>> getAllProductQuantities(String userId) async {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users');

    final userSnapshot = await userRef.doc(userId).get();
    if (!userSnapshot.exists) {
      return {}; // User not found, return an empty map
    }

    final todoCollection = userRef.doc(userId).collection('products');
    final querySnapshot = await todoCollection.get();

    final productQuantityMap = <String, int>{};
    querySnapshot.docs.forEach((doc) {
      final data = doc.data();
      final productName = data['name'] as String?;
      final productQuantity = data['quantity'] as int?;

      if (productName != null && productQuantity != null) {
        if (productQuantityMap.containsKey(productName)) {
          productQuantityMap[productName] =
              productQuantityMap[productName]! + productQuantity;
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

  Stream<int> getProductOutCount(String userId) {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(userId);

    final soldProductsCollection = userRef.collection('sold_products');

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

  Stream<Map<String, int>> getProductCount(String userId) {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(userId);

    final todoCollection = userRef.collection('products');
    final soldProductsCollection = userRef.collection('sold_products');

    final todoCountStream = todoCollection.snapshots().map((querySnapshot) {
      int totalQuantity = 0;
      List<String> userIds = []; // create an empty array to hold user ids
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        int productQuantity = data['productQuantity'];
        totalQuantity += productQuantity;
        if (data['basic_users'] != null) {
          for (String id in data['basic_users']) {
            if (!userIds.contains(id)) {
              // add new user ids to the array
              userIds.add(id);
            }
          }
        }
      }
      return {
        'count': totalQuantity,
        'userIds': userIds
      }; // return the count and user ids
    });

    final soldCountStream =
        soldProductsCollection.snapshots().map((querySnapshot) {
      int totalQuantity = 0;
      List<String> userIds = []; // create an empty array to hold user ids
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        int productQuantity = data['productQuantity'];
        totalQuantity += productQuantity;
        if (data['basic_users'] != null) {
          for (String id in data['basic_users']) {
            if (!userIds.contains(id)) {
              // add new user ids to the array
              userIds.add(id);
            }
          }
        }
      }
      return {
        'count': totalQuantity,
        'userIds': userIds
      }; // return the count and user ids
    });

    return Rx.combineLatest<Map<String, dynamic>, Map<String, int>>(
        [todoCountStream, soldCountStream], (values) {
      int totalCount = 0;
      List<String> userIds = [];
      for (var value in values) {
        totalCount += value['count'] as int;
        for (String id in value['userIds']) {
          if (!userIds.contains(id)) {
            userIds.add(id);
          }
        }
      }
      return {'count': totalCount, 'userIds': userIds.length};
    });
  }

  Stream<Map<String, int>> getBranchCount(String userId) {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users');

    final userSnapshot = userRef.doc(userId).snapshots();

    return userSnapshot.asyncMap((userDoc) async {
      if (userDoc.exists) {
        final todoCollection = userRef.doc(userId).collection('products');
        final querySnapshot = await todoCollection.get();
        final branchProductCountMap = <String, int>{};
        querySnapshot.docs.forEach((doc) {
          final data = doc.data();
          final branch = data['branch'] as String?;
          if (branch != null && branch.isNotEmpty) {
            if (branchProductCountMap.containsKey(branch)) {
              branchProductCountMap[branch] =
                  branchProductCountMap[branch]! + 1;
            } else {
              branchProductCountMap[branch] = 1;
            }
          }
        });
        return branchProductCountMap;
      } else {
        return <String, int>{};
      }
    });
  }

  Stream<List<Map<String, dynamic>>> getProductsGroupedByBranch(String userId) {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users');

    final userSnapshot = userRef.doc(userId).snapshots();

    return userSnapshot.asyncMap((userDoc) async {
      if (userDoc.exists) {
        final todoCollection = userRef.doc(userId).collection('products');
        final querySnapshot = await todoCollection.get();
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
              branchProductCountMap[branch]![product] =
                  branchProductCountMap[branch]![product]! + quantity;
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
      } else {
        return <Map<String, dynamic>>[];
      }
    });
  }

  Stream<Map<String, Map<String, int>>> getProductQuantitiesByBranch(
      String userId) {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users');

    final userSnapshot = userRef.doc(userId).snapshots();

    return userSnapshot.asyncMap((userDoc) async {
      if (userDoc.exists) {
        final productCollection =
            FirebaseFirestore.instance.collection('products');
        final todoCollection = userRef.doc(userId).collection('products');
        final querySnapshot = await todoCollection.get();
        final branchProductQuantityMap = <String, Map<String, int>>{};

        await Future.forEach(querySnapshot.docs, (doc) async {
          final data = doc.data();
          final branch = data['branch'] as String?;
          final productId = doc.id;

          if (branch != null && productId != null) {
            final productSnapshot =
                await productCollection.doc(productId).get();
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
                branchProductQuantityMap[branch] = {
                  productName: productQuantity
                };
              }
            }
          }
        });

        return branchProductQuantityMap;
      } else {
        return <String, Map<String, int>>{};
      }
    });
  }

  Stream<Map<String, Map<String, int>>> getBranchProductQuantities(
      String userId) {
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

        if (branch != null &&
            branch.isNotEmpty &&
            productId != null &&
            productName != null &&
            productQuantity != null) {
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

      final newBranchProductQuantityMap = <String, Map<String, int>>{};
      branchProductQuantityMap.forEach((branch, productQuantityMap) {
        final newProductQuantityMap = <String, int>{};
        productQuantityMap.forEach((productName, productQuantity) {
          final existingProductQuantity =
              newProductQuantityMap[productName] ?? 0;
          newProductQuantityMap[productName] =
              existingProductQuantity + productQuantity;
        });
        newBranchProductQuantityMap[branch] = newProductQuantityMap;
      });

      return newBranchProductQuantityMap;
    });
  }
}

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
