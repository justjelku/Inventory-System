// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:shoes_inventory_ms/model/constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:themed/themed.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


FirebaseFirestore firestore = FirebaseFirestore.instance;

class BasicUserLogin extends StatefulWidget {
  // final VoidCallback showAdminLogin;
  const BasicUserLogin({
    // required this.showAdminLogin,
    Key? key}) : super(key: key);

  @override
  State<BasicUserLogin> createState() => _BasicUserLoginState();
}

class _BasicUserLoginState extends State<BasicUserLogin> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  var formKey = GlobalKey<FormState>();
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount == null) return null;

      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      final userDetails = {
        'first name': userCredential.user!.displayName!.split(' ')[0],
        'last name': userCredential.user!.displayName!.split(' ')[1],
        'username': userCredential.user!.email!.split('@')[0],
        'email': userCredential.user!.email!,
        'role': 'admin',
        'enabled': true,
      };

      final userRef = FirebaseFirestore.instance.collection('users').doc('qIglLalZbFgIOnO0r3Zu');
      await userRef.collection('basic_users').doc(userCredential.user!.uid).set(userDetails);

      return userCredential;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      // Trigger the sign-in flow
      final LoginResult result = await FacebookAuth.instance.login();

      // Check if the user successfully signed in
      if (result.status == LoginStatus.success) {
        // Retrieve the access token
        final AccessToken accessToken = result.accessToken!;

        // Retrieve the user data
        final userData = await FacebookAuth.instance.getUserData(
          fields: "first_name,last_name,email,name",
        );

        // Extract the relevant user data
        final userId = userData['id'];
        final firstName = userData['first_name'];
        final lastName = userData['last_name'];
        final email = userData['email'];
        final userName = userData['name'];

        // Sign in with Firebase using the Facebook access token
        final OAuthCredential credential =
        FacebookAuthProvider.credential(accessToken.token);

        await FirebaseAuth.instance.signInWithCredential(credential);

        // Add user details to the database
        addUserDetails(userId, firstName, lastName, userName, email, 'admin', 'true');

        // Navigate to the home page
        Navigator.pushNamed(context, '/home');
      } else if (result.status == LoginStatus.cancelled) {
        // Handle canceled login
        _showMsg('Login canceled by user.', false);
      } else {
        // Handle the error
        _showMsg(result.message!, false);
      }
    } catch (e) {
      print('Error: $e');
      _showMsg('Error: $e', false);
    }
  }

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
          .collection('basic_users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists && userDoc.get('enabled') == 'true') {
        _showMsg('Logged In Successful!', true);
        Navigator.pushNamed(context, '/user');
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

  Future addUserDetails(String userId, String firstName, String lastName, String userName, String email, String role, String status) async{
    final userRef = FirebaseFirestore.instance.collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu');
    final userDetailsRef = userRef.collection('basic_users')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    final userDetails = {
      'userId' : userId,
      'first name': firstName,
      'last name': lastName,
      'username': userName,
      'email': email,
      'role': role,
      'enabled': status,
    };
    await userDetailsRef.set(userDetails);
  }

  bool passwordConfirmed() {
    if(_passwordController.text.trim() == _confirmPasswordController.text.trim()){
      return true;
    } else{
      return false;
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
        //create user
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        //add user details
        addUserDetails(
            FirebaseAuth.instance.currentUser!.uid,
          _firstNameController.text.trim(),
          _lastNameController.text.trim(),
          _userNameController.text.trim(),
          _emailController.text.trim(),
          'admin',
          'true'
        );
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
                  const Text("User Portal",
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
                  const Text("Welcome back, you've been missed!",
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
                  TextButton(
                      onPressed: (){
                        showMyDialogue();
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
                      child: const Text("Create Account",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      )
                  ),
                  const Text("or",
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () async {
                            final userCredential = await signInWithGoogle();
                            if (userCredential != null) {
                              _showMsg('Logged In Successful!', true);
                              Navigator.pushNamed(context, '/user');
                            } else {
                              _showMsg('Error: Unable to sign in with Google.', false);
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/icons8-google-48.png', // Replace with your Google icon asset
                                height: 45,
                              ),
                              const SizedBox(width: 10),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: signInWithFacebook,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/icons8-facebook-48.png', // Replace with your Facebook icon asset
                                height: 50,
                              ),
                              const SizedBox(width: 10),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
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
                onPressed: () async {
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
