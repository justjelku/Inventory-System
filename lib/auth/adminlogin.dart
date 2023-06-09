import 'package:flutter/material.dart';
import 'package:shoes_inventory_ms/model/constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:themed/themed.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

class AdminLogin extends StatefulWidget {
  // final VoidCallback showUserLoginPage;
  const AdminLogin({
    // required this.showUserLoginPage,
    Key? key}) : super(key: key);

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

  var formKey = GlobalKey<FormState>();

  Future<void> signIn() async {
    try {
      final userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc('qIglLalZbFgIOnO0r3Zu')
          // .collection('admin_users')
          // .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists && userDoc.get('enabled') == true) {
        _showMsg('Logged In Successful!', true);
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, '/admin');
      } else {
        _showMsg('User account is disabled.', false);
        await FirebaseAuth.instance.signOut();
      }

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showMsg('No user found for that email.', false);
      } else if (e.code == 'wrong-password') {
        _showMsg('Wrong password provided for that user.', false);
      } else {
        _showMsg('Error: ${e.message}', false);
      }
    }
  }

  Future<void> signUp() async {
    try {
      showDialog(
        context: context,
        builder: (context){
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      if (passwordConfirmed()) {
        // Create user in Firebase Auth
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        //add user details
        addUserDetails(
          _firstNameController.text.trim(),
          _lastNameController.text.trim(),
          _userNameController.text.trim(),
          _emailController.text.trim(),
          true,
          'superAdmin',
        );
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
        _showMsg('Account created!', true);
      } else {
        _showMsg('The password confirmation does not match.', false);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _showMsg('The account already exists for that email.', false);
      } else if (e.code == 'invalid-email') {
        _showMsg('The email address is not valid.', false);
      } else if (e.code == 'weak-password') {
        _showMsg('The password is too weak.', false);
      } else {
        _showMsg('Error: ${e.message}', false);
      }
    } catch (e) {
      _showMsg('Error: ${e.toString()}', false);
    }
  }

  // Future addUserDetails(String firstName, String lastName, String userName, String email, bool status, String role) async{
  //   final userRef = FirebaseFirestore.instance.collection('users')
  //       .doc('qIglLalZbFgIOnO0r3Zu');
  //   final userDetailsRef = userRef.collection('admin_users')
  //       .doc(FirebaseAuth.instance.currentUser!.uid);
  //   final userDetails = {
  //     'first name': firstName,
  //     'last name': lastName,
  //     'username': userName,
  //     'email': email,
  //     'enabled': status,
  //     'role': role,
  //   };
  //   await userDetailsRef.set(userDetails);
  // }
  Future<void> addUserDetails(String firstName, String lastName, String userName, String email, bool status, String role) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc('qIglLalZbFgIOnO0r3Zu');
    final userDetails = {
      'first name': firstName,
      'last name': lastName,
      'username': userName,
      'email': email,
      'enabled': status,
      'role': role,
    };
    await userRef.set(userDetails, SetOptions(merge: true));
  }


  bool passwordConfirmed() {
    if(_passwordController.text.trim() == _confirmPasswordController.text.trim()){
      return true;
    } else{
      return false;
    }
  }

  void _showMsg(String message, bool isSuccess) {
    Color color = isSuccess ? Colors.green : Colors.red;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: color,
            width: 2,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _firstNameController.dispose();
    _lastNameController.dispose();
    _userNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: gradientEndColor,
        body: Form(
            key: formKey,
            child: ListView(
                padding: const EdgeInsets.all(30),
                children: [
                  ChangeColors(
                      hue: 0.55,
                      brightness: 0.2,
                      saturation: 0.1,
                      child: Image.asset("assets/logo.png",
                          width: 300,
                          height: 300)
                  ),
                  const Text("Admin Portal",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.center
                  ),
                  const SizedBox(height: 5),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Navigate back to previous screen
                    },
                    child: Center(
                      child: Text("Change Role",
                          style: TextStyle(
                              color: mainTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14
                          )
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  const Text("Control panel login",
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
                    ),
                    validator: (value){
                      return (value == '')? "Email" : null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                      controller: _passwordController,
                      keyboardType: TextInputType.name,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Password',
                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
                      )
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: GestureDetector(
                      onTap: signIn,
                      child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: primaryBtnColor,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Center(
                            child: Text("Sign In",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17
                                )
                            ),
                          )
                      ),
                    ),
                  ),
                  // TextButton(
                  //     onPressed: (){
                  //       showMyDialogue();
                  //     },
                  //     style: ButtonStyle(
                  //       padding: MaterialStateProperty.all<EdgeInsets>(
                  //         const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  //       ),
                  //       shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  //         RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(50),
                  //         ),
                  //       ),
                  //     ),
                  //     child: const Text("Create Account",
                  //       style: TextStyle(
                  //         color: Colors.black,
                  //       ),
                  //     )
                  // )
                ]
            )
        )
    );
  }
  void showMyDialogue() async {

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            backgroundColor: gradientEndColor,
            scrollable: true,
            title: Text('Create Account',
              style: TextStyle(
                color: mainTextColor,
              ),
            ),
            content: Container(
              padding: const EdgeInsets.all(10.0),
              child: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _firstNameController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          labelText: "First Name",
                          labelStyle: TextStyle(color: mainTextColor),
                          hintStyle: TextStyle(color: mainTextColor),
                        ),
                        validator: (value){
                          return (value == '')? "First Name" : null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _lastNameController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          labelText: "Last Name",
                          labelStyle: TextStyle(color: mainTextColor),
                          hintStyle: TextStyle(color: mainTextColor),
                        ),
                        validator: (value){
                          return (value == '')? "Last Name" : null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _userNameController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          labelText: "Username",
                          labelStyle: TextStyle(color: mainTextColor),
                          hintStyle: TextStyle(color: mainTextColor),
                        ),
                        validator: (value){
                          return (value == '')? "Username" : null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "Email Address",
                          labelStyle: TextStyle(color: mainTextColor),
                          hintStyle: TextStyle(color: mainTextColor),
                        ),
                        validator: (value){
                          return (value == '')? "Email Address" : null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _passwordController,
                        keyboardType: TextInputType.name,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: TextStyle(color: mainTextColor),
                          hintStyle: TextStyle(color: mainTextColor),
                        ),
                        validator: (value){
                          return (value == '')? "Password" : null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _confirmPasswordController,
                        keyboardType: TextInputType.name,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Confirm Password",
                          labelStyle: TextStyle(color: mainTextColor),
                          hintStyle: TextStyle(color: mainTextColor),
                        ),
                        validator: (value){
                          return (value == '')? "Confirm Password" : null;
                        },
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  signUp();
                  Navigator.pop(context);
                },
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
                  ),
                  backgroundColor: MaterialStateProperty.all<Color>(primaryBtnColor),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
                child: Center(
                  child: Text("Sign Up",
                    style: TextStyle(
                      color: mainTextColor,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: (){
                  Navigator.pop(context);
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
                child: Center(
                  child: Text("Already have an account",
                    style: TextStyle(
                      color: mainTextColor,
                    ),
                  ),
                ),
              )
            ],
          );
        }
    );
  }
}
