import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_login_auth/model/constant.dart';
import 'package:firebase_login_auth/inventory/addproduct.dart';
import 'package:firebase_login_auth/inventory/productlist.dart';
import 'package:firebase_login_auth/model/productprovider.dart';
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
            leading: const Icon(Icons.menu, color: Colors.black,),
            backgroundColor: mainTextColor,
            title: Text('Hello, $userName',
              style: TextStyle(
                  color: secondaryTextColor,
                  fontWeight: FontWeight.bold,
              ),
            ),
            automaticallyImplyLeading: false,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildButton(
                      context,
                      icon: Icons.edit,
                      text: 'Edit Products',
                      color: Colors.orange,
                      onPressed: () {
                        // Navigate to the Edit Products screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProductList(action: 'edit'),
                          ),
                        );
                      },
                    ),
                    _buildButton(
                      context,
                      icon: Icons.delete,
                      text: 'Delete Products',
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
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildButton(
                      context,
                      icon: Icons.inventory,
                      text: 'View Inventory',
                      color: Colors.green,
                      onPressed: () {
                        // Navigate to the View Inventory screen

                        // Navigator.pushNamed(context, '/inventory');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddProduct(),
                          ),
                        );
                      },
                    ),
                    _buildButton(
                      context,
                      icon: Icons.visibility,
                      text: 'View Products',
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
                    ),
                  ],
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
}
