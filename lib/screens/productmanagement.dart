import 'package:firebase_login_auth/todo/addproduct.dart';
import 'package:firebase_login_auth/todo/productlist.dart';
import 'package:flutter/material.dart';

class ProductManagementScreen extends StatelessWidget {
  const ProductManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        builder: (context) => AddProduct(),
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
