import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shoes_inventory_ms/model/usermodel.dart';
import 'package:shoes_inventory_ms/model/userprovider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DB {
  // ignore: deprecated_member_use
  final DatabaseReference _userRef = FirebaseDatabase.instance.reference()
      .child('users');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Database> initDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, "AniDB.db"),
      onCreate: (database, version) async {
        await database.execute("""
        CREATE TABLE userTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstname TEXT NOT NULL,
        lastname TEXT NOT NULL,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        email TEXT NOT NULL
        )
        """);

        await database.execute("""
        CREATE TABLE adminTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstname TEXT NOT NULL,
        lastname TEXT NOT NULL,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        email TEXT NOT NULL
        )
        """);
      },
      version: 1,
    );
  }
  Future<bool> insertUserData(UserModel userModel) async {
    final Database db = await initDB();
    db.insert("userTable", userModel.toMap());
    return true;
  }


  Future<void> updateUser(UserModel userModel, int id) async {
    final Database db = await initDB();
    await db.update("userTable", userModel.toMap(), where: "id=?", whereArgs: [id]);
  }

  Future<void> deleteUser(int id) async {
    final Database db = await initDB();
    await db.delete("userTable", where: "id=?", whereArgs: [id]);
  }

  Future<void> deleteUserData(String uid) async {
    final Database db = await initDB();
    await db.delete("userTable", where: "id=?", whereArgs: [uid]);
  }
  // Future<void> syncUserData(UserModel user) async {
  //
  //   try {
  //     // Get the current user
  //     final user = FirebaseAuth.instance.currentUser;
  //     final userId = user!.uid;
  //
  //     // Get the user data from the user provider
  //     final userModel = UserProvider().getAllBasicUsers(userId);
  //
  //     // Update the user data in the database
  //     final userData = {
  //       'name': user.firstName,
  //       'email': userModel.email,
  //       'last_login': DateTime.now().toUtc(),
  //     };
  //     final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
  //     await userRef.update(userData);
  //
  //     // Log the successful sync
  //     print('User data synced successfully');
  //   } catch (error) {
  //     // Log the error
  //     print('Error syncing user data: $error');
  //   }
  // }

}