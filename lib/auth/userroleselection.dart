import 'package:shoes_inventory_ms/model/constant.dart';
import 'package:flutter/material.dart';
import 'package:themed/themed.dart';

class UserRoleSelectionPage extends StatelessWidget {
  const UserRoleSelectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: gradientEndColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChangeColors(
                  hue: 0.55,
                  brightness: 0.2,
                  saturation: 0.1,
                  child: Image.asset("assets/logo.png",
                      width: 300,
                      height: 300)
              ),
              const Text("Please choose your role",
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center
              ),
              const SizedBox(height: 16.0),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/basicUserLoginPage');
                },
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: primaryBtnColor,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Text('User Portal',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17
                      ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/adminLoginPage');
                },
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: primaryBtnColor,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Text('Admin Portal',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17
                      )
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
