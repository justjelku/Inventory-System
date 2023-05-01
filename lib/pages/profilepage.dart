import 'package:firebase_login_auth/model/constant.dart';
import 'package:firebase_login_auth/model/usermodel.dart';
import 'package:firebase_login_auth/model/userprovider.dart';
import 'package:firebase_login_auth/pages/editprofile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late String _initialUserName = "";
  late String _initialFirstName = "";
  late String _initialLastName = "";
  late String _initialPassword = "";
  late String _initialEmail = "";

  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final bool _isEditing = false;

  @override
  initState() {
    super.initState();
    _getUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _getUserData() async {
    // final user = FirebaseAuth.instance.currentUser!;
    final userRef = FirebaseFirestore.instance.collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    final userData = await userRef.get();

    final data = userData.data() as Map<String, dynamic>;
    setState(() {
      _initialUserName = data['username'];
      _initialFirstName = data['first name'];
      _initialLastName = data['last name'];
      _initialEmail = data['email'];
      _initialPassword = data['password'];
    });
  }

  @override
  Widget build(BuildContext context) {
    _userNameController.text = _initialUserName;
    _firstNameController.text = _initialFirstName;
    _lastNameController.text = _initialLastName;
    _emailController.text = _initialEmail;
    _passwordController.text = _initialPassword;

    // final user = FirebaseAuth.instance.currentUser!;
    Stream<DocumentSnapshot> userDataStream = FirebaseFirestore.instance.collection('users')
        .doc('qIglLalZbFgIOnO0r3Zu')
        .collection('basic_users')
        .doc(FirebaseAuth.instance.currentUser!.uid).snapshots();

    return StreamBuilder<DocumentSnapshot>(
      stream: userDataStream,
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
        _firstNameController.text = data['first name'] as String? ?? '';
        _lastNameController.text = data['last name'] as String? ?? '';
        _userNameController.text = data['username'] as String? ?? '';
        _emailController.text = data['email'] as String? ?? '';
        _passwordController.text = data['password'] as String? ?? '';
        return Scaffold(
          appBar: MyAppBar(
            // dropdownItems: ['Option 1', 'Option 2', 'Option 3'],
            title: '${data['username']}',
            // onItemSelected: (selectedItem) {
            //   // do something when a dropdown item is selected
            // },
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 43,
                        backgroundImage: const AssetImage('assets/logo.png'),
                        backgroundColor: Colors.grey,
                        child: ClipOval(
                          child: FutureBuilder<String?>(
                            future: Provider.of<UserProvider>(context).getProfilePicture(FirebaseAuth.instance.currentUser!.uid),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return const Center(child: Text('Error retrieving profile picture'));
                              }
                              if (snapshot.data == null) {
                                return const Center(child: Text(''));
                              }
                              return Center(
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundImage: NetworkImage(snapshot.data!),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${data['first name'] ?? 'Error:'} ${data['last name'] ?? 'Null'}',
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Status: ${data['enabled'] ? 'Enabled' : 'Disabled'}',
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _firstNameController,
                          enabled: _isEditing,
                          // initialValue: _initialFirstName,
                          decoration: const InputDecoration(
                            labelText: 'First Name',
                            hintText: 'Enter your first name',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _lastNameController,
                          enabled: _isEditing,
                          // initialValue: _initialLastName,
                          decoration: const InputDecoration(
                            labelText: 'Last Name',
                            hintText: 'Enter your last name',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _userNameController,
                          enabled: _isEditing,
                          // initialValue: _initialUserName,
                          decoration: const InputDecoration(
                            labelText: 'UserName',
                            hintText: 'Enter your username',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _emailController,
                          enabled: _isEditing,
                          // initialValue: _initialEmail,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter your email',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _passwordController,
                          enabled: _isEditing,
                          // initialValue: _initialPassword,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter your password',
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ) // Other widgets in your app
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
                  onPressed: () async {
                    final userData = UserModel(
                        uid: FirebaseAuth.instance.currentUser!.uid,
                        firstName: _firstNameController.text,
                        lastName: _lastNameController.text,
                        username: _userNameController.text,
                        email: _emailController.text,
                        role: 'basic',
                        status: true,
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfile(userData: userData),
                      ),
                    );
                  },
                  backgroundColor: gradientEndColor,
                  child: const Icon(Icons.edit),
          ),
        );
      },
    );
  }
}
class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  // final List<String> dropdownItems;
  final String title;
  // final Function(String) onItemSelected;

  const MyAppBar({super.key,
    // required this.dropdownItems,
    required this.title,
    // required this.onItemSelected,
  });

  void handleDropdownItemSelected(String? newValue) {
    // Your code here
  }


  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Text(title),
          const SizedBox(width: 8),
          GestureDetector(
            child: const Icon(Icons.arrow_drop_down, size: 30,),
            onTap: (){
              _showBottomSheet(context);
            },
          )
        ],
      ),
    );
  }
}
void _showBottomSheet(BuildContext context) {
  Stream<DocumentSnapshot> userDataStream = FirebaseFirestore.instance.collection('users')
      .doc('qIglLalZbFgIOnO0r3Zu')
      .collection('basic_users')
      .doc(FirebaseAuth.instance.currentUser!.uid).snapshots();

  showModalBottomSheet(
    context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
      // ignore: no_leading_underscores_for_local_identifiers
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

      return StreamBuilder<DocumentSnapshot>(
        stream: userDataStream,
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
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 50,
                    alignment: Alignment.center,
                    child: const Icon(Icons.arrow_drop_down),
                  ),
                ),
                ListTile(
                  leading: CircleAvatar(
                    radius: 43,
                    backgroundImage: const AssetImage('assets/logo.png'),
                    backgroundColor: Colors.grey,
                    child: ClipOval(
                      child: FutureBuilder<String?>(
                        future: Provider.of<UserProvider>(context)
                            .getProfilePicture(
                            FirebaseAuth.instance.currentUser!.uid),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState
                              .waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return const Center(
                                child: Text('Error retrieving profile picture'));
                          }
                          if (snapshot.data == null) {
                            return const Center(child: Text(''));
                          }
                          return Center(
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: NetworkImage(snapshot.data!),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  title: Text('${data['username']}'),
                  trailing: MaterialButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                      _showMsg('Signed out successfully.', true);
                    },
                    child: const Icon(Icons.logout),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  );
}

